# TỐI ƯU HÓA HIỆU SUẤT NextFlow CRM

## 1. TỔNG QUAN

Tài liệu này cung cấp hướng dẫn tối ưu hóa hiệu suất cho NextFlow CRM, bao gồm cấu hình phần cứng, tối ưu hóa cơ sở dữ liệu, và các cài đặt ứng dụng.

## 2. KHUYẾN NGHỊ PHẦN CỨNG

### 2.1. Yêu cầu tối thiểu
- **CPU**: 4 cores
- **RAM**: 8GB
- **Disk**: 100GB SSD
- **Network**: 100Mbps

### 2.2. Khuyến nghị cho 100 người dùng
- **CPU**: 8 cores
- **RAM**: 16GB
- **Disk**: 500GB SSD
- **Network**: 1Gbps

### 2.3. Khuyến nghị cho 500 người dùng
- **CPU**: 16 cores
- **RAM**: 32GB
- **Disk**: 1TB SSD
- **Network**: 10Gbps

### 2.4. Khuyến nghị cho 1000+ người dùng
- **CPU**: 32+ cores
- **RAM**: 64GB+
- **Disk**: 2TB+ SSD
- **Network**: 10Gbps+
- **Cấu trúc**: Microservices với load balancing

## 3. TỐI ƯU HÓA CƠ SỞ DỮ LIỆU

### 3.1. Cấu hình PostgreSQL

```bash
# Chỉnh sửa file postgresql.conf
vim /etc/postgresql/13/main/postgresql.conf
```

Các tham số quan trọng:
```
# Bộ nhớ
shared_buffers = 4GB                  # 25% RAM
effective_cache_size = 12GB           # 75% RAM
work_mem = 64MB                       # Tùy thuộc vào số kết nối
maintenance_work_mem = 1GB            # 25% RAM, tối đa 1GB

# Checkpoints
checkpoint_timeout = 15min
checkpoint_completion_target = 0.9
max_wal_size = 2GB

# Planner
random_page_cost = 1.1                # Cho SSD
effective_io_concurrency = 200        # Cho SSD

# Vacuum
autovacuum = on
autovacuum_vacuum_scale_factor = 0.05
autovacuum_analyze_scale_factor = 0.025
```

### 3.2. Indexing

Các index quan trọng cần kiểm tra:
```sql
-- Kiểm tra index thiếu
SELECT
  schemaname || '.' || relname AS table,
  indexrelname AS index,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch,
  pg_size_pretty(pg_relation_size(i.indexrelid)) AS index_size
FROM pg_stat_user_indexes i
JOIN pg_index USING (indexrelid)
WHERE idx_scan = 0
AND indisunique IS FALSE
ORDER BY pg_relation_size(i.indexrelid) DESC;

-- Tạo index cho các trường tìm kiếm phổ biến
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_phone ON customers(phone);
CREATE INDEX idx_opportunities_status ON opportunities(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
```

### 3.3. Phân vùng bảng

Phân vùng các bảng lớn:
```sql
-- Phân vùng bảng activities theo thời gian
CREATE TABLE activities (
    id UUID PRIMARY KEY,
    created_at TIMESTAMP NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL,
    data JSONB
) PARTITION BY RANGE (created_at);

-- Tạo phân vùng theo tháng
CREATE TABLE activities_y2023m01 PARTITION OF activities
    FOR VALUES FROM ('2023-01-01') TO ('2023-02-01');
    
CREATE TABLE activities_y2023m02 PARTITION OF activities
    FOR VALUES FROM ('2023-02-01') TO ('2023-03-01');
    
-- Script tạo phân vùng tự động
```

## 4. TỐI ƯU HÓA BACKEND

### 4.1. Cấu hình Node.js

```bash
# Chỉnh sửa file .env hoặc cấu hình Docker
NODE_ENV=production
NODE_OPTIONS="--max-old-space-size=4096"
```

### 4.2. Caching

```typescript
// Cấu hình Redis cache
import { CacheModule } from '@nestjs/cache-manager';
import { redisStore } from 'cache-manager-redis-store';

@Module({
  imports: [
    CacheModule.registerAsync({
      isGlobal: true,
      useFactory: () => ({
        store: redisStore,
        host: process.env.REDIS_HOST,
        port: process.env.REDIS_PORT,
        ttl: 60 * 60, // 1 hour
      }),
    }),
  ],
})
export class AppModule {}
```

### 4.3. Tối ưu hóa API

- Sử dụng pagination cho tất cả API danh sách
- Giới hạn số lượng bản ghi trả về
- Sử dụng projection để chỉ lấy các trường cần thiết
- Nén dữ liệu phản hồi (gzip, brotli)
- Sử dụng ETags và cache HTTP