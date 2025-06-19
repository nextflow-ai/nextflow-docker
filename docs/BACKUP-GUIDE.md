# 🗄️ NextFlow Docker - Hướng Dẫn Backup & Restore

## 📋 Tổng Quan

NextFlow Docker Backup System là một hệ thống backup toàn diện được thiết kế để bảo vệ dữ liệu quan trọng của NextFlow project bao gồm:

- **Databases**: PostgreSQL và MariaDB
- **Docker Volumes**: Persistent data của các services
- **Configuration Files**: Cấu hình hệ thống và applications
- **GitLab Data**: Repositories, logs, và cấu hình
- **Application Data**: Langflow workflows, WordPress uploads, etc.

## 🚀 Cách Sử Dụng

### Interactive Menu (Khuyến nghị cho người mới)

```bash
./scripts/backup.sh
```

Menu tương tác sẽ hiển thị các tùy chọn:

```
1) 🗄️  Full Backup (Toàn bộ: DB + Volumes + Configs)
2) 🐘  Database Backup (Chỉ databases)
3) ⚙️  Config Backup (Chỉ cấu hình)
4) 📈  Incremental Backup (Backup gia tăng)
5) 📋  List Backups (Xem danh sách)
6) 🔄  Restore Backup (Khôi phục)
7) 🧹  Cleanup Old Backups (Dọn dẹp)
8) ❌  Exit (Thoát)
```

### Command Line Interface

```bash
# Full backup (toàn bộ hệ thống)
./scripts/backup.sh --full

# Chỉ backup databases
./scripts/backup.sh --db-only

# Chỉ backup cấu hình
./scripts/backup.sh --config-only

# Backup gia tăng (incremental)
./scripts/backup.sh --incremental

# Xem danh sách backups
./scripts/backup.sh --list

# Restore từ backup
./scripts/backup.sh --restore /path/to/backup

# Dọn dẹp backups cũ
./scripts/backup.sh --cleanup

# Hiển thị help
./scripts/backup.sh --help
```

## 📁 Cấu Trúc Backup

Mỗi backup được tổ chức theo cấu trúc sau:

```
backups/
├── 2025-06-19_13-22-59/           # Timestamp folder
│   ├── databases/                 # Database dumps
│   │   ├── postgresql_nextflow.sql.gz
│   │   ├── postgresql_nextflow_n8n.sql.gz
│   │   ├── postgresql_gitlabhq_production.sql.gz
│   │   ├── postgresql_nextflow_langflow.sql.gz
│   │   ├── postgresql_nextflow_stalwart_mail.sql.gz
│   │   └── mariadb_nextflow_wordpress.sql.gz
│   ├── volumes/                   # Docker volumes backup
│   │   ├── langflow_data.tar.gz
│   │   ├── wordpress_data.tar.gz
│   │   ├── gitlab_data.tar.gz
│   │   ├── postgres_data.tar.gz
│   │   ├── mariadb_data.tar.gz
│   │   ├── redis_data.tar.gz
│   │   ├── grafana_data.tar.gz
│   │   ├── prometheus_data.tar.gz
│   │   └── qdrant_data.tar.gz
│   ├── configs/                   # Configuration files
│   │   ├── config.tar.gz          # config/ directory
│   │   ├── cloudflared.tar.gz     # cloudflared/ directory
│   │   ├── stalwart.tar.gz        # stalwart/ directory
│   │   ├── langflow.tar.gz        # langflow/ directory
│   │   ├── wordpress.tar.gz       # wordpress/ directory
│   │   ├── gitlab.tar.gz          # gitlab/ directory
│   │   ├── docker-compose.yml     # Main compose file
│   │   ├── .env.example           # Environment template
│   │   ├── README.md              # Documentation
│   │   └── env_sanitized.txt      # .env without passwords
│   └── metadata.json              # Backup metadata
```

## ⚙️ Cấu Hình

### Biến Môi Trường

Bạn có thể tùy chỉnh hành vi backup bằng các biến môi trường:

```bash
# Số ngày giữ backup (mặc định: 30)
export BACKUP_RETENTION_DAYS=30

# Số lượng backup tối đa (mặc định: 10)
export BACKUP_MAX_COUNT=10

# Mức nén (1-9, mặc định: 6)
export COMPRESSION_LEVEL=6

# Loại nén (mặc định: gzip)
export COMPRESSION_TYPE=gzip

# Bật mã hóa backup (mặc định: false)
export BACKUP_ENCRYPT=false
export BACKUP_ENCRYPT_PASSWORD="your_password"
```

### Retention Policy

Script tự động dọn dẹp backups cũ theo 2 tiêu chí:

1. **Thời gian**: Xóa backups cũ hơn `BACKUP_RETENTION_DAYS` ngày
2. **Số lượng**: Giữ lại tối đa `BACKUP_MAX_COUNT` backups mới nhất

