# TRIỂN KHAI LANGFLOW VỚI DOCKER

## 📋 TỔNG QUAN

Tài liệu này hướng dẫn triển khai Langflow sử dụng Docker và Docker Compose để tích hợp vào hệ thống NextFlow CRM.

## 🐳 DOCKERFILE

### Langflow Dockerfile
```dockerfile
# Dockerfile
FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    LANGFLOW_HOST=0.0.0.0 \
    LANGFLOW_PORT=7860

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Create non-root user
RUN groupadd -r langflow && useradd -r -g langflow langflow

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p /app/logs /app/data && \
    chown -R langflow:langflow /app

# Switch to non-root user
USER langflow

# Expose port
EXPOSE 7860

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:7860/health || exit 1

# Start command
CMD ["langflow", "run", "--host", "0.0.0.0", "--port", "7860"]
```

### Requirements.txt
```txt
# requirements.txt
langflow[all]==1.0.0
gunicorn==21.2.0
psycopg2-binary==2.9.7
redis==4.6.0
prometheus-client==0.17.1
openai==1.3.0
anthropics==0.8.0
google-generativeai==0.3.0
requests==2.31.0
pydantic==2.4.0
fastapi==0.104.0
uvicorn==0.24.0
```

## 🐙 DOCKER COMPOSE

### Production Docker Compose
```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  langflow:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: nextflow-langflow
    restart: unless-stopped
    ports:
      - "7860:7860"
    environment:
      - LANGFLOW_DATABASE_URL=postgresql://langflow_user:${POSTGRES_PASSWORD}@postgres:5432/langflow_db
      - LANGFLOW_REDIS_URL=redis://redis:6379/0
      - LANGFLOW_SECRET_KEY=${LANGFLOW_SECRET_KEY}
      - LANGFLOW_JWT_SECRET=${LANGFLOW_JWT_SECRET}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - GOOGLE_AI_API_KEY=${GOOGLE_AI_API_KEY}
    volumes:
      - langflow_data:/app/data
      - langflow_logs:/app/logs
      - ./config:/app/config:ro
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - nextflow-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:7860/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  postgres:
    image: postgres:15-alpine
    container_name: nextflow-langflow-postgres
    restart: unless-stopped
    environment:
      - POSTGRES_DB=langflow_db
      - POSTGRES_USER=langflow_user
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
    networks:
      - nextflow-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U langflow_user -d langflow_db"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: nextflow-langflow-redis
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - nextflow-network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  nginx:
    image: nginx:alpine
    container_name: nextflow-langflow-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - nginx_logs:/var/log/nginx
    depends_on:
      - langflow
    networks:
      - nextflow-network

volumes:
  langflow_data:
    driver: local
  langflow_logs:
    driver: local
  postgres_data:
    driver: local
  redis_data:
    driver: local
  nginx_logs:
    driver: local

networks:
  nextflow-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Development Docker Compose
```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  langflow-dev:
    build:
      context: .
      dockerfile: Dockerfile.dev
    container_name: nextflow-langflow-dev
    ports:
      - "7860:7860"
      - "5678:5678"  # Debug port
    environment:
      - LANGFLOW_ENV=development
      - LANGFLOW_DEBUG=true
      - LANGFLOW_DATABASE_URL=postgresql://langflow_user:dev_password@postgres-dev:5432/langflow_dev
      - LANGFLOW_REDIS_URL=redis://redis-dev:6379/0
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - postgres-dev
      - redis-dev
    networks:
      - nextflow-dev-network

  postgres-dev:
    image: postgres:15-alpine
    container_name: nextflow-langflow-postgres-dev
    environment:
      - POSTGRES_DB=langflow_dev
      - POSTGRES_USER=langflow_user
      - POSTGRES_PASSWORD=dev_password
    ports:
      - "5433:5432"
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data
    networks:
      - nextflow-dev-network

  redis-dev:
    image: redis:7-alpine
    container_name: nextflow-langflow-redis-dev
    ports:
      - "6380:6379"
    volumes:
      - redis_dev_data:/data
    networks:
      - nextflow-dev-network

volumes:
  postgres_dev_data:
  redis_dev_data:

networks:
  nextflow-dev-network:
    driver: bridge
