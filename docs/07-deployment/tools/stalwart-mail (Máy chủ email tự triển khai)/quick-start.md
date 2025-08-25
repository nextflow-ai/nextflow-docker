# Stalwart Mail Server - Hướng Dẫn Cài Đặt Nhanh

## 🚀 Cài Đặt Trong 5 Phút

### Bước 1: Chuẩn Bị

```bash
# Clone repository (nếu chưa có)
git clone <repository-url>
cd nextflow-docker

# Copy file environment
cp .env.example .env
```

### Bước 2: Cấu Hình Cơ Bản

Chỉnh sửa file `.env`:

```bash
# Thêm vào cuối file .env
MAIL_HOSTNAME=mail.localhost
MAIL_ADMIN_USER=admin
MAIL_ADMIN_PASSWORD=changeme123
MAIL_DB_NAME=stalwart_mail
MAIL_DB_USER=stalwart
MAIL_DB_PASSWORD=stalwart123
```

### Bước 3: Triển Khai

```bash
# Chạy script tự động
./scripts/profiles/mail.sh

# HOẶC triển khai thủ công
docker-compose --profile basic up -d
docker-compose --profile mail up -d
```

### Bước 4: Kiểm Tra

```bash
# Kiểm tra trạng thái
docker-compose ps

# Kiểm tra logs
docker-compose logs stalwart-mail
```

### Bước 5: Truy Cập

- **Web Admin**: http://localhost:8080
- **Username**: admin
- **Password**: changeme123

## 📧 Test Email

### Tạo User Đầu Tiên

1. Truy cập http://localhost:8080
2. Đăng nhập với admin/changeme123
3. Vào **Users** → **Add User**
4. Tạo user: `test@localhost` với password `test123`

### Cấu Hình Email Client

#### Thunderbird/Outlook

**IMAP Settings:**

- Server: localhost
- Port: 993 (SSL) hoặc 143 (STARTTLS)
- Username: test@localhost
- Password: test123

**SMTP Settings:**

- Server: localhost
- Port: 587 (STARTTLS) hoặc 465 (SSL)
- Username: test@localhost
- Password: test123

#### Gmail/Mobile Apps

**Incoming (IMAP):**

```
Server: localhost
Port: 993
Security: SSL/TLS
Username: test@localhost
Password: test123
```

**Outgoing (SMTP):**

```
Server: localhost
Port: 587
Security: STARTTLS
Username: test@localhost
Password: test123
```

## 🔧 Commands Hữu Ích

```bash
# Xem logs real-time
docker-compose logs -f stalwart-mail

# Restart mail server
docker-compose restart stalwart-mail

# Stop mail server
docker-compose stop stalwart-mail

# Backup database
docker exec postgres pg_dump -U stalwart stalwart_mail > backup.sql

# Test SMTP
telnet localhost 587

# Test IMAP
telnet localhost 143
```

## ⚠️ Lưu Ý Quan Trọng

1. **Đổi mật khẩu mặc định** ngay sau khi cài đặt
2. **Cấu hình SSL certificates** cho production
3. **Setup DNS records** (MX, SPF, DKIM, DMARC) cho domain thật
4. **Mở firewall ports** nếu cần truy cập từ bên ngoài
5. **Backup định kỳ** database và cấu hình

## 🆘 Troubleshooting Nhanh

### Container không khởi động

```bash
docker-compose logs stalwart-mail
# Kiểm tra lỗi trong logs
```

### Không kết nối được email client

```bash
# Kiểm tra ports
netstat -tuln | grep -E ':(587|993|143)'

# Test kết nối
telnet localhost 587
telnet localhost 993
```

### Database lỗi

```bash
# Kiểm tra PostgreSQL
docker-compose logs postgres

# Test kết nối database
docker exec postgres psql -U stalwart -d stalwart_mail -c "SELECT 1;"
```

### Reset hoàn toàn

```bash
# Dừng tất cả
docker-compose down

# Xóa volumes (CẢNH BÁO: Mất dữ liệu)
docker volume rm nextflow-docker_stalwart_config
docker volume rm nextflow-docker_stalwart_data
docker volume rm nextflow-docker_stalwart_logs

# Khởi động lại
docker-compose --profile mail up -d
```

## 📚 Tài Liệu Chi Tiết

Xem file [README.md](./README.md) để có hướng dẫn đầy đủ về:

- Cấu hình nâng cao
- Bảo mật
- Monitoring
- Backup/Restore
- Production deployment
