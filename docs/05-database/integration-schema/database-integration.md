# SCHEMA TÍCH HỢP - DATABASE

## 1. GIỚI THIỆU

Schema Database quản lý thông tin về các kết nối cơ sở dữ liệu, đồng bộ hóa dữ liệu và các hoạt động liên quan đến tích hợp cơ sở dữ liệu trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến tích hợp cơ sở dữ liệu trong hệ thống.

### 1.1. Mục đích

Schema Database phục vụ các mục đích sau:

- Lưu trữ thông tin kết nối cơ sở dữ liệu
- Quản lý đồng bộ hóa dữ liệu giữa các hệ thống
- Theo dõi lịch sử đồng bộ và di chuyển dữ liệu
- Quản lý cấu hình ánh xạ dữ liệu
- Hỗ trợ tích hợp với các hệ thống cơ sở dữ liệu bên ngoài
- Quản lý phân vùng và sharding dữ liệu trong kiến trúc multi-tenant

### 1.2. Các bảng chính

Schema Database bao gồm các bảng chính sau:

1. `database_connections` - Lưu trữ thông tin kết nối cơ sở dữ liệu
2. `database_sync_jobs` - Lưu trữ thông tin công việc đồng bộ dữ liệu
3. `database_sync_logs` - Lưu trữ thông tin lịch sử đồng bộ dữ liệu
4. `database_mappings` - Lưu trữ thông tin ánh xạ dữ liệu
5. `database_migrations` - Lưu trữ thông tin di chuyển cơ sở dữ liệu
6. `database_shards` - Lưu trữ thông tin phân vùng cơ sở dữ liệu

## 2. BẢNG DATABASE_CONNECTIONS

### 2.1. Mô tả

Bảng `database_connections` lưu trữ thông tin về các kết nối cơ sở dữ liệu trong hệ thống.

### 2.2. Cấu trúc

| Tên cột            | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                                      |
| ------------------ | ------------ | -------- | ----------------- | ---------------------------------------------------------- |
| id                 | uuid         | false    | gen_random_uuid() | Khóa chính, định danh duy nhất của kết nối                 |
| organization_id    | uuid         | false    |                   | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name               | varchar(100) | false    |                   | Tên kết nối                                                |
| description        | text         | true     | null              | Mô tả kết nối                                              |
| type               | varchar(50)  | false    |                   | Loại cơ sở dữ liệu: postgresql, mysql, mongodb, etc.       |
| host               | varchar(255) | false    |                   | Địa chỉ máy chủ                                            |
| port               | integer      | false    |                   | Cổng kết nối                                               |
| database           | varchar(100) | false    |                   | Tên cơ sở dữ liệu                                          |
| schema             | varchar(100) | true     | null              | Tên schema                                                 |
| username           | varchar(100) | false    |                   | Tên người dùng                                             |
| password           | varchar(255) | false    |                   | Mật khẩu (được mã hóa)                                     |
| ssl_enabled        | boolean      | false    | false             | Kích hoạt SSL                                              |
| ssl_config         | jsonb        | true     | null              | Cấu hình SSL                                               |
| connection_options | jsonb        | true     | null              | Tùy chọn kết nối bổ sung                                   |
| status             | varchar(20)  | false    | 'active'          | Trạng thái: active, inactive, error                        |
| last_connected_at  | timestamp    | true     | null              | Thời gian kết nối gần nhất                                 |
| error_message      | text         | true     | null              | Thông báo lỗi gần nhất                                     |
| is_primary         | boolean      | false    | false             | Đánh dấu là kết nối chính                                  |
| is_read_only       | boolean      | false    | false             | Đánh dấu là kết nối chỉ đọc                                |
| tenant_id          | varchar(100) | true     | null              | ID tenant (cho multi-tenant)                               |
| shard_key          | varchar(100) | true     | null              | Khóa phân vùng                                             |
| created_at         | timestamp    | false    | now()             | Thời gian tạo bản ghi                                      |
| updated_at         | timestamp    | false    | now()             | Thời gian cập nhật bản ghi                                 |
| deleted_at         | timestamp    | true     | null              | Thời gian xóa bản ghi (soft delete)                        |
| created_by         | uuid         | true     | null              | ID người tạo                                               |
| updated_by         | uuid         | true     | null              | ID người cập nhật                                          |

### 2.3. Chỉ mục

