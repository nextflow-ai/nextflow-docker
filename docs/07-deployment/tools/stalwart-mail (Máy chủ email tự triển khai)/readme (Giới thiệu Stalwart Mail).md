# Stalwart Mail Server - Hướng Dẫn Triển Khai và Sử Dụng

## 📋 Mục Lục

1. [Giới Thiệu](#giới-thiệu)
2. [Tính Năng Chính](#tính-năng-chính)
3. [Yêu Cầu Hệ Thống](#yêu-cầu-hệ-thống)
4. [Cài Đặt và Triển Khai](#cài-đặt-và-triển-khai)
5. [Cấu Hình](#cấu-hình)
6. [Quản Lý và Vận Hành](#quản-lý-và-vận-hành)
7. [Bảo Mật](#bảo-mật)
8. [Monitoring và Logging](#monitoring-và-logging)
9. [Backup và Restore](#backup-và-restore)
10. [Troubleshooting](#troubleshooting)
11. [FAQ](#faq)

## 🚀 Giới Thiệu

Stalwart Mail Server là một mail server hiện đại, được viết bằng Rust, cung cấp đầy đủ các tính năng của một mail server enterprise với hiệu suất cao và bảo mật tốt. Trong hệ thống NextFlow, Stalwart được tích hợp để cung cấp dịch vụ email nội bộ hoàn chỉnh.

### Tại Sao Chọn Stalwart?

- **Hiệu suất cao**: Được viết bằng Rust, tối ưu hóa memory và CPU
- **Bảo mật tốt**: Hỗ trợ đầy đủ các tiêu chuẩn bảo mật email hiện đại
- **Dễ quản lý**: Web interface trực quan, API REST đầy đủ
- **Tích hợp tốt**: Hỗ trợ PostgreSQL, Redis, và các hệ thống hiện có
- **Modern protocols**: Hỗ trợ đầy đủ SMTP, IMAP, POP3, ManageSieve

## ⭐ Tính Năng Chính

### Email Protocols
- **SMTP**: Gửi và nhận email (ports 25, 587, 465)
- **IMAP**: Truy cập email với đồng bộ hóa (ports 143, 993)
- **POP3**: Tải email về client (ports 110, 995)
- **ManageSieve**: Quản lý email filters (port 4190)

### Bảo Mật
- **DKIM**: DomainKeys Identified Mail
- **SPF**: Sender Policy Framework
- **DMARC**: Domain-based Message Authentication
- **TLS/SSL**: Mã hóa kết nối
- **SASL**: Xác thực an toàn

### Anti-Spam & Anti-Virus
- **SpamAssassin**: Lọc spam tích hợp
- **ClamAV**: Quét virus email
- **Greylisting**: Chống spam tạm thời
- **Rate limiting**: Giới hạn tốc độ gửi

### Quản Lý
- **Web Admin Interface**: Giao diện quản trị web
- **REST API**: API đầy đủ cho automation
- **Multi-domain**: Hỗ trợ nhiều domain
- **User management**: Quản lý người dùng và mailbox

## 💻 Yêu Cầu Hệ Thống

### Phần Cứng Tối Thiểu
- **CPU**: 2 cores
- **RAM**: 1GB (khuyến nghị 2GB+)
- **Storage**: 10GB (tùy thuộc vào lượng email)
- **Network**: Kết nối internet ổn định

### Phần Mềm
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **PostgreSQL**: 13+ (đã có trong stack)
- **Redis**: 6+ (đã có trong stack)

### Ports Cần Thiết
```
25    - SMTP (incoming mail)
110   - POP3
143   - IMAP
465   - SMTPS (SSL)
587   - SMTP Submission
993   - IMAPS (SSL)
995   - POP3S (SSL)
4190  - ManageSieve
8080  - Web Admin Interface
```

## 🛠️ Cài Đặt và Triển Khai

### Bước 1: Chuẩn Bị Môi Trường

```bash
# Di chuyển đến thư mục dự án
cd /path/to/nextflow-docker

# Kiểm tra file .env
cp .env.example .env
# Chỉnh sửa các biến môi trường cần thiết
```

### Bước 2: Cấu Hình Biến Môi Trường

Thêm vào file `.env`:

```bash
# ================================
# STALWART MAIL SERVER CONFIG
# ================================

# Cấu hình cơ bản
MAIL_HOSTNAME=mail.yourdomain.com
MAIL_ADMIN_USER=admin
MAIL_ADMIN_PASSWORD=your_secure_password_here

# Database configuration
MAIL_DB_NAME=stalwart_mail
MAIL_DB_USER=stalwart
MAIL_DB_PASSWORD=stalwart_secure_password

# Port configuration (tùy chọn, sử dụng default nếu không set)
MAIL_SMTP_PORT=25
MAIL_SUBMISSION_PORT=587
MAIL_SUBMISSIONS_PORT=465
MAIL_IMAP_PORT=143
MAIL_IMAPS_PORT=993
MAIL_POP3_PORT=110
MAIL_POP3S_PORT=995
MAIL_ADMIN_PORT=8080
MAIL_SIEVE_PORT=4190

# Logging
MAIL_LOG_LEVEL=info
```

### Bước 3: Triển Khai Tự Động

```bash
# Sử dụng script triển khai tự động
./scripts/profiles/mail.sh
```

### Bước 4: Triển Khai Thủ Công (Nếu Cần)

```bash
# Khởi động services cơ bản trước
docker-compose --profile basic up -d

# Chờ PostgreSQL sẵn sàng
docker-compose logs -f postgres

# Khởi động mail server
docker-compose --profile mail up -d

# Kiểm tra trạng thái
docker-compose ps
```

## ⚙️ Cấu Hình

### Cấu Hình Cơ Bản

File cấu hình chính: `./stalwart/config/stalwart-mail.toml`

```toml
[server]
hostname = "mail.yourdomain.com"
bind = ["0.0.0.0:25", "0.0.0.0:587", "0.0.0.0:465"]

[server.tls]
certificate = "/etc/stalwart/certs/cert.pem"
private-key = "/etc/stalwart/certs/key.pem"

[storage]
type = "postgresql"
host = "postgres"
port = 5432
database = "stalwart_mail"
username = "stalwart"
password = "stalwart123"

[authentication]
type = "sql"

[smtp]
max-message-size = 52428800  # 50MB
max-recipients = 100
timeout = 300

[imap]
bind = ["0.0.0.0:143", "0.0.0.0:993"]
max-connections = 1000

[pop3]
bind = ["0.0.0.0:110", "0.0.0.0:995"]
max-connections = 100

[sieve]
bind = ["0.0.0.0:4190"]

[web]
bind = ["0.0.0.0:8080"]

[security]
dkim.enable = true
spf.enable = true
dmarc.enable = true

[anti-spam]
enable = true
threshold = 5.0
max-score = 10.0

[logging]
level = "info"
format = "json"
output = "/var/log/stalwart/stalwart.log"
```

### Cấu Hình SSL/TLS

#### Tự Tạo Self-Signed Certificate (Development)

```bash
# Tạo thư mục certs
mkdir -p ./stalwart/certs

# Tạo private key
openssl genrsa -out ./stalwart/certs/key.pem 2048

# Tạo certificate
openssl req -new -x509 -key ./stalwart/certs/key.pem \
    -out ./stalwart/certs/cert.pem -days 365 \
    -subj "/C=VN/ST=HCM/L=HCM/O=NextFlow/CN=mail.localhost"

# Set permissions
chmod 600 ./stalwart/certs/key.pem
chmod 644 ./stalwart/certs/cert.pem
```

#### Sử Dụng Let's Encrypt (Production)

```bash
# Cài đặt certbot
sudo apt-get install certbot

# Tạo certificate
sudo certbot certonly --standalone -d mail.yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/mail.yourdomain.com/fullchain.pem ./stalwart/certs/cert.pem
sudo cp /etc/letsencrypt/live/mail.yourdomain.com/privkey.pem ./stalwart/certs/key.pem

# Set ownership
sudo chown $(id -u):$(id -g) ./stalwart/certs/*
```

### Cấu Hình DNS Records

Để mail server hoạt động đúng, bạn cần cấu hình các DNS records:

```dns
# MX Record
yourdomain.com.    IN MX 10 mail.yourdomain.com.

# A Record
mail.yourdomain.com.    IN A    YOUR_SERVER_IP

# SPF Record
yourdomain.com.    IN TXT "v=spf1 mx ~all"

# DMARC Record
_dmarc.yourdomain.com.    IN TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com"

# DKIM Record (sẽ được tạo sau khi cấu hình DKIM)
_domainkey.yourdomain.com.    IN TXT "o=~"
```

## 👥 Quản Lý và Vận Hành

### Truy Cập Web Admin Interface

```
URL: http://localhost:8080
Username: admin
Password: [như trong .env]
```

### Quản Lý Người Dùng

#### Tạo User Qua Web Interface
1. Đăng nhập vào web admin
2. Vào **Users** → **Add User**
3. Điền thông tin:
   - Email: user@yourdomain.com
   - Password: secure_password
   - Quota: 1GB (tùy chọn)

#### Tạo User Qua API

```bash
# Tạo user mới
curl -X POST http://localhost:8080/api/v1/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "email": "user@yourdomain.com",
    "password": "secure_password",
    "quota": 1073741824,
    "enabled": true
  }'

# Liệt kê users
curl -X GET http://localhost:8080/api/v1/users \
  -H "Authorization: Bearer YOUR_API_TOKEN"

# Xóa user
curl -X DELETE http://localhost:8080/api/v1/users/user@yourdomain.com \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

### Quản Lý Domains

```bash
# Thêm domain mới
curl -X POST http://localhost:8080/api/v1/domains \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "domain": "newdomain.com",
    "enabled": true
  }'

# Liệt kê domains
curl -X GET http://localhost:8080/api/v1/domains \
  -H "Authorization: Bearer YOUR_API_TOKEN"
```

### Quản Lý Email Aliases

```bash
# Tạo alias
curl -X POST http://localhost:8080/api/v1/aliases \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{
    "alias": "info@yourdomain.com",
    "destinations": ["admin@yourdomain.com", "support@yourdomain.com"]
  }'
```

## 🔒 Bảo Mật

### Cấu Hình DKIM

```bash
# Tạo DKIM key
docker exec stalwart-mail stalwart-mail \
  --config /etc/stalwart/stalwart-mail.toml \
  dkim generate --domain yourdomain.com --selector default

# Lấy public key để thêm vào DNS
docker exec stalwart-mail stalwart-mail \
  --config /etc/stalwart/stalwart-mail.toml \
  dkim show --domain yourdomain.com --selector default
```

Thêm DKIM record vào DNS:
```dns
default._domainkey.yourdomain.com.    IN TXT "v=DKIM1; k=rsa; p=YOUR_PUBLIC_KEY_HERE"
```

### Cấu Hình Firewall

```bash
# Ubuntu/Debian với ufw
sudo ufw allow 25/tcp    # SMTP
sudo ufw allow 110/tcp   # POP3
sudo ufw allow 143/tcp   # IMAP
sudo ufw allow 465/tcp   # SMTPS
sudo ufw allow 587/tcp   # SMTP Submission
sudo ufw allow 993/tcp   # IMAPS
sudo ufw allow 995/tcp   # POP3S
sudo ufw allow 4190/tcp  # ManageSieve
sudo ufw allow 8080/tcp  # Web Admin (chỉ từ IP tin cậy)

# CentOS/RHEL với firewalld
sudo firewall-cmd --permanent --add-port=25/tcp
sudo firewall-cmd --permanent --add-port=110/tcp
sudo firewall-cmd --permanent --add-port=143/tcp
sudo firewall-cmd --permanent --add-port=465/tcp
sudo firewall-cmd --permanent --add-port=587/tcp
sudo firewall-cmd --permanent --add-port=993/tcp
sudo firewall-cmd --permanent --add-port=995/tcp
sudo firewall-cmd --permanent --add-port=4190/tcp
sudo firewall-cmd --reload
```

### Rate Limiting

Cấu hình trong `stalwart-mail.toml`:

```toml
[smtp.rate-limit]
# Giới hạn số email gửi per IP
per-ip = "100/1h"  # 100 emails per hour per IP

# Giới hạn số email gửi per user
per-user = "1000/1d"  # 1000 emails per day per user

# Giới hạn kết nối
max-connections-per-ip = 10
```

## 📊 Monitoring và Logging

### Xem Logs

```bash
# Logs container
docker-compose logs -f stalwart-mail

# Logs file
tail -f ./stalwart/logs/stalwart.log

# Logs với filter
docker-compose logs stalwart-mail | grep ERROR
```

### Metrics và Monitoring

Stalwart cung cấp metrics cho Prometheus:

```yaml
# Thêm vào prometheus.yml
scrape_configs:
  - job_name: 'stalwart-mail'
    static_configs:
      - targets: ['stalwart-mail:9090']
    scrape_interval: 30s
```

### Health Checks

```bash
# Kiểm tra health
docker exec stalwart-mail stalwart-mail \
  --config /etc/stalwart/stalwart-mail.toml --test

# Kiểm tra ports
netstat -tuln | grep -E ':(25|587|465|143|993|110|995|4190|8080)'

# Test SMTP
telnet localhost 25
# EHLO test.com
# QUIT

# Test IMAP
telnet localhost 143
# A001 CAPABILITY
# A002 LOGOUT
```

## 💾 Backup và Restore

### Backup Database

```bash
#!/bin/bash
# backup-mail.sh

BACKUP_DIR="./stalwart/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Tạo thư mục backup
mkdir -p "$BACKUP_DIR"

# Backup PostgreSQL database
docker exec postgres pg_dump -U stalwart stalwart_mail > \
  "$BACKUP_DIR/stalwart_mail_$DATE.sql"

# Backup configuration
tar -czf "$BACKUP_DIR/stalwart_config_$DATE.tar.gz" \
  ./stalwart/config/

# Backup mail data
tar -czf "$BACKUP_DIR/stalwart_data_$DATE.tar.gz" \
  ./stalwart/data/

echo "Backup completed: $DATE"
```

### Restore Database

```bash
#!/bin/bash
# restore-mail.sh

BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
  echo "Usage: $0 <backup_file.sql>"
  exit 1
fi

# Stop mail server
docker-compose stop stalwart-mail

# Restore database
docker exec -i postgres psql -U stalwart stalwart_mail < "$BACKUP_FILE"

# Start mail server
docker-compose start stalwart-mail

echo "Restore completed"
```

### Automated Backup Script

```bash
#!/bin/bash
# Thêm vào crontab: 0 2 * * * /path/to/backup-mail-auto.sh

BACKUP_DIR="./stalwart/backups"
RETENTION_DAYS=30

# Chạy backup
./backup-mail.sh

# Xóa backup cũ
find "$BACKUP_DIR" -name "*.sql" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
```

## 🔧 Troubleshooting

### Các Vấn Đề Thường Gặp

#### 1. Container Không Khởi Động

```bash
# Kiểm tra logs
docker-compose logs stalwart-mail

# Kiểm tra cấu hình
docker exec stalwart-mail stalwart-mail \
  --config /etc/stalwart/stalwart-mail.toml --test

# Kiểm tra permissions
ls -la ./stalwart/config/
ls -la ./stalwart/certs/
```

#### 2. Không Kết Nối Được Database

```bash
# Kiểm tra PostgreSQL
docker-compose ps postgres
docker-compose logs postgres

# Test kết nối
docker exec postgres psql -U stalwart -d stalwart_mail -c "SELECT 1;"
```

#### 3. Email Không Gửi Được

```bash
# Kiểm tra SMTP logs
docker-compose logs stalwart-mail | grep smtp

# Test SMTP
telnet localhost 587

# Kiểm tra DNS
nslookup mail.yourdomain.com
dig MX yourdomain.com
```

#### 4. SSL/TLS Issues

```bash
# Kiểm tra certificates
openssl x509 -in ./stalwart/certs/cert.pem -text -noout

# Test SSL connection
openssl s_client -connect localhost:993 -servername mail.yourdomain.com
```

#### 5. Performance Issues

```bash
# Kiểm tra resource usage
docker stats stalwart-mail

# Kiểm tra database performance
docker exec postgres psql -U stalwart -d stalwart_mail \
  -c "SELECT * FROM pg_stat_activity;"

# Optimize database
docker exec postgres psql -U stalwart -d stalwart_mail \
  -c "VACUUM ANALYZE;"
```

### Debug Commands

```bash
# Enable debug logging
# Sửa trong stalwart-mail.toml:
# [logging]
# level = "debug"

# Restart với debug
docker-compose restart stalwart-mail

# Theo dõi logs real-time
docker-compose logs -f stalwart-mail

# Kiểm tra network connectivity
docker exec stalwart-mail netstat -tuln
docker exec stalwart-mail ss -tuln
```

## ❓ FAQ

### Q: Làm thế nào để thay đổi mật khẩu admin?

**A:** Có thể thay đổi qua web interface hoặc API:

```bash
curl -X PUT http://localhost:8080/api/v1/users/admin \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -d '{"password": "new_secure_password"}'
```

### Q: Có thể sử dụng external database không?

**A:** Có, chỉnh sửa cấu hình database trong `stalwart-mail.toml`:

```toml
[storage]
type = "postgresql"
host = "external-postgres.example.com"
port = 5432
database = "stalwart_mail"
username = "stalwart"
password = "password"
```

### Q: Làm thế nào để migrate từ mail server khác?

**A:** Stalwart hỗ trợ import từ nhiều định dạng:

```bash
# Import từ mbox
docker exec stalwart-mail stalwart-mail \
  import --format mbox --input /path/to/mailbox.mbox \
  --account user@domain.com

# Import từ Maildir
docker exec stalwart-mail stalwart-mail \
  import --format maildir --input /path/to/Maildir \
  --account user@domain.com
```

### Q: Có thể setup cluster không?

**A:** Stalwart hỗ trợ clustering với shared storage:

```toml
[cluster]
enabled = true
nodes = ["node1.example.com", "node2.example.com"]
shared-storage = true
```

### Q: Làm thế nào để tối ưu performance?

**A:** Một số cách tối ưu:

1. **Tăng memory cho container**:
```yaml
deploy:
  resources:
    limits:
      memory: 2G
    reservations:
      memory: 1G
```

2. **Tối ưu PostgreSQL**:
```sql
-- Tăng shared_buffers
ALTER SYSTEM SET shared_buffers = '256MB';
-- Tăng work_mem
ALTER SYSTEM SET work_mem = '4MB';
SELECT pg_reload_conf();
```

3. **Cấu hình connection pooling**:
```toml
[storage]
max-connections = 100
min-connections = 10
```

### Q: Có thể tích hợp với LDAP/Active Directory không?

**A:** Có, cấu hình LDAP authentication:

```toml
[authentication]
type = "ldap"
url = "ldap://ldap.example.com:389"
bind-dn = "cn=admin,dc=example,dc=com"
bind-password = "password"
user-base = "ou=users,dc=example,dc=com"
user-filter = "(mail=%u)"
```

---

## 📞 Hỗ Trợ

Nếu gặp vấn đề, vui lòng:

1. Kiểm tra logs: `docker-compose logs stalwart-mail`
2. Xem documentation: [Stalwart Official Docs](https://stalw.art/docs/)
3. Tạo issue trong repository dự án
4. Liên hệ team NextFlow

---

**Phiên bản tài liệu**: 1.0  
**Cập nhật lần cuối**: 2025  
**Tác giả**: NextFlow Team