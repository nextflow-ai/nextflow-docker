# Profile Langflow - AI Workflow Platform

## Tổng quan

Profile Langflow triển khai Langflow AI Platform - một nền tảng low-code/no-code để xây dựng và triển khai các AI workflows phức tạp. Langflow tích hợp với LangChain, OpenAI, và các AI frameworks khác, cho phép người dùng tạo ra các ứng dụng AI mạnh mẽ thông qua giao diện kéo-thả trực quan.

## Dịch vụ bao gồm

### 1. PostgreSQL Database
- **Mục đích**: Cơ sở dữ liệu chính lưu trữ workflows, components và cấu hình
- **Port**: 5432 (internal)
- **Database**: `langflow_db`
- **User**: `nextflow`
- **Password**: `nextflow@2025`

### 2. Redis Cache
- **Mục đích**: Cache và session management cho Langflow
- **Port**: 6379 (internal)
- **Database**: 1 (dành riêng cho Langflow)
- **Password**: `nextflow@2025`

### 3. Langflow Platform
- **Mục đích**: AI Workflow Platform chính
- **Port**: 7860
- **Username**: admin
- **Password**: `nextflow@2025`
- **Version**: 1.0.0a56

### 4. Cloudflare Tunnel AI (Tùy chọn)
- **Mục đích**: Truy cập từ xa qua Cloudflare
- **URL**: https://langflow.nextflow.vn

## Cách triển khai

### 1. Triển khai qua Command Line

```bash
# Triển khai profile langflow
./scripts/deploy.sh --profile langflow

# Xem trước triển khai (dry-run)
./scripts/deploy.sh --dry-run --profile langflow

# Triển khai với force (bỏ qua port conflicts)
./scripts/deploy.sh --profile langflow --force
```

### 2. Triển khai qua Interactive Mode

```bash
# Chạy chế độ tương tác
./scripts/deploy.sh

# Chọn option 4: "🔗 Triển khai Profile Langflow (AI Workflow Platform)"
```

### 3. Triển khai kết hợp với profiles khác

```bash
# Triển khai cùng với basic profile
./scripts/deploy.sh --profiles basic,langflow

# Triển khai cùng với AI profile
./scripts/deploy.sh --profiles ai,langflow
```

## Truy cập dịch vụ

### Langflow Web Interface
- **URL Local**: http://localhost:7860
- **URL Production**: https://langflow.nextflow.vn
- **Username**: admin
- **Password**: nextflow@2025

### Database Access
- **PostgreSQL**: localhost:5432
- **Database**: langflow_db
- **Username**: nextflow
- **Password**: nextflow@2025

### Redis Cache
- **Host**: localhost:6379
- **Database**: 1
- **Password**: nextflow@2025

## Thư mục dữ liệu

### Workflows
- **Đường dẫn**: `./langflow/flows/`
- **Mục đích**: Lưu trữ các custom workflows

### Components
- **Đường dẫn**: `./langflow/components/`
- **Mục đích**: Lưu trữ các custom components

### Shared Data
- **Đường dẫn**: `./shared/`
- **Mục đích**: Thư mục chia sẻ dữ liệu giữa các services

## Quản lý dịch vụ

### Xem trạng thái
```bash
./scripts/deploy.sh --status
```

### Xem logs
```bash
# Xem logs Langflow
./scripts/deploy.sh --logs langflow

# Xem logs PostgreSQL
./scripts/deploy.sh --logs postgres

# Xem logs Redis
./scripts/deploy.sh --logs redis
```

### Dừng dịch vụ
```bash
# Dừng tất cả dịch vụ
./scripts/deploy.sh --stop

# Force stop
./scripts/deploy.sh --force-stop
```

### Khởi động lại
```bash
./scripts/deploy.sh --restart
```

## Tính năng nâng cao

### 1. Checkpoint và Rollback
```bash
# Tạo checkpoint trước khi triển khai
./scripts/deploy.sh --checkpoint langflow-backup-$(date +%Y%m%d)

# Rollback về checkpoint
./scripts/deploy.sh --rollback langflow-backup-20250617
```

### 2. Cập nhật Images
```bash
./scripts/deploy.sh --update
```

### 3. Dọn dẹp tài nguyên
```bash
./scripts/deploy.sh --cleanup
```