## 🔄 Restore Process

### Restore Toàn Bộ

```bash
./scripts/backup.sh --restore /path/to/backup/2025-06-19_13-22-59
```

### Restore Từng Phần

Bạn có thể restore từng phần bằng cách:

1. **Databases**: Sử dụng các file `.sql.gz` trong thư mục `databases/`
2. **Volumes**: Sử dụng các file `.tar.gz` trong thư mục `volumes/`
3. **Configs**: Copy files từ thư mục `configs/`

### Lưu Ý Quan Trọng

⚠️ **CẢNH BÁO**: Restore sẽ ghi đè dữ liệu hiện tại!

- Dừng tất cả services trước khi restore
- Backup dữ liệu hiện tại trước khi restore
- Kiểm tra tính tương thích của backup

## 🛡️ Bảo Mật

### Files Được Loại Trừ

Script tự động loại trừ các files nhạy cảm:

- `.env` (chứa passwords)
- `*.log` (log files)
- `*.pid`, `*.lock` (runtime files)
- `node_modules/` (dependencies)
- `.git/` (git repository)
- `backups/` (tránh backup recursive)

### .env Sanitized

Script tạo file `env_sanitized.txt` với:
- Loại bỏ tất cả dòng chứa: PASSWORD, SECRET, KEY, TOKEN
- Giữ lại cấu hình không nhạy cảm
- An toàn để chia sẻ hoặc debug

## 📊 Monitoring & Logging

### Metadata File

Mỗi backup có file `metadata.json` chứa:

```json
{
    "backup_info": {
        "timestamp": "2025-06-19_13-22-59",
        "type": "full",
        "start_time": "1734612179",
        "end_time": "1734612188",
        "duration": "9 seconds",
        "status": "success"
    },
    "system_info": {
        "hostname": "DESKTOP-ABC123",
        "os": "MINGW64_NT-10.0",
        "docker_version": "Docker version 24.0.7",
        "compose_version": "docker-compose version 1.29.2"
    },
    "backup_contents": {
        "databases": ["nextflow", "nextflow_n8n", "gitlabhq_production"],
        "volumes": ["langflow_data", "wordpress_data", "gitlab_data"],
        "configs": ["config", "cloudflared", "stalwart"]
    }
}
```

### Progress Indicators

Script hiển thị progress real-time:

```
🔄 [LOADING] Backup database: nextflow
✅ [SUCCESS] ✅ Backup thành công: nextflow (1.0K)
⚠️ [WARNING] ⚠️ Database 'keycloak' không tồn tại - bỏ qua
❌ [ERROR] ❌ Backup thất bại: nextflow_wordpress
```

## 🚨 Troubleshooting

### Lỗi Thường Gặp

#### 1. Docker không chạy
```
❌ Docker không sẵn sàng
```
**Giải pháp**: Khởi động Docker Desktop

#### 2. Không đủ dung lượng
```
⚠️ Dung lượng ổ cứng có thể không đủ
```
**Giải pháp**: Giải phóng dung lượng hoặc cleanup backups cũ

#### 3. Database connection failed
```
❌ Backup thất bại: nextflow_wordpress
```
**Giải pháp**: Kiểm tra container database và credentials

#### 4. Permission denied
```
❌ Không thể tạo thư mục: /path/to/backup
```
**Giải pháp**: Kiểm tra quyền ghi thư mục

### Debug Mode

Để debug chi tiết, sử dụng:

```bash
# Bật debug logging
export LOG_LEVEL=debug
./scripts/backup.sh --full

# Kiểm tra logs container
docker logs postgres
docker logs mariadb
```

## 📈 Best Practices

### 1. Backup Strategy

- **Daily**: Incremental backup cho dữ liệu thay đổi thường xuyên
- **Weekly**: Full backup cho toàn bộ hệ thống
- **Monthly**: Archive backup cho long-term storage

### 2. Testing

- Test restore process định kỳ
- Verify backup integrity
- Document restore procedures

### 3. Storage

- Store backups ở multiple locations
- Sử dụng external storage cho production
- Encrypt sensitive backups

### 4. Automation

```bash
# Crontab example - daily incremental backup
0 2 * * * /path/to/nextflow-docker/scripts/backup.sh --incremental

# Weekly full backup
0 1 * * 0 /path/to/nextflow-docker/scripts/backup.sh --full

# Monthly cleanup
0 3 1 * * /path/to/nextflow-docker/scripts/backup.sh --cleanup
```

## 🔗 Liên Quan

- [Deployment Guide](DEPLOYMENT-GUIDE.md)
- [Docker Compose Documentation](../docker-compose.yml)
- [Environment Configuration](.env.example)
- [Troubleshooting Guide](TROUBLESHOOTING.md)

---

**📞 Hỗ Trợ**: Nếu gặp vấn đề, vui lòng tạo issue trên GitLab repository hoặc liên hệ team phát triển.
