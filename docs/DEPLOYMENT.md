# Rmotly Deployment Guide

This guide covers deploying the Rmotly backend API server to various environments. The Flutter mobile app is distributed through app stores and connects to your deployed API server.

## Table of Contents

- [Quick Start](#quick-start)
- [Environment Variables](#environment-variables)
- [Self-Hosting with Docker Compose](#self-hosting-with-docker-compose)
- [VPS Deployment](#vps-deployment)
- [Cloud Deployment](#cloud-deployment)
  - [AWS Deployment](#aws-deployment)
  - [Google Cloud Deployment](#google-cloud-deployment)
- [Production Checklist](#production-checklist)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

**One-Command Local Deployment:**

```bash
cd rmotly_server
docker compose up --build --detach
dart bin/main.dart
```

This starts:
- PostgreSQL on port 8090
- Redis on port 8091
- ntfy push server on port 8093
- Serverpod API on ports 8080-8082

Your API is now running at `http://localhost:8080`.

---

## Environment Variables

### Core Configuration

Rmotly uses YAML configuration files instead of environment variables. Configuration files are located in `rmotly_server/config/`:

| File | Purpose |
|------|---------|
| `development.yaml` | Local development settings |
| `staging.yaml` | Staging environment settings |
| `test.yaml` | Test environment settings |
| `passwords.yaml` | Database passwords (git-ignored) |

### Development Configuration (`config/development.yaml`)

```yaml
# API Server
apiServer:
  port: 8080
  publicHost: localhost
  publicPort: 8080
  publicScheme: http

# Database
database:
  host: localhost
  port: 5432
  name: rmotly
  user: rmotly_user

# Redis
redis:
  enabled: true
  host: localhost
  port: 6379

# Push Notifications (Web Push VAPID)
vapid:
  subject: 'mailto:admin@example.com'
  publicKey: 'YOUR_VAPID_PUBLIC_KEY'
  privateKey: 'YOUR_VAPID_PRIVATE_KEY'

# ntfy Push Server
ntfy:
  baseUrl: 'http://localhost:8093'
  defaultTopic: 'rmotly'
```

### Production Configuration (`config/production.yaml`)

For production, create `config/production.yaml` based on `staging.yaml`:

```yaml
# API Server
apiServer:
  port: 8080
  publicHost: api.yourdomain.com
  publicPort: 443
  publicScheme: https

# Database (managed or self-hosted)
database:
  host: your-postgres-host.com
  port: 5432
  name: rmotly
  user: rmotly_user
  requireSsl: true

# Redis (managed or self-hosted)
redis:
  enabled: true
  host: your-redis-host.com
  port: 6379
  requireSsl: true

# Push Notifications
vapid:
  subject: 'mailto:admin@yourdomain.com'
  publicKey: 'YOUR_PRODUCTION_VAPID_PUBLIC_KEY'
  privateKey: 'YOUR_PRODUCTION_VAPID_PRIVATE_KEY'

# ntfy Push Server
ntfy:
  baseUrl: 'https://ntfy.yourdomain.com'
  defaultTopic: 'rmotly'
```

### Passwords File (`config/passwords.yaml`)

**⚠️ Never commit this file to version control!**

```yaml
# Database password
database: 'your-secure-database-password'

# Redis password (if required)
redis: 'your-secure-redis-password'
```

### Generating VAPID Keys

For Web Push notifications:

```bash
cd rmotly_server
dart run bin/generate_vapid_keys.dart
```

This generates a new VAPID key pair. Update `vapid.publicKey` and `vapid.privateKey` in your config file.

### Docker Environment Variables

When using Docker, you can override config with environment variables:

```bash
docker run \
  -e runmode=production \
  -e serverid=api-1 \
  -e logging=normal \
  -e role=monolith \
  -p 8080:8080 \
  rmotly-server
```

---

## Self-Hosting with Docker Compose

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- 2GB+ RAM
- 10GB+ disk space

### Step 1: Clone Repository

```bash
git clone https://github.com/ht2-io/rmotly.git
cd rmotly/rmotly_server
```

### Step 2: Configure Environment

1. **Create passwords file:**

```bash
cat > config/passwords.yaml << EOF
database: $(openssl rand -base64 32)
redis: $(openssl rand -base64 32)
EOF
```

2. **Generate VAPID keys:**

```bash
dart run bin/generate_vapid_keys.dart
```

Copy the output keys to your `config/production.yaml`.

3. **Update configuration:**

Edit `config/production.yaml` with your domain and settings.

### Step 3: Update Docker Compose

Create `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  postgres:
    image: pgvector/pgvector:pg17
    container_name: rmotly-postgres
    environment:
      POSTGRES_USER: rmotly_user
      POSTGRES_DB: rmotly
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U rmotly_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:8-alpine
    container_name: rmotly-redis
    command: redis-server --requirepass-file /run/secrets/redis_password
    secrets:
      - redis_password
    volumes:
      - redis_data:/data
    restart: always
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  ntfy:
    image: binwiederhier/ntfy
    container_name: rmotly-ntfy
    command: serve
    environment:
      - TZ=UTC
      - NTFY_BASE_URL=https://ntfy.yourdomain.com
      - NTFY_CACHE_FILE=/var/cache/ntfy/cache.db
      - NTFY_CACHE_DURATION=24h
    volumes:
      - ntfy_cache:/var/cache/ntfy
      - ntfy_etc:/etc/ntfy
    restart: always
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:80/v1/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: rmotly-api
    environment:
      - runmode=production
      - serverid=api-1
      - logging=normal
      - role=monolith
    ports:
      - "8080:8080"
      - "8081:8081"
      - "8082:8082"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: always
    healthcheck:
      test: ["CMD", "wget", "-q", "--spider", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Traefik reverse proxy for HTTPS
  traefik:
    image: traefik:v3.0
    container_name: rmotly-traefik
    command:
      - "--api.dashboard=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.letsencrypt.acme.email=admin@yourdomain.com"
      - "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
      - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - traefik_letsencrypt:/letsencrypt
    restart: always

secrets:
  db_password:
    file: ./secrets/db_password.txt
  redis_password:
    file: ./secrets/redis_password.txt

volumes:
  postgres_data:
  redis_data:
  ntfy_cache:
  ntfy_etc:
  traefik_letsencrypt:
```

### Step 4: Create Secrets

```bash
mkdir -p secrets
echo "your-secure-db-password" > secrets/db_password.txt
echo "your-secure-redis-password" > secrets/redis_password.txt
chmod 600 secrets/*
```

### Step 5: Deploy

```bash
docker compose -f docker-compose.prod.yml up -d
```

### Step 6: Apply Migrations

```bash
# Run migrations in API container
docker exec -it rmotly-api ./server --apply-migrations
```

### Step 7: Verify Deployment

```bash
# Check all services are running
docker compose ps

# Check API health
curl http://localhost:8080/health

# View logs
docker compose logs -f api
```

---

## VPS Deployment

Deploy Rmotly on a VPS (DigitalOcean, Linode, Vultr, etc.).

### Prerequisites

- Ubuntu 22.04+ or Debian 11+ VPS
- 2 CPU cores, 4GB RAM minimum
- 20GB disk space
- Domain name pointing to VPS IP
- SSH access

### Step 1: Initial Server Setup

```bash
# SSH into your VPS
ssh root@your-server-ip

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose-plugin -y

# Create deployment user
adduser rmotly
usermod -aG docker rmotly
```

### Step 2: Configure Firewall

```bash
# Install UFW
apt install ufw -y

# Allow SSH, HTTP, HTTPS
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Enable firewall
ufw enable
```

### Step 3: Deploy Application

```bash
# Switch to deployment user
su - rmotly

# Clone repository
git clone https://github.com/ht2-io/rmotly.git
cd rmotly/rmotly_server

# Create config files
cp config/staging.yaml config/production.yaml

# Edit production config
nano config/production.yaml
# Update: publicHost, database host, redis host, vapid keys

# Create secrets
mkdir -p secrets
echo "$(openssl rand -base64 32)" > secrets/db_password.txt
echo "$(openssl rand -base64 32)" > secrets/redis_password.txt
chmod 600 secrets/*

# Create passwords.yaml
cat > config/passwords.yaml << EOF
database: $(cat secrets/db_password.txt)
redis: $(cat secrets/redis_password.txt)
EOF
chmod 600 config/passwords.yaml

# Deploy
docker compose -f docker-compose.prod.yml up -d

# Apply migrations
docker exec rmotly-api ./server --apply-migrations
```

### Step 4: Configure DNS

Point your domain to the VPS IP:

```
A     api.yourdomain.com     → your-vps-ip
A     ntfy.yourdomain.com    → your-vps-ip
CNAME insights.yourdomain.com → api.yourdomain.com
CNAME app.yourdomain.com      → api.yourdomain.com
```

### Step 5: Setup SSL with Let's Encrypt

SSL is automatically configured by Traefik. Update `docker-compose.prod.yml`:

```yaml
# In traefik service, add labels to api service:
api:
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.api.rule=Host(`api.yourdomain.com`)"
    - "traefik.http.routers.api.entrypoints=websecure"
    - "traefik.http.routers.api.tls.certresolver=letsencrypt"
    - "traefik.http.services.api.loadbalancer.server.port=8080"
```

Restart services:

```bash
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d
```

### Step 6: Setup Monitoring (Optional)

```bash
# View logs
docker compose logs -f

# Monitor resource usage
docker stats

# Setup log rotation
cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

systemctl restart docker
```

### Step 7: Configure Backups

```bash
# Create backup script
cat > ~/backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/rmotly/backups"
mkdir -p $BACKUP_DIR

# Backup PostgreSQL
docker exec rmotly-postgres pg_dump -U rmotly_user rmotly | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Backup Redis
docker exec rmotly-redis redis-cli --rdb /data/dump.rdb
docker cp rmotly-redis:/data/dump.rdb $BACKUP_DIR/redis_$DATE.rdb

# Backup config
tar -czf $BACKUP_DIR/config_$DATE.tar.gz -C ~/rmotly/rmotly_server config/

# Keep only last 7 days
find $BACKUP_DIR -mtime +7 -delete

echo "Backup completed: $DATE"
EOF

chmod +x ~/backup.sh

# Add to crontab (daily at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /home/rmotly/backup.sh >> /home/rmotly/backup.log 2>&1") | crontab -
```

---

## Cloud Deployment

### AWS Deployment

Rmotly includes Terraform configurations and GitHub Actions workflows for AWS deployment.

#### Prerequisites

- AWS account
- AWS CLI configured
- Terraform 1.0+
- GitHub repository secrets configured

#### Architecture

- **Compute**: EC2 instances with Auto Scaling
- **Database**: RDS PostgreSQL
- **Cache**: ElastiCache Redis
- **Load Balancer**: Application Load Balancer
- **Deployment**: AWS CodeDeploy

#### Setup

1. **Configure Terraform variables:**

```bash
cd rmotly_server/deploy/aws/terraform

# Edit terraform.tfvars
cat > terraform.tfvars << EOF
project_name = "rmotly"
aws_region   = "us-west-2"
environment  = "production"

# Database
db_instance_class = "db.t3.medium"
db_allocated_storage = 20

# Redis
redis_node_type = "cache.t3.micro"

# EC2
instance_type = "t3.small"
min_instances = 2
max_instances = 4
EOF
```

2. **Initialize Terraform:**

```bash
terraform init
terraform plan
terraform apply
```

3. **Configure GitHub Secrets:**

In your GitHub repository settings, add:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `SERVERPOD_PASSWORDS` (YAML content of passwords.yaml)

4. **Deploy via GitHub Actions:**

```bash
# Push to deployment branch
git checkout -b deployment-aws-production
git push origin deployment-aws-production
```

The GitHub Actions workflow (`.github/workflows/deployment-aws.yml`) will:
- Build the Dart server
- Create deployment package
- Deploy via AWS CodeDeploy
- Run database migrations

#### Manual Deployment

```bash
cd rmotly_server/deploy/aws/scripts

# Build and deploy
./deploy.sh production us-west-2
```

---

### Google Cloud Deployment

Deploy to Google Cloud Run with Cloud SQL and Memorystore.

#### Prerequisites

- Google Cloud account
- GCP project created
- `gcloud` CLI installed and authenticated
- Terraform 1.0+

#### Architecture

- **Compute**: Cloud Run (serverless containers)
- **Database**: Cloud SQL PostgreSQL
- **Cache**: Memorystore Redis
- **Load Balancer**: Cloud Load Balancing (automatic)

#### Setup

1. **Configure Terraform:**

```bash
cd rmotly_server/deploy/gcp/terraform_gce

# Edit config.auto.tfvars
cat > config.auto.tfvars << EOF
project_id = "your-gcp-project-id"
region     = "us-central1"
zone       = "us-central1-c"

# Database
db_tier = "db-f1-micro"

# Redis
redis_memory_size_gb = 1
EOF
```

2. **Deploy Infrastructure:**

```bash
terraform init
terraform plan
terraform apply
```

3. **Configure GitHub Secrets:**

- `GOOGLE_CREDENTIALS` (Service account JSON key)

4. **Deploy via GitHub Actions:**

```bash
git checkout -b deployment-gcp-production
git push origin deployment-gcp-production
```

#### Manual Deployment to Cloud Run

```bash
# Set variables
export PROJECT_ID=your-gcp-project-id
export REGION=us-central1
export SERVICE_NAME=rmotly-api

# Build container
gcloud builds submit --tag gcr.io/$PROJECT_ID/$SERVICE_NAME

# Deploy to Cloud Run
gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --set-env-vars runmode=production \
  --set-cloudsql-instances $PROJECT_ID:$REGION:rmotly-db \
  --cpu 1 \
  --memory 512Mi \
  --min-instances 1 \
  --max-instances 10
```

---

## Production Checklist

Before deploying to production, verify:

### Security

- [ ] Strong passwords generated for database and Redis
- [ ] `passwords.yaml` is git-ignored and secured
- [ ] SSL/TLS enabled (HTTPS)
- [ ] Firewall rules configured
- [ ] `requireSsl: true` for database and Redis in production
- [ ] VAPID keys generated for production (not using dev keys)
- [ ] API rate limiting configured
- [ ] CORS configured for Flutter app domain

### Configuration

- [ ] Production config file created (`config/production.yaml`)
- [ ] Correct domain names in config
- [ ] Database connection verified
- [ ] Redis connection verified
- [ ] ntfy push server accessible
- [ ] All environment-specific settings updated

### Database

- [ ] PostgreSQL 17 running
- [ ] Database migrations applied
- [ ] Database backups configured
- [ ] Connection pooling configured
- [ ] Performance tuning applied

### Monitoring

- [ ] Health check endpoints responding
- [ ] Log aggregation configured
- [ ] Error tracking setup (e.g., Sentry)
- [ ] Performance monitoring active
- [ ] Disk space monitoring
- [ ] Backup verification scheduled

### Scaling

- [ ] Auto-scaling rules configured (if using cloud)
- [ ] Load balancer health checks passing
- [ ] CDN configured for static assets (optional)
- [ ] Database read replicas (if needed)
- [ ] Redis clustering (if needed)

### Flutter App Configuration

- [ ] API base URL updated in Flutter app
- [ ] App connects to production API
- [ ] Push notification topics configured
- [ ] App signing keys generated
- [ ] App store listings prepared

---

## Troubleshooting

### Server Won't Start

**Symptom**: Server exits immediately or shows connection errors.

**Solutions**:

```bash
# Check configuration
cat config/production.yaml

# Verify database connection
psql -h your-db-host -U rmotly_user -d rmotly

# Check Redis connection
redis-cli -h your-redis-host -a your-redis-password ping

# View detailed logs
docker logs rmotly-api

# Check environment variables
docker exec rmotly-api env | grep runmode
```

### Database Connection Failed

**Symptom**: "Could not connect to database" error.

**Solutions**:

```bash
# Test PostgreSQL from server
psql -h localhost -p 5432 -U rmotly_user -d rmotly

# Check PostgreSQL is running
docker ps | grep postgres

# Verify passwords.yaml exists and is readable
ls -la config/passwords.yaml

# Check database host in config
grep "host:" config/production.yaml

# Ensure SSL requirements match
# In config: requireSsl: true
# Database must support SSL
```

### Redis Connection Issues

**Symptom**: "Redis connection failed" or performance degradation.

**Solutions**:

```bash
# Test Redis connection
redis-cli -h localhost -p 6379 -a your-password ping

# Check Redis is running
docker ps | grep redis

# Verify Redis password
grep "redis:" config/passwords.yaml

# Check Redis logs
docker logs rmotly-redis
```

### Push Notifications Not Working

**Symptom**: Mobile app not receiving push notifications.

**Solutions**:

```bash
# Test ntfy server
curl http://localhost:8093/v1/health

# Check ntfy logs
docker logs rmotly-ntfy

# Verify VAPID keys are set
grep "vapid:" config/production.yaml

# Test notification endpoint
curl -X POST http://localhost:8080/notifications/send \
  -H "Content-Type: application/json" \
  -d '{"topic":"test","message":"Hello"}'

# Ensure Flutter app has correct ntfy URL
```

### SSL/HTTPS Issues

**Symptom**: SSL certificate errors or HTTPS not working.

**Solutions**:

```bash
# Check Traefik logs
docker logs rmotly-traefik

# Verify DNS points to server
dig api.yourdomain.com

# Check Let's Encrypt rate limits
# https://letsencrypt.org/docs/rate-limits/

# Manual certificate check
openssl s_client -connect api.yourdomain.com:443

# Force certificate renewal
docker exec rmotly-traefik traefik healthcheck
```

### High Memory Usage

**Symptom**: Server using too much memory, OOM errors.

**Solutions**:

```bash
# Check container memory usage
docker stats

# Increase Docker memory limits in docker-compose.prod.yml
# Add under api service:
deploy:
  resources:
    limits:
      memory: 1G

# Optimize PostgreSQL memory settings
# Edit postgresql.conf:
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 4MB

# Restart services
docker compose -f docker-compose.prod.yml restart
```

### Database Migration Failures

**Symptom**: Migration command fails or database schema issues.

**Solutions**:

```bash
# Check current migration status
docker exec rmotly-api ./server --list-migrations

# Manually inspect migrations
ls -la migrations/

# Roll back last migration (if needed)
docker exec -it rmotly-postgres psql -U rmotly_user -d rmotly
# Run rollback SQL manually

# Reapply migrations
docker exec rmotly-api ./server --apply-migrations --repair
```

### Performance Issues

**Symptom**: Slow API responses, timeouts.

**Solutions**:

```bash
# Check API response times
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8080/health

# Create curl-format.txt:
cat > curl-format.txt << EOF
time_namelookup:  %{time_namelookup}\n
time_connect:  %{time_connect}\n
time_starttransfer:  %{time_starttransfer}\n
time_total:  %{time_total}\n
EOF

# Check database query performance
docker exec -it rmotly-postgres psql -U rmotly_user -d rmotly
# Run: EXPLAIN ANALYZE SELECT * FROM users LIMIT 10;

# Check Redis performance
redis-cli --latency

# Scale up resources (cloud deployments)
# Increase instance size or add more instances

# Enable Redis caching
# Verify redis.enabled: true in config
```

---

## Additional Resources

- **Serverpod Documentation**: https://docs.serverpod.dev
- **Project Architecture**: [docs/ARCHITECTURE.md](ARCHITECTURE.md)
- **API Documentation**: [docs/API.md](API.md)
- **CI/CD Setup**: [docs/CI_CD.md](CI_CD.md)
- **Task List**: [TASKS.md](../TASKS.md)

---

## Support

For issues or questions:

1. Check this documentation
2. Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
3. Search existing GitHub issues
4. Create a new issue with:
   - Deployment environment (Docker, VPS, AWS, GCP)
   - Error messages and logs
   - Configuration files (remove sensitive data)
   - Steps to reproduce

---

**Last Updated**: January 2026  
**Version**: 1.0.0
