# GitLab Custom Build cho NextFlow CRM-AI

## 🎯 Tổng quan

GitLab CE **Custom Build** được cấu hình trong `docker-compose.yml` với:
- **Version cố định:** 16.11.10-ce.0 (đảm bảo tính ổn định)
- **Custom Dockerfile** với NextFlow scripts
- **PostgreSQL external** (shared database)
- **Redis external** (shared cache)
- **Stalwart Mail integration**
- **Container Registry**
- **Backup tự động**
- **Vietnamese timezone**
- **Optimized configuration**

## 🚀 Quy trình triển khai

### Script quản lý tập trung: `gitlab-manager.sh`

```bash
# Build GitLab custom image
./scripts/gitlab-manager.sh build

# Cài đặt GitLab (tự động build nếu cần)
./scripts/gitlab-manager.sh install

# Cập nhật GitLab
./scripts/gitlab-manager.sh update

# Backup GitLab
./scripts/gitlab-manager.sh backup

# Restore GitLab
./scripts/gitlab-manager.sh restore

# Xem hướng dẫn
./scripts/gitlab-manager.sh help
```

## 📋 Quy trình cài đặt đầy đủ

### 1. Cấu hình .env (đã có sẵn)

Các biến GitLab trong `.env`:
```bash
GITLAB_VERSION=16.11.10-ce.0
GITLAB_EXTERNAL_URL=http://localhost:8088
GITLAB_ROOT_USERNAME=root
GITLAB_ROOT_PASSWORD=Nex!tFlow@2025!
GITLAB_ROOT_EMAIL=nextflow.vn@gmail.com
```

### 2. Cài đặt GitLab

```bash
# Cài đặt GitLab (tự động build image nếu cần)
./scripts/gitlab-manager.sh install
```

Script sẽ tự động:
- Kiểm tra yêu cầu hệ thống
- Tạo thư mục cần thiết
- Khởi động PostgreSQL và Redis
- Tạo database `gitlabhq_production`
- Khởi động GitLab container
- Đợi GitLab sẵn sàng (5-10 phút)

### 2. Truy cập GitLab

- **URL:** http://localhost:8088
- **Username:** root
- **Password:** nextflow@2025

### 3. Container Registry

- **URL:** http://localhost:5050
- **Login:** Dùng tài khoản GitLab

### 4. SSH Git Access

```bash
# Clone repository
git clone ssh://git@localhost:2222/group/project.git

# Thêm SSH key vào GitLab profile
```

## 🔧 Cấu hình Environment

### Biến môi trường trong docker-compose.yml

```yaml
# GitLab cơ bản
GITLAB_EXTERNAL_URL: http://localhost:8088
GITLAB_ROOT_PASSWORD: nextflow@2025

# Database
POSTGRES_USER: nextflow
POSTGRES_PASSWORD: nextflow@2025

# Redis
REDIS_PASSWORD: nextflow@2025

# Mail (Stalwart integration)
MAIL_SMTP_HOST: stalwart-mail
MAIL_SMTP_PORT: 587
MAIL_FROM: gitlab@nextflow.local

# Performance
GITLAB_PUMA_WORKERS: 4
GITLAB_SIDEKIQ_CONCURRENCY: 10

# Resource limits
GITLAB_CPU_LIMIT: 4
GITLAB_MEMORY_LIMIT: 8G
```

## 💾 Backup và Restore

### Tạo backup

```bash
# Backup thủ công
./scripts/gitlab-manager.sh backup

# Backup tự động được lưu tại:
# gitlab/backups/YYYYMMDD_HHMMSS_gitlab_backup.tar
# gitlab/backups/config_YYYYMMDD_HHMMSS.tar.gz
```

### Restore backup

```bash
# Restore từ backup
./scripts/gitlab-manager.sh restore

# Script sẽ hiển thị danh sách backup để chọn
```

### Dọn dẹp backup cũ

- Backup tự động xóa sau 7 ngày
- Có thể thay đổi trong script

## 🔄 Cập nhật GitLab

```bash
# Cập nhật lên phiên bản mới
./scripts/gitlab-manager.sh update
```

Script sẽ:
- Tạo backup trước khi cập nhật
- Pull image mới
- Restart container
- Verify hoạt động

## 📁 Cấu trúc thư mục

```
gitlab/
├── config/          # Cấu hình GitLab
├── logs/            # Log files
├── data/            # Dữ liệu GitLab
├── backups/         # Backup files
└── README-SETUP.md  # File này
```

## 🛠️ Troubleshooting

### GitLab không khởi động

```bash
# Kiểm tra logs
docker-compose logs gitlab

# Kiểm tra status
docker exec gitlab-nextflow gitlab-ctl status

# Restart GitLab
docker-compose restart gitlab
```

### Database connection issues

```bash
# Kiểm tra PostgreSQL
docker exec postgres pg_isready -U nextflow

# Kiểm tra database
docker exec postgres psql -U nextflow -l
```

### Memory issues

```bash
# Kiểm tra resource usage
docker stats gitlab-nextflow

# Tăng memory limit trong docker-compose.yml
GITLAB_MEMORY_LIMIT: 16G
```

### Slow performance

```bash
# Tăng workers
GITLAB_PUMA_WORKERS: 8
GITLAB_SIDEKIQ_CONCURRENCY: 20

# Restart để áp dụng
docker-compose restart gitlab
```

## 📊 Monitoring

### Health check

```bash
# GitLab health
curl http://localhost:8088/-/health

# GitLab readiness
curl http://localhost:8088/-/readiness
```

### Resource monitoring

```bash
# Container stats
docker stats gitlab-nextflow

# GitLab internal status
docker exec gitlab-nextflow gitlab-ctl status
```

## 🔐 Security

### SSL/HTTPS (Optional)

1. Tạo SSL certificates
2. Mount vào container
3. Cập nhật GITLAB_EXTERNAL_URL

### Firewall

```bash
# Chỉ mở ports cần thiết
ufw allow 8088/tcp  # GitLab Web
ufw allow 2222/tcp  # GitLab SSH
ufw allow 5050/tcp  # Container Registry
```

## 📞 Support

### Logs quan trọng

```bash
# GitLab logs
docker-compose logs gitlab

# PostgreSQL logs
docker-compose logs postgres

# Redis logs
docker-compose logs redis
```

### Commands hữu ích

```bash
# GitLab console
docker exec -it gitlab-nextflow gitlab-rails console

# GitLab reconfigure
docker exec gitlab-nextflow gitlab-ctl reconfigure

# GitLab restart
docker exec gitlab-nextflow gitlab-ctl restart
```

## 🎯 Next Steps

1. Cài đặt GitLab Runner cho CI/CD
2. Cấu hình webhooks
3. Setup project templates
4. Integrate với monitoring stack
5. Setup automated backups
