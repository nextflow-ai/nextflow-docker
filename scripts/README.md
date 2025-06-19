# 🔧 NextFlow Scripts

## 📋 Tổng quan

Thư mục này chứa tất cả các scripts để quản lý và triển khai NextFlow CRM system với GitLab self-hosted và CI/CD.

## 📁 Cấu trúc Scripts (Đã tối ưu)

```
scripts/
├── 🚀 Core Deployment
│   ├── deploy.sh                   # Script triển khai chính
│   └── update-env.sh               # Quản lý environment variables

├── 🌐 Cloudflare Tunnels
│   ├── setup-tunnels.sh            # Setup Cloudflare tunnels
│   ├── manage-tunnels.sh            # Quản lý tunnels (start/stop/status)
│   ├── update-tunnel-env.sh         # Cập nhật tunnel info vào .env
│   └── README.md                    # Cloudflare documentation
├── 🧪 Testing & Utilities
│   └── test-postgres-connection.sh # Test kết nối PostgreSQL
├── 🦊 GitLab Management
│   └── gitlab.sh                    # Quản lý GitLab (start/stop/status/logs/password)
├── 📁 Organized Modules
│   ├── profiles/                   # Scripts theo profile
│   │   ├── basic.sh               # Profile cơ bản
│   │   ├── monitoring.sh          # Profile monitoring
│   │   ├── ai.sh                  # Profile AI
│   │   └── backup.sh              # Profile backup
│   └── utils/                      # Utility functions
│       ├── logging.sh             # Logging utilities
│       ├── docker.sh              # Docker utilities
│       └── validation.sh          # Validation utilities
└── 📚 Documentation
    └── README.md                   # Tài liệu này
```

## 🚀 Quick Start

```bash
# 1. Triển khai profile cơ bản
./scripts/deploy.sh --profile basic

# 2. Triển khai với monitoring
./scripts/deploy.sh --profile basic,monitoring

# 3. Triển khai với AI
./scripts/deploy.sh --profile basic,ai

# 4. Setup Cloudflare tunnels (Optional)
./scripts/cloudflare/setup-tunnels.sh --domain nextflow.vn
```

## 📚 Mục lục

