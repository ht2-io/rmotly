# VPS Deployment Guide

Deploy Rmotly to any VPS provider (Hetzner, Contabo, DigitalOcean, etc.) using Docker and Traefik.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                            VPS Server                               │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                     Traefik (Reverse Proxy)                   │ │
│  │              SSL/TLS Termination via Let's Encrypt            │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                    │              │              │                  │
│         ┌─────────┴──────┐ ┌────┴────┐ ┌──────┴──────┐            │
│         │   Serverpod    │ │  ntfy   │ │  Insights   │            │
│         │   (API:8080)   │ │ (Push)  │ │   (:8081)   │            │
│         └───────┬────────┘ └─────────┘ └─────────────┘            │
│                 │                                                   │
│     ┌───────────┴───────────┐                                      │
│     │                       │                                      │
│  ┌──┴───────┐    ┌─────────┴──┐                                   │
│  │PostgreSQL│    │   Redis    │                                   │
│  │   :5432  │    │   :6379    │                                   │
│  └──────────┘    └────────────┘                                   │
└─────────────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Provision VPS

**Recommended specs:** 4 vCPU, 8GB RAM, 80GB SSD

| Provider | Plan | Monthly Cost |
|----------|------|--------------|
| [Hetzner](https://hetzner.com/cloud) | CX32 | €7.50 |
| [Contabo](https://contabo.com) | VPS S | €5.99 |
| [DigitalOcean](https://digitalocean.com) | Basic 4GB | $24 |

### 2. Run Setup Script

SSH into your VPS and run:

```bash
curl -fsSL https://raw.githubusercontent.com/USER/rmotly/main/rmotly_server/deploy/vps/setup-vps.sh | sudo bash
```

Or manually:

```bash
git clone https://github.com/USER/rmotly.git
cd rmotly/rmotly_server/deploy/vps
chmod +x setup-vps.sh
sudo ./setup-vps.sh
```

### 3. Configure Environment

```bash
# Copy example env
cp .env.example /opt/rmotly/.env

# Edit with your values
vim /opt/rmotly/.env
```

Required variables:
- `DOMAIN` - Your root domain (e.g., `rmotly.com`)
- `ACME_EMAIL` - Email for Let's Encrypt
- `POSTGRES_PASSWORD` - Strong database password
- `REDIS_PASSWORD` - Strong Redis password
- `GITHUB_REPOSITORY` - Your GitHub repo (e.g., `user/rmotly`)

### 4. Configure DNS

Point these subdomains to your VPS IP:

| Record | Subdomain | Value |
|--------|-----------|-------|
| A | `api.yourdomain.com` | VPS IP |
| A | `insights.yourdomain.com` | VPS IP |
| A | `ntfy.yourdomain.com` | VPS IP |
| A | `web.yourdomain.com` | VPS IP |
| A | `traefik.yourdomain.com` | VPS IP (optional) |

### 5. Add GitHub Secrets

In your GitHub repository, add these secrets:

| Secret | Description |
|--------|-------------|
| `VPS_HOST_PRODUCTION` | Production VPS IP address |
| `VPS_HOST_STAGING` | Staging VPS IP (can be same as production) |
| `VPS_USER` | `deploy` |
| `VPS_SSH_KEY` | Private SSH key for deploy user |
| `SERVERPOD_PASSWORDS` | Contents of `config/passwords.yaml` |

### 6. Generate SSH Key

```bash
# On your local machine
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/rmotly_deploy

# Add public key to VPS
ssh root@YOUR_VPS "echo '$(cat ~/.ssh/rmotly_deploy.pub)' >> /home/deploy/.ssh/authorized_keys"

# Copy private key to GitHub Secrets (VPS_SSH_KEY)
cat ~/.ssh/rmotly_deploy
```

### 7. Deploy

**Option A: Push to deployment branch**
```bash
git checkout -b deployment-vps-production
git push origin deployment-vps-production
```

**Option B: Manual trigger**
- Go to Actions → Deploy to VPS → Run workflow

## Files

```
deploy/vps/
├── docker-compose.production.yaml  # Production stack
├── docker-compose.staging.yaml     # Staging stack
├── .env.example                    # Environment template
├── setup-vps.sh                    # VPS initialization script
└── README.md                       # This file
```

## Services

| Service | Internal Port | External URL |
|---------|--------------|--------------|
| Serverpod API | 8080 | `https://api.yourdomain.com` |
| Serverpod Insights | 8081 | `https://insights.yourdomain.com` |
| Serverpod Web | 8082 | `https://web.yourdomain.com` |
| ntfy Push | 80 | `https://ntfy.yourdomain.com` |
| Traefik Dashboard | 8080 | `https://traefik.yourdomain.com` |
| PostgreSQL | 5432 | Internal only |
| Redis | 6379 | Internal only |

## Commands

### On VPS

```bash
# View logs
/opt/rmotly/logs.sh              # All services
/opt/rmotly/logs.sh serverpod    # Specific service

# Manual deployment
/opt/rmotly/deploy.sh

# Manual backup
/opt/rmotly/backup.sh

# Restart services
cd /opt/rmotly
docker compose -f docker-compose.production.yaml restart

# View running containers
docker ps

# Check disk usage
docker system df
```

### From Local Machine

```bash
# SSH into VPS
ssh deploy@YOUR_VPS_IP

# Copy file to VPS
scp file.txt deploy@YOUR_VPS_IP:/opt/rmotly/

# Stream logs remotely
ssh deploy@YOUR_VPS_IP "docker logs -f rmotly-serverpod"
```

## Backups

Automated PostgreSQL backups run daily and are stored in `/opt/rmotly/backups/postgres/`.

Retention policy:
- Daily backups: 7 days
- Weekly backups: 4 weeks
- Monthly backups: 6 months

### Manual Backup

```bash
/opt/rmotly/backup.sh
```

### Restore from Backup

```bash
# Stop services
docker compose -f docker-compose.production.yaml stop serverpod

# Restore database
gunzip -c /opt/rmotly/backups/postgres/rmotly_YYYYMMDD_HHMMSS.sql.gz | \
  docker exec -i rmotly-postgres psql -U postgres rmotly

# Start services
docker compose -f docker-compose.production.yaml start serverpod
```

## SSL Certificates

Traefik automatically provisions SSL certificates via Let's Encrypt. Certificates are:
- Stored in `/opt/rmotly/letsencrypt/` (Docker volume)
- Auto-renewed before expiration
- Issued on first request to each domain

### Troubleshooting SSL

```bash
# Check Traefik logs
docker logs rmotly-traefik

# Force certificate renewal (rarely needed)
docker exec rmotly-traefik rm /letsencrypt/acme.json
docker restart rmotly-traefik
```

## Monitoring

### Health Checks

All services include health checks. View status:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### Traefik Dashboard

Access at `https://traefik.yourdomain.com` (requires basic auth configured in `.env`).

Generate password hash:

```bash
# Install htpasswd
apt-get install apache2-utils

# Generate hash (escape $ with $$)
htpasswd -nB admin
# Output: admin:$2y$05$...
# In .env use: admin:$$2y$$05$$...
```

## Security

The setup script configures:
- **UFW Firewall**: Only SSH, HTTP, HTTPS allowed
- **fail2ban**: Blocks IPs after 3 failed SSH attempts (24h ban)
- **Automatic updates**: Security patches applied automatically
- **Non-root deployment**: Uses `deploy` user with limited permissions

### Additional Hardening

```bash
# Change SSH port (optional)
vim /etc/ssh/sshd_config
# Change: Port 22 → Port 2222
systemctl restart sshd
ufw allow 2222/tcp
ufw delete allow ssh

# Disable root login
vim /etc/ssh/sshd_config
# Set: PermitRootLogin no
```

## Troubleshooting

### Service won't start

```bash
# Check logs
docker logs rmotly-serverpod

# Check if ports are in use
netstat -tlnp | grep -E '80|443'

# Restart everything
cd /opt/rmotly
docker compose -f docker-compose.production.yaml down
docker compose -f docker-compose.production.yaml up -d
```

### Database connection failed

```bash
# Check PostgreSQL is running
docker logs rmotly-postgres

# Test connection
docker exec -it rmotly-postgres psql -U postgres -d rmotly -c "SELECT 1"
```

### SSL certificate issues

```bash
# Check Traefik can reach Let's Encrypt
docker exec rmotly-traefik wget -q -O- https://acme-v02.api.letsencrypt.org/directory

# Verify DNS is pointing to VPS
dig api.yourdomain.com +short
```

### Out of disk space

```bash
# Check usage
df -h
docker system df

# Clean up
docker system prune -af
docker volume prune -f
```

## Cost Comparison

| Item | AWS/GCP | VPS (Hetzner) |
|------|---------|---------------|
| Compute | $50-100/mo | €7.50/mo |
| Database (RDS) | $25-50/mo | Included |
| Redis (ElastiCache) | $15-30/mo | Included |
| Load Balancer | $20/mo | Included (Traefik) |
| SSL Certificates | Free (ACM) | Free (Let's Encrypt) |
| **Total** | **$110-200/mo** | **€7.50/mo** |

*Savings: ~95% reduction in hosting costs*
