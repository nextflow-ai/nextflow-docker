# TROUBLESHOOTING - HIỆU SUẤT

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn khắc phục sự cố liên quan đến hiệu suất trong hệ thống NextFlow CRM-AI. Các vấn đề hiệu suất có thể bao gồm hệ thống chạy chậm, thời gian phản hồi cao, sử dụng tài nguyên cao, và các vấn đề hiệu suất khác.

## 2. VẤN ĐỀ HIỆU SUẤT ỨNG DỤNG

### 2.1. Hệ thống chạy chậm

#### Triệu chứng

- Thời gian tải trang cao
- Thao tác người dùng phản hồi chậm
- API phản hồi chậm

#### Nguyên nhân có thể

1. Tài nguyên máy chủ không đủ
2. Cơ sở dữ liệu không được tối ưu hóa
3. Cache không hiệu quả
4. Tải hệ thống cao
5. Mã nguồn không hiệu quả

#### Giải pháp

##### 2.1.1. Kiểm tra sử dụng tài nguyên

```bash
# Kiểm tra CPU, RAM, disk
top
htop
free -h
df -h

# Kiểm tra sử dụng tài nguyên của các container Docker
docker stats
```

##### 2.1.2. Tối ưu hóa cơ sở dữ liệu

Kiểm tra và tối ưu hóa các truy vấn chậm:

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Bật log các truy vấn chậm
ALTER SYSTEM SET log_min_duration_statement = 200;
SELECT pg_reload_conf();

# Kiểm tra các truy vấn đang chạy
SELECT pid, age(clock_timestamp(), query_start), usename, query
FROM pg_stat_activity
WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start desc;

# Kiểm tra các chỉ mục thiếu
SELECT
  relname AS table_name,
  seq_scan - idx_scan AS too_much_seq,
  CASE WHEN seq_scan - idx_scan > 0 THEN 'Missing Index?' ELSE 'OK' END,
  pg_relation_size(relname::regclass) AS table_size,
  seq_scan, idx_scan
FROM pg_stat_user_tables
WHERE pg_relation_size(relname::regclass) > 5000000
ORDER BY too_much_seq DESC;

# Thoát
\q
```

Thêm chỉ mục cho các cột thường được truy vấn:

```sql
CREATE INDEX idx_table_column ON table_name(column_name);
```

Phân tích và tối ưu hóa cơ sở dữ liệu:

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Phân tích cơ sở dữ liệu
VACUUM ANALYZE;

# Thoát
\q
```

##### 2.1.3. Cấu hình lại cache

Kiểm tra cấu hình Redis:

```bash
# Kết nối đến Redis
redis-cli -h localhost -p 6379 -a your_secure_password

# Kiểm tra thông tin
INFO

# Kiểm tra các khóa
KEYS *

# Kiểm tra kích thước bộ nhớ
INFO memory

# Thoát
exit
```

Cấu hình lại cache trong ứng dụng:

```typescript
// src/config/cache.ts
export const cacheConfig = {
  ttl: 3600, // Thời gian sống của cache (giây)
  max: 1000, // Số lượng mục tối đa trong cache
  store: "redis",
  host: process.env.REDIS_HOST || "localhost",
  port: parseInt(process.env.REDIS_PORT || "6379", 10),
  password: process.env.REDIS_PASSWORD,
  db: parseInt(process.env.REDIS_DB || "0", 10),
};
```

##### 2.1.4. Cân bằng tải hệ thống

Nếu hệ thống có nhiều người dùng, cân nhắc triển khai cân bằng tải:

```bash
# Cài đặt HAProxy
sudo apt update
sudo apt install -y haproxy

# Cấu hình HAProxy
sudo nano /etc/haproxy/haproxy.cfg
```

Thêm cấu hình cân bằng tải:

```
frontend http_front
   bind *:80
   stats uri /haproxy?stats
   default_backend http_back

backend http_back
   balance roundrobin
   server server1 192.168.1.101:3000 check
   server server2 192.168.1.102:3000 check
```

Khởi động lại HAProxy:

```bash
sudo systemctl restart haproxy
```

