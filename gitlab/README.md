# GitLab NextFlow CRM-AI

## 🎯 Tổng quan

GitLab CE tùy chỉnh cho dự án NextFlow CRM-AI với các tính năng:
- Custom Docker image với cấu hình tối ưu
- Tích hợp PostgreSQL và Redis external
- Tích hợp Stalwart Mail server
- Backup tự động
- CI/CD templates cho NextFlow projects

## 📁 Cấu trúc thư mục

```
gitlab/
├── docker/                    # Docker build context
│   ├── Dockerfile             # Custom GitLab image
│   ├── scripts/               # Custom scripts
│   │   ├── docker-entrypoint.sh
│   │   ├── gitlab-init.sh
│   │   └── gitlab-backup.sh
│   └── config/
│       └── gitlab.rb          # GitLab configuration template
├── config/                    # GitLab configuration (mounted)
├── logs/                      # GitLab logs (mounted)
├── data/                      # GitLab data (mounted)
├── backups/                   # GitLab backups (mounted)
├── ssl/                       # SSL certificates (optional)
├── hooks/                     # Custom Git hooks (optional)
├── docker-compose.build.yml   # Docker Compose for custom build
├── .env.example              # Environment variables template
└── README.md                 # This file
```

## 🚀 Cài đặt và sử dụng

### 1. Chuẩn bị môi trường

```bash
# Copy environment file
cp gitlab/.env.example gitlab/.env

# Chỉnh sửa cấu hình trong .env
nano gitlab/.env
```

### 2. Build và khởi động GitLab

```bash
# Build custom GitLab image
docker-compose -f gitlab/docker-compose.build.yml build

# Khởi động GitLab
docker-compose -f gitlab/docker-compose.build.yml up -d

# Xem logs
docker-compose -f gitlab/docker-compose.build.yml logs -f gitlab
```

### 3. Truy cập GitLab

- **URL:** http://localhost:8088
- **Username:** root
- **Password:** nextflow@2025 (hoặc theo GITLAB_ROOT_PASSWORD trong .env)

### 4. Cấu hình GitLab Runner (Optional)

```bash
# Khởi động với GitLab Runner
docker-compose -f gitlab/docker-compose.build.yml --profile gitlab-runner up -d

# Đăng ký runner
docker exec -it gitlab-runner-nextflow gitlab-runner register
```

## 🔧 Cấu hình

### Environment Variables

Các biến môi trường quan trọng trong `.env`:

| Biến | Mô tả | Mặc định |
|------|-------|----------|
| `GITLAB_EXTERNAL_URL` | URL truy cập GitLab | http://localhost:8088 |
| `GITLAB_ROOT_PASSWORD` | Password user root | nextflow@2025 |
| `POSTGRES_HOST` | PostgreSQL host | postgres |
| `REDIS_HOST` | Redis host | redis |
| `MAIL_SMTP_HOST` | SMTP server | stalwart-mail |

### Ports

| Service | Port | Mô tả |
|---------|------|-------|
| GitLab Web | 8088 | HTTP interface |
| GitLab HTTPS | 8443 | HTTPS interface |
| GitLab SSH | 2222 | Git SSH access |
| Container Registry | 5050 | Docker registry |

## 🔄 Backup và Restore

### Tạo backup

```bash
# Backup thủ công
docker exec gitlab-nextflow /opt/gitlab/bin/gitlab-backup.sh

# Backup tự động (đã cấu hình trong container)
# Chạy hàng ngày lúc 2:00 AM
```

### Restore backup

```bash
# List backups
docker exec gitlab-nextflow ls -la /var/opt/gitlab/backups/

# Restore backup
docker exec gitlab-nextflow gitlab-backup restore BACKUP=20250113_020000_2025.01.13_16.11.10-ce
```

## 🛠️ Troubleshooting

### GitLab không khởi động

```bash
# Kiểm tra logs
docker-compose -f gitlab/docker-compose.build.yml logs gitlab

# Kiểm tra health
docker exec gitlab-nextflow gitlab-ctl status

# Restart GitLab
docker exec gitlab-nextflow gitlab-ctl restart
```

### Database connection issues

```bash
# Kiểm tra PostgreSQL
docker exec postgres pg_isready -U nextflow

# Kiểm tra Redis
docker exec redis redis-cli ping
```

### Performance issues

```bash
# Kiểm tra resource usage
docker stats gitlab-nextflow

# Tăng resource limits trong docker-compose.build.yml
```

## 📝 Development

### Custom Scripts

Scripts trong `docker/scripts/` sẽ được copy vào container:
- `docker-entrypoint.sh`: Entry point tùy chỉnh
- `gitlab-init.sh`: Khởi tạo GitLab
- `gitlab-backup.sh`: Backup tự động

### Custom Configuration

File `docker/config/gitlab.rb` là template cấu hình GitLab với các biến:
- `{{GITLAB_EXTERNAL_URL}}`
- `{{GITLAB_DB_HOST}}`
- `{{GITLAB_DB_USER}}`
- etc.

### Rebuild Image

```bash
# Rebuild khi có thay đổi
docker-compose -f gitlab/docker-compose.build.yml build --no-cache

# Restart với image mới
docker-compose -f gitlab/docker-compose.build.yml up -d
```

## 🔗 Tích hợp với NextFlow

### Projects được tạo sẵn

GitLab sẽ tự động tạo các projects:
- `nextflow-backend` - NestJS API
- `nextflow-frontend` - Next.js Web App
- `nextflow-mobile` - Flutter Mobile App
- `nextflow-infrastructure` - Docker & CI/CD

### CI/CD Variables

Các biến CI/CD được cấu hình sẵn:
- `DOCKER_REGISTRY=localhost:5050`
- `POSTGRES_USER=nextflow`
- `POSTGRES_PASSWORD=nextflow@2025`
- `REDIS_PASSWORD=nextflow@2025`

## 📞 Support

Nếu gặp vấn đề, kiểm tra:
1. Logs của GitLab container
2. Health check status
3. Database và Redis connectivity
4. Resource usage (CPU, Memory)
5. Disk space cho backups
