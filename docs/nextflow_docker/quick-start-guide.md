# 🚀 Hướng dẫn Bắt đầu Nhanh - NextFlow Docker

## 📋 Tổng quan

Hướng dẫn này giúp bạn triển khai và chạy hệ thống NextFlow Docker trong vòng 15-30 phút.

## ⚡ Yêu cầu Hệ thống

### 🖥️ Phần cứng Tối thiểu
- **CPU**: 4 cores (Intel i5 hoặc AMD Ryzen 5)
- **RAM**: 8GB (khuyến nghị 16GB)
- **Storage**: 50GB SSD khả dụng
- **Network**: Kết nối internet ổn định

### 🛠️ Phần mềm Cần thiết
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+
- **Git**: Version 2.30+
- **OS**: Ubuntu 20.04+, CentOS 8+, hoặc Windows 10/11

## 📥 Bước 1: Tải về và Chuẩn bị

### 1.1. Clone Repository
```bash
# Clone dự án từ repository
git clone https://github.com/your-org/nextflow-docker.git
cd nextflow-docker

# Kiểm tra branch hiện tại
git branch
```

### 1.2. Kiểm tra Docker
```bash
# Kiểm tra Docker đã cài đặt
docker --version
docker-compose --version

# Kiểm tra Docker service đang chạy
sudo systemctl status docker
```

## ⚙️ Bước 2: Cấu hình Môi trường

### 2.1. Copy Environment Files
```bash
# Copy file cấu hình mẫu
cp .env.example .env
cp docker-compose.override.yml.example docker-compose.override.yml
```

### 2.2. Cấu hình Cơ bản
Chỉnh sửa file `.env`:
```bash
# Database Configuration
POSTGRES_DB=nextflow_db
POSTGRES_USER=nextflow_user
POSTGRES_PASSWORD=your_secure_password_here

# Redis Configuration
REDIS_PASSWORD=your_redis_password_here

# Application Configuration
APP_ENV=production
APP_DEBUG=false
APP_URL=http://localhost:8080

# Security
JWT_SECRET=your_jwt_secret_here
ENCRYPTION_KEY=your_32_character_encryption_key
```

## 🚀 Bước 3: Triển khai Hệ thống

### 3.1. Build và Start Services
```bash
# Build tất cả services
docker-compose build

# Start hệ thống (chế độ background)
docker-compose up -d

# Kiểm tra trạng thái containers
docker-compose ps
```

### 3.2. Kiểm tra Logs
```bash
# Xem logs tất cả services
docker-compose logs -f

# Xem logs service cụ thể
docker-compose logs -f nextflow-app
docker-compose logs -f nextflow-db
```

## 🔍 Bước 4: Xác minh Triển khai

### 4.1. Health Check
```bash
# Kiểm tra health của tất cả services
curl http://localhost:8080/health

# Kiểm tra database connection
docker-compose exec nextflow-db psql -U nextflow_user -d nextflow_db -c "SELECT version();"

# Kiểm tra Redis
docker-compose exec redis redis-cli ping
```

### 4.2. Truy cập Ứng dụng
- **Web Interface**: http://localhost:8080
- **API Documentation**: http://localhost:8080/api/docs
- **Admin Panel**: http://localhost:8080/admin
- **Monitoring**: http://localhost:3000 (Grafana)

## 👤 Bước 5: Tạo Tài khoản Admin

### 5.1. Chạy Migration
```bash
# Chạy database migrations
docker-compose exec nextflow-app php artisan migrate

# Seed dữ liệu mẫu (tùy chọn)
docker-compose exec nextflow-app php artisan db:seed
```

### 5.2. Tạo Admin User
```bash
# Tạo user admin đầu tiên
docker-compose exec nextflow-app php artisan user:create-admin \
  --email=admin@yourdomain.com \
  --password=SecurePassword123 \
  --name="System Administrator"
```

## 🔧 Bước 6: Cấu hình Bổ sung

### 6.1. SSL/TLS (Production)
```bash
# Cài đặt Certbot cho Let's Encrypt
sudo apt install certbot python3-certbot-nginx

# Tạo SSL certificate
sudo certbot --nginx -d yourdomain.com
```

