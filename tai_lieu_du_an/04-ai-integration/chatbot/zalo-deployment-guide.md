# HƯỚNG DẪN TRIỂN KHAI ZALO CHATBOT

## MỤC LỤC

1. [Chuẩn bị môi trường](#1-chuẩn-bị-môi-trường)
2. [Cài đặt và cấu hình](#2-cài-đặt-và-cấu-hình)
3. [Triển khai từng bước](#3-triển-khai-từng-bước)
4. [Testing và Validation](#4-testing-và-validation)
5. [Go-live Checklist](#5-go-live-checklist)
6. [Monitoring và Maintenance](#6-monitoring-và-maintenance)

## 1. CHUẨN BỊ MÔI TRƯỜNG

### 1.1. Yêu cầu hệ thống

#### Server Requirements
```bash
# Minimum requirements
CPU: 4 cores
RAM: 8GB
Storage: 100GB SSD
Network: 100Mbps

# Recommended for production
CPU: 8 cores
RAM: 16GB
Storage: 500GB SSD
Network: 1Gbps
```

#### Software Dependencies
```bash
# Node.js và npm
node --version  # >= 18.0.0
npm --version   # >= 8.0.0

# Docker và Docker Compose
docker --version        # >= 20.0.0
docker-compose --version # >= 2.0.0

# PostgreSQL
psql --version  # >= 13.0

# Redis
redis-cli --version # >= 6.0
```

### 1.2. Zalo Official Account Setup

#### Bước 1: Đăng ký Zalo OA
1. Truy cập https://oa.zalo.me/
2. Đăng ký tài khoản doanh nghiệp
3. Hoàn thành xác minh danh tính
4. Chờ phê duyệt (2-5 ngày làm việc)

#### Bước 2: Lấy API Credentials
```bash
# Thông tin cần thu thập
ZALO_APP_ID=your_app_id
ZALO_APP_SECRET=your_app_secret
ZALO_OA_ID=your_oa_id
ZALO_ACCESS_TOKEN=your_access_token
```

#### Bước 3: Cấu hình Webhook URL
```
Webhook URL: https://your-domain.com/api/webhook/zalo/chat
Verify Token: your_custom_verify_token
Events: user_send_text, user_send_image, user_send_sticker
```

### 1.3. SSL Certificate Setup

```bash
# Sử dụng Let's Encrypt
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com

# Hoặc sử dụng Cloudflare SSL
# Cấu hình trong Cloudflare dashboard
```

## 2. CÀI ĐẶT VÀ CẤU HÌNH

### 2.1. Clone Repository

```bash
# Clone NextFlow CRM
git clone https://github.com/nextflow-crm/nextflow-crm.git
cd nextflow-crm

# Checkout branch có Zalo integration
git checkout feature/zalo-integration
```

### 2.2. Environment Configuration

```bash
# Copy environment template
cp .env.example .env.production

# Cấu hình các biến môi trường
nano .env.production
```

#### Environment Variables
```bash
# NextFlow CRM Core
NODE_ENV=production
APP_URL=https://your-domain.com
API_URL=https://api.your-domain.com
DATABASE_URL=postgresql://user:password@localhost:5432/nextflow_crm

# Zalo Configuration
ZALO_APP_ID=your_zalo_app_id
ZALO_APP_SECRET=your_zalo_app_secret
ZALO_ACCESS_TOKEN=your_zalo_access_token
ZALO_WEBHOOK_VERIFY_TOKEN=your_verify_token

# n8n Configuration
N8N_HOST=n8n.your-domain.com
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=secure_password

# Flowise Configuration
FLOWISE_HOST=flowise.your-domain.com
FLOWISE_PORT=3000
FLOWISE_API_KEY=your_flowise_api_key

# AI Models
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key
GOOGLE_AI_API_KEY=your_google_ai_key

# Redis
REDIS_URL=redis://localhost:6379

# Monitoring
SENTRY_DSN=your_sentry_dsn
LOG_LEVEL=info
```

### 2.3. Docker Compose Setup

```yaml
# docker-compose.production.yml
version: '3.8'

services:
  nextflow-api:
    build: 
      context: .
      dockerfile: Dockerfile.production
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    env_file:
      - .env.production
    depends_on:
      - postgres
      - redis
    restart: unless-stopped

  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - WEBHOOK_URL=https://${N8N_HOST}/
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
    env_file:
      - .env.production
    volumes:
      - n8n_data:/home/node/.n8n
      - ./n8n/workflows:/home/node/.n8n/workflows
    depends_on:
      - postgres
    restart: unless-stopped

  flowise:
    image: flowiseai/flowise:latest
    ports:
      - "3001:3000"
    environment:
      - PORT=3000
      - FLOWISE_USERNAME=admin
      - FLOWISE_PASSWORD=${FLOWISE_PASSWORD}
    volumes:
      - flowise_data:/root/.flowise
    restart: unless-stopped

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=nextflow_crm
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - nextflow-api
      - n8n
      - flowise
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  n8n_data:
  flowise_data:
```

## 3. TRIỂN KHAI TỪNG BƯỚC

### 3.1. Database Setup

```bash
# Tạo database
createdb nextflow_crm

# Chạy migrations
npm run migrate:production

# Seed initial data
npm run seed:production
```

### 3.2. Deploy Services

```bash
# Build và start services
docker-compose -f docker-compose.production.yml up -d

# Kiểm tra status
docker-compose ps

# Xem logs
docker-compose logs -f nextflow-api
```

### 3.3. N8n Workflow Import

```bash
# Import Zalo workflows
curl -X POST "https://n8n.your-domain.com/api/v1/workflows/import" \
  -H "Authorization: Basic $(echo -n admin:password | base64)" \
  -H "Content-Type: application/json" \
  -d @./n8n/workflows/zalo-customer-service.json

# Activate workflow
curl -X POST "https://n8n.your-domain.com/api/v1/workflows/1/activate" \
  -H "Authorization: Basic $(echo -n admin:password | base64)"
```

### 3.4. Flowise Chatflow Setup

```bash
# Import chatflow
curl -X POST "https://flowise.your-domain.com/api/v1/chatflows/import" \
  -H "Authorization: Bearer ${FLOWISE_API_KEY}" \
  -H "Content-Type: application/json" \
  -d @./flowise/chatflows/zalo-support-bot.json
```

### 3.5. Zalo Webhook Registration

```bash
# Đăng ký webhook với Zalo
curl -X POST "https://openapi.zalo.me/v2.0/oa/webhook" \
  -H "Content-Type: application/json" \
  -H "access_token: ${ZALO_ACCESS_TOKEN}" \
  -d '{
    "webhook": "https://api.your-domain.com/v1/webhook/zalo/chat",
    "types": ["user_send_text", "user_send_image", "user_send_sticker"]
  }'
```

## 4. TESTING VÀ VALIDATION

### 4.1. Health Checks

```bash
# API Health Check
curl https://api.your-domain.com/health

# N8n Health Check  
curl https://n8n.your-domain.com/healthz

# Flowise Health Check
curl https://flowise.your-domain.com/api/v1/ping
```

### 4.2. Webhook Testing

```bash
# Test webhook endpoint
curl -X POST "https://api.your-domain.com/v1/webhook/zalo/chat" \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "123456789",
    "user_id_by_app": "test_user",
    "timestamp": "1635321300000",
    "event_name": "user_send_text",
    "sender": {
      "id": "test_sender_id",
      "name": "Test User"
    },
    "message": {
      "text": "Hello test",
      "msg_id": "test_msg_123",
      "msg_type": "text"
    }
  }'
```

### 4.3. End-to-End Testing

```javascript
// Automated test script
const testCases = [
  {
    name: "Product Inquiry",
    input: "Tôi muốn tìm hiểu về sản phẩm CRM",
    expectedIntent: "product_inquiry",
    expectedResponse: "NextFlow CRM"
  },
  {
    name: "Support Request", 
    input: "Tôi gặp lỗi đăng nhập",
    expectedIntent: "support_request",
    expectedResponse: "hỗ trợ"
  }
];

// Run tests
for (const test of testCases) {
  const response = await sendTestMessage(test.input);
  console.log(`Test ${test.name}: ${response.success ? 'PASS' : 'FAIL'}`);
}
```

## 5. GO-LIVE CHECKLIST

### 5.1. Pre-launch Checklist

- [ ] SSL certificates installed and valid
- [ ] All environment variables configured
- [ ] Database migrations completed
- [ ] Zalo webhook registered and verified
- [ ] N8n workflows imported and activated
- [ ] Flowise chatflows configured
- [ ] Health checks passing
- [ ] End-to-end tests passing
- [ ] Monitoring and alerting configured
- [ ] Backup procedures in place
- [ ] Documentation updated

### 5.2. Launch Day Tasks

```bash
# 1. Final deployment
git pull origin main
docker-compose -f docker-compose.production.yml up -d

# 2. Verify all services
./scripts/health-check.sh

# 3. Enable monitoring
./scripts/enable-monitoring.sh

# 4. Notify team
./scripts/notify-launch.sh
```

### 5.3. Post-launch Monitoring

```bash
# Monitor logs for first 24 hours
tail -f /var/log/nextflow/app.log | grep -i error

# Check metrics dashboard
open https://monitoring.your-domain.com/dashboard/zalo-chatbot

# Monitor Zalo webhook delivery
curl "https://openapi.zalo.me/v2.0/oa/webhook/delivery" \
  -H "access_token: ${ZALO_ACCESS_TOKEN}"
```

## 6. MONITORING VÀ MAINTENANCE

### 6.1. Monitoring Setup

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'nextflow-api'
    static_configs:
      - targets: ['localhost:3000']
    metrics_path: '/metrics'

  - job_name: 'n8n'
    static_configs:
      - targets: ['localhost:5678']
    metrics_path: '/metrics'
```

### 6.2. Alerting Rules

```yaml
# alerts.yml
groups:
  - name: zalo-chatbot
    rules:
      - alert: WebhookFailureRate
        expr: rate(webhook_failures_total[5m]) > 0.1
        for: 2m
        annotations:
          summary: "High webhook failure rate"
          
      - alert: ResponseTimeHigh
        expr: avg_response_time > 5
        for: 1m
        annotations:
          summary: "Chatbot response time too high"
```

### 6.3. Maintenance Tasks

```bash
# Daily maintenance script
#!/bin/bash

# Cleanup old logs
find /var/log/nextflow -name "*.log" -mtime +7 -delete

# Database maintenance
psql -d nextflow_crm -c "VACUUM ANALYZE;"

# Check disk space
df -h | grep -E "(80%|90%|100%)" && echo "Disk space warning"

# Restart services if needed
docker-compose restart redis
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 1.0.0  
**Tác giả**: NextFlow DevOps Team
