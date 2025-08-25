# THIẾT LẬP DOCKER VÀ CLOUDFLARE TUNNEL - Bootstrap AI Server

## 🎯 **TỔNG QUAN**

Tài liệu này hướng dẫn thiết lập **toàn bộ hệ thống NextFlow CRM-AI** chạy trên **laptop** bằng **Docker containers** và sử dụng **Cloudflare Tunnel** để expose ra internet một cách an toàn.

### **🔤 Định nghĩa thuật ngữ:**
- **Docker**: Công nghệ container hóa - đóng gói ứng dụng và dependencies vào containers độc lập
- **Container**: Môi trường ảo nhẹ chứa ứng dụng, tách biệt với hệ điều hành chính
- **Docker Compose**: Công cụ quản lý nhiều containers cùng lúc bằng file YAML
- **Cloudflare Tunnel**: Dịch vụ tạo đường hầm an toàn từ laptop ra internet không cần mở port
- **Reverse Proxy**: Máy chủ trung gian chuyển tiếp requests từ internet đến ứng dụng
- **Load Balancer**: Bộ cân bằng tải phân phối requests đến nhiều containers
- **Health Check**: Kiểm tra sức khỏe containers để đảm bảo hoạt động ổn định

---

## 🏗️ **KIẾN TRÚC HỆ THỐNG**

### **📊 Sơ đồ tổng quan:**
```
Internet → Cloudflare Tunnel → Laptop Docker Host
                                      ↓
┌─────────────────────────────────────────────────────────┐
│                 Docker Network                          │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │
│ │   Nginx     │ │  NextFlow   │ │  AI Server  │        │
│ │ (Proxy)     │ │   CRM-AI    │ │  (Ollama)   │        │
│ │   :80       │ │   :3000     │ │   :11434    │        │
│ └─────────────┘ └─────────────┘ └─────────────┘        │
├─────────────────────────────────────────────────────────┤
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐        │
│ │ PostgreSQL  │ │    Redis    │ │   Qdrant    │        │
│ │ Database    │ │   Cache     │ │  Vector DB  │        │
│ │   :5432     │ │   :6379     │ │   :6333     │        │
│ └─────────────┘ └─────────────┘ └─────────────┘        │
└─────────────────────────────────────────────────────────┘
```

### **🔧 Các thành phần chính:**
- **Nginx**: Reverse proxy và load balancer
- **NextFlow CRM-AI**: Ứng dụng chính (Node.js + React)
- **AI Server (Ollama)**: Máy chủ AI chạy local models
- **PostgreSQL**: Cơ sở dữ liệu chính
- **Redis**: Cache và session storage
- **Qdrant**: Vector database cho AI embeddings

---

## 📁 **CẤU TRÚC PROJECT**

```
nextflow-crm-ai/
├── docker-compose.yml              # Cấu hình tất cả containers
├── .env                           # Biến môi trường
├── nginx/
│   ├── nginx.conf                 # Cấu hình Nginx
│   └── ssl/                       # SSL certificates (nếu cần)
├── backend/
│   ├── Dockerfile                 # Docker image cho backend
│   ├── package.json
│   └── src/
├── frontend/
│   ├── Dockerfile                 # Docker image cho frontend
│   ├── package.json
│   └── src/
├── ai-server/
│   ├── Dockerfile                 # Docker image cho AI server
│   └── models/                    # AI models storage
├── database/
│   ├── init.sql                   # Database initialization
│   └── backups/                   # Database backups
└── cloudflare/
    ├── tunnel-config.yml          # Cloudflare tunnel config
    └── credentials.json           # Tunnel credentials
```

---

## 🐳 **DOCKER COMPOSE CONFIGURATION**