### 6.2. Backup Configuration
```bash
# Tạo thư mục backup
mkdir -p ./backups

# Setup cron job cho backup tự động
crontab -e
# Thêm dòng: 0 2 * * * /path/to/backup-script.sh
```

## 📊 Monitoring và Logging

### 📈 Grafana Dashboard
1. Truy cập: http://localhost:3000
2. Login: admin/admin (đổi password ngay)
3. Import dashboard từ `./monitoring/dashboards/`

### 📝 Log Management
```bash
# Xem logs realtime
docker-compose logs -f --tail=100

# Xem logs của service cụ thể
docker-compose logs nextflow-app | grep ERROR

# Rotate logs để tránh đầy disk
docker system prune -f
```

## 🚨 Troubleshooting Cơ bản

### ❌ Container không start
```bash
# Kiểm tra lỗi chi tiết
docker-compose logs [service-name]

# Restart service cụ thể
docker-compose restart [service-name]

# Rebuild nếu cần
docker-compose build --no-cache [service-name]
```

### 🔌 Lỗi kết nối Database
```bash
# Kiểm tra database container
docker-compose exec nextflow-db pg_isready

# Reset database nếu cần
docker-compose down
docker volume rm nextflow-docker_postgres_data
docker-compose up -d
```

### 🌐 Lỗi Network
```bash
# Kiểm tra network Docker
docker network ls
docker network inspect nextflow-docker_default

# Recreate network nếu cần
docker-compose down
docker network prune
docker-compose up -d
```

## 🔄 Cập nhật Hệ thống

### 📦 Update Code
```bash
# Pull latest changes
git pull origin main

# Rebuild và restart
docker-compose build
docker-compose up -d

# Chạy migrations nếu có
docker-compose exec nextflow-app php artisan migrate
```

### 🗄️ Backup trước Update
```bash
# Backup database
docker-compose exec nextflow-db pg_dump -U nextflow_user nextflow_db > backup_$(date +%Y%m%d).sql

# Backup volumes
docker run --rm -v nextflow-docker_app_data:/data -v $(pwd):/backup alpine tar czf /backup/app_data_$(date +%Y%m%d).tar.gz /data
```

## 📚 Tài liệu Tham khảo

### 📖 Tài liệu Chi tiết
- [Security Recommendations](./security-recommendations.md) - Bảo mật hệ thống
- [Performance Optimization](./performance-optimization.md) - Tối ưu hiệu suất
- [Infrastructure Improvements](./infrastructure-improvements.md) - Cải thiện hạ tầng
- [Implementation Roadmap](./implementation-roadmap.md) - Lộ trình triển khai

### 🔗 Links Hữu ích
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)

## 🆘 Hỗ trợ

### 📞 Liên hệ
- **Email**: support@nextflow.com
- **Documentation**: https://docs.nextflow.com
- **Community**: https://community.nextflow.com
- **Issues**: https://github.com/your-org/nextflow-docker/issues

### ⏰ Thời gian Hỗ trợ
- **Business Hours**: 9:00 - 18:00 (GMT+7)
- **Emergency**: 24/7 cho khách hàng Enterprise
- **Response Time**: < 4 giờ cho Priority issues

---

## ✅ Checklist Hoàn thành

- [ ] Docker và Docker Compose đã cài đặt
- [ ] Repository đã clone và cấu hình
- [ ] File .env đã được cấu hình
- [ ] Tất cả containers đang chạy healthy
- [ ] Database migrations đã chạy thành công
- [ ] Admin user đã được tạo
- [ ] Web interface có thể truy cập
- [ ] API endpoints hoạt động bình thường
- [ ] Monitoring dashboard đã setup
- [ ] Backup strategy đã cấu hình
- [ ] SSL certificate đã cài đặt (Production)

**🎉 Chúc mừng! Hệ thống NextFlow Docker đã sẵn sàng sử dụng.**

---

**Cập nhật**: 2024 | **Version**: 1.0.0 | **NextFlow Development Team**