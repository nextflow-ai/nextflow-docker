# TROUBLESHOOTING - KẾT NỐI

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn khắc phục sự cố liên quan đến kết nối trong hệ thống NextFlow CRM-AI. Các vấn đề kết nối có thể bao gồm kết nối đến cơ sở dữ liệu, Redis, API bên ngoài, n8n, Flowise, và các dịch vụ khác.

## 2. VẤN ĐỀ KẾT NỐI CƠ SỞ DỮ LIỆU

### 2.1. Không thể kết nối đến PostgreSQL

#### Triệu chứng

- Lỗi "Connection refused" khi khởi động ứng dụng
- Lỗi "ECONNREFUSED" trong log
- Thông báo "Unable to connect to the database"

#### Nguyên nhân có thể

1. PostgreSQL không chạy
2. Thông tin kết nối không chính xác
3. Tường lửa chặn kết nối
4. PostgreSQL không lắng nghe trên địa chỉ IP đúng
5. Lỗi xác thực

#### Giải pháp

##### 2.1.1. Kiểm tra PostgreSQL đang chạy

```bash
# Ubuntu/Debian
sudo systemctl status postgresql

# CentOS/RHEL
sudo systemctl status postgresql-13

# Docker
docker ps | grep postgres
```

Nếu PostgreSQL không chạy, khởi động lại:

```bash
# Ubuntu/Debian
sudo systemctl start postgresql

# CentOS/RHEL
sudo systemctl start postgresql-13

# Docker
docker start NextFlow-postgres
```

##### 2.1.2. Kiểm tra thông tin kết nối

Xác minh thông tin kết nối trong file `.env`:

```
DB_HOST=localhost
DB_PORT=5432
DB_USER=NextFlow
DB_PASSWORD=your_secure_password
DB_NAME=NextFlow_crm
```

Thử kết nối trực tiếp đến PostgreSQL:

```bash
psql -h localhost -p 5432 -U NextFlow -d NextFlow_crm
```

##### 2.1.3. Kiểm tra cấu hình PostgreSQL

Kiểm tra file `postgresql.conf`:

```bash
# Ubuntu/Debian
sudo nano /etc/postgresql/13/main/postgresql.conf

# CentOS/RHEL
sudo nano /var/lib/pgsql/13/data/postgresql.conf
```

Đảm bảo PostgreSQL lắng nghe trên tất cả các địa chỉ IP:

```
listen_addresses = '*'
```

Kiểm tra file `pg_hba.conf`:

```bash
# Ubuntu/Debian
sudo nano /etc/postgresql/13/main/pg_hba.conf

# CentOS/RHEL
sudo nano /var/lib/pgsql/13/data/pg_hba.conf
```

Thêm dòng sau để cho phép kết nối từ ứng dụng:

```
host    all             all             0.0.0.0/0               md5
host    all             all             ::/0                    md5
```

Khởi động lại PostgreSQL:

```bash
# Ubuntu/Debian
sudo systemctl restart postgresql

# CentOS/RHEL
sudo systemctl restart postgresql-13
```

##### 2.1.4. Kiểm tra tường lửa

```bash
# Ubuntu/Debian
sudo ufw status
sudo ufw allow 5432/tcp

# CentOS/RHEL
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload
```

##### 2.1.5. Kiểm tra logs PostgreSQL

```bash
# Ubuntu/Debian
sudo tail -f /var/log/postgresql/postgresql-13-main.log

# CentOS/RHEL
sudo tail -f /var/lib/pgsql/13/data/log/postgresql-*.log
```

### 2.2. Lỗi xác thực PostgreSQL

#### Triệu chứng

- Lỗi "password authentication failed for user"
- Lỗi "role does not exist"

#### Nguyên nhân có thể

1. Mật khẩu không chính xác
2. Người dùng không tồn tại
3. Phương thức xác thực không đúng

#### Giải pháp

##### 2.2.1. Đặt lại mật khẩu người dùng