### **📄 File docker-compose.yml:**
```yaml
version: '3.8'

services:
  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: nextflow-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - backend
      - frontend
    networks:
      - nextflow-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # NextFlow Backend API
  backend:
    build: ./backend
    container_name: nextflow-backend
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://nextflow:${DB_PASSWORD}@postgres:5432/nextflow_db
      - REDIS_URL=redis://redis:6379
      - AI_SERVER_URL=http://ai-server:11434
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - postgres
      - redis
      - ai-server
    networks:
      - nextflow-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # NextFlow Frontend
  frontend:
    build: ./frontend
    container_name: nextflow-frontend
    environment:
      - REACT_APP_API_URL=http://backend:3000/api
    depends_on:
      - backend
    networks:
      - nextflow-network
    restart: unless-stopped

  # AI Server (Ollama)
  ai-server:
    image: ollama/ollama:latest
    container_name: nextflow-ai-server
    ports:
      - "11434:11434"
    volumes:
      - ./ai-server/models:/root/.ollama
      - /dev/nvidia0:/dev/nvidia0  # GPU access
    environment:
      - OLLAMA_HOST=0.0.0.0
      - OLLAMA_MODELS=/root/.ollama/models
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    networks:
      - nextflow-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
      interval: 60s
      timeout: 30s
      retries: 3

  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: nextflow-postgres
    environment:
      - POSTGRES_DB=nextflow_db
      - POSTGRES_USER=nextflow
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - nextflow-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U nextflow -d nextflow_db"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: nextflow-redis
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - nextflow-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Qdrant Vector Database
  qdrant:
    image: qdrant/qdrant:latest
    container_name: nextflow-qdrant
    ports:
      - "6333:6333"
      - "6334:6334"
    volumes:
      - qdrant_data:/qdrant/storage
    environment:
      - QDRANT__SERVICE__HTTP_PORT=6333
      - QDRANT__SERVICE__GRPC_PORT=6334
    networks:
      - nextflow-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6333/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Cloudflare Tunnel
  cloudflare-tunnel:
    image: cloudflare/cloudflared:latest
    container_name: nextflow-tunnel
    command: tunnel --config /etc/cloudflared/config.yml run
    volumes:
      - ./cloudflare/tunnel-config.yml:/etc/cloudflared/config.yml
      - ./cloudflare/credentials.json:/etc/cloudflared/credentials.json
    depends_on:
      - nginx
    networks:
      - nextflow-network
    restart: unless-stopped

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
  qdrant_data:
    driver: local

networks:
  nextflow-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### **📄 File .env:**
```bash
# Database Configuration
DB_PASSWORD=your_super_secure_db_password_here
REDIS_PASSWORD=your_redis_password_here

# JWT Secret for authentication
JWT_SECRET=your_jwt_secret_key_256_bits_long

# AI Configuration
OLLAMA_MODELS_PATH=./ai-server/models
AI_MODEL_DEFAULT=llama2:7b-chat

# Cloudflare Configuration
CLOUDFLARE_TUNNEL_TOKEN=your_tunnel_token_here
CLOUDFLARE_ACCOUNT_ID=your_account_id_here

# Application Configuration
NODE_ENV=production
LOG_LEVEL=info
MAX_CONCURRENT_USERS=100

# Backup Configuration
BACKUP_SCHEDULE=0 2 * * *  # Daily at 2 AM
BACKUP_RETENTION_DAYS=30
```

---

## ☁️ **CLOUDFLARE TUNNEL SETUP**

### **🔧 Bước 1: Tạo Tunnel**
```bash
# Cài đặt cloudflared
# Windows
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe -o cloudflared.exe

# Linux
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
chmod +x cloudflared

# Đăng nhập Cloudflare
./cloudflared tunnel login

# Tạo tunnel mới
./cloudflared tunnel create nextflow-crm-ai

# Lấy tunnel ID và credentials
# Sao chép file credentials.json vào thư mục cloudflare/
```

### **📄 File cloudflare/tunnel-config.yml:**
```yaml
tunnel: nextflow-crm-ai
credentials-file: /etc/cloudflared/credentials.json