1. [Core Scripts](#core-scripts)
2. [Cloudflare Tunnels](#cloudflare-tunnels)
3. [GitLab Management](#gitlab-management)
4. [Profiles System](#profiles-system)
5. [Utilities](#utilities)
## 🚀 Core Scripts

### deploy.sh
Script triển khai chính với hệ thống profiles.

```bash
# Triển khai cơ bản
./scripts/deploy.sh --profile basic

# Triển khai với monitoring
./scripts/deploy.sh --profiles basic,monitoring

# Triển khai với AI
./scripts/deploy.sh --profiles basic,ai

# Dừng tất cả services
./scripts/deploy.sh --stop
```

### update-env.sh
Quản lý environment variables và configurations.

```bash
# Interactive mode
./scripts/update-env.sh

# Load specific environment
./scripts/update-env.sh --env development
./scripts/update-env.sh --env production

# Update specific variable
./scripts/update-env.sh --var DATABASE_URL --value "new_value"
```





## 🌐 Cloudflare Tunnels

### setup-tunnels.sh
Setup Cloudflare tunnels để expose services ra internet.

```bash
# Setup all tunnels for domain
./scripts/cloudflare/setup-tunnels.sh --domain nextflow.vn

# Create only (don't start)
./scripts/cloudflare/setup-tunnels.sh --domain nextflow.vn --create-only

# Start existing tunnels
./scripts/cloudflare/setup-tunnels.sh --domain nextflow.vn --start-only
```

**Features:**
- Tạo tunnels cho tất cả services
- Automatic HTTPS với SSL certificates
- DDoS protection từ Cloudflare
- Global CDN acceleration

### manage-tunnels.sh
Quản lý Cloudflare tunnels (start, stop, restart, status).

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

### update-tunnel-env.sh
Cập nhật tunnel IDs và tokens vào .env file.

```bash
# Interactive mode
./scripts/cloudflare/update-tunnel-env.sh

# Auto-detect mode
./scripts/cloudflare/update-tunnel-env.sh --auto
```

## 🦊 GitLab Management

### gitlab.sh
Quản lý GitLab CE với shared infrastructure (PostgreSQL và Redis).

```bash
# Interactive mode (khuyến nghị)
./scripts/gitlab.sh

# Command line options
./scripts/gitlab.sh --start
./scripts/gitlab.sh --stop
./scripts/gitlab.sh --status
./scripts/gitlab.sh --logs --follow
./scripts/gitlab.sh --password
./scripts/gitlab.sh --restart
```

**Features:**
- 🎯 **Interactive Menu**: Dễ sử dụng với menu tương tác
- 🦊 **GitLab CE**: Container Registry tích hợp
- 🗄️ **Shared Infrastructure**: Sử dụng PostgreSQL và Redis có sẵn
- 🔧 **Auto Setup**: Tự động tạo database và dependencies
- 📊 **Health Monitoring**: Kiểm tra trạng thái real-time
- 🔐 **Password Management**: Lấy initial password dễ dàng

**Thông tin truy cập:**
- 🌐 Web Interface: http://gitlab.nextflow.vn:8088
- 📦 Container Registry: http://gitlab.nextflow.vn:5050
- 🔑 Username: root
- 🔐 Password: `./scripts/gitlab.sh --password`

## 📁 Profiles System

### Profile Basic
Các dịch vụ cốt lõi cần thiết:
- **PostgreSQL**: Database (port 5432)
- **Redis**: Cache (port 6379)
- **n8n**: Workflow automation (port 5678)
- **Flowise**: AI orchestration (port 3000)
- **Qdrant**: Vector database (port 6333)

### Profile Monitoring
Stack giám sát:
- **Prometheus**: Metrics collection (port 9090)
- **Grafana**: Dashboard (port 3030)
- **Loki**: Log aggregation (port 3100)

### Profile AI
AI services:
- **Ollama**: Local AI models (port 11434)
- **Open WebUI**: AI chat interface (port 5080)

### Profile Backup
Automated backup:
- **Backup service**: Tự động backup databases
- **Retention policy**: Quản lý backup cũ
- **Restore capabilities**: Khôi phục dữ liệu

## 🧪 Utilities

### test-postgres-connection.sh
Test kết nối PostgreSQL database.

```bash
# Test connection
./scripts/test-postgres-connection.sh

# Test with custom parameters
./scripts/test-postgres-connection.sh --host localhost --port 5432 --user nextflow
```

### utils/logging.sh
Logging utilities cho tất cả scripts.

**Functions:**
- `log_info()`: Thông tin chung
- `log_success()`: Thành công
- `log_warning()`: Cảnh báo
- `log_error()`: Lỗi
- `show_banner()`: Hiển thị banner

### utils/docker.sh
Docker utilities và helper functions.

**Functions:**
- `check_docker()`: Kiểm tra Docker
- `check_compose()`: Kiểm tra Docker Compose
- `docker_cleanup()`: Dọn dẹp Docker
- `get_container_status()`: Trạng thái container

### utils/validation.sh
Validation functions cho inputs và configurations.

**Functions:**
- `validate_email()`: Validate email
- `validate_url()`: Validate URL
- `validate_port()`: Validate port number
- `validate_env_file()`: Validate environment file

## 🔧 Advanced Usage

### Environment Management
```bash
# Load development environment
./scripts/update-env.sh --env development

# Load staging environment
./scripts/update-env.sh --env staging

# Load production environment
./scripts/update-env.sh --env production
```

### Multi-Profile Deployment
```bash
# Deploy basic + monitoring
./scripts/deploy.sh --profiles basic,monitoring

# Deploy basic + AI + monitoring
./scripts/deploy.sh --profiles basic,ai,monitoring

# Deploy everything
./scripts/deploy.sh --profiles basic,monitoring,ai,backup
```



## 🚨 Troubleshooting

### Common Issues

#### Docker Issues
```bash
# Check Docker status
docker info

# Restart Docker service
sudo systemctl restart docker

# Clean up Docker
docker system prune -af
```



### Performance Optimization
```bash
# Check resource usage
docker stats

# Monitor system resources
htop
df -h

# Clean up old images
docker image prune -af
```

## 📚 Best Practices

### Security
- ✅ Thay đổi tất cả passwords mặc định
- ✅ Sử dụng strong secrets cho production
- ✅ Enable SSL/TLS cho external access
- ✅ Regular security updates

### Backup Strategy
- ✅ Daily automated backups
- ✅ Test restore procedures
- ✅ Off-site backup storage
- ✅ Retention policy implementation

### Monitoring
- ✅ Setup alerts cho critical metrics
- ✅ Monitor resource usage
- ✅ Track application performance
- ✅ Log aggregation và analysis

## 🆘 Support

### Documentation
- 🔄 [CI/CD Guide](../docs/guides/cicd-guide.md)
- 📚 [Deployment Guide](../docs/guides/deployment-guide.md)
- 🚀 [Quick Start Guide](../docs/guides/QUICK-START.md)

### Community
- 💬 **Discord**: [NextFlow Community](https://discord.gg/nextflow)
- 📧 **Email**: devops@nextflow.vn
- 🐛 **Issues**: [GitHub Issues](https://github.com/huynguyenak1996/nextflow-docker/issues)

---

**Happy scripting with NextFlow! 🚀**
