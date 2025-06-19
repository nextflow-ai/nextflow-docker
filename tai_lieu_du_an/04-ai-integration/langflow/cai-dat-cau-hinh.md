# CÀI ĐẶT VÀ CẤU HÌNH LANGFLOW

## 📋 TỔNG QUAN

Tài liệu này hướng dẫn chi tiết cách cài đặt và cấu hình Langflow để tích hợp vào hệ thống NextFlow CRM.

## 🔧 YÊU CẦU HỆ THỐNG

### Minimum Requirements
- **OS**: Ubuntu 20.04+ / CentOS 8+ / Windows 10+
- **CPU**: 2 cores
- **RAM**: 4GB
- **Storage**: 20GB free space
- **Python**: 3.8+
- **Node.js**: 16+

### Recommended Requirements
- **OS**: Ubuntu 22.04 LTS
- **CPU**: 4+ cores
- **RAM**: 8GB+
- **Storage**: 50GB+ SSD
- **Python**: 3.10+
- **Node.js**: 18+

## 🐍 CÀI ĐẶT PYTHON VÀ DEPENDENCIES

### 1. Cài đặt Python và pip
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3.10 python3.10-pip python3.10-venv

# CentOS/RHEL
sudo dnf install python3.10 python3.10-pip

# Windows (sử dụng chocolatey)
choco install python --version=3.10.0
```

### 2. Tạo virtual environment
```bash
# Tạo virtual environment
python3.10 -m venv langflow-env

# Kích hoạt virtual environment
# Linux/Mac
source langflow-env/bin/activate

# Windows
langflow-env\Scripts\activate
```

### 3. Cài đặt Langflow
```bash
# Cài đặt từ PyPI
pip install langflow

# Hoặc cài đặt phiên bản development
pip install langflow[dev]

# Cài đặt với tất cả dependencies
pip install "langflow[all]"
```

## 🗄️ CẤU HÌNH DATABASE

### PostgreSQL Setup
```sql
-- Tạo database cho Langflow
CREATE DATABASE langflow_db;

-- Tạo user cho Langflow
CREATE USER langflow_user WITH PASSWORD 'secure_password';

-- Cấp quyền
GRANT ALL PRIVILEGES ON DATABASE langflow_db TO langflow_user;
GRANT ALL ON SCHEMA public TO langflow_user;
```

### Environment Variables
```bash
# Database configuration
export LANGFLOW_DATABASE_URL="postgresql://langflow_user:secure_password@localhost:5432/langflow_db"
export LANGFLOW_CACHE_TYPE="redis"
export LANGFLOW_REDIS_URL="redis://localhost:6379/0"

# Security
export LANGFLOW_SECRET_KEY="your-super-secret-key-here"
export LANGFLOW_JWT_SECRET="your-jwt-secret-here"

# API Configuration
export LANGFLOW_HOST="0.0.0.0"
export LANGFLOW_PORT="7860"
export LANGFLOW_WORKERS="4"

# Logging
export LANGFLOW_LOG_LEVEL="INFO"
export LANGFLOW_LOG_FILE="/var/log/langflow/langflow.log"
```

## ⚙️ CẤU HÌNH LANGFLOW

### 1. Tạo file cấu hình
```yaml
# config.yaml
database:
  url: "postgresql://langflow_user:secure_password@localhost:5432/langflow_db"
  pool_size: 10
  max_overflow: 20

cache:
  type: "redis"
  url: "redis://localhost:6379/0"
  ttl: 3600

security:
  secret_key: "your-super-secret-key-here"
  jwt_secret: "your-jwt-secret-here"
  cors_origins:
    - "http://localhost:3000"
    - "https://your-nextflow-domain.com"

api:
  host: "0.0.0.0"
  port: 7860
  workers: 4
  timeout: 300

logging:
  level: "INFO"
  file: "/var/log/langflow/langflow.log"
  max_size: "100MB"
  backup_count: 5

ai_models:
  openai:
    api_key: "${OPENAI_API_KEY}"
    base_url: "https://api.openai.com/v1"
  anthropic:
    api_key: "${ANTHROPIC_API_KEY}"
  google:
    api_key: "${GOOGLE_AI_API_KEY}"
```

### 2. Khởi tạo database
```bash
# Chạy migrations
langflow migration upgrade