| Tên chỉ mục                                | Loại        | Cột                   | Mô tả                                         |
| ------------------------------------------ | ----------- | --------------------- | --------------------------------------------- |
| database_connections_pkey                  | PRIMARY KEY | id                    | Khóa chính                                    |
| database_connections_organization_name_idx | UNIQUE      | organization_id, name | Đảm bảo tên kết nối là duy nhất trong tổ chức |
| database_connections_organization_id_idx   | INDEX       | organization_id       | Tăng tốc truy vấn theo tổ chức                |
| database_connections_type_idx              | INDEX       | type                  | Tăng tốc truy vấn theo loại cơ sở dữ liệu     |
| database_connections_status_idx            | INDEX       | status                | Tăng tốc truy vấn theo trạng thái             |
| database_connections_is_primary_idx        | INDEX       | is_primary            | Tăng tốc truy vấn theo kết nối chính          |
| database_connections_tenant_id_idx         | INDEX       | tenant_id             | Tăng tốc truy vấn theo tenant                 |
| database_connections_shard_key_idx         | INDEX       | shard_key             | Tăng tốc truy vấn theo khóa phân vùng         |

### 2.4. Ràng buộc

| Tên ràng buộc                             | Loại        | Mô tả                                        |
| ----------------------------------------- | ----------- | -------------------------------------------- |
| database_connections_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id)        |
| database_connections_created_by_fkey      | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| database_connections_updated_by_fkey      | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| database_connections_type_check           | CHECK       | Đảm bảo type chỉ nhận các giá trị cho phép   |
| database_connections_status_check         | CHECK       | Đảm bảo status chỉ nhận các giá trị cho phép |
| database_connections_port_check           | CHECK       | Đảm bảo port > 0 và port < 65536             |

### 2.5. Ví dụ JSON

