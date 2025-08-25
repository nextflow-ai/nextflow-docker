# HƯỚNG DẪN TRIỂN KHAI nextflow CRM

## 1. GIỚI THIỆU

### 1.1. Mục đích

Tài liệu này cung cấp hướng dẫn chi tiết về quy trình triển khai hệ thống nextflow CRM, từ chuẩn bị môi trường đến cài đặt, cấu hình và vận hành. Tài liệu này dành cho đội ngũ kỹ thuật và quản trị viên hệ thống.

### 1.2. Đối tượng sử dụng

- **Quản trị viên hệ thống**: Chịu trách nhiệm triển khai và quản lý hệ thống
- **Đội ngũ kỹ thuật**: Thực hiện cài đặt và cấu hình hệ thống
- **Đối tác triển khai**: Cung cấp dịch vụ triển khai cho khách hàng
- **Người dùng nâng cao**: Muốn tự triển khai hệ thống

### 1.3. Phạm vi

Tài liệu này bao gồm:
- Chuẩn bị môi trường triển khai
- Cài đặt các thành phần hệ thống
- Cấu hình hệ thống
- Kiểm thử và xác nhận
- Triển khai sản xuất
- Bảo trì và nâng cấp

## 2. CHUẨN BỊ TRIỂN KHAI

### 2.1. Yêu cầu hệ thống

#### 2.1.1. Yêu cầu phần cứng

**Môi trường phát triển**
- CPU: 4 cores
- RAM: 8GB trở lên
- Ổ cứng: 50GB trở lên (SSD khuyến nghị)

**Môi trường sản xuất (cho 100 người dùng đồng thời)**
- CPU: 8 cores trở lên
- RAM: 16GB trở lên
- Ổ cứng: 100GB trở lên (SSD bắt buộc)
- Băng thông mạng: 100Mbps trở lên

**Môi trường sản xuất (cho 1000 người dùng đồng thời)**
- CPU: 16 cores trở lên
- RAM: 32GB trở lên
- Ổ cứng: 500GB trở lên (SSD bắt buộc)
- Băng thông mạng: 1Gbps trở lên

#### 2.1.2. Yêu cầu phần mềm

**Hệ điều hành**
- Linux (Ubuntu 20.04 LTS hoặc CentOS 8 trở lên)
- Windows Server 2019 trở lên

**Cơ sở dữ liệu**
- PostgreSQL 13.0 trở lên
- Redis 6.0 trở lên

**Môi trường chạy**
- Node.js 16.x trở lên
- Docker 20.10.x trở lên
- Docker Compose 2.0.x trở lên

**Dịch vụ bổ sung**
- NGINX hoặc Apache (cho reverse proxy)
- Let's Encrypt (cho SSL)
- n8n (cho workflow automation)
- Flowise (cho AI chatbot)

### 2.2. Chuẩn bị môi trường

#### 2.2.1. Cài đặt hệ điều hành

Đảm bảo hệ điều hành đã được cài đặt và cập nhật với các bản vá bảo mật mới nhất.

**Ubuntu**
```bash
# Cập nhật hệ thống
sudo apt update
sudo apt upgrade -y

# Cài đặt các công cụ cần thiết
sudo apt install -y curl wget git unzip htop
```

**CentOS**
```bash
# Cập nhật hệ thống
sudo dnf update -y

# Cài đặt các công cụ cần thiết
sudo dnf install -y curl wget git unzip htop
```

#### 2.2.2. Cài đặt Docker và Docker Compose

Docker và Docker Compose là các công cụ cần thiết để triển khai nextflow CRM.

**Ubuntu**
```bash
# Cài đặt Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Thêm user hiện tại vào nhóm docker
sudo usermod -aG docker $USER

# Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Kiểm tra phiên bản
docker --version
docker-compose --version
```

**CentOS**
```bash
# Cài đặt Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Thêm user hiện tại vào nhóm docker
sudo usermod -aG docker $USER

# Cài đặt Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Khởi động Docker
sudo systemctl start docker
sudo systemctl enable docker

# Kiểm tra phiên bản
docker --version
docker-compose --version
```

#### 2.2.3. Cài đặt Node.js

Node.js là môi trường chạy cần thiết cho một số thành phần của nextflow CRM.

**Ubuntu**
```bash
# Cài đặt Node.js 16.x
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install -y nodejs

# Kiểm tra phiên bản
node -v
npm -v
```

**CentOS**
```bash
# Cài đặt Node.js 16.x
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
sudo dnf install -y nodejs

# Kiểm tra phiên bản
node -v
npm -v
```

### 2.3. Chuẩn bị dữ liệu

#### 2.3.1. Sao lưu dữ liệu hiện có

Nếu bạn đang nâng cấp từ một hệ thống hiện có, hãy đảm bảo sao lưu tất cả dữ liệu quan trọng:

```bash
# Sao lưu cơ sở dữ liệu PostgreSQL
pg_dump -U username -d database_name -f backup.sql

# Sao lưu tệp cấu hình
cp -r /path/to/config /path/to/backup/config

# Sao lưu dữ liệu người dùng
cp -r /path/to/user/data /path/to/backup/user_data
```

#### 2.3.2. Chuẩn bị dữ liệu di chuyển

Nếu bạn cần di chuyển dữ liệu từ hệ thống khác sang nextflow CRM, hãy chuẩn bị dữ liệu theo định dạng phù hợp:

- Dữ liệu khách hàng: CSV hoặc JSON
- Dữ liệu sản phẩm: CSV hoặc JSON
- Dữ liệu đơn hàng: CSV hoặc JSON
- Dữ liệu người dùng: CSV hoặc JSON

## 3. CÀI ĐẶT HỆ THỐNG

### 3.1. Cài đặt cơ sở dữ liệu

nextflow CRM sử dụng PostgreSQL làm cơ sở dữ liệu chính và Redis làm cache. Dưới đây là hướng dẫn cài đặt và cấu hình.

#### 3.1.1. Cài đặt PostgreSQL

**Ubuntu**
```bash
# Cài đặt PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Khởi động dịch vụ
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Kiểm tra trạng thái
sudo systemctl status postgresql
```

**CentOS**
```bash
# Cài đặt PostgreSQL repository
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Cài đặt PostgreSQL
sudo dnf install -y postgresql13-server postgresql13-contrib

# Khởi tạo database
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb

# Khởi động dịch vụ
sudo systemctl start postgresql-13
sudo systemctl enable postgresql-13

# Kiểm tra trạng thái
sudo systemctl status postgresql-13
```

#### 3.1.2. Cấu hình PostgreSQL

Sau khi cài đặt, cần tạo database và user cho nextflow CRM:

```bash
# Đăng nhập vào PostgreSQL với user postgres
sudo -u postgres psql

# Tạo user cho nextflow CRM
CREATE USER nextflow WITH PASSWORD 'your_secure_password';

# Tạo database
CREATE DATABASE nextflow_crm;

# Cấp quyền cho user
GRANT ALL PRIVILEGES ON DATABASE nextflow_crm TO nextflow;

# Thoát
\q
```