##### 2.1.5. Tối ưu hóa mã nguồn

Sử dụng công cụ phân tích hiệu suất để xác định các điểm nghẽn trong mã nguồn:

```bash
# Cài đặt Node.js profiler
npm install -g clinic

# Chạy ứng dụng với profiler
clinic doctor -- node dist/main.js
```

### 2.2. Sử dụng CPU cao

#### Triệu chứng

- Sử dụng CPU cao liên tục
- Quạt máy chủ chạy liên tục
- Hệ thống phản hồi chậm

#### Nguyên nhân có thể

1. Vòng lặp vô hạn
2. Xử lý dữ liệu lớn không hiệu quả
3. Quá nhiều tiến trình đồng thời
4. Malware hoặc cryptominer
5. Cấu hình không đúng

#### Giải pháp

##### 2.2.1. Xác định tiến trình sử dụng CPU cao

```bash
# Kiểm tra tiến trình sử dụng CPU cao
top
htop

# Kiểm tra tiến trình Node.js
ps aux | grep node
```

##### 2.2.2. Kiểm tra logs

```bash
# Kiểm tra logs ứng dụng
tail -f /path/to/NextFlow-crm/logs/application.log

# Kiểm tra logs hệ thống
sudo journalctl -u NextFlow-crm
```

##### 2.2.3. Tối ưu hóa xử lý dữ liệu lớn

Sử dụng phân trang và xử lý theo batch:

```typescript
// Thay vì
const allRecords = await repository.find();
allRecords.forEach((record) => processRecord(record));

// Sử dụng
const batchSize = 100;
let page = 0;
let records;

do {
  records = await repository.find({
    skip: page * batchSize,
    take: batchSize,
  });

  for (const record of records) {
    await processRecord(record);
  }

  page++;
} while (records.length === batchSize);
```

##### 2.2.4. Giới hạn tiến trình đồng thời

Cấu hình giới hạn tiến trình đồng thời trong PM2:

```json
// ecosystem.config.js
module.exports = {
  apps: [{
    name: "NextFlow-crm",
    script: "dist/main.js",
    instances: "max",
    exec_mode: "cluster",
    max_memory_restart: "1G",
    max_restarts: 10,
    watch: false,
    env: {
      NODE_ENV: "production"
    }
  }]
}
```

##### 2.2.5. Kiểm tra malware

```bash
# Cài đặt ClamAV
sudo apt update
sudo apt install -y clamav clamav-daemon

# Cập nhật cơ sở dữ liệu virus
sudo freshclam

# Quét hệ thống
sudo clamscan -r /path/to/NextFlow-crm
```

### 2.3. Sử dụng RAM cao

#### Triệu chứng

- Sử dụng RAM cao liên tục
- Hệ thống swap nhiều
- Ứng dụng bị crash với lỗi "out of memory"

#### Nguyên nhân có thể

1. Memory leak
2. Cấu hình heap size không đúng
3. Quá nhiều dữ liệu được lưu trong bộ nhớ
4. Cache quá lớn
5. Quá nhiều tiến trình đồng thời

#### Giải pháp

##### 2.3.1. Xác định tiến trình sử dụng RAM cao

```bash
# Kiểm tra tiến trình sử dụng RAM cao
top
htop

# Kiểm tra sử dụng RAM của Node.js
ps -o pid,rss,command -p $(pgrep -f node)
```

##### 2.3.2. Cấu hình heap size cho Node.js

```bash
# Cấu hình heap size trong PM2
pm2 start dist/main.js --node-args="--max-old-space-size=2048"
```

Hoặc cấu hình trong file `ecosystem.config.js`:

```json
module.exports = {
  apps: [{
    name: "NextFlow-crm",
    script: "dist/main.js",
    node_args: "--max-old-space-size=2048",
    instances: "max",
    exec_mode: "cluster"
  }]
}
```

##### 2.3.3. Kiểm tra memory leak

Sử dụng công cụ phân tích bộ nhớ:

