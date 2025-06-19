# HƯỚNG DẪN CẤU HÌNH HỆ THỐNG

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn chi tiết về cách cấu hình hệ thống NextFlow CRM sau khi đã cài đặt. Hướng dẫn này bao gồm các bước cấu hình cơ sở dữ liệu, kết nối API, tích hợp với các dịch vụ bên ngoài, và thiết lập các thông số hệ thống.

## 2. CẤU HÌNH MÔI TRƯỜNG

### 2.1. Tạo file .env

File `.env` chứa các biến môi trường cần thiết cho hệ thống. Sao chép file mẫu và chỉnh sửa:

```bash
# Di chuyển đến thư mục NextFlow CRM
cd /path/to/NextFlow-crm

# Sao chép file mẫu
cp .env.example .env

# Chỉnh sửa file .env
nano .env
```

### 2.2. Cấu hình biến môi trường

Dưới đây là các biến môi trường quan trọng cần cấu hình:

```
# Cấu hình ứng dụng
NODE_ENV=production
PORT=3000
API_URL=https://api.yourdomain.com
FRONTEND_URL=https://yourdomain.com
APP_SECRET=your_app_secret_key

# Cấu hình cơ sở dữ liệu
DB_HOST=localhost
DB_PORT=5432
DB_USER=NextFlow
DB_PASSWORD=your_secure_password
DB_NAME=NextFlow_crm
DB_SCHEMA=public
DB_SSL=false

# Cấu hình Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_secure_password
REDIS_DB=0

# Cấu hình JWT
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=1d
JWT_REFRESH_SECRET=your_jwt_refresh_secret_key
JWT_REFRESH_EXPIRES_IN=7d

# Cấu hình email
MAIL_HOST=smtp.yourmailserver.com
MAIL_PORT=587
MAIL_SECURE=false
MAIL_USER=your_email@yourdomain.com
MAIL_PASSWORD=your_email_password
MAIL_FROM=noreply@yourdomain.com
MAIL_FROM_NAME=NextFlow CRM

# Cấu hình tích hợp
N8N_URL=https://n8n.yourdomain.com
N8N_API_KEY=your_n8n_api_key
FLOWISE_URL=https://flowise.yourdomain.com
FLOWISE_API_KEY=your_flowise_api_key

# Cấu hình tải lên file
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760 # 10MB
ALLOWED_FILE_TYPES=jpg,jpeg,png,gif,pdf,doc,docx,xls,xlsx,zip

# Cấu hình bảo mật
CORS_ORIGIN=https://yourdomain.com
RATE_LIMIT_WINDOW=15 # 15 phút
RATE_LIMIT_MAX=100 # 100 yêu cầu
SESSION_SECRET=your_session_secret_key
COOKIE_SECRET=your_cookie_secret_key
```

Thay thế các giá trị mẫu bằng giá trị thực tế của bạn.

## 3. CẤU HÌNH CƠ SỞ DỮ LIỆU

### 3.1. Khởi tạo cơ sở dữ liệu

```bash
# Di chuyển đến thư mục NextFlow CRM
cd /path/to/NextFlow-crm

# Chạy migration để tạo cấu trúc database
pnpm db:migrate

# Chạy seeder để tạo dữ liệu ban đầu
pnpm db:seed
```

### 3.2. Cấu hình PostgreSQL

Cấu hình PostgreSQL để tối ưu hóa hiệu suất:

```bash
# Mở file cấu hình PostgreSQL
sudo nano /etc/postgresql/13/main/postgresql.conf
```

Thêm hoặc chỉnh sửa các thông số sau:

```
# Bộ nhớ
shared_buffers = 2GB                  # 25% RAM cho server chuyên dụng
work_mem = 64MB                       # Tùy thuộc vào số lượng kết nối
maintenance_work_mem = 256MB          # Cho các tác vụ bảo trì

# Checkpoint
checkpoint_timeout = 15min            # Thời gian giữa các checkpoint
checkpoint_completion_target = 0.9    # Mục tiêu hoàn thành checkpoint
max_wal_size = 2GB                    # Kích thước WAL tối đa

# Planner
random_page_cost = 1.1                # Cho SSD
effective_cache_size = 6GB            # 75% RAM cho server chuyên dụng

# Logging
log_min_duration_statement = 200ms    # Ghi log các truy vấn chậm
```

Khởi động lại PostgreSQL:

```bash
sudo systemctl restart postgresql
```

### 3.3. Cấu hình Redis

Cấu hình Redis để tối ưu hóa hiệu suất:

```bash
# Mở file cấu hình Redis
sudo nano /etc/redis/redis.conf
```

Thêm hoặc chỉnh sửa các thông số sau:

```
# Bộ nhớ
maxmemory 2gb
maxmemory-policy allkeys-lru

# Persistence
save 900 1
save 300 10
save 60 10000

# Bảo mật
requirepass your_secure_password
```

Khởi động lại Redis:

```bash
sudo systemctl restart redis
```

## 4. CẤU HÌNH NGINX

