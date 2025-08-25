# HƯỚNG DẪN CÀI ĐẶT MÔI TRƯỜNG

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn chi tiết về cách cài đặt môi trường cho NextFlow CRM-AI. Hướng dẫn này bao gồm các bước cài đặt các thành phần cần thiết như hệ điều hành, cơ sở dữ liệu, và các dịch vụ liên quan.

## 2. YÊU CẦU HỆ THỐNG

### 2.1. Yêu cầu phần cứng

#### Môi trường phát triển
- CPU: 4 cores
- RAM: 8GB trở lên
- Ổ cứng: 50GB trở lên (SSD khuyến nghị)

#### Môi trường sản xuất (cho 100 người dùng đồng thời)
- CPU: 8 cores trở lên
- RAM: 16GB trở lên
- Ổ cứng: 100GB trở lên (SSD bắt buộc)
- Băng thông mạng: 100Mbps trở lên

### 2.2. Yêu cầu phần mềm

- Hệ điều hành: Ubuntu 20.04 LTS, CentOS 8, hoặc Windows Server 2019 trở lên
- Docker 20.10.x trở lên và Docker Compose 2.0.x trở lên
- Node.js 16.x trở lên
- PostgreSQL 13.0 trở lên
- Redis 6.0 trở lên

## 3. CÀI ĐẶT HỆ ĐIỀU HÀNH

### 3.1. Ubuntu 20.04 LTS