```bash
# Đăng nhập vào PostgreSQL với quyền superuser
sudo -u postgres psql

# Đặt lại mật khẩu
ALTER USER NextFlow WITH PASSWORD 'new_secure_password';

# Thoát
\q
```

##### 2.2.2. Tạo người dùng nếu chưa tồn tại

```bash
# Đăng nhập vào PostgreSQL với quyền superuser
sudo -u postgres psql

# Tạo người dùng
CREATE USER NextFlow WITH PASSWORD 'your_secure_password';

# Cấp quyền
ALTER USER NextFlow WITH SUPERUSER;

# Thoát
\q
```

##### 2.2.3. Kiểm tra phương thức xác thực

Kiểm tra file `pg_hba.conf` và đảm bảo phương thức xác thực là `md5` hoặc `scram-sha-256`:

```
host    all             all             127.0.0.1/32            md5
```

### 2.3. Lỗi "database does not exist"

#### Triệu chứng

- Lỗi "database NextFlow_crm does not exist"

#### Nguyên nhân có thể

1. Cơ sở dữ liệu chưa được tạo
2. Tên cơ sở dữ liệu không chính xác

#### Giải pháp

##### 2.3.1. Tạo cơ sở dữ liệu

```bash
# Đăng nhập vào PostgreSQL với quyền superuser
sudo -u postgres psql

# Tạo cơ sở dữ liệu
CREATE DATABASE NextFlow_crm OWNER NextFlow;

# Thoát
\q
```

##### 2.3.2. Kiểm tra tên cơ sở dữ liệu

```bash
# Đăng nhập vào PostgreSQL với quyền superuser
sudo -u postgres psql

# Liệt kê các cơ sở dữ liệu
\l

# Thoát
\q
```

## 3. VẤN ĐỀ KẾT NỐI REDIS

### 3.1. Không thể kết nối đến Redis

#### Triệu chứng

- Lỗi "Connection refused" khi khởi động ứng dụng
- Lỗi "ECONNREFUSED" trong log
- Thông báo "Redis connection failed"

#### Nguyên nhân có thể

1. Redis không chạy
2. Thông tin kết nối không chính xác
3. Tường lửa chặn kết nối
4. Redis không lắng nghe trên địa chỉ IP đúng

#### Giải pháp

##### 3.1.1. Kiểm tra Redis đang chạy

```bash
# Ubuntu/Debian/CentOS/RHEL
sudo systemctl status redis

# Docker
docker ps | grep redis
```

Nếu Redis không chạy, khởi động lại:

```bash
# Ubuntu/Debian/CentOS/RHEL
sudo systemctl start redis

# Docker
docker start NextFlow-redis
```

##### 3.1.2. Kiểm tra thông tin kết nối

Xác minh thông tin kết nối trong file `.env`:

```
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_secure_password
REDIS_DB=0
```

Thử kết nối trực tiếp đến Redis:

```bash
redis-cli -h localhost -p 6379 -a your_secure_password ping
```

##### 3.1.3. Kiểm tra cấu hình Redis

Kiểm tra file `redis.conf`:

```bash
# Ubuntu/Debian
sudo nano /etc/redis/redis.conf

# CentOS/RHEL
sudo nano /etc/redis.conf
```

Đảm bảo Redis lắng nghe trên tất cả các địa chỉ IP:

```
bind 0.0.0.0
```

Đảm bảo mật khẩu được cấu hình:

```
requirepass your_secure_password
```

Khởi động lại Redis:

```bash
sudo systemctl restart redis
```

##### 3.1.4. Kiểm tra tường lửa

```bash
# Ubuntu/Debian
sudo ufw status
sudo ufw allow 6379/tcp

# CentOS/RHEL
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=6379/tcp
sudo firewall-cmd --reload
```

### 3.2. Lỗi xác thực Redis

#### Triệu chứng

- Lỗi "NOAUTH Authentication required"
- Lỗi "WRONGPASS invalid password"

#### Nguyên nhân có thể

1. Mật khẩu không chính xác
2. Redis yêu cầu xác thực nhưng không cung cấp mật khẩu
3. Redis không yêu cầu xác thực nhưng cung cấp mật khẩu

#### Giải pháp

##### 3.2.1. Kiểm tra và đặt lại mật khẩu Redis

```bash
# Kết nối đến Redis
redis-cli

# Đặt lại mật khẩu
CONFIG SET requirepass "new_secure_password"
CONFIG REWRITE

# Thoát
exit
```

##### 3.2.2. Cập nhật cấu hình Redis

Kiểm tra file `redis.conf` và đảm bảo cấu hình mật khẩu:

```
requirepass your_secure_password
```

##### 3.2.3. Cập nhật biến môi trường

Cập nhật file `.env` với mật khẩu Redis chính xác:

```
REDIS_PASSWORD=your_secure_password
```

## 4. VẤN ĐỀ KẾT NỐI API BÊN NGOÀI

### 4.1. Không thể kết nối đến API bên ngoài

#### Triệu chứng

- Lỗi "Connection timeout" khi gọi API bên ngoài
- Lỗi "ETIMEDOUT" trong log
- Thông báo "Failed to fetch from external API"

#### Nguyên nhân có thể

1. API bên ngoài không khả dụng
2. Thông tin kết nối không chính xác
3. Tường lửa chặn kết nối
4. Vấn đề mạng
5. Lỗi xác thực

#### Giải pháp

##### 4.1.1. Kiểm tra API bên ngoài có khả dụng

Sử dụng công cụ như curl để kiểm tra API:

```bash
curl -v https://api.external-service.com/endpoint
```

##### 4.1.2. Kiểm tra thông tin kết nối

Xác minh URL API và thông tin xác thực trong file `.env`:

```
EXTERNAL_API_URL=https://api.external-service.com
EXTERNAL_API_KEY=your_api_key
```

##### 4.1.3. Kiểm tra tường lửa và proxy

Đảm bảo tường lửa cho phép kết nối đến API bên ngoài:

```bash
# Ubuntu/Debian
sudo ufw status

# CentOS/RHEL
sudo firewall-cmd --list-all
```

Nếu sử dụng proxy, kiểm tra cấu hình proxy:

```
HTTP_PROXY=http://proxy.example.com:8080
HTTPS_PROXY=http://proxy.example.com:8080
NO_PROXY=localhost,127.0.0.1
```

##### 4.1.4. Kiểm tra kết nối mạng

```bash
ping api.external-service.com
traceroute api.external-service.com
```

##### 4.1.5. Kiểm tra logs

```bash
tail -f /path/to/NextFlow-crm/logs/application.log
```

### 4.2. Lỗi xác thực API

#### Triệu chứng

- Lỗi "401 Unauthorized" khi gọi API bên ngoài
- Lỗi "403 Forbidden" khi gọi API bên ngoài
- Thông báo "Invalid API key" hoặc "Authentication failed"

#### Nguyên nhân có thể

1. API key không chính xác
2. API key hết hạn
3. API key không có quyền truy cập
4. Định dạng xác thực không đúng

#### Giải pháp

##### 4.2.1. Kiểm tra API key

Xác minh API key trong file `.env`:

```
EXTERNAL_API_KEY=your_api_key
```

Tạo API key mới nếu cần thiết.

##### 4.2.2. Kiểm tra định dạng xác thực

Đảm bảo định dạng xác thực đúng:

