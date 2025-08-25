# QUY TRÌNH NÂNG CẤP NextFlow CRM-AI

## 1. TỔNG QUAN

Tài liệu này mô tả quy trình nâng cấp NextFlow CRM-AI từ phiên bản hiện tại lên phiên bản mới. Quy trình này được thiết kế để giảm thiểu thời gian ngừng hoạt động và đảm bảo tính toàn vẹn dữ liệu.

## 2. CHUẨN BỊ NÂNG CẤP

### 2.1. Kiểm tra phiên bản hiện tại

```bash
# Kiểm tra phiên bản backend
docker exec -it NextFlow-backend npm version

# Kiểm tra phiên bản frontend
docker exec -it NextFlow-frontend npm version

# Kiểm tra phiên bản database
docker exec -it NextFlow-postgres psql -U postgres -c "SELECT version();"
```

### 2.2. Sao lưu dữ liệu

```bash
# Sao lưu cơ sở dữ liệu
docker exec -it NextFlow-postgres pg_dump -U postgres NextFlow > NextFlow_backup_$(date +%Y%m%d).sql
docker exec -it NextFlow-postgres pg_dump -U postgres n8n > n8n_backup_$(date +%Y%m%d).sql
docker exec -it NextFlow-postgres pg_dump -U postgres flowise > flowise_backup_$(date +%Y%m%d).sql

# Sao lưu file cấu hình
cp .env .env.backup
cp docker-compose.yml docker-compose.yml.backup
```

### 2.3. Kiểm tra yêu cầu hệ thống

Đảm bảo hệ thống đáp ứng yêu cầu tối thiểu cho phiên bản mới:

- CPU: 4 cores
- RAM: 8GB
- Disk:
