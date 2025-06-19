# N8N - CÀI ĐẶT

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn chi tiết về cách cài đặt và cấu hình n8n trong hệ thống NextFlow CRM. n8n là một nền tảng tự động hóa quy trình làm việc (workflow automation) mã nguồn mở, cho phép kết nối các ứng dụng, dịch vụ và API khác nhau để tự động hóa các tác vụ mà không cần viết mã.

## 2. YÊU CẦU HỆ THỐNG

### 2.1. Yêu cầu phần cứng

- CPU: 2 cores trở lên
- RAM: 4GB trở lên
- Ổ cứng: 20GB trở lên

### 2.2. Yêu cầu phần mềm

- Docker 20.10.x trở lên
- Docker Compose 2.0.x trở lên
- Node.js 16.x trở lên (nếu cài đặt không sử dụng Docker)
- PostgreSQL 13.0 trở lên (cho lưu trữ workflow)
- Nginx hoặc Apache (cho reverse proxy)

## 3. CÀI ĐẶT N8N

### 3.1. Cài đặt sử dụng Docker (Khuyến nghị)

#### 3.1.1. Tạo thư mục cho n8n

```bash
# Tạo thư mục cho n8n
mkdir -p /opt/NextFlow/n8n
cd /opt/NextFlow/n8n
```

#### 3.1.2. Tạo file docker-compose.yml

```bash
# Tạo file docker-compose.yml
nano docker-compose.yml
```

Thêm nội dung sau vào file `docker-compose.yml`:

```yaml
version: '3'

services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_secure_password
      - N8N_HOST=n8n.yourdomain.com
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - N8N_ENCRYPTION_KEY=your_encryption_key
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=NextFlow-postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=NextFlow
      - DB_POSTGRESDB_PASSWORD=your_secure_password
      - WEBHOOK_URL=https://n8n.yourdomain.com/
      - EXECUTIONS_PROCESS=main
      - EXECUTIONS_TIMEOUT=300
      - EXECUTIONS_TIMEOUT_MAX=3600
      - EXECUTIONS_DATA_SAVE_ON_ERROR=all
      - EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
      - EXECUTIONS_DATA_SAVE_ON_PROGRESS=true
      - EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true
      - EXECUTIONS_DATA_PRUNE=true
      - EXECUTIONS_DATA_MAX_AGE=168
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
      - N8N_EMAIL_MODE=smtp
      - N8N_SMTP_HOST=smtp.yourmailserver.com
      - N8N_SMTP_PORT=587
      - N8N_SMTP_USER=your_email@yourdomain.com
      - N8N_SMTP_PASS=your_email_password
      - N8N_SMTP_SENDER=noreply@yourdomain.com
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - NextFlow-network

volumes:
  n8n_data:

networks:
  NextFlow-network:
    external: true
```

Thay thế các giá trị sau bằng giá trị thực tế của bạn:
- `your_secure_password`: Mật khẩu an toàn cho n8n
- `n8n.yourdomain.com`: Tên miền của bạn
- `your_encryption_key`: Khóa mã hóa (tạo ngẫu nhiên)
- `NextFlow-postgres`: Tên host PostgreSQL
- `your_email@yourdomain.com`: Email của bạn
- `your_email_password`: Mật khẩu email của bạn

#### 3.1.3. Tạo mạng Docker

```bash
# Tạo mạng Docker nếu chưa tồn tại
docker network create NextFlow-network
```

#### 3.1.4. Tạo cơ sở dữ liệu cho n8n

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Tạo cơ sở dữ liệu cho n8n
CREATE DATABASE n8n OWNER NextFlow;

# Thoát
\q
```

#### 3.1.5. Khởi động n8n

```bash
# Khởi động n8n
docker-compose up -d
```

#### 3.1.6. Kiểm tra n8n đang chạy

```bash
# Kiểm tra container n8n
docker ps | grep n8n

# Kiểm tra logs n8n
docker logs NextFlow-n8n
```

### 3.2. Cài đặt sử dụng npm (Không khuyến nghị cho môi trường sản xuất)

#### 3.2.1. Cài đặt n8n

```bash
# Cài đặt n8n
npm install -g n8n
```

#### 3.2.2. Cấu hình biến môi trường

```bash
# Tạo file .env
nano ~/.n8n/.env
```

Thêm nội dung sau vào file `.env`:

```
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password
N8N_HOST=n8n.yourdomain.com
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_ENCRYPTION_KEY=your_encryption_key
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=localhost
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=NextFlow
DB_POSTGRESDB_PASSWORD=your_secure_password
WEBHOOK_URL=https://n8n.yourdomain.com/
EXECUTIONS_PROCESS=main
EXECUTIONS_TIMEOUT=300
EXECUTIONS_TIMEOUT_MAX=3600
EXECUTIONS_DATA_SAVE_ON_ERROR=all
EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
EXECUTIONS_DATA_SAVE_ON_PROGRESS=true
EXECUTIONS_DATA_SAVE_MANUAL_EXECUTIONS=true
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=168
GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
```

#### 3.2.3. Khởi động n8n

```bash
# Khởi động n8n
n8n start
```

#### 3.2.4. Cài đặt n8n như một dịch vụ

```bash
# Cài đặt pm2
npm install -g pm2

