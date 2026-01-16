#!/bin/bash
# =============================================================================
# Rmotly VPS Setup Script
# =============================================================================
# This script prepares a fresh VPS for Rmotly deployment.
# Tested on: Ubuntu 22.04 LTS, Ubuntu 24.04 LTS, Debian 12
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/USER/rmotly/main/rmotly_server/deploy/vps/setup-vps.sh | bash
#   OR
#   chmod +x setup-vps.sh && ./setup-vps.sh
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# -----------------------------------------------------------------------------
# Check if running as root
# -----------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
fi

log_info "Starting Rmotly VPS setup..."

# -----------------------------------------------------------------------------
# Update system
# -----------------------------------------------------------------------------
log_info "Updating system packages..."
apt-get update && apt-get upgrade -y

# -----------------------------------------------------------------------------
# Install dependencies
# -----------------------------------------------------------------------------
log_info "Installing dependencies..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    htop \
    vim \
    ufw \
    fail2ban \
    unattended-upgrades

# -----------------------------------------------------------------------------
# Install Docker
# -----------------------------------------------------------------------------
log_info "Installing Docker..."

# Remove old versions
apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker

log_success "Docker installed successfully"

# -----------------------------------------------------------------------------
# Create deployment user
# -----------------------------------------------------------------------------
log_info "Creating deployment user..."

if ! id "deploy" &>/dev/null; then
    useradd -m -s /bin/bash -G docker deploy
    log_success "User 'deploy' created"
else
    usermod -aG docker deploy
    log_info "User 'deploy' already exists, added to docker group"
fi

# -----------------------------------------------------------------------------
# Setup SSH key for deploy user
# -----------------------------------------------------------------------------
log_info "Setting up SSH for deploy user..."

mkdir -p /home/deploy/.ssh
chmod 700 /home/deploy/.ssh

if [[ ! -f /home/deploy/.ssh/authorized_keys ]]; then
    touch /home/deploy/.ssh/authorized_keys
fi
chmod 600 /home/deploy/.ssh/authorized_keys
chown -R deploy:deploy /home/deploy/.ssh

log_warn "Remember to add your SSH public key to /home/deploy/.ssh/authorized_keys"

# -----------------------------------------------------------------------------
# Create application directory
# -----------------------------------------------------------------------------
log_info "Creating application directory..."

mkdir -p /opt/rmotly
mkdir -p /opt/rmotly/backups/postgres
chown -R deploy:deploy /opt/rmotly

log_success "Application directory created at /opt/rmotly"

# -----------------------------------------------------------------------------
# Configure firewall
# -----------------------------------------------------------------------------
log_info "Configuring firewall..."

ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https

# Enable without prompt
echo "y" | ufw enable

log_success "Firewall configured (SSH, HTTP, HTTPS allowed)"

# -----------------------------------------------------------------------------
# Configure fail2ban
# -----------------------------------------------------------------------------
log_info "Configuring fail2ban..."

cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 24h
EOF

systemctl restart fail2ban
systemctl enable fail2ban

log_success "fail2ban configured"

# -----------------------------------------------------------------------------
# Configure automatic security updates
# -----------------------------------------------------------------------------
log_info "Configuring automatic security updates..."

cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

log_success "Automatic security updates enabled"

# -----------------------------------------------------------------------------
# Create Docker network
# -----------------------------------------------------------------------------
log_info "Creating Docker network..."

docker network create rmotly-network 2>/dev/null || log_info "Network already exists"

# -----------------------------------------------------------------------------
# Set system limits for production
# -----------------------------------------------------------------------------
log_info "Configuring system limits..."

cat >> /etc/sysctl.conf << 'EOF'

# Rmotly production settings
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
vm.overcommit_memory = 1
EOF

sysctl -p

# -----------------------------------------------------------------------------
# Create helper scripts
# -----------------------------------------------------------------------------
log_info "Creating helper scripts..."

# Deployment helper
cat > /opt/rmotly/deploy.sh << 'EOF'
#!/bin/bash
set -e
cd /opt/rmotly
docker compose -f docker-compose.production.yaml pull
docker compose -f docker-compose.production.yaml up -d --remove-orphans
docker image prune -af --filter "until=24h"
echo "Deployment complete!"
EOF
chmod +x /opt/rmotly/deploy.sh

# Logs helper
cat > /opt/rmotly/logs.sh << 'EOF'
#!/bin/bash
docker compose -f /opt/rmotly/docker-compose.production.yaml logs -f "${1:-serverpod}"
EOF
chmod +x /opt/rmotly/logs.sh

# Backup helper
cat > /opt/rmotly/backup.sh << 'EOF'
#!/bin/bash
set -e
BACKUP_DIR="/opt/rmotly/backups"
DATE=$(date +%Y%m%d_%H%M%S)
docker exec rmotly-postgres pg_dump -U postgres rmotly > "$BACKUP_DIR/postgres/rmotly_$DATE.sql"
gzip "$BACKUP_DIR/postgres/rmotly_$DATE.sql"
find "$BACKUP_DIR/postgres" -name "*.gz" -mtime +7 -delete
echo "Backup complete: rmotly_$DATE.sql.gz"
EOF
chmod +x /opt/rmotly/backup.sh

chown -R deploy:deploy /opt/rmotly

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "============================================================================="
log_success "Rmotly VPS setup complete!"
echo "============================================================================="
echo ""
echo "Next steps:"
echo ""
echo "1. Add your SSH public key:"
echo "   echo 'your-public-key' >> /home/deploy/.ssh/authorized_keys"
echo ""
echo "2. Copy docker-compose files to /opt/rmotly/"
echo "   scp docker-compose.production.yaml deploy@YOUR_VPS:/opt/rmotly/"
echo ""
echo "3. Create .env file:"
echo "   cp .env.example /opt/rmotly/.env"
echo "   vim /opt/rmotly/.env  # Edit with your values"
echo ""
echo "4. Configure DNS records:"
echo "   A    api.yourdomain.com      -> YOUR_VPS_IP"
echo "   A    insights.yourdomain.com -> YOUR_VPS_IP"
echo "   A    ntfy.yourdomain.com     -> YOUR_VPS_IP"
echo "   A    web.yourdomain.com      -> YOUR_VPS_IP"
echo ""
echo "5. Add GitHub Secrets:"
echo "   VPS_HOST_PRODUCTION  = YOUR_VPS_IP"
echo "   VPS_HOST_STAGING     = YOUR_STAGING_VPS_IP (if separate)"
echo "   VPS_USER             = deploy"
echo "   VPS_SSH_KEY          = (your private SSH key)"
echo "   SERVERPOD_PASSWORDS  = (contents of passwords.yaml)"
echo ""
echo "6. Deploy:"
echo "   Push to 'deployment-vps-production' branch"
echo "   OR trigger workflow manually"
echo ""
echo "Helper commands:"
echo "   /opt/rmotly/deploy.sh  - Manual deployment"
echo "   /opt/rmotly/logs.sh    - View logs"
echo "   /opt/rmotly/backup.sh  - Manual backup"
echo ""
echo "============================================================================="