```

## ⚙️ CẤU HÌNH NGINX

### Nginx Configuration
```nginx
# nginx/nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream langflow_backend {
        server langflow:7860;
    }
    
    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    
    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # HTTP to HTTPS redirect
    server {
        listen 80;
        server_name langflow.nextflow.com;
        return 301 https://$server_name$request_uri;
    }
    
    # HTTPS Server
    server {
        listen 443 ssl http2;
        server_name langflow.nextflow.com;
        
        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/private.key;
        
        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        
        # Gzip compression
        gzip on;
        gzip_vary on;
        gzip_min_length 1024;
        gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
        
        # API endpoints
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://langflow_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }
        
        # WebSocket support
        location /ws/ {
            proxy_pass http://langflow_backend;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Static files
        location / {
            proxy_pass http://langflow_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Health check
        location /health {
            access_log off;
            proxy_pass http://langflow_backend/health;
        }
    }
}
```

## 🔐 ENVIRONMENT VARIABLES

### Production Environment
```bash
# .env.prod
# Database
POSTGRES_PASSWORD=super_secure_password_here

# Redis
REDIS_PASSWORD=redis_secure_password_here

# Langflow
LANGFLOW_SECRET_KEY=your-super-secret-key-minimum-32-characters
LANGFLOW_JWT_SECRET=your-jwt-secret-key-minimum-32-characters

# AI API Keys
OPENAI_API_KEY=sk-your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key
GOOGLE_AI_API_KEY=your-google-ai-api-key

# Monitoring
PROMETHEUS_ENABLED=true
GRAFANA_ENABLED=true

# Logging
LOG_LEVEL=INFO
LOG_FORMAT=json
```

### Development Environment
```bash
# .env.dev
# Database
POSTGRES_PASSWORD=dev_password

# Redis
REDIS_PASSWORD=dev_redis_password

# Langflow
LANGFLOW_SECRET_KEY=dev-secret-key-for-development-only
LANGFLOW_JWT_SECRET=dev-jwt-secret-for-development-only
LANGFLOW_DEBUG=true

# AI API Keys (development)
OPENAI_API_KEY=sk-dev-openai-key
ANTHROPIC_API_KEY=dev-anthropic-key

# Logging
LOG_LEVEL=DEBUG
LOG_FORMAT=text
```

## 🚀 TRIỂN KHAI

### 1. Chuẩn bị môi trường
```bash
# Tạo thư mục dự án
mkdir nextflow-langflow
cd nextflow-langflow

# Clone repository hoặc copy files
git clone <repository-url> .

# Tạo thư mục cần thiết
mkdir -p nginx/ssl config init-scripts

# Copy SSL certificates
cp /path/to/ssl/cert.pem nginx/ssl/
cp /path/to/ssl/private.key nginx/ssl/

# Set permissions
chmod 600 nginx/ssl/private.key
```

### 2. Cấu hình environment
```bash
# Copy và chỉnh sửa environment file
cp .env.example .env.prod
nano .env.prod

# Generate secure keys
openssl rand -hex 32  # For LANGFLOW_SECRET_KEY
openssl rand -hex 32  # For LANGFLOW_JWT_SECRET
```

### 3. Build và khởi động
```bash
# Build images
docker-compose -f docker-compose.prod.yml build

# Khởi động services
docker-compose -f docker-compose.prod.yml up -d

# Kiểm tra status
docker-compose -f docker-compose.prod.yml ps

# Xem logs
docker-compose -f docker-compose.prod.yml logs -f langflow
```

### 4. Database initialization
```bash
# Chạy migrations
docker-compose -f docker-compose.prod.yml exec langflow langflow migration upgrade

# Tạo superuser
docker-compose -f docker-compose.prod.yml exec langflow langflow superuser create
```

## 📊 MONITORING VÀ LOGGING

### Docker Compose với Monitoring
```yaml
# monitoring.yml (thêm vào docker-compose.prod.yml)
services:
  prometheus:
    image: prom/prometheus:latest
    container_name: nextflow-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    networks:
      - nextflow-network

  grafana:
    image: grafana/grafana:latest
    container_name: nextflow-grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
    networks:
      - nextflow-network

  loki:
    image: grafana/loki:latest
    container_name: nextflow-loki
    ports:
      - "3100:3100"
    volumes:
      - ./monitoring/loki.yml:/etc/loki/local-config.yaml:ro
      - loki_data:/loki
    networks:
      - nextflow-network

volumes:
  prometheus_data:
  grafana_data:
  loki_data:
```

### Prometheus Configuration
```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'langflow'
    static_configs:
      - targets: ['langflow:7860']
    metrics_path: '/metrics'
    scrape_interval: 30s

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:80']
```

## 🔧 MAINTENANCE

### Backup Scripts
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/langflow"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup database
docker-compose -f docker-compose.prod.yml exec -T postgres pg_dump -U langflow_user langflow_db > $BACKUP_DIR/db_backup_$DATE.sql

# Backup volumes
docker run --rm -v nextflow-langflow_langflow_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/langflow_data_$DATE.tar.gz -C /data .

# Cleanup old backups (keep last 7 days)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

### Update Scripts
```bash
#!/bin/bash
# update.sh

echo "Starting Langflow update..."

# Pull latest images
docker-compose -f docker-compose.prod.yml pull

# Backup before update
./backup.sh

# Stop services
docker-compose -f docker-compose.prod.yml down

# Start services with new images
docker-compose -f docker-compose.prod.yml up -d

# Run migrations
docker-compose -f docker-compose.prod.yml exec langflow langflow migration upgrade

# Health check
sleep 30
if curl -f http://localhost:7860/health; then
    echo "Update successful!"
else
    echo "Update failed! Rolling back..."
    # Rollback logic here
fi
```

## 🐛 TROUBLESHOOTING

### Common Issues

#### 1. Container không khởi động
```bash
# Kiểm tra logs
docker-compose -f docker-compose.prod.yml logs langflow

# Kiểm tra resource usage
docker stats

# Kiểm tra network
docker network ls
docker network inspect nextflow-langflow_nextflow-network
```

#### 2. Database connection issues
```bash
# Test database connection
docker-compose -f docker-compose.prod.yml exec postgres psql -U langflow_user -d langflow_db -c "SELECT 1;"

# Check database logs
docker-compose -f docker-compose.prod.yml logs postgres
```

#### 3. Performance issues
```bash
# Monitor resource usage
docker stats --no-stream

# Check disk usage
docker system df

# Clean up unused resources
docker system prune -f
```

---

*Tài liệu triển khai Docker Langflow - Phiên bản 1.0*