```json
{
  "id": "d1b2c3o4-n5n6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "PostgreSQL Production",
  "description": "Kết nối đến cơ sở dữ liệu PostgreSQL chính của hệ thống",
  "type": "postgresql",
  "host": "db.example.com",
  "port": 5432,
  "database": "NextFlow_crm",
  "schema": "public",
  "username": "NextFlow_user",
  "password": "encrypted:database_password_123456789",
  "ssl_enabled": true,
  "ssl_config": {
    "mode": "require",
    "ca_cert": "encrypted:ca_cert_content",
    "client_cert": null,
    "client_key": null
  },
  "connection_options": {
    "connect_timeout": 10,
    "application_name": "NextFlow CRM-AI",
    "pool_size": 20,
    "idle_timeout": 30000
  },
  "status": "active",
  "last_connected_at": "2023-07-15T10:30:00Z",
  "error_message": null,
  "is_primary": true,
  "is_read_only": false,
  "tenant_id": null,
  "shard_key": null,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-07-15T10:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG DATABASE_SYNC_JOBS

### 3.1. Mô tả

Bảng `database_sync_jobs` lưu trữ thông tin về các công việc đồng bộ dữ liệu giữa các cơ sở dữ liệu.

### 3.2. Cấu trúc

| Tên cột              | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                                   |
| -------------------- | ------------ | -------- | ----------------- | ------------------------------------------------------- |
| id                   | uuid         | false    | gen_random_uuid() | Khóa chính                                              |
| organization_id      | uuid         | false    |                   | Khóa ngoại tới bảng organizations                       |
| name                 | varchar(100) | false    |                   | Tên công việc đồng bộ                                   |
| description          | text         | true     | null              | Mô tả công việc đồng bộ                                 |
| source_connection_id | uuid         | false    |                   | Khóa ngoại tới bảng database_connections, kết nối nguồn |
| target_connection_id | uuid         | false    |                   | Khóa ngoại tới bảng database_connections, kết nối đích  |
| source_query         | text         | true     | null              | Truy vấn nguồn                                          |
| source_table         | varchar(100) | true     | null              | Bảng nguồn                                              |
| target_table         | varchar(100) | false    |                   | Bảng đích                                               |
| mapping_id           | uuid         | true     | null              | Khóa ngoại tới bảng database_mappings                   |
| sync_type            | varchar(20)  | false    | 'full'            | Loại đồng bộ: full, incremental, delta                  |
| sync_mode            | varchar(20)  | false    | 'append'          | Chế độ đồng bộ: append, replace, merge                  |
| schedule             | varchar(100) | true     | null              | Lịch trình đồng bộ (cron expression)                    |
| filter_criteria      | jsonb        | true     | null              | Tiêu chí lọc                                            |
| batch_size           | integer      | false    | 1000              | Kích thước batch                                        |
| timeout              | integer      | false    | 3600              | Thời gian chờ tối đa (giây)                             |
| retry_limit          | integer      | false    | 3                 | Số lần thử lại tối đa                                   |
| retry_interval       | integer      | false    | 300               | Khoảng thời gian giữa các lần thử lại (giây)            |
| status               | varchar(20)  | false    | 'active'          | Trạng thái: active, inactive, error                     |
| last_run_id          | uuid         | true     | null              | ID lần chạy gần nhất                                    |
| last_run_at          | timestamp    | true     | null              | Thời gian chạy gần nhất                                 |
| next_run_at          | timestamp    | true     | null              | Thời gian chạy tiếp theo                                |
| created_at           | timestamp    | false    | now()             | Thời gian tạo bản ghi                                   |
| updated_at           | timestamp    | false    | now()             | Thời gian cập nhật bản ghi                              |
| deleted_at           | timestamp    | true     | null              | Thời gian xóa bản ghi (soft delete)                     |
| created_by           | uuid         | true     | null              | ID người tạo                                            |
| updated_by           | uuid         | true     | null              | ID người cập nhật                                       |

### 3.3. Chỉ mục

| Tên chỉ mục                                 | Loại        | Cột                   | Mô tả                                                   |
| ------------------------------------------- | ----------- | --------------------- | ------------------------------------------------------- |
| database_sync_jobs_pkey                     | PRIMARY KEY | id                    | Khóa chính                                              |
| database_sync_jobs_organization_name_idx    | UNIQUE      | organization_id, name | Đảm bảo tên công việc đồng bộ là duy nhất trong tổ chức |
| database_sync_jobs_organization_id_idx      | INDEX       | organization_id       | Tăng tốc truy vấn theo tổ chức                          |
| database_sync_jobs_source_connection_id_idx | INDEX       | source_connection_id  | Tăng tốc truy vấn theo kết nối nguồn                    |
| database_sync_jobs_target_connection_id_idx | INDEX       | target_connection_id  | Tăng tốc truy vấn theo kết nối đích                     |
| database_sync_jobs_mapping_id_idx           | INDEX       | mapping_id            | Tăng tốc truy vấn theo ánh xạ                           |
| database_sync_jobs_sync_type_idx            | INDEX       | sync_type             | Tăng tốc truy vấn theo loại đồng bộ                     |
| database_sync_jobs_status_idx               | INDEX       | status                | Tăng tốc truy vấn theo trạng thái                       |
| database_sync_jobs_last_run_at_idx          | INDEX       | last_run_at           | Tăng tốc truy vấn theo thời gian chạy gần nhất          |
| database_sync_jobs_next_run_at_idx          | INDEX       | next_run_at           | Tăng tốc truy vấn theo thời gian chạy tiếp theo         |

### 3.4. Ràng buộc

| Tên ràng buộc                                | Loại        | Mô tả                                                |
| -------------------------------------------- | ----------- | ---------------------------------------------------- |
| database_sync_jobs_organization_id_fkey      | FOREIGN KEY | Tham chiếu đến bảng organizations(id)                |
| database_sync_jobs_source_connection_id_fkey | FOREIGN KEY | Tham chiếu đến bảng database_connections(id)         |
| database_sync_jobs_target_connection_id_fkey | FOREIGN KEY | Tham chiếu đến bảng database_connections(id)         |
| database_sync_jobs_mapping_id_fkey           | FOREIGN KEY | Tham chiếu đến bảng database_mappings(id)            |
| database_sync_jobs_created_by_fkey           | FOREIGN KEY | Tham chiếu đến bảng users(id)                        |
| database_sync_jobs_updated_by_fkey           | FOREIGN KEY | Tham chiếu đến bảng users(id)                        |
| database_sync_jobs_sync_type_check           | CHECK       | Đảm bảo sync_type chỉ nhận các giá trị cho phép      |
| database_sync_jobs_sync_mode_check           | CHECK       | Đảm bảo sync_mode chỉ nhận các giá trị cho phép      |
| database_sync_jobs_status_check              | CHECK       | Đảm bảo status chỉ nhận các giá trị cho phép         |
| database_sync_jobs_batch_size_check          | CHECK       | Đảm bảo batch_size > 0                               |
| database_sync_jobs_timeout_check             | CHECK       | Đảm bảo timeout > 0                                  |
| database_sync_jobs_retry_limit_check         | CHECK       | Đảm bảo retry_limit >= 0                             |
| database_sync_jobs_retry_interval_check      | CHECK       | Đảm bảo retry_interval > 0                           |
| database_sync_jobs_source_target_check       | CHECK       | Đảm bảo source_connection_id != target_connection_id |

### 3.5. Ví dụ JSON

```json
{
  "id": "s1y2n3c4-j5o6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Đồng bộ dữ liệu khách hàng từ CRM cũ",
  "description": "Đồng bộ dữ liệu khách hàng từ hệ thống CRM cũ sang NextFlow CRM-AI",
  "source_connection_id": "s1o2u3r4-c5e6-7890-abcd-ef1234567890",
  "target_connection_id": "d1b2c3o4-n5n6-7890-abcd-ef1234567890",
  "source_query": "SELECT * FROM customers WHERE updated_at >= :last_sync_date",
  "source_table": "customers",
  "target_table": "customers",
  "mapping_id": "m1a2p3p4-i5n6-7890-abcd-ef1234567890",
  "sync_type": "incremental",
  "sync_mode": "merge",
  "schedule": "0 0 * * *",
  "filter_criteria": {
    "status": ["active", "pending"],
    "updated_at": {
      "operator": ">=",
      "value": "{{last_sync_date}}"
    }
  },
  "batch_size": 1000,
  "timeout": 3600,
  "retry_limit": 3,
  "retry_interval": 300,
  "status": "active",
  "last_run_id": "r1u2n3i4-d5i6-7890-abcd-ef1234567890",
  "last_run_at": "2023-07-15T00:00:00Z",
  "next_run_at": "2023-07-16T00:00:00Z",
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-07-15T00:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG DATABASE_MAPPINGS

### 4.1. Mô tả

Bảng `database_mappings` lưu trữ thông tin về ánh xạ dữ liệu giữa các cơ sở dữ liệu.

### 4.2. Cấu trúc

| Tên cột          | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                        |
| ---------------- | ------------ | -------- | ----------------- | -------------------------------------------- |
| id               | uuid         | false    | gen_random_uuid() | Khóa chính                                   |
| organization_id  | uuid         | false    |                   | Khóa ngoại tới bảng organizations            |
| name             | varchar(100) | false    |                   | Tên ánh xạ                                   |
| description      | text         | true     | null              | Mô tả ánh xạ                                 |
| source_type      | varchar(50)  | false    |                   | Loại nguồn: postgresql, mysql, mongodb, etc. |
| target_type      | varchar(50)  | false    |                   | Loại đích: postgresql, mysql, mongodb, etc.  |
| source_schema    | jsonb        | true     | null              | Schema nguồn                                 |
| target_schema    | jsonb        | true     | null              | Schema đích                                  |
| field_mappings   | jsonb        | false    |                   | Ánh xạ trường                                |
| transformations  | jsonb        | true     | null              | Biến đổi dữ liệu                             |
| primary_key      | jsonb        | true     | null              | Khóa chính                                   |
| unique_keys      | jsonb        | true     | null              | Khóa duy nhất                                |
| merge_strategy   | jsonb        | true     | null              | Chiến lược merge                             |
| validation_rules | jsonb        | true     | null              | Quy tắc xác thực                             |
| created_at       | timestamp    | false    | now()             | Thời gian tạo bản ghi                        |
| updated_at       | timestamp    | false    | now()             | Thời gian cập nhật bản ghi                   |
| deleted_at       | timestamp    | true     | null              | Thời gian xóa bản ghi (soft delete)          |
| created_by       | uuid         | true     | null              | ID người tạo                                 |
| updated_by       | uuid         | true     | null              | ID người cập nhật                            |

### 4.3. Chỉ mục

| Tên chỉ mục                             | Loại        | Cột                   | Mô tả                                        |
| --------------------------------------- | ----------- | --------------------- | -------------------------------------------- |
| database_mappings_pkey                  | PRIMARY KEY | id                    | Khóa chính                                   |
| database_mappings_organization_name_idx | UNIQUE      | organization_id, name | Đảm bảo tên ánh xạ là duy nhất trong tổ chức |
| database_mappings_organization_id_idx   | INDEX       | organization_id       | Tăng tốc truy vấn theo tổ chức               |
| database_mappings_source_type_idx       | INDEX       | source_type           | Tăng tốc truy vấn theo loại nguồn            |
| database_mappings_target_type_idx       | INDEX       | target_type           | Tăng tốc truy vấn theo loại đích             |

### 4.4. Ràng buộc

| Tên ràng buộc                          | Loại        | Mô tả                                             |
| -------------------------------------- | ----------- | ------------------------------------------------- |
| database_mappings_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id)             |
| database_mappings_created_by_fkey      | FOREIGN KEY | Tham chiếu đến bảng users(id)                     |
| database_mappings_updated_by_fkey      | FOREIGN KEY | Tham chiếu đến bảng users(id)                     |
| database_mappings_source_type_check    | CHECK       | Đảm bảo source_type chỉ nhận các giá trị cho phép |
| database_mappings_target_type_check    | CHECK       | Đảm bảo target_type chỉ nhận các giá trị cho phép |

