# SCHEMA KIẾN TRÚC HỆ THỐNG

## 1. GIỚI THIỆU

Schema Kiến trúc hệ thống quản lý thông tin về cấu trúc và cấu hình hệ thống NextFlow CRM, bao gồm các thành phần, dịch vụ, cấu hình và các thông tin liên quan đến kiến trúc hệ thống. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến kiến trúc hệ thống.

### 1.1. Mục đích

Schema Kiến trúc hệ thống phục vụ các mục đích sau:

- Lưu trữ thông tin về các thành phần hệ thống
- Quản lý cấu hình hệ thống và môi trường
- Theo dõi trạng thái và hiệu suất hệ thống
- Quản lý phiên bản và triển khai
- Hỗ trợ kiến trúc multi-tenant
- Quản lý cân bằng tải và phân phối tài nguyên

### 1.2. Các bảng chính

Schema Kiến trúc hệ thống bao gồm các bảng chính sau:

1. `system_components` - Lưu trữ thông tin về các thành phần hệ thống
2. `system_services` - Lưu trữ thông tin về các dịch vụ hệ thống
3. `system_configurations` - Lưu trữ thông tin cấu hình hệ thống
4. `system_environments` - Lưu trữ thông tin môi trường hệ thống
5. `system_deployments` - Lưu trữ thông tin triển khai hệ thống
6. `tenant_configurations` - Lưu trữ thông tin cấu hình tenant

## 2. BẢNG SYSTEM_COMPONENTS

### 2.1. Mô tả

Bảng `system_components` lưu trữ thông tin về các thành phần hệ thống trong NextFlow CRM.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của thành phần |
| name | varchar(100) | false | | Tên thành phần |
| code | varchar(50) | false | | Mã thành phần |
| description | text | true | null | Mô tả thành phần |
| type | varchar(50) | false | | Loại thành phần: api, ui, database, cache, queue, etc. |
| version | varchar(20) | false | | Phiên bản thành phần |
| status | varchar(20) | false | 'active' | Trạng thái: active, inactive, deprecated |
| dependencies | jsonb | true | null | Các phụ thuộc |
| repository_url | varchar(255) | true | null | URL kho lưu trữ mã nguồn |
| documentation_url | varchar(255) | true | null | URL tài liệu |
| maintainer | varchar(100) | true | null | Người bảo trì |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| system_components_pkey | PRIMARY KEY | id | Khóa chính |
| system_components_code_idx | UNIQUE | code | Đảm bảo mã thành phần là duy nhất |
| system_components_type_idx | INDEX | type | Tăng tốc truy vấn theo loại thành phần |
| system_components_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| system_components_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| system_components_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| system_components_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| system_components_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "c1o2m3p4-o5n6-7890-abcd-ef1234567890",
  "name": "NextFlow API Core",
  "code": "api-core",
  "description": "Core API service for NextFlow CRM",
  "type": "api",
  "version": "1.5.0",
  "status": "active",
  "dependencies": [
    {
      "component": "database",
      "version": "^1.0.0",
      "required": true
    },
    {
      "component": "cache",
      "version": "^1.0.0",
      "required": false
    },
    {
      "component": "queue",
      "version": "^1.0.0",
      "required": true
    }
  ],
  "repository_url": "https://github.com/NextFlow/api-core",
  "documentation_url": "https://docs.NextFlow.com/api-core",
  "maintainer": "Nguyễn Văn A",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-06-15T10:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG SYSTEM_SERVICES

### 3.1. Mô tả

Bảng `system_services` lưu trữ thông tin về các dịch vụ hệ thống trong NextFlow CRM.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| component_id | uuid | false | | Khóa ngoại tới bảng system_components |
| name | varchar(100) | false | | Tên dịch vụ |
| code | varchar(50) | false | | Mã dịch vụ |
| description | text | true | null | Mô tả dịch vụ |
| type | varchar(50) | false | | Loại dịch vụ: http, grpc, websocket, etc. |
| endpoint | varchar(255) | true | null | Endpoint dịch vụ |
| port | integer | true | null | Cổng dịch vụ |
| protocol | varchar(20) | false | 'http' | Giao thức: http, https, tcp, udp, etc. |
| status | varchar(20) | false | 'active' | Trạng thái: active, inactive, maintenance |
| health_check_url | varchar(255) | true | null | URL kiểm tra sức khỏe |
| health_check_interval | integer | true | null | Khoảng thời gian kiểm tra sức khỏe (giây) |
| retry_policy | jsonb | true | null | Chính sách thử lại |
| timeout | integer | true | null | Thời gian chờ (giây) |
| rate_limit | integer | true | null | Giới hạn tốc độ (requests/minute) |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| system_services_pkey | PRIMARY KEY | id | Khóa chính |
| system_services_code_idx | UNIQUE | code | Đảm bảo mã dịch vụ là duy nhất |
| system_services_component_id_idx | INDEX | component_id | Tăng tốc truy vấn theo thành phần |
| system_services_type_idx | INDEX | type | Tăng tốc truy vấn theo loại dịch vụ |
| system_services_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| system_services_component_id_fkey | FOREIGN KEY | Tham chiếu đến bảng system_components(id) |
| system_services_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| system_services_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| system_services_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| system_services_protocol_check | CHECK | Đảm bảo protocol chỉ nhận các giá trị cho phép |
| system_services_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| system_services_port_check | CHECK | Đảm bảo port > 0 và port < 65536 khi không null |
| system_services_health_check_interval_check | CHECK | Đảm bảo health_check_interval > 0 khi không null |
| system_services_timeout_check | CHECK | Đảm bảo timeout > 0 khi không null |
| system_services_rate_limit_check | CHECK | Đảm bảo rate_limit > 0 khi không null |