```javascript
// Bearer Token
headers: {
  'Authorization': `Bearer ${apiKey}`
}

// API Key in header
headers: {
  'X-API-Key': apiKey
}

// API Key in query parameter
url: `https://api.external-service.com/endpoint?api_key=${apiKey}`
```

##### 4.2.3. Kiểm tra quyền truy cập

Kiểm tra quyền truy cập của API key trong trang quản lý của dịch vụ bên ngoài.

## 5. VẤN ĐỀ KẾT NỐI N8N

### 5.1. Không thể kết nối đến n8n

#### Triệu chứng

- Lỗi "Connection refused" khi gọi n8n API
- Lỗi "ECONNREFUSED" trong log
- Thông báo "Failed to connect to n8n"

#### Nguyên nhân có thể

1. n8n không chạy
2. Thông tin kết nối không chính xác
3. Tường lửa chặn kết nối
4. n8n không lắng nghe trên địa chỉ IP đúng
5. Lỗi xác thực

#### Giải pháp

##### 5.1.1. Kiểm tra n8n đang chạy

```bash
# Docker
docker ps | grep n8n

# Kiểm tra logs
docker logs NextFlow-n8n
```

Nếu n8n không chạy, khởi động lại:

```bash
# Docker Compose
cd /opt/NextFlow/n8n
docker-compose up -d
```

##### 5.1.2. Kiểm tra thông tin kết nối

Xác minh thông tin kết nối trong file `.env`:

```
N8N_URL=https://n8n.yourdomain.com
N8N_API_KEY=your_n8n_api_key
```

Thử kết nối trực tiếp đến n8n:

```bash
curl -v https://n8n.yourdomain.com/api/v1/workflows -H "X-N8N-API-KEY: your_n8n_api_key"
```

##### 5.1.3. Kiểm tra cấu hình n8n

Kiểm tra cấu hình n8n trong file `docker-compose.yml`:

```yaml
environment:
  - N8N_BASIC_AUTH_ACTIVE=true
  - N8N_BASIC_AUTH_USER=admin
  - N8N_BASIC_AUTH_PASSWORD=your_secure_password
  - N8N_HOST=n8n.yourdomain.com
  - N8N_PORT=5678
  - N8N_PROTOCOL=https
```

##### 5.1.4. Kiểm tra logs n8n

```bash
docker logs NextFlow-n8n
```

### 5.2. Lỗi xác thực n8n

#### Triệu chứng

- Lỗi "401 Unauthorized" khi gọi n8n API
- Thông báo "Invalid API key" hoặc "Authentication failed"

#### Nguyên nhân có thể

1. API key không chính xác
2. API key không có quyền truy cập
3. Định dạng xác thực không đúng

#### Giải pháp

##### 5.2.1. Tạo API key mới trong n8n

1. Đăng nhập vào n8n
2. Truy cập **Settings > API Keys**
3. Tạo API key mới
4. Cập nhật file `.env` với API key mới:

```
N8N_API_KEY=your_new_n8n_api_key
```

##### 5.2.2. Kiểm tra định dạng xác thực

Đảm bảo định dạng xác thực đúng:

```javascript
headers: {
  'X-N8N-API-KEY': n8nApiKey
}
```

## 6. VẤN ĐỀ KẾT NỐI FLOWISE

### 6.1. Không thể kết nối đến Flowise

#### Triệu chứng

- Lỗi "Connection refused" khi gọi Flowise API
- Lỗi "ECONNREFUSED" trong log
- Thông báo "Failed to connect to Flowise"

#### Nguyên nhân có thể

1. Flowise không chạy
2. Thông tin kết nối không chính xác
3. Tường lửa chặn kết nối
4. Flowise không lắng nghe trên địa chỉ IP đúng
5. Lỗi xác thực

#### Giải pháp

##### 6.1.1. Kiểm tra Flowise đang chạy

```bash
# Docker
docker ps | grep flowise

