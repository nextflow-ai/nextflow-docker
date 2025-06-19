# 🌐 NextFlow Cloudflare Tunnels

## 📋 Tổng quan

Thư mục này chứa các scripts để quản lý Cloudflare Tunnels cho NextFlow, cho phép expose các services ra internet một cách an toàn mà không cần mở ports trên firewall.

## 🎯 Lợi ích Cloudflare Tunnels

### ✅ Ưu điểm
- **No port forwarding**: Không cần mở ports trên router/firewall
- **Automatic HTTPS**: SSL/TLS certificates tự động
- **DDoS protection**: Bảo vệ DDoS từ Cloudflare
- **Global CDN**: Tăng tốc truy cập từ khắp nơi
- **Access control**: Kiểm soát truy cập chi tiết
- **Zero Trust**: Bảo mật Zero Trust architecture

### 🔒 Security Features
- **End-to-end encryption**: Mã hóa đầu cuối
- **IP whitelisting**: Whitelist IP addresses
- **Authentication**: Tích hợp với identity providers
- **Audit logs**: Logs truy cập chi tiết

## 📁 Scripts Available

```
scripts/cloudflare/
├── setup-tunnels.sh           # Setup và tạo tunnels
├── manage-tunnels.sh           # Quản lý tunnels (start/stop/status)
├── update-tunnel-env.sh        # Cập nhật tunnel info vào .env
└── README.md                   # Tài liệu này
```

## 🚀 Quick Start

### 1. Prerequisites

```bash
# Install cloudflared
# Ubuntu/Debian
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb

# macOS
brew install cloudflared

# Windows
# Download from: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/
```

### 2. Login to Cloudflare

```bash
# Login to Cloudflare account
cloudflared tunnel login

# This will open browser for authentication
```

### 3. Setup Tunnels

```bash
# Setup all tunnels for your domain
./scripts/cloudflare/setup-tunnels.sh --domain nextflow.vn

# Or create only (don't start)
./scripts/cloudflare/setup-tunnels.sh --domain nextflow.vn --create-only
```

### 4. Manage Tunnels

```bash
# Start all tunnels
./scripts/cloudflare/manage-tunnels.sh start --all

# Stop specific tunnel
./scripts/cloudflare/manage-tunnels.sh stop --tunnel nextflow-api

# Check status
./scripts/cloudflare/manage-tunnels.sh status --all

# View logs
./scripts/cloudflare/manage-tunnels.sh logs --tunnel nextflow
```

## 🔧 Detailed Usage

### setup-tunnels.sh

**Purpose**: Tạo và cấu hình Cloudflare tunnels cho NextFlow services.

```bash
# Full setup with domain
./scripts/cloudflare/setup-tunnels.sh --domain nextflow.vn

# Create tunnels only (no start)
./scripts/cloudflare/setup-tunnels.sh --domain company.com --create-only

# Start existing tunnels only
./scripts/cloudflare/setup-tunnels.sh --domain nextflow.vn --start-only

# Don't update .env file
./scripts/cloudflare/setup-tunnels.sh --domain nextflow.vn --no-env-update
```

**What it does:**
1. Creates Cloudflare tunnels for each service
2. Generates configuration files
3. Updates .env with tunnel IDs and tokens
4. Starts tunnels (unless --create-only)

### manage-tunnels.sh

**Purpose**: Quản lý lifecycle của tunnels (start, stop, restart, status).

```bash
# Start operations
./scripts/cloudflare/manage-tunnels.sh start --all
./scripts/cloudflare/manage-tunnels.sh start --tunnel nextflow-api

# Stop operations
./scripts/cloudflare/manage-tunnels.sh stop --all
./scripts/cloudflare/manage-tunnels.sh stop --tunnel nextflow-gitlab

# Restart operations
./scripts/cloudflare/manage-tunnels.sh restart --all
./scripts/cloudflare/manage-tunnels.sh restart --tunnel nextflow-monitoring

# Status check
./scripts/cloudflare/manage-tunnels.sh status --all
./scripts/cloudflare/manage-tunnels.sh status --tunnel nextflow-docs

# View logs
./scripts/cloudflare/manage-tunnels.sh logs --tunnel nextflow
```

### update-tunnel-env.sh

**Purpose**: Cập nhật tunnel IDs và tokens vào file .env.

```bash
# Interactive mode
./scripts/cloudflare/update-tunnel-env.sh

# Auto-detect mode
./scripts/cloudflare/update-tunnel-env.sh --auto
```

**Features:**
- Auto-detect existing tunnels
- Interactive tunnel-by-tunnel update
- Validates tunnel IDs and tokens
- Updates .env file safely

## 🌍 Tunnel Configuration

### Available Tunnels

| Tunnel Name | Purpose | Subdomain | Local Port |
|-------------|---------|-----------|------------|
| **nextflow** | Main application | `nextflow.vn` | 3002 |
| **nextflow-api** | API backend | `api.nextflow.vn` | 3001 |
| **nextflow-docs** | Documentation | `docs.nextflow.vn` | 3003 |
| **nextflow-monitoring** | Monitoring stack | `grafana.nextflow.vn` | 3030 |
| **nextflow-ai** | AI services | `flowise.nextflow.vn` | 3000 |
| **nextflow-gitlab** | GitLab self-hosted | `gitlab.nextflow.vn` | 8080 |