# Tạo superuser
langflow superuser create
```

## 🔐 CẤU HÌNH BẢO MẬT

### 1. SSL/TLS Configuration
```nginx
# nginx.conf
server {
    listen 443 ssl http2;
    server_name langflow.your-domain.com;
    
    ssl_certificate /path/to/ssl/cert.pem;
    ssl_certificate_key /path/to/ssl/private.key;
    
    location / {
        proxy_pass http://127.0.0.1:7860;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### 2. Firewall Configuration
```bash
# UFW (Ubuntu)
sudo ufw allow 7860/tcp
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp

# iptables
sudo iptables -A INPUT -p tcp --dport 7860 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

## 🚀 KHỞI ĐỘNG LANGFLOW

### 1. Development Mode
```bash
# Khởi động với cấu hình development
langflow run --host 0.0.0.0 --port 7860 --dev

# Với file cấu hình tùy chỉnh
langflow run --config config.yaml
```

### 2. Production Mode
```bash
# Sử dụng gunicorn
gunicorn langflow.main:app \
    --bind 0.0.0.0:7860 \
    --workers 4 \
    --worker-class uvicorn.workers.UvicornWorker \
    --timeout 300 \
    --keep-alive 2 \
    --max-requests 1000 \
    --max-requests-jitter 100
```

### 3. Systemd Service
```ini
# /etc/systemd/system/langflow.service
[Unit]
Description=Langflow AI Platform
After=network.target postgresql.service redis.service
Requires=postgresql.service redis.service

[Service]
Type=exec
User=langflow
Group=langflow
WorkingDirectory=/opt/langflow
Environment=PATH=/opt/langflow/langflow-env/bin
EnvironmentFile=/opt/langflow/.env
ExecStart=/opt/langflow/langflow-env/bin/gunicorn langflow.main:app --bind 0.0.0.0:7860 --workers 4 --worker-class uvicorn.workers.UvicornWorker
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Kích hoạt service
sudo systemctl daemon-reload
sudo systemctl enable langflow
sudo systemctl start langflow
sudo systemctl status langflow
```

## 🔍 KIỂM TRA CÀI ĐẶT

### 1. Health Check
```bash
# Kiểm tra API health
curl http://localhost:7860/health

# Kiểm tra database connection
curl http://localhost:7860/api/v1/health/db

# Kiểm tra cache connection
curl http://localhost:7860/api/v1/health/cache
```

### 2. Web Interface
```
# Truy cập web interface
http://localhost:7860

# Login với superuser đã tạo
Username: admin
Password: [password bạn đã tạo]
```

## 🐛 TROUBLESHOOTING

### Lỗi thường gặp

#### 1. Database Connection Error
```bash
# Kiểm tra PostgreSQL service
sudo systemctl status postgresql

# Kiểm tra connection
psql -h localhost -U langflow_user -d langflow_db

# Kiểm tra firewall
sudo ufw status
```

#### 2. Redis Connection Error
```bash
# Kiểm tra Redis service
sudo systemctl status redis

# Test Redis connection
redis-cli ping

# Kiểm tra Redis config
sudo nano /etc/redis/redis.conf
```

#### 3. Permission Errors
```bash
# Cấp quyền cho thư mục log
sudo mkdir -p /var/log/langflow
sudo chown langflow:langflow /var/log/langflow
sudo chmod 755 /var/log/langflow

# Cấp quyền cho thư mục data
sudo chown -R langflow:langflow /opt/langflow
```

### Log Analysis
```bash
# Xem log realtime
tail -f /var/log/langflow/langflow.log

# Xem log với filter
grep "ERROR" /var/log/langflow/langflow.log

# Xem systemd logs
sudo journalctl -u langflow -f
```

## 📊 MONITORING

### Metrics Collection
```python
# metrics.py
from prometheus_client import Counter, Histogram, Gauge

# Define metrics
request_count = Counter('langflow_requests_total', 'Total requests')
request_duration = Histogram('langflow_request_duration_seconds', 'Request duration')
active_flows = Gauge('langflow_active_flows', 'Number of active flows')
```

### Health Monitoring
```bash
# Script kiểm tra health
#!/bin/bash
# health_check.sh

HEALTH_URL="http://localhost:7860/health"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_URL)

if [ $RESPONSE -eq 200 ]; then
    echo "Langflow is healthy"
    exit 0
else
    echo "Langflow is unhealthy (HTTP $RESPONSE)"
    exit 1
fi
```

## 🔄 BACKUP VÀ RESTORE

### Database Backup
```bash
# Backup database
pg_dump -h localhost -U langflow_user langflow_db > langflow_backup_$(date +%Y%m%d_%H%M%S).sql

# Restore database
psql -h localhost -U langflow_user langflow_db < langflow_backup_20240101_120000.sql
```

### Configuration Backup
```bash
# Backup cấu hình
tar -czf langflow_config_backup_$(date +%Y%m%d_%H%M%S).tar.gz \
    /opt/langflow/config.yaml \
    /opt/langflow/.env \
    /etc/systemd/system/langflow.service
```

---

*Tài liệu cài đặt Langflow - Phiên bản 1.0*