# Cấu hình ingress rules
ingress:
  # Main application
  - hostname: nextflow-crm-ai.yourdomain.com
    service: http://nginx:80
    
  # API endpoint
  - hostname: api.nextflow-crm-ai.yourdomain.com
    service: http://nginx:80
    path: /api/*
    
  # AI endpoint (nếu cần expose trực tiếp)
  - hostname: ai.nextflow-crm-ai.yourdomain.com
    service: http://ai-server:11434
    
  # Admin dashboard
  - hostname: admin.nextflow-crm-ai.yourdomain.com
    service: http://nginx:80
    path: /admin/*
    
  # Catch-all rule (bắt buộc phải có)
  - service: http_status:404

# Cấu hình bổ sung
originRequest:
  connectTimeout: 30s
  tlsTimeout: 30s
  tcpKeepAlive: 30s
  noHappyEyeballs: false
  keepAliveTimeout: 90s
  keepAliveConnections: 100

# Logging
logLevel: info
logFile: /var/log/cloudflared.log
```

### **🌐 Cấu hình DNS:**
```bash
# Thêm CNAME records trong Cloudflare Dashboard:
# nextflow-crm-ai.yourdomain.com → tunnel-id.cfargotunnel.com
# api.nextflow-crm-ai.yourdomain.com → tunnel-id.cfargotunnel.com
# ai.nextflow-crm-ai.yourdomain.com → tunnel-id.cfargotunnel.com
# admin.nextflow-crm-ai.yourdomain.com → tunnel-id.cfargotunnel.com
```

---

## 🚀 **TRIỂN KHAI VÀ CHẠY HỆ THỐNG**

### **📋 Checklist chuẩn bị:**
```bash
# 1. Cài đặt Docker và Docker Compose
# Windows: Docker Desktop
# Linux: 
sudo apt update
sudo apt install docker.io docker-compose-plugin

# 2. Cài đặt NVIDIA Container Toolkit (cho GPU)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# 3. Clone project và setup
git clone https://github.com/your-repo/nextflow-crm-ai.git
cd nextflow-crm-ai
cp .env.example .env
# Chỉnh sửa .env với thông tin thực tế
```

### **🏃 Khởi động hệ thống:**
```bash
# Build và start tất cả containers
docker-compose up -d --build

# Kiểm tra trạng thái containers
docker-compose ps

# Xem logs
docker-compose logs -f

# Kiểm tra health của từng service
docker-compose exec nginx curl -f http://localhost/health
docker-compose exec backend curl -f http://localhost:3000/api/health
docker-compose exec ai-server curl -f http://localhost:11434/api/tags
```

### **🤖 Setup AI Models:**
```bash
# Vào container AI server
docker-compose exec ai-server bash

# Tải AI models
ollama pull llama2:7b-chat
ollama pull codellama:7b
ollama pull mistral:7b

# Kiểm tra models đã tải
ollama list

# Test AI
ollama run llama2:7b-chat "Xin chào, bạn có thể giúp tôi gì?"
```

---

## 📊 **GIÁM SÁT VÀ LOGGING**

### **🔍 Monitoring Commands:**
```bash
# Xem resource usage
docker stats

# Xem logs real-time
docker-compose logs -f --tail=100

# Xem logs của service cụ thể
docker-compose logs -f backend
docker-compose logs -f ai-server

# Kiểm tra disk usage
docker system df

# Cleanup unused resources
docker system prune -a
```

### **📈 Health Check Dashboard:**
```bash
# Tạo script health-check.sh
#!/bin/bash
echo "=== NextFlow CRM-AI Health Check ==="
echo "Thời gian: $(date)"
echo ""

# Check containers
echo "📦 Container Status:"
docker-compose ps

echo ""
echo "🔍 Health Checks:"

# Nginx
if curl -f -s http://localhost/health > /dev/null; then
    echo "✅ Nginx: Healthy"
else
    echo "❌ Nginx: Unhealthy"
fi

# Backend API
if curl -f -s http://localhost:3000/api/health > /dev/null; then
    echo "✅ Backend API: Healthy"
else
    echo "❌ Backend API: Unhealthy"
fi

# AI Server
if curl -f -s http://localhost:11434/api/tags > /dev/null; then
    echo "✅ AI Server: Healthy"
else
    echo "❌ AI Server: Unhealthy"
fi

# Database
if docker-compose exec -T postgres pg_isready -U nextflow -d nextflow_db > /dev/null; then
    echo "✅ PostgreSQL: Healthy"
else
    echo "❌ PostgreSQL: Unhealthy"
fi

echo ""
echo "💻 System Resources:"
echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "Memory: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')"
echo "Disk: $(df -h / | awk 'NR==2{printf "%s", $5}')"

# Chạy mỗi 5 phút
# */5 * * * * /path/to/health-check.sh >> /var/log/nextflow-health.log
```

---

**Cập nhật lần cuối**: 2025-08-01  
**Tác giả**: NextFlow Team  
**Phiên bản**: Bootstrap v1.0 - Docker + Cloudflare