## Cấu hình môi trường

Các biến môi trường quan trọng trong file `.env`:

```env
# Langflow Configuration
LANGFLOW_SECRET_KEY=nextflow-langflow-secret-key-minimum-32-characters-2025
LANGFLOW_JWT_SECRET=nextflow-langflow-jwt-secret-key-minimum-32-characters-2025
LANGFLOW_SUPERUSER_PASSWORD=nextflow@2025
LANGFLOW_PORT=7860
LANGFLOW_URL=https://langflow.nextflow.vn

# Database Configuration
POSTGRES_USER=nextflow
POSTGRES_PASSWORD=nextflow@2025
POSTGRES_DB=nextflow
POSTGRES_MULTIPLE_DATABASES=nextflow_n8n,keycloak,gitlabhq_production,langflow_db,nextflow_stalwart_mail

# Redis Configuration
REDIS_PASSWORD=nextflow@2025
```

## Troubleshooting

### 1. Langflow không khởi động
```bash
# Kiểm tra logs
docker logs langflow

# Kiểm tra database connection
docker exec postgres pg_isready -U nextflow

# Kiểm tra Redis
docker exec redis redis-cli ping
```

### 2. Port 7860 bị chiếm
```bash
# Kiểm tra process sử dụng port
netstat -tulpn | grep 7860

# Triển khai với force
./scripts/deploy.sh --profile langflow --force
```

### 3. Database connection error
```bash
# Kiểm tra database tồn tại
docker exec postgres psql -U nextflow -l | grep langflow_db

# Tạo lại database
docker exec postgres psql -U nextflow -c "CREATE DATABASE langflow_db;"
```

### 4. Thu thập thông tin chẩn đoán
```bash
# Script sẽ tự động thu thập khi có lỗi
# Hoặc có thể xem thủ công:
docker ps -a
docker logs langflow
docker logs postgres
docker logs redis
```

## Tích hợp với các services khác

### 1. Với n8n Automation
- Langflow có thể tạo workflows và export thành API
- n8n có thể gọi các API này để tích hợp vào automation flows

### 2. Với Flowise AI
- Cả hai đều là AI platforms, có thể sử dụng song song
- Langflow tập trung vào LangChain workflows
- Flowise tập trung vào chatbots và conversational AI

### 3. Với Open WebUI
- Langflow có thể tạo custom AI models/workflows
- Open WebUI có thể sử dụng các models này thông qua API

## Bảo mật

### 1. Thay đổi mật khẩu mặc định
```bash
# Cập nhật trong file .env
LANGFLOW_SUPERUSER_PASSWORD=your-secure-password
```

### 2. Cấu hình HTTPS
- Sử dụng Cloudflare Tunnel cho production
- Cấu hình SSL certificates nếu cần

### 3. Database Security
- Sử dụng strong passwords
- Giới hạn network access
- Regular backups

## Backup và Restore

### 1. Backup dữ liệu
```bash
# Backup database
docker exec postgres pg_dump -U nextflow langflow_db > langflow_backup.sql

# Backup workflows
tar -czf langflow_flows_backup.tar.gz langflow/flows/

# Backup components
tar -czf langflow_components_backup.tar.gz langflow/components/
```

### 2. Restore dữ liệu
```bash
# Restore database
docker exec -i postgres psql -U nextflow langflow_db < langflow_backup.sql

# Restore workflows
tar -xzf langflow_flows_backup.tar.gz

# Restore components
tar -xzf langflow_components_backup.tar.gz
```

## Monitoring và Logs

### 1. Health Check
```bash
# Kiểm tra health endpoint
curl http://localhost:7860/health

# Kiểm tra API status
curl http://localhost:7860/api/v1/status
```

### 2. Performance Monitoring
- Sử dụng profile monitoring để theo dõi hiệu năng
- Kiểm tra resource usage qua Docker stats

### 3. Log Management
- Logs được lưu trong `langflow_logs` volume
- Có thể xem qua Docker logs hoặc truy cập trực tiếp

## Kết luận

Profile Langflow cung cấp một giải pháp hoàn chỉnh để triển khai AI Workflow Platform trong môi trường NextFlow Docker. Với các tính năng tự động hóa, monitoring và backup tích hợp, việc quản lý và vận hành Langflow trở nên đơn giản và hiệu quả.