1. Tải Ubuntu 20.04 LTS từ [trang chủ Ubuntu](https://ubuntu.com/download/server)
2. Tạo USB boot hoặc sử dụng ISO để cài đặt
3. Cài đặt Ubuntu Server theo hướng dẫn trên màn hình
4. Cập nhật hệ thống:

```bash
sudo apt update
sudo apt upgrade -y
```

### 3.2. CentOS 8

1. Tải CentOS 8 từ [trang chủ CentOS](https://www.centos.org/download/)
2. Tạo USB boot hoặc sử dụng ISO để cài đặt
3. Cài đặt CentOS 8 theo hướng dẫn trên màn hình
4. Cập nhật hệ thống:

```bash
sudo dnf update -y
```

### 3.3. Windows Server 2019

1. Tải Windows Server 2019 từ [trang chủ Microsoft](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019)
2. Cài đặt Windows Server 2019 theo hướng dẫn trên màn hình
3. Cài đặt các bản cập nhật mới nhất

## 4. CÀI ĐẶT DOCKER VÀ DOCKER COMPOSE

### 4.1. Ubuntu 20.04 LTS

```bash
# Cài đặt các gói cần thiết
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Thêm GPG key của Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Thêm repository Docker
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Cài đặt Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Thêm user hiện tại vào nhóm docker
sudo usermod -aG docker $USER

# Khởi động Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 4.2. CentOS 8

```bash
# Cài đặt các gói cần thiết
sudo dnf install -y yum-utils

# Thêm repository Docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Cài đặt Docker
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Thêm user hiện tại vào nhóm docker
sudo usermod -aG docker $USER

# Khởi động Docker
sudo systemctl start docker
sudo systemctl enable docker
```

### 4.3. Windows Server 2019

1. Cài đặt WSL 2 (Windows Subsystem for Linux 2):
   - Mở PowerShell với quyền Administrator
   - Chạy lệnh: `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`
   - Chạy lệnh: `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`
   - Khởi động lại máy chủ
   - Tải và cài đặt [WSL 2 Linux kernel update package](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)
   - Chạy lệnh: `wsl --set-default-version 2`

2. Cài đặt Docker Desktop:
   - Tải Docker Desktop từ [trang chủ Docker](https://www.docker.com/products/docker-desktop)
   - Cài đặt Docker Desktop, chọn "Use WSL 2 instead of Hyper-V"
   - Khởi động Docker Desktop

## 5. CÀI ĐẶT NODE.JS

### 5.1. Ubuntu 20.04 LTS

```bash
# Sử dụng NodeSource
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Kiểm tra phiên bản
node -v
npm -v

# Cài đặt pnpm
npm install -g pnpm
```

### 5.2. CentOS 8

```bash
# Sử dụng NodeSource
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo dnf install -y nodejs

# Kiểm tra phiên bản
node -v
npm -v

# Cài đặt pnpm
npm install -g pnpm
```

### 5.3. Windows Server 2019

1. Tải Node.js từ [trang chủ Node.js](https://nodejs.org/)
2. Chọn phiên bản LTS (16.x trở lên)
3. Cài đặt Node.js theo hướng dẫn trên màn hình
4. Mở Command Prompt và kiểm tra phiên bản:

```cmd
node -v
npm -v
```

5. Cài đặt pnpm:

```cmd
npm install -g pnpm
```

## 6. CÀI ĐẶT POSTGRESQL

### 6.1. Sử dụng Docker (Khuyến nghị)

```bash
# Tạo volume để lưu trữ dữ liệu
docker volume create NextFlow-postgres-data

# Tạo network
docker network create NextFlow-network

# Chạy PostgreSQL container
docker run -d \
  --name NextFlow-postgres \
  --network NextFlow-network \
  -e POSTGRES_PASSWORD=your_secure_password \
  -e POSTGRES_USER=NextFlow \
  -e POSTGRES_DB=NextFlow_crm \
  -p 5432:5432 \
  -v NextFlow-postgres-data:/var/lib/postgresql/data \
  postgres:13
```

### 6.2. Ubuntu 20.04 LTS

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

### 6.3. CentOS 8

```bash
# Thêm repository PostgreSQL
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo dnf -qy module disable postgresql
sudo dnf install -y postgresql13-server postgresql13-contrib

# Khởi tạo database
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb

# Khởi động dịch vụ
sudo systemctl start postgresql-13
sudo systemctl enable postgresql-13

# Tạo user và database
sudo -u postgres psql -c "CREATE USER NextFlow WITH PASSWORD 'your_secure_password';"
sudo -u postgres psql -c "CREATE DATABASE NextFlow_crm OWNER NextFlow;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE NextFlow_crm TO NextFlow;"
```

### 6.4. Windows Server 2019

1. Tải PostgreSQL từ [trang chủ PostgreSQL](https://www.postgresql.org/download/windows/)
2. Cài đặt PostgreSQL theo hướng dẫn trên màn hình
3. Trong quá trình cài đặt, tạo user `NextFlow` với mật khẩu an toàn
4. Sau khi cài đặt, mở pgAdmin hoặc psql để tạo database:

```sql
CREATE DATABASE NextFlow_crm;
```

## 7. CÀI ĐẶT REDIS

### 7.1. Sử dụng Docker (Khuyến nghị)

```bash
# Tạo volume để lưu trữ dữ liệu
docker volume create NextFlow-redis-data

# Chạy Redis container
docker run -d \
  --name NextFlow-redis \
  --network NextFlow-network \
  -p 6379:6379 \
  -v NextFlow-redis-data:/data \
  redis:6.2 redis-server --requirepass your_secure_password
```

### 7.2. Ubuntu 20.04 LTS

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

### 7.3. CentOS 8

```bash
# Cài đặt Redis
sudo dnf install -y redis

# Cấu hình Redis
sudo sed -i 's/supervised no/supervised systemd/g' /etc/redis.conf
sudo sed -i 's/# requirepass foobared/requirepass your_secure_password/g' /etc/redis.conf

# Khởi động dịch vụ
sudo systemctl start redis
sudo systemctl enable redis
```

### 7.4. Windows Server 2019

1. Tải Redis cho Windows từ [GitHub](https://github.com/microsoftarchive/redis/releases)
2. Cài đặt Redis theo hướng dẫn trên màn hình
3. Cấu hình Redis:
   - Mở file `redis.windows.conf`
   - Thêm dòng: `requirepass your_secure_password`
4. Cài đặt Redis như một dịch vụ Windows:
   - Mở Command Prompt với quyền Administrator
   - Chạy lệnh: `redis-server --service-install redis.windows.conf --service-name Redis`
   - Khởi động dịch vụ: `net start Redis`

## 8. CÀI ĐẶT NGINX

### 8.1. Ubuntu 20.04 LTS

```bash
# Cài đặt Nginx
sudo apt update
sudo apt install -y nginx

# Khởi động dịch vụ
sudo systemctl start nginx
sudo systemctl enable nginx

# Cấu hình tường lửa
sudo ufw allow 'Nginx Full'
```

### 8.2. CentOS 8

```bash
# Cài đặt Nginx
sudo dnf install -y nginx

# Khởi động dịch vụ
sudo systemctl start nginx
sudo systemctl enable nginx

# Cấu hình tường lửa
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

### 8.3. Windows Server 2019

1. Tải Nginx cho Windows từ [trang chủ Nginx](http://nginx.org/en/download.html)
2. Giải nén vào thư mục, ví dụ: `C:\nginx`
3. Cài đặt Nginx như một dịch vụ Windows:
   - Tải [nssm](https://nssm.cc/download)
   - Giải nén và mở Command Prompt với quyền Administrator
   - Chạy lệnh: `nssm install nginx "C:\nginx\nginx.exe"`
   - Khởi động dịch vụ: `net start nginx`

## 9. CÀI ĐẶT LET'S ENCRYPT

### 9.1. Ubuntu 20.04 LTS

```bash
# Cài đặt Certbot
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Tạo chứng chỉ SSL
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com -d n8n.yourdomain.com -d flowise.yourdomain.com

# Cấu hình tự động gia hạn
sudo systemctl status certbot.timer
```

### 9.2. CentOS 8

```bash
# Cài đặt Certbot
sudo dnf install -y epel-release
sudo dnf install -y certbot python3-certbot-nginx

# Tạo chứng chỉ SSL
sudo certbot --nginx -d yourdomain.com -d api.yourdomain.com -d n8n.yourdomain.com -d flowise.yourdomain.com

# Cấu hình tự động gia hạn
sudo systemctl status certbot-renew.timer
```

### 9.3. Windows Server 2019

1. Tải và cài đặt [Win-ACME](https://www.win-acme.com/)
2. Chạy Win-ACME và làm theo hướng dẫn để tạo chứng chỉ SSL cho các domain
3. Cấu hình Nginx để sử dụng chứng chỉ SSL đã tạo

## 10. KIỂM TRA CÀI ĐẶT

### 10.1. Kiểm tra Docker

```bash
docker --version
docker-compose --version
docker ps
```

### 10.2. Kiểm tra Node.js

```bash
node -v
npm -v
pnpm -v
```

### 10.3. Kiểm tra PostgreSQL

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Trong PostgreSQL, kiểm tra phiên bản
SELECT version();

# Thoát
\q
```

### 10.4. Kiểm tra Redis

```bash
# Kết nối đến Redis
redis-cli -h localhost -p 6379 -a your_secure_password

# Trong Redis, kiểm tra kết nối
PING

# Thoát
exit
```

### 10.5. Kiểm tra Nginx

```bash
# Kiểm tra cấu hình Nginx
sudo nginx -t

# Kiểm tra trạng thái dịch vụ
sudo systemctl status nginx
```

## 11. XỬ LÝ SỰ CỐ

### 11.1. Docker

- **Lỗi "Permission denied"**: Thêm user vào nhóm docker và đăng xuất/đăng nhập lại
- **Lỗi "Cannot connect to the Docker daemon"**: Kiểm tra dịch vụ Docker đã chạy chưa
- **Lỗi "Port is already allocated"**: Kiểm tra và dừng các dịch vụ đang sử dụng cổng đó

### 11.2. PostgreSQL

- **Lỗi "Connection refused"**: Kiểm tra dịch vụ PostgreSQL đã chạy chưa và cấu hình pg_hba.conf
- **Lỗi "Authentication failed"**: Kiểm tra tên người dùng và mật khẩu
- **Lỗi "Database does not exist"**: Tạo database bằng lệnh CREATE DATABASE

### 11.3. Redis

- **Lỗi "Connection refused"**: Kiểm tra dịch vụ Redis đã chạy chưa
- **Lỗi "NOAUTH Authentication required"**: Cung cấp mật khẩu Redis
- **Lỗi "WRONGPASS invalid password"**: Kiểm tra mật khẩu Redis

### 11.4. Nginx

- **Lỗi "Address already in use"**: Kiểm tra và dừng các dịch vụ đang sử dụng cổng 80/443
- **Lỗi "Permission denied"**: Kiểm tra quyền truy cập thư mục và file
- **Lỗi "Invalid configuration"**: Kiểm tra cú pháp trong file cấu hình Nginx

## 12. TÀI LIỆU THAM KHẢO

1. [Tài liệu Docker](https://docs.docker.com/)
2. [Tài liệu Node.js](https://nodejs.org/en/docs/)
3. [Tài liệu PostgreSQL](https://www.postgresql.org/docs/)
4. [Tài liệu Redis](https://redis.io/documentation)
5. [Tài liệu Nginx](https://nginx.org/en/docs/)
6. [Tài liệu Let's Encrypt](https://letsencrypt.org/docs/)
