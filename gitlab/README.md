# GitLab Configuration Directory

## 📋 Tổng Quan

Thư mục này chứa tất cả cấu hình và tài nguyên cần thiết cho GitLab instance của NextFlow CRM-AI.

## 📁 Cấu Trúc Thư Mục

```
gitlab/
├── README.md              # Tài liệu này
├── config/                # Cấu hình GitLab
│   └── gitlab.rb          # File cấu hình chính
├── docker/                # Docker customization
│   └── Dockerfile         # Custom GitLab image
├── scripts/               # Ruby scripts hỗ trợ
│   ├── README.md          # Hướng dẫn scripts
│   ├── create_root_user.rb    # Tạo root user
│   ├── check_root_user.rb     # Kiểm tra root user
│   ├── reset_root_password.rb # Reset password
│   └── gitlab_status.rb       # Kiểm tra status
├── backups/               # GitLab backups
├── data/                  # GitLab runtime data (auto-generated)
└── logs/                  # GitLab logs (auto-generated)
```

## ⚙️ Cấu Hình

### gitlab.rb
File cấu hình chính của GitLab với các tối ưu cho NextFlow CRM-AI:
- Vietnamese locale support : hỗ trợ ngôn ngữ tiếng Việt
- Performance tuning : tối ưu hiệu suất
- Security configurations : cấu hình bảo mật
- Email settings : cài đặt email
- Backup configurations : cấu hình sao lưu

### Dockerfile
Custom GitLab image : Docker image tùy chỉnh với:
- Vietnamese language pack : gói ngôn ngữ tiếng Việt
- Performance optimizations : tối ưu hiệu suất
- Security enhancements : cải thiện bảo mật
- Custom configurations : cấu hình tùy chỉnh

## 🔧 Scripts Hỗ Trợ

### create_root_user.rb
Tạo root user với thông tin tùy chỉnh:
```bash
docker exec gitlab gitlab-rails runner /path/to/create_root_user.rb
```

### check_root_user.rb
Kiểm tra thông tin root user:
```bash
docker exec gitlab gitlab-rails runner /path/to/check_root_user.rb
```

### reset_root_password.rb
Reset password cho root user:
```bash
docker exec gitlab gitlab-rails runner /path/to/reset_root_password.rb
```

### gitlab_status.rb
Kiểm tra trạng thái GitLab chi tiết:
```bash
docker exec gitlab gitlab-rails runner /path/to/gitlab_status.rb
```

## 💾 Backup & Data

### backups/
- Chứa GitLab backup files : file sao lưu (.tar)
- Được quản lý bởi GitLab Manager : công cụ quản lý GitLab
- Automatic cleanup : dọn dẹp tự động theo retention policy : chính sách lưu trữ

### data/
- Runtime data : dữ liệu thời gian chạy của GitLab
- Được tạo tự động khi container : thùng chứa ứng dụng chạy
- Chứa repositories : kho mã nguồn, uploads : file tải lên, artifacts : sản phẩm build

### logs/
- GitLab application logs : nhật ký ứng dụng
- Được tạo tự động khi container : thùng chứa chạy
- Rotation : xoay vòng tự động

## 🚀 Sử Dụng

### Quản Lý Qua GitLab Manager
```bash
# Cài đặt GitLab
./scripts/gitlab-manager.sh install

# Kiểm tra status
./scripts/gitlab-manager.sh status

# Tạo backup
./scripts/gitlab-manager.sh backup

# Restore backup
./scripts/gitlab-manager.sh restore
```

### Truy Cập Trực Tiếp
```bash
# Vào GitLab container
docker exec -it gitlab bash

# Chạy GitLab commands
gitlab-ctl status
gitlab-ctl reconfigure
gitlab-rake gitlab:check
```

## 🔒 Bảo Mật

### File Permissions
- Config files: 644
- Scripts: 755
- Data directory: 755
- Logs directory: 755

### Sensitive Data
- Passwords được lưu trong environment variables
- Không hardcode credentials trong files
- SSL/TLS configuration trong gitlab.rb

## 📊 Monitoring

### Health Checks : kiểm tra sức khỏe hệ thống
```bash
# GitLab health : sức khỏe GitLab
curl http://localhost:8088/-/health

# Readiness check : kiểm tra sẵn sàng
curl http://localhost:8088/-/readiness

# Liveness check : kiểm tra hoạt động
curl http://localhost:8088/-/liveness
```

### Logs Monitoring : giám sát nhật ký
```bash
# GitLab application logs : nhật ký ứng dụng GitLab
docker exec gitlab tail -f /var/log/gitlab/gitlab-rails/production.log

# Nginx access logs : nhật ký truy cập Nginx
docker exec gitlab tail -f /var/log/gitlab/nginx/gitlab_access.log

# System logs : nhật ký hệ thống
docker logs gitlab
```

## 🔧 Troubleshooting

### Common Issues

#### GitLab Won't Start
1. Check logs: `docker logs gitlab`
2. Check disk space: `df -h`
3. Check memory: `free -h`
4. Reconfigure: `docker exec gitlab gitlab-ctl reconfigure`

#### Database Issues : vấn đề cơ sở dữ liệu
1. Check PostgreSQL : kiểm tra PostgreSQL: `docker exec postgres pg_isready`
2. Check connections : kiểm tra kết nối: `docker exec gitlab gitlab-rake gitlab:check`
3. Run migrations : chạy migration: `./scripts/gitlab-manager.sh migrate`

#### Performance Issues : vấn đề hiệu suất
1. Check resources : kiểm tra tài nguyên: `docker stats gitlab`
2. Check GitLab status : kiểm tra trạng thái GitLab: `./scripts/gitlab-manager.sh status`
3. Review configuration : xem lại cấu hình: `gitlab/config/gitlab.rb`

### Recovery Procedures

#### Complete Reset
```bash
# Reset everything (DANGEROUS)
./scripts/gitlab-manager.sh reset-all
```

#### Restore from Backup
```bash
# List available backups
ls gitlab/backups/

# Restore specific backup
./scripts/gitlab-manager.sh restore
```

## 📞 Hỗ Trợ

- **GitLab Manager**: `./scripts/gitlab-manager.sh help`
- **Documentation**: `docs/GITLAB_MANAGER_GUIDE.md`
- **Support**: nextflow.vn@gmail.com

---

**NextFlow CRM-AI Team**  
*GitLab Configuration v2.0 - 2025*