```bash
# Cài đặt heapdump
npm install heapdump

# Tạo heapdump
node -e "require('heapdump').writeSnapshot('/tmp/heap-' + Date.now() + '.heapsnapshot')"
```

Phân tích heapdump bằng Chrome DevTools.

##### 2.3.4. Tối ưu hóa cache

Giới hạn kích thước cache:

```typescript
// src/config/cache.ts
export const cacheConfig = {
  ttl: 3600, // Thời gian sống của cache (giây)
  max: 1000, // Số lượng mục tối đa trong cache
  maxSize: 100 * 1024 * 1024, // Kích thước tối đa (100MB)
};
```

##### 2.3.5. Sử dụng streaming cho dữ liệu lớn

```typescript
// Thay vì tải toàn bộ dữ liệu vào bộ nhớ
const data = await repository.find();
return data;

// Sử dụng streaming
const stream = repository.createQueryBuilder().stream();

stream.on("data", (data) => {
  // Xử lý từng bản ghi
});

stream.on("end", () => {
  // Hoàn thành
});
```

### 2.4. Sử dụng disk I/O cao

#### Triệu chứng

- Disk I/O cao liên tục
- Hệ thống phản hồi chậm
- Thời gian chờ disk cao

#### Nguyên nhân có thể

1. Logging quá nhiều
2. Cơ sở dữ liệu thực hiện nhiều I/O
3. Tệp tạm thời quá lớn
4. Backup hoặc quét virus đang chạy
5. Disk đầy hoặc phân mảnh

#### Giải pháp

##### 2.4.1. Kiểm tra sử dụng disk I/O

```bash
# Kiểm tra sử dụng disk I/O
iostat -x 1
iotop
```

##### 2.4.2. Tối ưu hóa logging

Cấu hình logging để giảm I/O:

```typescript
// src/config/logger.ts
export const loggerConfig = {
  level: process.env.NODE_ENV === "production" ? "info" : "debug",
  format: winston.format.combine(winston.format.timestamp(), winston.format.json()),
  transports: [
    new winston.transports.Console(),
    new winston.transports.DailyRotateFile({
      filename: "logs/application-%DATE%.log",
      datePattern: "YYYY-MM-DD",
      maxSize: "20m",
      maxFiles: "14d",
    }),
  ],
};
```

##### 2.4.3. Tối ưu hóa cơ sở dữ liệu

Cấu hình PostgreSQL để giảm I/O:

```
# postgresql.conf
effective_io_concurrency = 200
random_page_cost = 1.1
checkpoint_completion_target = 0.9
wal_buffers = 16MB
```

##### 2.4.4. Dọn dẹp tệp tạm thời

```bash
# Dọn dẹp tệp tạm thời
sudo find /tmp -type f -atime +10 -delete
```

##### 2.4.5. Kiểm tra và sửa chữa disk

```bash
# Kiểm tra disk
sudo fsck -f /dev/sdaX

# Kiểm tra bad blocks
sudo badblocks -v /dev/sdaX
```

## 3. VẤN ĐỀ HIỆU SUẤT CƠ SỞ DỮ LIỆU

### 3.1. Truy vấn chậm

#### Triệu chứng

- Truy vấn cơ sở dữ liệu mất nhiều thời gian
- Timeout khi thực hiện truy vấn
- CPU PostgreSQL cao

#### Nguyên nhân có thể

1. Thiếu chỉ mục
2. Truy vấn không hiệu quả
3. Bảng quá lớn
4. Thống kê cơ sở dữ liệu không cập nhật
5. Cấu hình PostgreSQL không tối ưu

#### Giải pháp

##### 3.1.1. Xác định truy vấn chậm

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Bật log các truy vấn chậm
ALTER SYSTEM SET log_min_duration_statement = 200;
SELECT pg_reload_conf();

# Kiểm tra các truy vấn đang chạy
SELECT pid, age(clock_timestamp(), query_start), usename, query
FROM pg_stat_activity
WHERE query != '<IDLE>' AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start desc;

# Thoát
\q
```

##### 3.1.2. Thêm chỉ mục

```sql
-- Thêm chỉ mục cho cột thường được truy vấn
CREATE INDEX idx_table_column ON table_name(column_name);

