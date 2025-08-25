# FLOWISE - CÀI ĐẶT

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn chi tiết về cách cài đặt và cấu hình Flowise trong hệ thống NextFlow CRM-AI. Flowise là một nền tảng mã nguồn mở cho phép xây dựng và triển khai các ứng dụng AI và chatbot dựa trên LangChain một cách trực quan thông qua giao diện kéo thả.

## 2. YÊU CẦU HỆ THỐNG

### 2.1. Yêu cầu phần cứng

- CPU: 2 cores trở lên
- RAM: 4GB trở lên
- Ổ cứng: 20GB trở lên

### 2.2. Yêu cầu phần mềm

- Docker 20.10.x trở lên
- Docker Compose 2.0.x trở lên
- Node.js 16.x trở lên (nếu cài đặt không sử dụng Docker)
- Nginx hoặc Apache (cho reverse proxy)

## 3. CÀI ĐẶT FLOWISE

### 3.1. Cài đặt sử dụng Docker (Khuyến nghị)

#### 3.1.1. Tạo thư mục cho Flowise

```bash
# Tạo thư mục cho Flowise
mkdir -p /opt/NextFlow/flowise
cd /opt/NextFlow/flowise
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
      - TOOL_FUNCTION_BUILTIN_DEP=crypto,fs,path,url
      - TOOL_FUNCTION_EXTERNAL_DEP=axios,cheerio,pdf-parse,mammoth
      - DISABLE_FLOWISE_TELEMETRY=true
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

Thay thế các giá trị sau bằng giá trị thực tế của bạn:
- `your_secure_password`: Mật khẩu an toàn cho Flowise
- `your_secret_key`: Khóa bí mật (tạo ngẫu nhiên)
- `your_langchain_api_key`: API key của LangChain (nếu sử dụng)

#### 3.1.3. Tạo mạng Docker

```bash
# Tạo mạng Docker nếu chưa tồn tại
docker network create NextFlow-network
```

#### 3.1.4. Khởi động Flowise

```bash
# Khởi động Flowise
docker-compose up -d
```

#### 3.1.5. Kiểm tra Flowise đang chạy

```bash
# Kiểm tra container Flowise
docker ps | grep flowise

# Kiểm tra logs Flowise
docker logs NextFlow-flowise
```

### 3.2. Cài đặt sử dụng npm (Không khuyến nghị cho môi trường sản xuất)

#### 3.2.1. Cài đặt Flowise

```bash
# Cài đặt Flowise
npm install -g flowise
```

#### 3.2.2. Khởi động Flowise

```bash
# Khởi động Flowise
npx flowise start
```

#### 3.2.3. Cài đặt Flowise như một dịch vụ

```bash
# Cài đặt pm2
npm install -g pm2

# Khởi động Flowise với pm2
pm2 start "npx flowise start" --name flowise

# Đảm bảo Flowise tự động khởi động khi server reboot
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

### 4.2. Cấu hình Nginx cho Flowise

```bash
# Tạo file cấu hình Nginx cho Flowise
sudo nano /etc/nginx/sites-available/flowise
```

Thêm nội dung sau vào file cấu hình:

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

### 4.3. Kích hoạt cấu hình Nginx

```bash
# Tạo symbolic link
sudo ln -s /etc/nginx/sites-available/flowise /etc/nginx/sites-enabled/

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
sudo certbot --nginx -d flowise.yourdomain.com

# Cấu hình tự động gia hạn
sudo systemctl status certbot.timer
```

## 5. CẤU HÌNH FLOWISE

### 5.1. Cấu hình cơ bản

Sau khi cài đặt, truy cập Flowise tại `https://flowise.yourdomain.com` và đăng nhập với thông tin:
- Username: admin
- Password: your_secure_password

### 5.2. Cấu hình API

#### 5.2.1. Tạo API Key

1. Truy cập **Settings**
2. Chọn **API Keys**
3. Nhấp vào **Create API Key**
4. Nhập thông tin:
   - Name: NextFlow CRM-AI
   - Expiration: Never (hoặc chọn thời gian hết hạn)
5. Nhấp vào **Create**
6. Sao chép API Key và lưu lại

#### 5.2.2. Cấu hình API trong NextFlow CRM-AI

Cập nhật file `.env` của NextFlow CRM-AI với thông tin API Flowise:

```
FLOWISE_URL=https://flowise.yourdomain.com
FLOWISE_API_KEY=your_flowise_api_key
```

### 5.3. Cấu hình Credentials

#### 5.3.1. Thêm Credentials cho OpenAI

1. Truy cập **Credentials**
2. Nhấp vào **New**
3. Chọn **OpenAI**
4. Nhập thông tin:
   - Name: OpenAI
   - OpenAI API Key: your_openai_api_key
5. Nhấp vào **Save**

#### 5.3.2. Thêm Credentials cho Google AI