### URL Mappings

```
# Main application
https://nextflow.vn → http://localhost:3002
https://app.nextflow.vn → http://localhost:3002

# API backend
https://api.nextflow.vn → http://localhost:3001

# Documentation
https://docs.nextflow.vn → http://localhost:3003

# Monitoring
https://grafana.nextflow.vn → http://localhost:3030
https://prometheus.nextflow.vn → http://localhost:9090

# AI services
https://flowise.nextflow.vn → http://localhost:3000
https://ai.nextflow.vn → http://localhost:5080
https://ollama.nextflow.vn → http://localhost:11434

# GitLab
https://gitlab.nextflow.vn → http://localhost:8080
https://registry.nextflow.vn → http://localhost:5050
```

## 📊 Integration với NextFlow

### 1. Environment Variables

Sau khi setup, các biến sau sẽ được thêm vào `.env`:

```bash
# Domain
DOMAIN=nextflow.vn

# Tunnel IDs
CLOUDFLARE_TUNNEL_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
CLOUDFLARE_TUNNEL_API_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
CLOUDFLARE_TUNNEL_DOCS_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
CLOUDFLARE_TUNNEL_MONITORING_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
CLOUDFLARE_TUNNEL_AI_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
CLOUDFLARE_TUNNEL_GITLAB_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Tunnel Tokens (optional)
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoixxxxx...
CLOUDFLARE_TUNNEL_API_TOKEN=eyJhIjoixxxxx...
# ... etc
```

### 2. Docker Compose Integration

```yaml
# docker-compose.yml
services:
  cloudflared-nextflow:
    image: cloudflare/cloudflared:latest
    command: tunnel --config /etc/cloudflared/nextflow.yml run
    volumes:
      - ./cloudflared/nextflow.yml:/etc/cloudflared/nextflow.yml
      - ~/.cloudflared:/root/.cloudflared
    restart: unless-stopped
    profiles: ["tunnels"]
```

### 3. Startup Integration

```bash
# Start NextFlow with tunnels
./scripts/deploy.sh --profiles basic,tunnels

# Or start tunnels separately
./scripts/cloudflare/manage-tunnels.sh start --all
```

## 🔧 Advanced Configuration

### Custom Tunnel Configuration

Bạn có thể tùy chỉnh tunnel configuration trong `cloudflared/*.yml`:

```yaml
# cloudflared/nextflow.yml
tunnel: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
credentials-file: /root/.cloudflared/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.json

ingress:
  - hostname: nextflow.vn
    service: http://host.docker.internal:3002
    originRequest:
      httpHostHeader: nextflow.vn
  - hostname: app.nextflow.vn
    service: http://host.docker.internal:3002
  - service: http_status:404
```

### Access Control

```yaml
# Add access control
ingress:
  - hostname: admin.nextflow.vn
    service: http://host.docker.internal:3030
    originRequest:
      access:
        required: true
        teamName: nextflow-team
        audTag: admin-access
```

### Load Balancing

```yaml
# Load balancing across multiple instances
ingress:
  - hostname: api.nextflow.vn
    service: http://localhost:3001
    originRequest:
      loadBalancer:
        - http://localhost:3001
        - http://localhost:3011
        - http://localhost:3021
```

## 🚨 Troubleshooting

### Common Issues

#### 1. Tunnel not starting
```bash
# Check logs
./scripts/cloudflare/manage-tunnels.sh logs --tunnel nextflow

# Check configuration
cat cloudflared/nextflow.yml

# Test connectivity
cloudflared tunnel --config cloudflared/nextflow.yml run
```

#### 2. DNS not resolving
```bash
# Check Cloudflare DNS settings
# Ensure CNAME records point to tunnel

# Example DNS records:
# nextflow.vn CNAME xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.cfargotunnel.com
# *.nextflow.vn CNAME xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.cfargotunnel.com
```

#### 3. Service not accessible
```bash
# Check local service
curl http://localhost:3002

# Check tunnel status
./scripts/cloudflare/manage-tunnels.sh status --all

# Check tunnel logs
tail -f logs/cloudflared-nextflow.log
```

#### 4. Authentication issues
```bash
# Re-login to Cloudflare
cloudflared tunnel login

# Check credentials
ls ~/.cloudflared/

# Regenerate tunnel token
cloudflared tunnel token nextflow
```

## 📚 Best Practices

### Security
- ✅ Use Cloudflare Access for sensitive endpoints
- ✅ Enable audit logging
- ✅ Regularly rotate tunnel credentials
- ✅ Monitor tunnel access logs

### Performance
- ✅ Use appropriate cache settings
- ✅ Enable compression
- ✅ Configure proper origin timeouts
- ✅ Use load balancing for high traffic

### Monitoring
- ✅ Monitor tunnel health
- ✅ Set up alerts for tunnel downtime
- ✅ Track tunnel performance metrics
- ✅ Regular backup of tunnel configurations

## 🆘 Support

### Documentation
- 📖 [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- 🔧 [NextFlow Deployment Guide](../../docs/guides/deployment-guide.md)

### Community
- 💬 **Discord**: [NextFlow Community](https://discord.gg/nextflow)
- 📧 **Email**: devops@nextflow.vn

---

**Secure and fast internet access with Cloudflare Tunnels! 🌐🚀**