-- Thêm chỉ mục tổng hợp
CREATE INDEX idx_table_multiple_columns ON table_name(column1, column2);

-- Thêm chỉ mục một phần
CREATE INDEX idx_table_column_partial ON table_name(column_name) WHERE condition;
```

##### 3.1.3. Tối ưu hóa truy vấn

```sql
-- Thay vì
SELECT * FROM users WHERE id IN (SELECT user_id FROM orders WHERE status = 'completed');

-- Sử dụng
SELECT u.* FROM users u
JOIN orders o ON u.id = o.user_id
WHERE o.status = 'completed';
```

##### 3.1.4. Cập nhật thống kê cơ sở dữ liệu

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Cập nhật thống kê
ANALYZE;

# Thoát
\q
```

##### 3.1.5. Tối ưu hóa cấu hình PostgreSQL

```
# postgresql.conf
shared_buffers = 2GB
work_mem = 64MB
maintenance_work_mem = 256MB
effective_cache_size = 6GB
```

### 3.2. Kết nối cơ sở dữ liệu quá nhiều

#### Triệu chứng

- Lỗi "too many connections"
- Kết nối cơ sở dữ liệu tăng liên tục
- Hiệu suất giảm khi có nhiều người dùng

#### Nguyên nhân có thể

1. Kết nối không được đóng đúng cách
2. Pool kết nối không được cấu hình đúng
3. Quá nhiều tiến trình đồng thời
4. Kết nối bị rò rỉ
5. Cấu hình PostgreSQL không tối ưu

#### Giải pháp

##### 3.2.1. Kiểm tra số lượng kết nối

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Kiểm tra số lượng kết nối
SELECT count(*) FROM pg_stat_activity;

# Kiểm tra kết nối theo database
SELECT datname, count(*) FROM pg_stat_activity GROUP BY datname;

# Kiểm tra kết nối theo user
SELECT usename, count(*) FROM pg_stat_activity GROUP BY usename;

# Thoát
\q
```

##### 3.2.2. Cấu hình pool kết nối

```typescript
// src/config/database.ts
export const databaseConfig = {
  type: "postgres",
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT || "5432", 10),
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  schema: process.env.DB_SCHEMA,
  synchronize: false,
  logging: process.env.NODE_ENV !== "production",
  entities: ["dist/**/*.entity{.ts,.js}"],
  migrations: ["dist/migrations/*{.ts,.js}"],
  cli: {
    migrationsDir: "src/migrations",
  },
  // Cấu hình pool
  poolSize: 20, // Số lượng kết nối tối đa trong pool
  connectionTimeoutMillis: 0, // Thời gian chờ kết nối (0 = không giới hạn)
  idleTimeoutMillis: 30000, // Thời gian kết nối không hoạt động trước khi đóng
};
```

##### 3.2.3. Cấu hình PostgreSQL

```
# postgresql.conf
max_connections = 200
```

##### 3.2.4. Sử dụng connection pooler

```bash
# Cài đặt PgBouncer
sudo apt update
sudo apt install -y pgbouncer

# Cấu hình PgBouncer
sudo nano /etc/pgbouncer/pgbouncer.ini
```

Thêm cấu hình PgBouncer:

```
[databases]
NextFlow_crm = host=localhost port=5432 dbname=NextFlow_crm

[pgbouncer]
listen_addr = *
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 20
```

Tạo file userlist.txt:

```bash
sudo nano /etc/pgbouncer/userlist.txt
```

Thêm thông tin người dùng:

```
"NextFlow" "md5password"
```

Khởi động lại PgBouncer:

```bash
sudo systemctl restart pgbouncer
```

Cập nhật cấu hình kết nối trong ứng dụng:

```
DB_HOST=localhost
DB_PORT=6432
```

## 4. VẤN ĐỀ HIỆU SUẤT REDIS

### 4.1. Redis sử dụng bộ nhớ cao

#### Triệu chứng

- Redis sử dụng bộ nhớ cao
- Lỗi "out of memory"
- Hiệu suất Redis giảm

#### Nguyên nhân có thể

1. Quá nhiều khóa được lưu trữ
2. Khóa không có thời gian hết hạn
3. Dữ liệu lớn được lưu trong Redis
4. Cấu hình maxmemory không đúng
5. Chính sách maxmemory-policy không phù hợp

#### Giải pháp

##### 4.1.1. Kiểm tra sử dụng bộ nhớ Redis

```bash
# Kết nối đến Redis
redis-cli -h localhost -p 6379 -a your_secure_password