### 4.5. Ví dụ JSON

```json
{
  "id": "m1a2p3p4-i5n6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Ánh xạ khách hàng từ CRM cũ",
  "description": "Ánh xạ dữ liệu khách hàng từ hệ thống CRM cũ sang NextFlow CRM-AI",
  "source_type": "mysql",
  "target_type": "postgresql",
  "source_schema": {
    "table": "customers",
    "fields": [
      { "name": "id", "type": "int", "nullable": false },
      { "name": "first_name", "type": "varchar", "length": 50, "nullable": false },
      { "name": "last_name", "type": "varchar", "length": 50, "nullable": false },
      { "name": "email", "type": "varchar", "length": 100, "nullable": false },
      { "name": "phone", "type": "varchar", "length": 20, "nullable": true },
      { "name": "status", "type": "enum", "values": ["active", "inactive", "pending"], "nullable": false },
      { "name": "created_date", "type": "datetime", "nullable": false },
      { "name": "updated_date", "type": "datetime", "nullable": false }
    ]
  },
  "target_schema": {
    "table": "customers",
    "fields": [
      { "name": "id", "type": "uuid", "nullable": false },
      { "name": "organization_id", "type": "uuid", "nullable": false },
      { "name": "first_name", "type": "varchar", "length": 50, "nullable": false },
      { "name": "last_name", "type": "varchar", "length": 50, "nullable": false },
      { "name": "email", "type": "varchar", "length": 255, "nullable": false },
      { "name": "phone", "type": "varchar", "length": 20, "nullable": true },
      { "name": "status", "type": "varchar", "length": 20, "nullable": false },
      { "name": "created_at", "type": "timestamp", "nullable": false },
      { "name": "updated_at", "type": "timestamp", "nullable": false }
    ]
  },
  "field_mappings": [
    { "source": "id", "target": "legacy_id", "type": "direct" },
    { "source": "first_name", "target": "first_name", "type": "direct" },
    { "source": "last_name", "target": "last_name", "type": "direct" },
    { "source": "email", "target": "email", "type": "direct" },
    { "source": "phone", "target": "phone", "type": "direct" },
    { "source": "status", "target": "status", "type": "direct" },
    { "source": "created_date", "target": "created_at", "type": "transform", "transform": "toISOString" },
    { "source": "updated_date", "target": "updated_at", "type": "transform", "transform": "toISOString" }
  ],
  "transformations": [
    {
      "target": "id",
      "type": "generate",
      "generator": "uuid"
    },
    {
      "target": "organization_id",
      "type": "constant",
      "value": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890"
    }
  ],
  "primary_key": ["id"],
  "unique_keys": [["organization_id", "email"]],
  "merge_strategy": {
    "match_fields": ["legacy_id"],
    "update_fields": ["first_name", "last_name", "phone", "status", "updated_at"],
    "insert_if_not_exists": true
  },
  "validation_rules": [
    {
      "field": "email",
      "rule": "email",
      "message": "Email không hợp lệ"
    },
    {
      "field": "phone",
      "rule": "regex",
      "pattern": "^\\+?[0-9]{10,15}$",
      "message": "Số điện thoại không hợp lệ"
    }
  ],
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-01-15T09:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
