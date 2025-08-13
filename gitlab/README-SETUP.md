# Hướng dẫn cài đặt GitLab cho NextFlow CRM-AI

## 🎯 Tổng quan hệ thống

GitLab CE (Community Edition - Phiên bản miễn phí) được tùy chỉnh cho dự án NextFlow CRM-AI với các tính năng:

- **Phiên bản cố định:** 16.11.10-ce.0 (đảm bảo hệ thống ổn định, không bị lỗi do cập nhật tự động)
- **Quản lý cấu hình tập trung:** Tất cả thông số được lưu trong file `.env` để dễ thay đổi
- **Dockerfile tùy chỉnh:** Có thêm các script riêng cho NextFlow
- **Cơ sở dữ liệu PostgreSQL riêng biệt:** Không dùng database tích hợp sẵn mà dùng chung với hệ thống
- **Redis cache riêng biệt:** Dùng chung Redis server để tăng hiệu suất
- **Tích hợp email Stalwart:** Gửi email thông báo qua mail server riêng
- **Container Registry:** Lưu trữ Docker images của dự án
- **Sao lưu tự động:** Tự động backup dữ liệu định kỳ
- **Múi giờ Việt Nam:** Hiển thị thời gian theo giờ Việt Nam
- **Cấu hình tối ưu:** Điều chỉnh hiệu suất phù hợp với server

## 🚀 Quy trình triển khai

### Script quản lý tập trung: `gitlab-manager.sh`

Script này giúp quản lý toàn bộ GitLab một cách đơn giản:

```bash
# Xây dựng GitLab image tùy chỉnh (chứa các script riêng của NextFlow)
./scripts/gitlab-manager.sh build

# Cài đặt GitLab hoàn chỉnh (tự động build image nếu chưa có)
./scripts/gitlab-manager.sh install

# Kiểm tra trạng thái tổng thể của GitLab
./scripts/gitlab-manager.sh status

# Tạo tài khoản root (quản trị viên) khi chưa có
./scripts/gitlab-manager.sh create-root

# Sao lưu dữ liệu GitLab
./scripts/gitlab-manager.sh backup

# Khôi phục dữ liệu từ bản sao lưu
./scripts/gitlab-manager.sh restore

# Xem tất cả lệnh có thể dùng
./scripts/gitlab-manager.sh help
```

### Lệnh khẩn cấp khi cần reset:

```bash
# Xóa database GitLab (cẩn thận - mất hết dữ liệu!)
docker exec postgres psql -U nextflow -c "DROP DATABASE IF EXISTS nextflow_gitlab;"

# Reset toàn bộ GitLab về trạng thái ban đầu
./scripts/gitlab-manager.sh reset-all
```

## 📋 Quy trình cài đặt đầy đủ

### 1. Cấu hình .env (đã có sẵn)

## 📋 Cấu hình hệ thống từ file .env

Tất cả thông số GitLab được quản lý tập trung trong file `.env` để dễ thay đổi:

### Phiên bản và Cơ sở dữ liệu:
```bash
GITLAB_VERSION=16.11.10-ce.0        # Phiên bản GitLab cố định (không tự động cập nhật)
GITLAB_DATABASE=nextflow_gitlab      # Tên database PostgreSQL cho GitLab
```

### Địa chỉ truy cập và Tài khoản:
```bash
GITLAB_EXTERNAL_URL=http://localhost:8088     # Địa chỉ web để truy cập GitLab
GITLAB_REGISTRY_URL=http://localhost:5050     # Địa chỉ Docker Registry (lưu trữ images)
GITLAB_ROOT_USERNAME=root                     # Tên tài khoản quản trị viên
GITLAB_ROOT_PASSWORD=Nex!tFlow@2025!          # Mật khẩu tài khoản quản trị viên
GITLAB_ROOT_EMAIL=nextflow.vn@gmail.com       # Email tài khoản quản trị viên
```

### Cổng kết nối (Ports):
```bash
GITLAB_HTTP_PORT=8088      # Cổng web HTTP (truy cập qua trình duyệt)
GITLAB_HTTPS_PORT=8443     # Cổng web HTTPS (bảo mật SSL)
GITLAB_SSH_PORT=2222       # Cổng SSH (clone/push code qua SSH)
GITLAB_REGISTRY_PORT=5050  # Cổng Docker Registry
```

### Hiệu suất xử lý (Performance):
```bash
GITLAB_PUMA_WORKERS=4          # Số worker xử lý web (càng nhiều càng nhanh)
GITLAB_PUMA_MIN_THREADS=4      # Số thread tối thiểu mỗi worker
GITLAB_PUMA_MAX_THREADS=16     # Số thread tối đa mỗi worker
GITLAB_SIDEKIQ_CONCURRENCY=10  # Số job xử lý đồng thời (background tasks)
```

### Tài nguyên hệ thống (Resources):
```bash
GITLAB_CPU_LIMIT=4         # Giới hạn CPU tối đa (4 cores)
GITLAB_MEMORY_LIMIT=8G     # Giới hạn RAM tối đa (8GB)
GITLAB_CPU_RESERVE=2       # CPU dành riêng tối thiểu (2 cores)
GITLAB_MEMORY_RESERVE=4G   # RAM dành riêng tối thiểu (4GB)
```

### Tính năng hệ thống (Features):
```bash
GITLAB_SIGNUP_ENABLED=true      # Cho phép đăng ký tài khoản mới (true/false)
GITLAB_BACKUP_KEEP_TIME=604800  # Thời gian lưu backup (604800 = 7 ngày)
```

## ✅ Lợi ích cấu hình tập trung

- **🎯 Dễ quản lý:** Tất cả cấu hình ở một nơi
- **🔧 Dễ thay đổi:** Chỉ cần sửa file `.env`
- **🚀 Không hardcode:** Tránh giá trị cố định trong docker-compose
- **🔄 Override được:** Có thể override bằng environment variables
- **💾 Backup dễ:** Backup/restore cấu hình đơn giản
- **🔍 Kiểm tra được:** Script `check-env-config.sh` để verify

### Kiểm tra cấu hình:
```bash
./scripts/check-env-config.sh
```

## 🔧 Troubleshooting & Fix

### Script GitLab Manager (tích hợp fix):
```bash
# Menu tương tác
./scripts/gitlab-manager.sh

# Hoặc dùng command line:
# Kiểm tra database
./scripts/gitlab-manager.sh check-db

# Reset root user (khi không đăng nhập được)
./scripts/gitlab-manager.sh reset-root

# Xóa database cũ và partitions không dùng
./scripts/gitlab-manager.sh clean-db

# Migrate database
./scripts/gitlab-manager.sh migrate

# Reset toàn bộ GitLab
./scripts/gitlab-manager.sh reset-all
```

### Các trường hợp thường gặp:

#### 1. Không đăng nhập được (root user chưa tạo):
```bash
./scripts/gitlab-manager.sh reset-root
```

#### 2. Database cũ `gitlabhq_production` vẫn tồn tại:
```bash
./scripts/gitlab-manager.sh clean-db
```

#### 3. Database partitions không dùng:
- `gitlab_partitions_dynamic`
- `gitlab_partitions_static`
```bash
./scripts/gitlab-manager.sh clean-db
```

#### 4. GitLab không khởi động được:
```bash
./scripts/gitlab-manager.sh reset-all
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
- Tạo database `nextflow_gitlab`
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
GITLAB_ROOT_PASSWORD: Nex!tFlow@2025!

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