1. Truy cập **Credentials**
2. Nhấp vào **New**
3. Chọn **Google AI**
4. Nhập thông tin:
   - Name: Google AI
   - Google API Key: your_google_api_key
5. Nhấp vào **Save**

#### 5.3.3. Thêm Credentials cho Pinecone

1. Truy cập **Credentials**
2. Nhấp vào **New**
3. Chọn **Pinecone**
4. Nhập thông tin:
   - Name: Pinecone
   - Environment: your_pinecone_environment
   - API Key: your_pinecone_api_key
5. Nhấp vào **Save**

## 6. BẢO MẬT FLOWISE

### 6.1. Bảo mật cơ bản

#### 6.1.1. Sử dụng xác thực

Đảm bảo xác thực được kích hoạt trong cấu hình Flowise:

```
FLOWISE_USERNAME=admin
FLOWISE_PASSWORD=your_secure_password
```

#### 6.1.2. Sử dụng HTTPS

Đảm bảo Flowise được truy cập qua HTTPS thông qua Nginx.

#### 6.1.3. Giới hạn truy cập IP

Cấu hình Nginx để giới hạn truy cập IP:

```nginx
# Chỉ cho phép truy cập từ IP cụ thể
allow 192.168.1.100;
allow 10.0.0.0/24;
deny all;
```

### 6.2. Bảo mật nâng cao

#### 6.2.1. Sử dụng khóa bí mật

Đảm bảo khóa bí mật được cấu hình:

```
FLOWISE_SECRETKEY_OVERWRITE=your_secret_key
```

#### 6.2.2. Bảo vệ API Key

1. Đặt thời gian hết hạn cho API Key
2. Chỉ cấp quyền cần thiết cho API Key

#### 6.2.3. Giám sát logs

```bash
# Giám sát logs Flowise
docker logs -f NextFlow-flowise
```

## 7. NÂNG CẤP FLOWISE

### 7.1. Nâng cấp sử dụng Docker

```bash
# Di chuyển đến thư mục Flowise
cd /opt/NextFlow/flowise

# Kéo image mới nhất
docker-compose pull

# Khởi động lại Flowise với image mới
docker-compose up -d
```

### 7.2. Nâng cấp sử dụng npm

```bash
# Nâng cấp Flowise
npm update -g flowise

# Khởi động lại Flowise
pm2 restart flowise
```

## 8. SAO LƯU VÀ KHÔI PHỤC

### 8.1. Sao lưu dữ liệu

#### 8.1.1. Sao lưu volume Docker

```bash
# Dừng Flowise
docker-compose stop flowise

# Sao lưu volume
docker run --rm -v flowise_data:/source -v $(pwd):/backup alpine tar -czf /backup/flowise_data_$(date +%Y%m%d).tar.gz -C /source .

# Khởi động lại Flowise
docker-compose start flowise
```

### 8.2. Khôi phục dữ liệu

#### 8.2.1. Khôi phục volume Docker

```bash
# Dừng Flowise
docker-compose stop flowise

# Khôi phục volume
docker run --rm -v flowise_data:/target -v $(pwd):/backup alpine sh -c "rm -rf /target/* && tar -xzf /backup/flowise_data_20230101.tar.gz -C /target"

# Khởi động lại Flowise
docker-compose start flowise
```

## 9. XỬ LÝ SỰ CỐ

### 9.1. Không thể kết nối đến Flowise

#### 9.1.1. Kiểm tra Flowise đang chạy

```bash
# Kiểm tra container Flowise
docker ps | grep flowise

# Kiểm tra logs Flowise
docker logs NextFlow-flowise
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

### 9.2. Lỗi kết nối LLM

#### 9.2.1. Kiểm tra API key

Kiểm tra API key của các dịch vụ LLM (OpenAI, Google AI, v.v.) trong Flowise.

#### 9.2.2. Kiểm tra kết nối đến API LLM

```bash
# Kiểm tra kết nối đến OpenAI
curl -v https://api.openai.com/v1/models \
  -H "Authorization: Bearer your_openai_api_key"
```

### 9.3. Lỗi chatbot

#### 9.3.1. Kiểm tra logs chatbot

```bash
# Kiểm tra logs Flowise
docker logs NextFlow-flowise | grep error
```

#### 9.3.2. Kiểm tra cấu hình chatflow

Đăng nhập vào Flowise và kiểm tra cấu hình chatflow:
1. Truy cập **Chatflows**
2. Mở chatflow cần kiểm tra
3. Kiểm tra từng node

## 10. TÀI LIỆU THAM KHẢO

1. [Tài liệu chính thức Flowise](https://docs.flowiseai.com/)
2. [GitHub Flowise](https://github.com/FlowiseAI/Flowise)
3. [Tài liệu Docker](https://docs.docker.com/)
4. [Tài liệu Nginx](https://nginx.org/en/docs/)
5. [Tài liệu LangChain](https://js.langchain.com/docs/)
