# TRIỂN KHAI NextFlow CRM - CÀI ĐẶT

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Cài đặt môi trường](#2-cài-đặt-môi-trường)
3. [Cài đặt NextFlow CRM](#3-cài-đặt-nextflow-crm)
4. [Cài đặt dịch vụ bổ sung](#4-cài-đặt-dịch-vụ-bổ-sung)
5. [Kiểm tra cài đặt](#5-kiểm-tra-cài-đặt)
6. [Cấu hình bảo mật](#6-cấu-hình-bảo-mật)
7. [Tối ưu hóa hiệu suất](#7-tối-ưu-hóa-hiệu-suất)
8. [Kết luận](#8-kết-luận)
9. [Tài liệu tham khảo](#9-tài-liệu-tham-khảo)

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn chi tiết về quy trình cài đặt hệ thống NextFlow CRM, bao gồm cài đặt các thành phần cơ bản, cấu hình môi trường và thiết lập ban đầu. Tài liệu này dành cho đội ngũ kỹ thuật và quản trị viên hệ thống NextFlow CRM.

## 2. CÀI ĐẶT MÔI TRƯỜNG

### 2.1. Cài đặt Docker và Docker Compose

Docker và Docker Compose là công cụ chính để triển khai NextFlow CRM. Dưới đây là hướng dẫn cài đặt trên các hệ điều hành phổ biến.

#### Ubuntu/Debian

```bash
# Cài đặt Docker
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Thêm user hiện tại vào nhóm docker
sudo usermod -aG docker $USER
```

#### CentOS/RHEL

```bash
# Cài đặt Docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker

# Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Thêm user hiện tại vào nhóm docker
sudo usermod -aG docker $USER
```

#### Windows Server

1. Tải và cài đặt Docker Desktop từ [trang chủ Docker](https://www.docker.com/products/docker-desktop)
2. Trong quá trình cài đặt, chọn "Use WSL 2 instead of Hyper-V"
3. Sau khi cài đặt, khởi động Docker Desktop
4. Docker Compose đã được tích hợp sẵn trong Docker Desktop

### 2.2. Cài đặt Node.js

NextFlow CRM yêu cầu Node.js phiên bản 16.x trở lên.

#### Ubuntu/Debian

```bash
# Sử dụng NodeSource
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Cài đặt pnpm
npm install -g pnpm
```

#### CentOS/RHEL

```bash
# Sử dụng NodeSource
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo yum install -y nodejs

# Cài đặt pnpm
npm install -g pnpm
```

#### Windows Server

1. Tải và cài đặt Node.js từ [trang chủ Node.js](https://nodejs.org/)
2. Chọn phiên bản LTS (16.x trở lên)
3. Mở Command Prompt với quyền Administrator và cài đặt pnpm:

```cmd
npm install -g pnpm
```

### 2.3. Cài đặt PostgreSQL

NextFlow CRM yêu cầu PostgreSQL phiên bản 13.0 trở lên.

#### Sử dụng Docker (Khuyến nghị)

```bash
# Tạo volume để lưu trữ dữ liệu
docker volume create NextFlow-postgres-data

# Chạy PostgreSQL container
docker run -d \
  --name NextFlow-postgres \
  -e POSTGRES_PASSWORD=your_secure_password \
  -e POSTGRES_USER=NextFlow \
  -e POSTGRES_DB=NextFlow_crm \
  -p 5432:5432 \
  -v NextFlow-postgres-data:/var/lib/postgresql/data \
  postgres:13
```

#### Cài đặt trực tiếp trên Ubuntu/Debian

```bash
# Thêm repository PostgreSQL
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update

# Cài đặt PostgreSQL
sudo apt install -y postgresql-13 postgresql-contrib-13

# Khởi động dịch vụ
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Tạo user và database
sudo -u postgres psql -c "CREATE USER NextFlow WITH PASSWORD 'your_secure_password';"
sudo -u postgres psql -c "CREATE DATABASE NextFlow_crm OWNER NextFlow;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE NextFlow_crm TO NextFlow;"
```

### 2.4. Cài đặt Redis

NextFlow CRM yêu cầu Redis phiên bản 6.0 trở lên.

#### Sử dụng Docker (Khuyến nghị)

```bash
# Tạo volume để lưu trữ dữ liệu
docker volume create NextFlow-redis-data

# Chạy Redis container
docker run -d \
  --name NextFlow-redis \
  -p 6379:6379 \
  -v NextFlow-redis-data:/data \
  redis:6.2 redis-server --requirepass your_secure_password
```

#### Cài đặt trực tiếp trên Ubuntu/Debian

```bash
# Cài đặt Redis
sudo apt update
sudo apt install -y redis-server

# Cấu hình Redis
sudo sed -i 's/supervised no/supervised systemd/g' /etc/redis/redis.conf
sudo sed -i 's/# requirepass foobared/requirepass your_secure_password/g' /etc/redis/redis.conf

# Khởi động dịch vụ
sudo systemctl restart redis
sudo systemctl enable redis
```

## 3. CÀI ĐẶT NextFlow CRM

### 3.1. Tải mã nguồn

```bash
# Clone repository
git clone https://github.com/NextFlow/NextFlow-crm.git
cd NextFlow-crm

# Cài đặt dependencies
pnpm install
```

### 3.2. Cấu hình môi trường

```bash
# Tạo file .env từ mẫu
cp .env.example .env

# Chỉnh sửa file .env
nano .env
```

Cấu hình các thông số quan trọng trong file `.env`:

```
# Cấu hình ứng dụng
NODE_ENV=production
PORT=3000
API_URL=https://api.yourdomain.com
FRONTEND_URL=https://yourdomain.com

# Cấu hình cơ sở dữ liệu
DB_HOST=localhost
DB_PORT=5432
DB_USER=NextFlow
DB_PASSWORD=your_secure_password
DB_NAME=NextFlow_crm
DB_SCHEMA=public

# Cấu hình Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_secure_password

# Cấu hình JWT
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=1d
JWT_REFRESH_EXPIRES_IN=7d

# Cấu hình email
MAIL_HOST=smtp.yourmailserver.com
MAIL_PORT=587
MAIL_USER=your_email@yourdomain.com
MAIL_PASSWORD=your_email_password
MAIL_FROM=noreply@yourdomain.com

# Cấu hình tích hợp
N8N_URL=https://n8n.yourdomain.com
N8N_API_KEY=your_n8n_api_key
FLOWISE_URL=https://flowise.yourdomain.com
FLOWISE_API_KEY=your_flowise_api_key
```

### 3.3. Khởi tạo cơ sở dữ liệu

```bash
# Chạy migration để tạo cấu trúc database
pnpm db:migrate

# Chạy seeder để tạo dữ liệu ban đầu
pnpm db:seed
```

### 3.4. Xây dựng ứng dụng

```bash
# Build backend
pnpm build:backend

# Build frontend
pnpm build:frontend
```

### 3.5. Chạy ứng dụng

#### Sử dụng PM2 (Khuyến nghị cho môi trường sản xuất)

```bash
# Cài đặt PM2
npm install -g pm2

# Khởi động ứng dụng
pm2 start ecosystem.config.js

# Đảm bảo ứng dụng tự động khởi động khi server reboot
pm2 startup
pm2 save
```

#### Sử dụng Docker Compose

```bash
# Khởi động toàn bộ hệ thống
docker-compose up -d
```

## 4. CÀI ĐẶT DỊCH VỤ BỔ SUNG

### 4.1. Cài đặt n8n

n8n là công cụ tự động hóa quy trình làm việc được tích hợp với NextFlow CRM.

```bash
# Tạo thư mục cho n8n
mkdir -p /opt/NextFlow/n8n
cd /opt/NextFlow/n8n

# Tạo file docker-compose.yml
cat > docker-compose.yml << 'EOL'
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
    volumes:
      - n8n_data:/home/node/.n8n
    networks:
      - NextFlow-network

volumes:
  n8n_data:

networks:
  NextFlow-network:
    external: true
EOL

# Khởi động n8n
docker-compose up -d
```

### 4.2. Cài đặt Flowise

Flowise là công cụ xây dựng chatbot AI được tích hợp với NextFlow CRM.

```bash
# Tạo thư mục cho Flowise
mkdir -p /opt/NextFlow/flowise
cd /opt/NextFlow/flowise

# Tạo file docker-compose.yml
cat > docker-compose.yml << 'EOL'
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
    volumes:
      - flowise_data:/app
    networks:
      - NextFlow-network

volumes:
  flowise_data:

networks:
  NextFlow-network:
    external: true
EOL

# Khởi động Flowise
docker-compose up -d
```

### 4.3. Cài đặt NGINX

NGINX được sử dụng làm reverse proxy cho NextFlow CRM và các dịch vụ liên quan.

```bash
# Cài đặt NGINX
sudo apt update
sudo apt install -y nginx

# Cấu hình NGINX cho NextFlow CRM
sudo cat > /etc/nginx/sites-available/NextFlow << 'EOL'
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

    # n8n
    location /n8n/ {
        proxy_pass http://localhost:5678/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Flowise
    location /flowise/ {
        proxy_pass http://localhost:3100/;
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
EOL

# Kích hoạt cấu hình
sudo ln -s /etc/nginx/sites-available/NextFlow /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 4.4. Cài đặt Let's Encrypt

Let's Encrypt được sử dụng để cung cấp chứng chỉ SSL miễn phí.

```bash
# Cài đặt Certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Tạo chứng chỉ SSL
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com -d n8n.yourdomain.com -d flowise.yourdomain.com

# Cấu hình tự động gia hạn
sudo systemctl status certbot.timer
```

## 5. KIỂM TRA CÀI ĐẶT

### 5.1. Kiểm tra dịch vụ

```bash
# Kiểm tra trạng thái các container
docker ps

# Kiểm tra logs của NextFlow CRM
pm2 logs

# Kiểm tra logs của n8n
docker logs -f NextFlow-n8n

# Kiểm tra logs của Flowise
docker logs -f NextFlow-flowise

# Kiểm tra trạng thái NGINX
sudo systemctl status nginx
```

### 5.2. Kiểm tra kết nối

```bash
# Kiểm tra kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm -c "SELECT version();"

# Kiểm tra kết nối đến Redis
redis-cli -h localhost -p 6379 -a your_secure_password ping

# Kiểm tra kết nối đến API
curl -I https://api.yourdomain.com/api/health

# Kiểm tra kết nối đến n8n
curl -I https://n8n.yourdomain.com

# Kiểm tra kết nối đến Flowise
curl -I https://flowise.yourdomain.com
```

### 5.3. Kiểm tra tài khoản quản trị

1. Mở trình duyệt và truy cập https://yourdomain.com
2. Đăng nhập với tài khoản quản trị mặc định:
   - Email: admin@NextFlow.com
   - Mật khẩu: Admin@123
3. Đổi mật khẩu mặc định ngay sau khi đăng nhập lần đầu

## 6. XỬ LÝ SỰ CỐ THƯỜNG GẶP

### 6.1. Không thể kết nối đến cơ sở dữ liệu

```bash
# Kiểm tra trạng thái PostgreSQL
sudo systemctl status postgresql

# Kiểm tra cấu hình PostgreSQL
sudo cat /etc/postgresql/13/main/postgresql.conf
sudo cat /etc/postgresql/13/main/pg_hba.conf

# Khởi động lại PostgreSQL
sudo systemctl restart postgresql
```

### 6.2. Không thể kết nối đến Redis

```bash
# Kiểm tra trạng thái Redis
sudo systemctl status redis

# Kiểm tra cấu hình Redis
sudo cat /etc/redis/redis.conf

# Khởi động lại Redis
sudo systemctl restart redis
```

### 6.3. Lỗi NGINX

```bash
# Kiểm tra cấu hình NGINX
sudo nginx -t

# Kiểm tra logs NGINX
sudo tail -f /var/log/nginx/error.log

# Khởi động lại NGINX
sudo systemctl restart nginx
```

### 6.4. Lỗi Docker

```bash
# Kiểm tra trạng thái Docker
sudo systemctl status docker

# Kiểm tra logs Docker
sudo journalctl -u docker

# Khởi động lại Docker
sudo systemctl restart docker
```

## 6. CẤU HÌNH BẢO MẬT

### 6.1. Firewall Configuration

```bash
# Cài đặt UFW (Ubuntu Firewall)
sudo apt install -y ufw

# Cấu hình firewall rules
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 5432/tcp  # PostgreSQL (chỉ từ internal network)
sudo ufw allow 6379/tcp  # Redis (chỉ từ internal network)

# Kích hoạt firewall
sudo ufw enable
```

### 6.2. SSL/TLS Configuration

```bash
# Cấu hình SSL ciphers mạnh
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Cập nhật NGINX với SSL configuration
sudo nano /etc/nginx/sites-available/nextflow
```

### 6.3. Database Security

```bash
# Tạo user database với quyền hạn chế
sudo -u postgres psql -c "CREATE USER nextflow_app WITH PASSWORD 'secure_password';"
sudo -u postgres psql -c "GRANT CONNECT ON DATABASE nextflow_crm TO nextflow_app;"
sudo -u postgres psql -c "GRANT USAGE ON SCHEMA public TO nextflow_app;"
sudo -u postgres psql -c "GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO nextflow_app;"
```

## 7. TỐI ƯU HÓA HIỆU SUẤT

### 7.1. Database Optimization

```bash
# Cấu hình PostgreSQL cho hiệu suất
sudo nano /etc/postgresql/13/main/postgresql.conf

# Thêm các cấu hình sau:
# shared_buffers = 256MB
# effective_cache_size = 1GB
# maintenance_work_mem = 64MB
# checkpoint_completion_target = 0.9
# wal_buffers = 16MB
# default_statistics_target = 100
```

### 7.2. Application Optimization

```bash
# Cấu hình PM2 cho production
cat > ecosystem.config.js << 'EOL'
module.exports = {
  apps: [{
    name: 'nextflow-crm',
    script: 'dist/main.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    max_memory_restart: '1G',
    node_args: '--max-old-space-size=1024'
  }]
};
EOL
```

### 7.3. NGINX Optimization

```bash
# Cấu hình NGINX cho hiệu suất cao
sudo nano /etc/nginx/nginx.conf

# Thêm các cấu hình sau:
# worker_processes auto;
# worker_connections 1024;
# keepalive_timeout 65;
# gzip on;
# gzip_vary on;
# gzip_min_length 1024;
```

## 8. KẾT LUẬN

Việc cài đặt NextFlow CRM đòi hỏi sự chuẩn bị kỹ lưỡng và tuân thủ các bước cài đặt một cách chính xác. Tài liệu này đã cung cấp hướng dẫn chi tiết từ việc chuẩn bị môi trường đến cài đặt và cấu hình hệ thống hoàn chỉnh.

### 8.1. Checklist hoàn thành cài đặt

- ✅ **Môi trường**: Docker, Node.js, PostgreSQL, Redis đã được cài đặt
- ✅ **NextFlow CRM**: Ứng dụng chính đã được build và deploy
- ✅ **Dịch vụ bổ sung**: n8n, Flowise, NGINX đã được cấu hình
- ✅ **SSL/TLS**: Chứng chỉ SSL đã được cài đặt và cấu hình
- ✅ **Bảo mật**: Firewall và các biện pháp bảo mật đã được thiết lập
- ✅ **Hiệu suất**: Các tối ưu hóa hiệu suất đã được áp dụng

### 8.2. Bước tiếp theo

1. **Kiểm tra toàn diện**: Thực hiện kiểm tra chức năng đầy đủ
2. **Backup setup**: Thiết lập quy trình backup tự động
3. **Monitoring**: Cài đặt hệ thống giám sát và alerting
4. **Documentation**: Cập nhật tài liệu vận hành
5. **Training**: Đào tạo team vận hành và sử dụng

### 8.3. Lưu ý quan trọng

- **Security**: Thường xuyên cập nhật security patches
- **Backup**: Kiểm tra backup định kỳ và test restore
- **Monitoring**: Theo dõi logs và metrics hệ thống
- **Performance**: Định kỳ review và tối ưu hiệu suất
- **Updates**: Lập kế hoạch update và maintenance

### 8.4. Tài liệu liên quan

- [Tổng quan Triển khai](./tong-quan.md)
- [Bảo mật Chi tiết](./bao-mat/bao-mat-chi-tiet.md)
- [Giám sát Hệ thống](./monitoring/monitoring-va-logging.md)
- [Khắc phục Sự cố](./troubleshooting/tong-quan.md)

## 9. TÀI LIỆU THAM KHẢO

### 9.1. Công nghệ cốt lõi
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Redis Documentation](https://redis.io/documentation)
- [Node.js Documentation](https://nodejs.org/en/docs/)

### 9.2. Dịch vụ tích hợp
- [n8n Documentation](https://docs.n8n.io/)
- [Flowise Documentation](https://docs.flowiseai.com/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

### 9.3. Bảo mật và hiệu suất
- [OWASP Security Guidelines](https://owasp.org/)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [NGINX Performance Tuning](https://nginx.org/en/docs/http/ngx_http_core_module.html)
- [Node.js Performance Best Practices](https://nodejs.org/en/docs/guides/simple-profiling/)

### 9.4. NextFlow CRM specific
- [Kiến trúc Hệ thống](../02-kien-truc/kien-truc-tong-the.md)
- [API Documentation](../06-api/tong-quan-api.md)
- [Schema Database](../05-schema/tong-quan-schema.md)
- [AI Integration](../04-ai-integration/tong-quan-ai.md)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 1.0.0
**Tác giả**: NextFlow Development Team