# Kiểm tra logs
docker logs NextFlow-flowise
```

Nếu Flowise không chạy, khởi động lại:

```bash
# Docker Compose
cd /opt/NextFlow/flowise
docker-compose up -d
```

##### 6.1.2. Kiểm tra thông tin kết nối

Xác minh thông tin kết nối trong file `.env`:

```
FLOWISE_URL=https://flowise.yourdomain.com
FLOWISE_API_KEY=your_flowise_api_key
```

Thử kết nối trực tiếp đến Flowise:

```bash
curl -v https://flowise.yourdomain.com/api/v1/chatflows -H "Authorization: Bearer your_flowise_api_key"
```

##### 6.1.3. Kiểm tra cấu hình Flowise

Kiểm tra cấu hình Flowise trong file `docker-compose.yml`:

```yaml
environment:
  - PORT=3000
  - FLOWISE_USERNAME=admin
  - FLOWISE_PASSWORD=your_secure_password
  - APIKEY_PATH=/app/apikeys
```

##### 6.1.4. Kiểm tra logs Flowise

```bash
docker logs NextFlow-flowise
```

### 6.2. Lỗi xác thực Flowise

#### Triệu chứng

- Lỗi "401 Unauthorized" khi gọi Flowise API
- Thông báo "Invalid API key" hoặc "Authentication failed"

#### Nguyên nhân có thể

1. API key không chính xác
2. API key không có quyền truy cập
3. Định dạng xác thực không đúng

#### Giải pháp

##### 6.2.1. Tạo API key mới trong Flowise

1. Đăng nhập vào Flowise
2. Truy cập **Settings > API Keys**
3. Tạo API key mới
4. Cập nhật file `.env` với API key mới:

```
FLOWISE_API_KEY=your_new_flowise_api_key
```

##### 6.2.2. Kiểm tra định dạng xác thực

Đảm bảo định dạng xác thực đúng:

```javascript
headers: {
  'Authorization': `Bearer ${flowiseApiKey}`
}
```

## 7. CÔNG CỤ CHẨN ĐOÁN KẾT NỐI

### 7.1. Network Analyzer

Network Analyzer là công cụ trong NextFlow CRM-AI giúp chẩn đoán vấn đề kết nối:

1. Truy cập **Cài đặt > Hệ thống > Network Analyzer**
2. Chọn dịch vụ cần kiểm tra (PostgreSQL, Redis, n8n, Flowise, v.v.)
3. Nhấp vào **Chạy kiểm tra**

### 7.2. Health Check

Health Check kiểm tra sức khỏe các kết nối:

1. Truy cập **Cài đặt > Hệ thống > Health Check**
2. Xem trạng thái các kết nối

### 7.3. Công cụ dòng lệnh

#### 7.3.1. Kiểm tra kết nối mạng

```bash
# Kiểm tra kết nối đến host
ping hostname

# Kiểm tra đường dẫn mạng
traceroute hostname

# Kiểm tra cổng
nc -zv hostname port

# Kiểm tra DNS
nslookup hostname
```

#### 7.3.2. Kiểm tra kết nối PostgreSQL

```bash
# Kiểm tra kết nối
psql -h hostname -p port -U username -d database -c "SELECT 1"

# Kiểm tra phiên bản
psql -h hostname -p port -U username -d database -c "SELECT version()"
```

#### 7.3.3. Kiểm tra kết nối Redis

```bash
# Kiểm tra kết nối
redis-cli -h hostname -p port -a password ping

# Kiểm tra thông tin
redis-cli -h hostname -p port -a password info
```

#### 7.3.4. Kiểm tra kết nối HTTP

```bash
# Kiểm tra kết nối HTTP
curl -v https://hostname/path

# Kiểm tra với xác thực
curl -v -H "Authorization: Bearer token" https://hostname/path
```

## 8. TÀI LIỆU THAM KHẢO

1. [Tài liệu PostgreSQL](https://www.postgresql.org/docs/)
2. [Tài liệu Redis](https://redis.io/documentation)
3. [Tài liệu n8n](https://docs.n8n.io/)
4. [Tài liệu Flowise](https://docs.flowiseai.com/)
5. [Tài liệu Nginx](https://nginx.org/en/docs/)
6. [Tài liệu Docker](https://docs.docker.com/)