### 4.1. Tạo cấu hình Nginx

```bash
# Tạo file cấu hình Nginx cho NextFlow CRM
sudo nano /etc/nginx/sites-available/NextFlow
```

Thêm nội dung sau:

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;

    # Frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # API
    location /api {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files
    location /uploads {
        alias /path/to/NextFlow-crm/uploads;
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
    }

    # Gzip compression
    gzip on;
    gzip_comp_level 5;
    gzip_min_length 256;
    gzip_proxied any;
    gzip_vary on;
    gzip_types
        application/javascript
        application/json
        application/x-javascript
        application/xml
        application/xml+rss
        text/css
        text/javascript
        text/plain
        text/xml;
}
```

### 4.2. Kích hoạt cấu hình Nginx

```bash
# Tạo symbolic link
sudo ln -s /etc/nginx/sites-available/NextFlow /etc/nginx/sites-enabled/

# Kiểm tra cấu hình
sudo nginx -t

# Khởi động lại Nginx
sudo systemctl restart nginx
```

### 4.3. Cấu hình Nginx cho n8n và Flowise

```bash
# Tạo file cấu hình Nginx cho n8n
sudo nano /etc/nginx/sites-available/n8n
```

Thêm nội dung sau:

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

```bash
# Tạo file cấu hình Nginx cho Flowise
sudo nano /etc/nginx/sites-available/flowise
```

Thêm nội dung sau:

```nginx
server {
    listen 80;
    server_name flowise.yourdomain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name flowise.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/flowise.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/flowise.yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384;

    location / {
        proxy_pass http://localhost:3100;
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

Kích hoạt cấu hình:

```bash
# Tạo symbolic link
sudo ln -s /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/flowise /etc/nginx/sites-enabled/

# Kiểm tra cấu hình
sudo nginx -t

# Khởi động lại Nginx
sudo systemctl restart nginx
```

## 5. CẤU HÌNH N8N

### 5.1. Tạo file docker-compose.yml cho n8n

```bash
# Tạo thư mục cho n8n
mkdir -p /opt/NextFlow/n8n
cd /opt/NextFlow/n8n

# Tạo file docker-compose.yml
nano docker-compose.yml
```

Thêm nội dung sau:

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

### 5.2. Khởi động n8n

```bash
# Khởi động n8n
docker-compose up -d
```

### 5.3. Cấu hình n8n trong NextFlow CRM

Cập nhật file `.env` với thông tin n8n:

```
N8N_URL=https://n8n.yourdomain.com
N8N_API_KEY=your_n8n_api_key
```

## 6. CẤU HÌNH FLOWISE

### 6.1. Tạo file docker-compose.yml cho Flowise

```bash
# Tạo thư mục cho Flowise
mkdir -p /opt/NextFlow/flowise
cd /opt/NextFlow/flowise

# Tạo file docker-compose.yml
nano docker-compose.yml
```

Thêm nội dung sau:

```yaml
version: '3'

services:
  flowise:
    image: flowiseai/flowise:latest
    restart: always
    ports:
      - "3100:3000"
    environment:
      - PORT=3000
      - FLOWISE_USERNAME=admin
      - FLOWISE_PASSWORD=your_secure_password
      - APIKEY_PATH=/app/apikeys
      - SECRETKEY_PATH=/app/secrets
      - DATABASE_PATH=/app/database
      - FLOWISE_SECRETKEY_OVERWRITE=your_secret_key
      - DEBUG=true
      - LANGCHAIN_TRACING_V2=true
      - LANGCHAIN_ENDPOINT=https://api.smith.langchain.com
      - LANGCHAIN_API_KEY=your_langchain_api_key
      - LANGCHAIN_PROJECT=NextFlow-crm
    volumes:
      - flowise_data:/app
    networks:
      - NextFlow-network

volumes:
  flowise_data:

networks:
  NextFlow-network:
    external: true
```

### 6.2. Khởi động Flowise

```bash
# Khởi động Flowise
docker-compose up -d
```

### 6.3. Cấu hình Flowise trong NextFlow CRM

Cập nhật file `.env` với thông tin Flowise:

```
FLOWISE_URL=https://flowise.yourdomain.com
FLOWISE_API_KEY=your_flowise_api_key
```

## 7. CẤU HÌNH EMAIL

### 7.1. Cấu hình SMTP

Cập nhật file `.env` với thông tin SMTP:

```
MAIL_HOST=smtp.yourmailserver.com
MAIL_PORT=587
MAIL_SECURE=false
MAIL_USER=your_email@yourdomain.com
MAIL_PASSWORD=your_email_password
MAIL_FROM=noreply@yourdomain.com
MAIL_FROM_NAME=NextFlow CRM
```

### 7.2. Cấu hình mẫu email

Các mẫu email được lưu trữ trong thư mục `templates/emails`. Bạn có thể tùy chỉnh các mẫu này theo nhu cầu:

```bash
# Di chuyển đến thư mục mẫu email
cd /path/to/NextFlow-crm/templates/emails

# Chỉnh sửa mẫu email
nano welcome.hbs
nano password-reset.hbs
nano verification.hbs
```

## 8. CẤU HÌNH BẢO MẬT

### 8.1. Cấu hình CORS

Cập nhật file `.env` với thông tin CORS:

```
CORS_ORIGIN=https://yourdomain.com
```

Hoặc cho phép nhiều origin:

```
CORS_ORIGIN=https://yourdomain.com,https://admin.yourdomain.com
```

### 8.2. Cấu hình Rate Limiting

Cập nhật file `.env` với thông tin rate limiting:

```
RATE_LIMIT_WINDOW=15 # 15 phút
RATE_LIMIT_MAX=100 # 100 yêu cầu
```

### 8.3. Cấu hình Helmet

Helmet được sử dụng để bảo vệ ứng dụng khỏi các lỗ hổng bảo mật phổ biến. Cấu hình Helmet trong file `src/config/security.ts`:

```typescript
import helmet from 'helmet';

export const securityConfig = {
  helmet: helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
        styleSrc: ["'self'", "'unsafe-inline'", 'https://fonts.googleapis.com'],
        imgSrc: ["'self'", 'data:', 'https://storage.googleapis.com'],
        fontSrc: ["'self'", 'https://fonts.gstatic.com'],
        connectSrc: ["'self'", 'https://api.yourdomain.com'],
      },
    },
    xssFilter: true,
    noSniff: true,
    referrerPolicy: { policy: 'same-origin' },
  }),
};
```

## 9. CẤU HÌNH MULTI-TENANT

### 9.1. Cấu hình Database Schema

Cập nhật file `.env` với thông tin schema:

```
DB_SCHEMA=public
DB_ENABLE_MULTI_TENANT=true
DB_TENANT_FIELD=organization_id
```

### 9.2. Cấu hình Tenant Resolver

Cấu hình tenant resolver trong file `src/config/tenant.ts`:

```typescript
export const tenantConfig = {
  resolvers: [
    {
      type: 'header',
      headerName: 'x-tenant-id',
      priority: 1,
    },
    {
      type: 'jwt',
      jwtField: 'organization_id',
      priority: 2,
    },
    {
      type: 'domain',
      domainMapping: {
        'tenant1.yourdomain.com': 'tenant1_id',
        'tenant2.yourdomain.com': 'tenant2_id',
      },
      priority: 3,
    },
  ],
  defaultTenant: 'default_tenant_id',
};
```

## 10. CẤU HÌNH LOGGING

### 10.1. Cấu hình Winston Logger

Cấu hình logger trong file `src/config/logger.ts`:

```typescript
import winston from 'winston';
import 'winston-daily-rotate-file';

const fileTransport = new winston.transports.DailyRotateFile({
  filename: 'logs/application-%DATE%.log',
  datePattern: 'YYYY-MM-DD',
  zippedArchive: true,
  maxSize: '20m',
  maxFiles: '14d',
});

export const loggerConfig = {
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      ),
    }),
    fileTransport,
  ],
};
```

### 10.2. Cấu hình Audit Logging

Cấu hình audit logging trong file `src/config/audit.ts`:

```typescript
export const auditConfig = {
  enabled: true,
  excludedPaths: ['/api/health', '/api/metrics'],
  excludedMethods: ['GET'],
  sensitiveFields: ['password', 'token', 'secret', 'credit_card'],
};
```

## 11. KIỂM TRA CẤU HÌNH

### 11.1. Kiểm tra kết nối cơ sở dữ liệu

```bash
# Di chuyển đến thư mục NextFlow CRM
cd /path/to/NextFlow-crm

# Chạy lệnh kiểm tra kết nối
pnpm db:check
```

### 11.2. Kiểm tra kết nối Redis

```bash
# Di chuyển đến thư mục NextFlow CRM
cd /path/to/NextFlow-crm

# Chạy lệnh kiểm tra kết nối
pnpm redis:check
```

### 11.3. Kiểm tra kết nối n8n và Flowise

```bash
# Di chuyển đến thư mục NextFlow CRM
cd /path/to/NextFlow-crm

# Chạy lệnh kiểm tra kết nối
pnpm integration:check
```

### 11.4. Kiểm tra cấu hình email

```bash
# Di chuyển đến thư mục NextFlow CRM
cd /path/to/NextFlow-crm

# Chạy lệnh kiểm tra email
pnpm email:test
```

## 12. TÀI LIỆU THAM KHẢO

1. [Tài liệu NestJS](https://docs.nestjs.com/)
2. [Tài liệu TypeORM](https://typeorm.io/)
3. [Tài liệu Redis](https://redis.io/documentation)
4. [Tài liệu n8n](https://docs.n8n.io/)
5. [Tài liệu Flowise](https://docs.flowiseai.com/)
6. [Tài liệu Nginx](https://nginx.org/en/docs/)
7. [Tài liệu PostgreSQL](https://www.postgresql.org/docs/)