### 3.5. Ví dụ JSON

```json
{
  "id": "s1e2r3v4-i5c6-7890-abcd-ef1234567890",
  "component_id": "c1o2m3p4-o5n6-7890-abcd-ef1234567890",
  "name": "NextFlow API Core Service",
  "code": "api-core-service",
  "description": "RESTful API service for NextFlow CRM core functionality",
  "type": "http",
  "endpoint": "https://api.NextFlow.com/v1",
  "port": 443,
  "protocol": "https",
  "status": "active",
  "health_check_url": "https://api.NextFlow.com/v1/health",
  "health_check_interval": 60,
  "retry_policy": {
    "max_retries": 3,
    "initial_backoff_ms": 100,
    "max_backoff_ms": 1000,
    "backoff_multiplier": 2.0,
    "retry_conditions": ["connection_error", "server_error", "timeout"]
  },
  "timeout": 30,
  "rate_limit": 1000,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-06-15T10:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG SYSTEM_CONFIGURATIONS

### 4.1. Mô tả

Bảng `system_configurations` lưu trữ thông tin cấu hình hệ thống trong NextFlow CRM.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| environment_id | uuid | false | | Khóa ngoại tới bảng system_environments |
| component_id | uuid | true | null | Khóa ngoại tới bảng system_components |
| key | varchar(100) | false | | Khóa cấu hình |
| value | text | true | null | Giá trị cấu hình |
| value_type | varchar(20) | false | 'string' | Kiểu giá trị: string, number, boolean, json |
| is_encrypted | boolean | false | false | Đánh dấu là giá trị được mã hóa |
| description | text | true | null | Mô tả cấu hình |
| is_system | boolean | false | false | Đánh dấu là cấu hình hệ thống |
| is_editable | boolean | false | true | Đánh dấu là có thể chỉnh sửa |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| system_configurations_pkey | PRIMARY KEY | id | Khóa chính |
| system_configurations_env_key_idx | UNIQUE | environment_id, key | Đảm bảo khóa cấu hình là duy nhất trong mỗi môi trường |
| system_configurations_environment_id_idx | INDEX | environment_id | Tăng tốc truy vấn theo môi trường |
| system_configurations_component_id_idx | INDEX | component_id | Tăng tốc truy vấn theo thành phần |
| system_configurations_is_system_idx | INDEX | is_system | Tăng tốc truy vấn theo cấu hình hệ thống |
| system_configurations_is_editable_idx | INDEX | is_editable | Tăng tốc truy vấn theo khả năng chỉnh sửa |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| system_configurations_environment_id_fkey | FOREIGN KEY | Tham chiếu đến bảng system_environments(id) |
| system_configurations_component_id_fkey | FOREIGN KEY | Tham chiếu đến bảng system_components(id) |
| system_configurations_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| system_configurations_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| system_configurations_value_type_check | CHECK | Đảm bảo value_type chỉ nhận các giá trị cho phép |

### 4.5. Ví dụ JSON

```json
{
  "id": "c1o2n3f4-i5g6-7890-abcd-ef1234567890",
  "environment_id": "e1n2v3i4-r5o6-7890-abcd-ef1234567890",
  "component_id": "c1o2m3p4-o5n6-7890-abcd-ef1234567890",
  "key": "database.connection_pool.max_size",
  "value": "20",
  "value_type": "number",
  "is_encrypted": false,
  "description": "Kích thước tối đa của connection pool cho cơ sở dữ liệu",
  "is_system": true,
  "is_editable": true,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-06-15T10:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 5. BẢNG TENANT_CONFIGURATIONS

### 5.1. Mô tả

Bảng `tenant_configurations` lưu trữ thông tin cấu hình tenant trong kiến trúc multi-tenant của NextFlow CRM.

### 5.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| tenant_id | varchar(100) | false | | ID tenant |
| tenant_name | varchar(100) | false | | Tên tenant |
| tenant_code | varchar(50) | false | | Mã tenant |
| database_type | varchar(50) | false | 'postgresql' | Loại cơ sở dữ liệu |
| database_host | varchar(255) | false | | Địa chỉ máy chủ cơ sở dữ liệu |
| database_port | integer | false | | Cổng cơ sở dữ liệu |
| database_name | varchar(100) | false | | Tên cơ sở dữ liệu |
| database_schema | varchar(100) | true | null | Schema cơ sở dữ liệu |
| database_username | varchar(100) | false | | Tên người dùng cơ sở dữ liệu |
| database_password | varchar(255) | false | | Mật khẩu cơ sở dữ liệu (được mã hóa) |
| database_options | jsonb | true | null | Tùy chọn cơ sở dữ liệu |
| cache_type | varchar(50) | true | null | Loại cache |
| cache_host | varchar(255) | true | null | Địa chỉ máy chủ cache |
| cache_port | integer | true | null | Cổng cache |
| cache_options | jsonb | true | null | Tùy chọn cache |
| storage_type | varchar(50) | true | null | Loại lưu trữ |
| storage_options | jsonb | true | null | Tùy chọn lưu trữ |
| custom_domain | varchar(255) | true | null | Tên miền tùy chỉnh |
| status | varchar(20) | false | 'active' | Trạng thái: active, inactive, suspended |
| is_shared | boolean | false | false | Đánh dấu là tenant dùng chung |
| shard_key | varchar(100) | true | null | Khóa phân vùng |
| shard_group | varchar(100) | true | null | Nhóm phân vùng |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 5.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| tenant_configurations_pkey | PRIMARY KEY | id | Khóa chính |
| tenant_configurations_organization_id_idx | UNIQUE | organization_id | Đảm bảo mỗi tổ chức chỉ có một cấu hình tenant |
| tenant_configurations_tenant_id_idx | UNIQUE | tenant_id | Đảm bảo ID tenant là duy nhất |
| tenant_configurations_tenant_code_idx | UNIQUE | tenant_code | Đảm bảo mã tenant là duy nhất |
| tenant_configurations_custom_domain_idx | UNIQUE | custom_domain | Đảm bảo tên miền tùy chỉnh là duy nhất |
| tenant_configurations_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| tenant_configurations_is_shared_idx | INDEX | is_shared | Tăng tốc truy vấn theo tenant dùng chung |
| tenant_configurations_shard_key_idx | INDEX | shard_key | Tăng tốc truy vấn theo khóa phân vùng |
| tenant_configurations_shard_group_idx | INDEX | shard_group | Tăng tốc truy vấn theo nhóm phân vùng |

### 5.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| tenant_configurations_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| tenant_configurations_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| tenant_configurations_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| tenant_configurations_database_type_check | CHECK | Đảm bảo database_type chỉ nhận các giá trị cho phép |
| tenant_configurations_cache_type_check | CHECK | Đảm bảo cache_type chỉ nhận các giá trị cho phép |
| tenant_configurations_storage_type_check | CHECK | Đảm bảo storage_type chỉ nhận các giá trị cho phép |
| tenant_configurations_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| tenant_configurations_database_port_check | CHECK | Đảm bảo database_port > 0 và database_port < 65536 |
| tenant_configurations_cache_port_check | CHECK | Đảm bảo cache_port > 0 và cache_port < 65536 khi không null |

### 5.5. Ví dụ JSON

```json
{
  "id": "t1e2n3a4-n5t6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "tenant_id": "tenant-001",
  "tenant_name": "Công ty ABC",
  "tenant_code": "abc",
  "database_type": "postgresql",
  "database_host": "db-cluster-1.NextFlow.com",
  "database_port": 5432,
  "database_name": "NextFlow_tenant_001",
  "database_schema": "public",
  "database_username": "tenant_001_user",
  "database_password": "encrypted:tenant_database_password_123456789",
  "database_options": {
    "pool_size": 10,
    "idle_timeout": 30000,
    "connect_timeout": 10000
  },
  "cache_type": "redis",
  "cache_host": "redis-cluster-1.NextFlow.com",
  "cache_port": 6379,
  "cache_options": {
    "prefix": "tenant_001:",
    "ttl": 3600
  },
  "storage_type": "s3",
  "storage_options": {
    "bucket": "NextFlow-tenant-001",
    "region": "ap-southeast-1",
    "base_url": "https://storage.NextFlow.com/tenant-001"
  },
  "custom_domain": "abc.NextFlow.com",
  "status": "active",
  "is_shared": false,
  "shard_key": "region-1",
  "shard_group": "apac",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-06-15T10:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