# Khởi động n8n với pm2
pm2 start n8n -- start

# Đảm bảo n8n tự động khởi động khi server reboot
pm2 startup
pm2 save
```

## 4. CẤU HÌNH NGINX

### 4.1. Cài đặt Nginx

```bash
# Cài đặt Nginx
sudo apt update
sudo apt install -y nginx
```

### 4.2. Cấu hình Nginx cho n8n

```bash
# Tạo file cấu hình Nginx cho n8n
sudo nano /etc/nginx/sites-available/n8n
```

Thêm nội dung sau vào file cấu hình:

```nginx
server {
    listen 80;
    server_name n8n.yourdomain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name n8n.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/n8n.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/n8n.yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;

    location / {
        proxy_pass http://localhost:5678;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 4.3. Kích hoạt cấu hình Nginx

```bash
# Tạo symbolic link
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/

# Kiểm tra cấu hình
sudo nginx -t

# Khởi động lại Nginx
sudo systemctl restart nginx
```

### 4.4. Cài đặt Let's Encrypt

```bash
# Cài đặt Certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Tạo chứng chỉ SSL
sudo certbot --nginx -d n8n.yourdomain.com

# Cấu hình tự động gia hạn
sudo systemctl status certbot.timer
```

## 5. CẤU HÌNH N8N

### 5.1. Cấu hình cơ bản

Sau khi cài đặt, truy cập n8n tại `https://n8n.yourdomain.com` và đăng nhập với thông tin:
- Username: admin
- Password: your_secure_password

#### 5.1.1. Cấu hình thông tin cá nhân

1. Nhấp vào biểu tượng người dùng ở góc trên bên phải
2. Chọn **Settings**
3. Cập nhật thông tin cá nhân

#### 5.1.2. Cấu hình email

1. Nhấp vào biểu tượng người dùng ở góc trên bên phải
2. Chọn **Settings**
3. Chọn **Email**
4. Cấu hình thông tin SMTP

### 5.2. Cấu hình API

#### 5.2.1. Tạo API Key

1. Nhấp vào biểu tượng người dùng ở góc trên bên phải
2. Chọn **Settings**
3. Chọn **API**
4. Nhấp vào **Create API Key**
5. Nhập tên cho API Key
6. Sao chép API Key và lưu lại

#### 5.2.2. Cấu hình API trong NextFlow CRM

Cập nhật file `.env` của NextFlow CRM với thông tin API n8n:

```
N8N_URL=https://n8n.yourdomain.com
N8N_API_KEY=your_n8n_api_key
```

### 5.3. Cấu hình Credentials

#### 5.3.1. Thêm Credentials cho NextFlow CRM

1. Truy cập **Credentials**
2. Nhấp vào **Create New**
3. Chọn **HTTP**
4. Nhập thông tin:
   - Name: NextFlow CRM
   - Authentication: Bearer Token
   - Token: your_NextFlow_api_token
5. Nhấp vào **Save**

#### 5.3.2. Thêm Credentials cho Email

1. Truy cập **Credentials**
2. Nhấp vào **Create New**
3. Chọn **SMTP**
4. Nhập thông tin:
   - Name: Email SMTP
   - User: your_email@yourdomain.com
   - Password: your_email_password
   - Host: smtp.yourmailserver.com
   - Port: 587
   - SSL/TLS: STARTTLS
5. Nhấp vào **Save**

#### 5.3.3. Thêm Credentials cho Database

1. Truy cập **Credentials**
2. Nhấp vào **Create New**
3. Chọn **PostgreSQL**
4. Nhập thông tin:
   - Name: NextFlow Database
   - Host: NextFlow-postgres
   - Database: NextFlow_crm
   - User: NextFlow
   - Password: your_secure_password
   - Port: 5432
   - SSL: Disable
5. Nhấp vào **Save**

## 6. BẢO MẬT N8N

### 6.1. Bảo mật cơ bản

#### 6.1.1. Sử dụng xác thực cơ bản

Đảm bảo xác thực cơ bản được kích hoạt trong cấu hình n8n:

```
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password
```

#### 6.1.2. Sử dụng HTTPS

Đảm bảo n8n được cấu hình để sử dụng HTTPS:

```
N8N_PROTOCOL=https
```

#### 6.1.3. Giới hạn truy cập IP

Cấu hình Nginx để giới hạn truy cập IP:

```nginx
# Chỉ cho phép truy cập từ IP cụ thể
allow 192.168.1.100;
allow 10.0.0.0/24;
deny all;
```

### 6.2. Bảo mật nâng cao

#### 6.2.1. Sử dụng khóa mã hóa

Đảm bảo khóa mã hóa được cấu hình:

```
N8N_ENCRYPTION_KEY=your_encryption_key
```

#### 6.2.2. Bảo vệ Credentials

1. Sử dụng biến môi trường thay vì lưu trữ thông tin nhạy cảm trong workflow
2. Giới hạn quyền truy cập vào Credentials

#### 6.2.3. Giám sát logs

```bash
# Giám sát logs n8n
docker logs -f NextFlow-n8n
```

## 7. NÂNG CẤP N8N

### 7.1. Nâng cấp sử dụng Docker

```bash
# Di chuyển đến thư mục n8n
cd /opt/NextFlow/n8n

# Kéo image mới nhất
docker-compose pull

# Khởi động lại n8n với image mới
docker-compose up -d
```

### 7.2. Nâng cấp sử dụng npm

```bash
# Nâng cấp n8n
npm update -g n8n

# Khởi động lại n8n
pm2 restart n8n
```

## 8. SAO LƯU VÀ KHÔI PHỤC

### 8.1. Sao lưu dữ liệu

#### 8.1.1. Sao lưu cơ sở dữ liệu

```bash
# Sao lưu cơ sở dữ liệu n8n
pg_dump -h localhost -U NextFlow -d n8n > n8n_backup_$(date +%Y%m%d).sql
```

#### 8.1.2. Sao lưu volume Docker

```bash
# Dừng n8n
docker-compose stop n8n

# Sao lưu volume
docker run --rm -v n8n_data:/source -v $(pwd):/backup alpine tar -czf /backup/n8n_data_$(date +%Y%m%d).tar.gz -C /source .

# Khởi động lại n8n
docker-compose start n8n
```

### 8.2. Khôi phục dữ liệu

#### 8.2.1. Khôi phục cơ sở dữ liệu

```bash
# Khôi phục cơ sở dữ liệu n8n
psql -h localhost -U NextFlow -d n8n < n8n_backup_20230101.sql
```

#### 8.2.2. Khôi phục volume Docker

```bash
# Dừng n8n
docker-compose stop n8n

# Khôi phục volume
docker run --rm -v n8n_data:/target -v $(pwd):/backup alpine sh -c "rm -rf /target/* && tar -xzf /backup/n8n_data_20230101.tar.gz -C /target"

# Khởi động lại n8n
docker-compose start n8n
```

## 9. XỬ LÝ SỰ CỐ

### 9.1. Không thể kết nối đến n8n

#### 9.1.1. Kiểm tra n8n đang chạy

```bash
# Kiểm tra container n8n
docker ps | grep n8n

# Kiểm tra logs n8n
docker logs NextFlow-n8n
```

#### 9.1.2. Kiểm tra cấu hình Nginx

```bash
# Kiểm tra cấu hình Nginx
sudo nginx -t

# Kiểm tra logs Nginx
sudo tail -f /var/log/nginx/error.log
```

#### 9.1.3. Kiểm tra tường lửa

```bash
# Kiểm tra tường lửa
sudo ufw status
```

### 9.2. Lỗi kết nối cơ sở dữ liệu

#### 9.2.1. Kiểm tra kết nối PostgreSQL

```bash
# Kiểm tra kết nối PostgreSQL
psql -h localhost -U NextFlow -d n8n -c "SELECT 1"
```

#### 9.2.2. Kiểm tra cấu hình cơ sở dữ liệu

Kiểm tra cấu hình cơ sở dữ liệu trong file `docker-compose.yml`:

```yaml
environment:
  - DB_TYPE=postgresdb
  - DB_POSTGRESDB_HOST=NextFlow-postgres
  - DB_POSTGRESDB_PORT=5432
  - DB_POSTGRESDB_DATABASE=n8n
  - DB_POSTGRESDB_USER=NextFlow
  - DB_POSTGRESDB_PASSWORD=your_secure_password
```

### 9.3. Lỗi webhook

#### 9.3.1. Kiểm tra cấu hình webhook

Kiểm tra cấu hình webhook trong file `docker-compose.yml`:

```yaml
environment:
  - WEBHOOK_URL=https://n8n.yourdomain.com/
```

#### 9.3.2. Kiểm tra logs webhook

```bash
# Kiểm tra logs n8n
docker logs NextFlow-n8n | grep webhook
```

## 10. TÀI LIỆU THAM KHẢO

1. [Tài liệu chính thức n8n](https://docs.n8n.io/)
2. [Tài liệu Docker](https://docs.docker.com/)
3. [Tài liệu Nginx](https://nginx.org/en/docs/)
4. [Tài liệu PostgreSQL](https://www.postgresql.org/docs/)
5. [Tài liệu Let's Encrypt](https://letsencrypt.org/docs/)