# Kiểm tra thông tin bộ nhớ
INFO memory

# Kiểm tra số lượng khóa
DBSIZE

# Kiểm tra các khóa lớn
redis-cli --bigkeys

# Thoát
exit
```

##### 4.1.2. Đặt thời gian hết hạn cho khóa

```bash
# Kết nối đến Redis
redis-cli -h localhost -p 6379 -a your_secure_password

# Đặt thời gian hết hạn cho khóa
EXPIRE key_name 3600

# Thoát
exit
```

Trong ứng dụng:

```typescript
// Đặt thời gian hết hạn khi lưu khóa
await this.redisService.set(key, value, 3600);
```

##### 4.1.3. Cấu hình maxmemory và maxmemory-policy

```bash
# Kết nối đến Redis
redis-cli -h localhost -p 6379 -a your_secure_password

# Cấu hình maxmemory
CONFIG SET maxmemory 2gb

# Cấu hình maxmemory-policy
CONFIG SET maxmemory-policy allkeys-lru

# Lưu cấu hình
CONFIG REWRITE

# Thoát
exit
```

Hoặc cấu hình trong file `redis.conf`:

```
maxmemory 2gb
maxmemory-policy allkeys-lru
```

##### 4.1.4. Sử dụng Redis Cluster

Nếu dữ liệu quá lớn, cân nhắc sử dụng Redis Cluster để phân phối dữ liệu trên nhiều node.

## 5. CÔNG CỤ CHẨN ĐOÁN HIỆU SUẤT

### 5.1. Database Profiler

Database Profiler là công cụ trong NextFlow CRM-AI giúp phân tích hiệu suất cơ sở dữ liệu:

1. Truy cập **Cài đặt > Hệ thống > Database Profiler**
2. Chọn loại phân tích (Truy vấn chậm, Chỉ mục thiếu, v.v.)
3. Nhấp vào **Chạy phân tích**

### 5.2. System Monitor

System Monitor giúp giám sát tài nguyên hệ thống:

1. Truy cập **Cài đặt > Hệ thống > System Monitor**
2. Xem biểu đồ sử dụng CPU, RAM, disk, và mạng

### 5.3. Công cụ dòng lệnh

#### 5.3.1. Giám sát tài nguyên hệ thống

```bash
# Giám sát CPU, RAM, disk
top
htop
vmstat 1
iostat -x 1
```

#### 5.3.2. Phân tích hiệu suất Node.js

```bash
# Cài đặt clinic
npm install -g clinic

# Chạy ứng dụng với clinic doctor
clinic doctor -- node dist/main.js

# Chạy ứng dụng với clinic flame
clinic flame -- node dist/main.js

# Chạy ứng dụng với clinic heap
clinic heap -- node dist/main.js
```

#### 5.3.3. Phân tích hiệu suất PostgreSQL

```bash
# Cài đặt pgbadger
sudo apt install -y pgbadger

# Phân tích log PostgreSQL
pgbadger /var/log/postgresql/postgresql-13-main.log
```

## 6. TÀI LIỆU THAM KHẢO

1. [Tài liệu Node.js Performance](https://nodejs.org/en/docs/guides/dont-block-the-event-loop/)
2. [Tài liệu PostgreSQL Performance](https://www.postgresql.org/docs/current/performance-tips.html)
3. [Tài liệu Redis Performance](https://redis.io/topics/latency)
4. [Tài liệu NestJS Performance](https://docs.nestjs.com/techniques/performance)
5. [Tài liệu TypeORM Performance](https://github.com/typeorm/typeorm/blob/master/docs/performance.md)
