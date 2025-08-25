# SCHEMA TÍCH HỢP - API

## 1. GIỚI THIỆU

Schema API quản lý thông tin về các API, khóa API, quyền truy cập API và lịch sử sử dụng API trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến API trong hệ thống.

### 1.1. Mục đích

Schema API phục vụ các mục đích sau:

- Lưu trữ thông tin về các API được cung cấp
- Quản lý khóa API và xác thực
- Theo dõi quyền truy cập API
- Ghi nhận lịch sử sử dụng API
- Quản lý giới hạn tốc độ và hạn ngạch
- Hỗ trợ tích hợp với các hệ thống bên ngoài

### 1.2. Các bảng chính

Schema API bao gồm các bảng chính sau:

1. `api_resources` - Lưu trữ thông tin về các tài nguyên API
2. `api_keys` - Lưu trữ thông tin về các khóa API
3. `api_permissions` - Lưu trữ thông tin về quyền truy cập API
4. `api_logs` - Lưu trữ thông tin lịch sử sử dụng API
5. `api_rate_limits` - Lưu trữ thông tin giới hạn tốc độ API
6. `api_quotas` - Lưu trữ thông tin hạn ngạch API

## 2. BẢNG API_RESOURCES

### 2.1. Mô tả

Bảng `api_resources` lưu trữ thông tin về các tài nguyên API được cung cấp trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của tài nguyên API |
| name | varchar(100) | false | | Tên tài nguyên API |
| code | varchar(100) | false | | Mã tài nguyên API |
| description | text | true | null | Mô tả tài nguyên API |
| version | varchar(20) | false | 'v1' | Phiên bản API |
| path | varchar(255) | false | | Đường dẫn API |
| http_method | varchar(10) | false | | Phương thức HTTP: GET, POST, PUT, PATCH, DELETE |
| controller | varchar(100) | true | null | Controller xử lý |
| action | varchar(100) | true | null | Action xử lý |
| request_schema | jsonb | true | null | Schema của request |
| response_schema | jsonb | true | null | Schema của response |
| category | varchar(50) | true | null | Danh mục API: customer, order, product, etc. |
| is_public | boolean | false | false | Đánh dấu là API công khai |
| is_deprecated | boolean | false | false | Đánh dấu là API đã lỗi thời |
| deprecated_since | varchar(20) | true | null | Phiên bản bắt đầu lỗi thời |
| deprecated_message | text | true | null | Thông báo lỗi thời |
| rate_limit | integer | true | null | Giới hạn số lượng request (requests/minute) |
| requires_authentication | boolean | false | true | Yêu cầu xác thực |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| api_resources_pkey | PRIMARY KEY | id | Khóa chính |
| api_resources_code_version_idx | UNIQUE | code, version | Đảm bảo mã tài nguyên API là duy nhất trong mỗi phiên bản |
| api_resources_path_method_version_idx | UNIQUE | path, http_method, version | Đảm bảo đường dẫn API là duy nhất trong mỗi phiên bản và phương thức |
| api_resources_category_idx | INDEX | category | Tăng tốc truy vấn theo danh mục |
| api_resources_is_public_idx | INDEX | is_public | Tăng tốc truy vấn theo API công khai |
| api_resources_is_deprecated_idx | INDEX | is_deprecated | Tăng tốc truy vấn theo API lỗi thời |
| api_resources_requires_authentication_idx | INDEX | requires_authentication | Tăng tốc truy vấn theo yêu cầu xác thực |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| api_resources_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| api_resources_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| api_resources_http_method_check | CHECK | Đảm bảo http_method chỉ nhận các giá trị cho phép |
| api_resources_category_check | CHECK | Đảm bảo category chỉ nhận các giá trị cho phép |
| api_resources_rate_limit_check | CHECK | Đảm bảo rate_limit > 0 khi không null |

### 2.5. Ví dụ JSON

```json
{
  "id": "a1p2i3r4-e5s6-7890-abcd-ef1234567890",
  "name": "Lấy danh sách khách hàng",
  "code": "customers.list",
  "description": "API lấy danh sách khách hàng với các tùy chọn lọc và phân trang",
  "version": "v1",
  "path": "/api/v1/customers",
  "http_method": "GET",
  "controller": "CustomersController",
  "action": "index",
  "request_schema": {
    "type": "object",
    "properties": {
      "page": {
        "type": "integer",
        "description": "Số trang",
        "default": 1
      },
      "per_page": {
        "type": "integer",
        "description": "Số lượng bản ghi mỗi trang",
        "default": 20,
        "maximum": 100
      },
      "sort": {
        "type": "string",
        "description": "Trường sắp xếp",
        "enum": ["created_at", "updated_at", "name", "email"]
      },
      "order": {
        "type": "string",
        "description": "Thứ tự sắp xếp",
        "enum": ["asc", "desc"],
        "default": "desc"
      },
      "search": {
        "type": "string",
        "description": "Từ khóa tìm kiếm"
      },
      "status": {
        "type": "string",
        "description": "Lọc theo trạng thái",
        "enum": ["active", "inactive", "pending"]
      }
    }
  },
  "response_schema": {
    "type": "object",
    "properties": {
      "success": {
        "type": "boolean",
        "description": "Trạng thái thành công"
      },
      "code": {
        "type": "string",
        "description": "Mã phản hồi"
      },
      "message": {
        "type": "string",
        "description": "Thông báo phản hồi"
      },
      "data": {
        "type": "array",
        "description": "Danh sách khách hàng",
        "items": {
          "type": "object",
          "properties": {
            "id": {
              "type": "string",
              "description": "ID khách hàng"
            },
            "name": {
              "type": "string",
              "description": "Tên khách hàng"
            },
            "email": {
              "type": "string",
              "description": "Email khách hàng"
            },
            "phone": {
              "type": "string",
              "description": "Số điện thoại khách hàng"
            },
            "status": {
              "type": "string",
              "description": "Trạng thái khách hàng"
            },
            "created_at": {
              "type": "string",
              "format": "date-time",
              "description": "Thời gian tạo"
            },
            "updated_at": {
              "type": "string",
              "format": "date-time",
              "description": "Thời gian cập nhật"
            }
          }
        }
      },
      "meta": {
        "type": "object",
        "description": "Thông tin phân trang",
        "properties": {
          "current_page": {
            "type": "integer",
            "description": "Trang hiện tại"
          },
          "per_page": {
            "type": "integer",
            "description": "Số lượng bản ghi mỗi trang"
          },
          "total": {
            "type": "integer",
            "description": "Tổng số bản ghi"
          },
          "total_pages": {
            "type": "integer",
            "description": "Tổng số trang"
          }
        }
      }
    }
  },
  "category": "customer",
  "is_public": true,
  "is_deprecated": false,
  "deprecated_since": null,
  "deprecated_message": null,
  "rate_limit": 100,
  "requires_authentication": true,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG API_KEYS

### 3.1. Mô tả

Bảng `api_keys` lưu trữ thông tin về các khóa API được cấp trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| user_id | uuid | true | null | Khóa ngoại tới bảng users |
| name | varchar(100) | false | | Tên khóa API |
| description | text | true | null | Mô tả khóa API |
| key | varchar(255) | false | | Khóa API (được mã hóa) |
| secret | varchar(255) | true | null | Bí mật API (được mã hóa) |
| type | varchar(20) | false | 'client' | Loại khóa: client, server, admin |
| status | varchar(20) | false | 'active' | Trạng thái: active, inactive, revoked |
| expires_at | timestamp | true | null | Thời gian hết hạn |
| last_used_at | timestamp | true | null | Thời gian sử dụng gần nhất |
| usage_count | integer | false | 0 | Số lần sử dụng |
| ip_restrictions | jsonb | true | null | Giới hạn địa chỉ IP |
| rate_limit | integer | true | null | Giới hạn số lượng request (requests/minute) |
| quota | integer | true | null | Hạn ngạch sử dụng (requests/month) |
| quota_reset_at | timestamp | true | null | Thời gian reset hạn ngạch |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| api_keys_pkey | PRIMARY KEY | id | Khóa chính |
| api_keys_key_idx | UNIQUE | key | Đảm bảo khóa API là duy nhất |
| api_keys_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| api_keys_user_id_idx | INDEX | user_id | Tăng tốc truy vấn theo người dùng |
| api_keys_type_idx | INDEX | type | Tăng tốc truy vấn theo loại khóa |
| api_keys_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| api_keys_expires_at_idx | INDEX | expires_at | Tăng tốc truy vấn theo thời gian hết hạn |
| api_keys_last_used_at_idx | INDEX | last_used_at | Tăng tốc truy vấn theo thời gian sử dụng gần nhất |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| api_keys_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| api_keys_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| api_keys_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| api_keys_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| api_keys_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| api_keys_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| api_keys_usage_count_check | CHECK | Đảm bảo usage_count >= 0 |
| api_keys_rate_limit_check | CHECK | Đảm bảo rate_limit > 0 khi không null |
| api_keys_quota_check | CHECK | Đảm bảo quota > 0 khi không null |

### 3.5. Ví dụ JSON

```json
{
  "id": "a1p2i3k4-e5y6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "name": "Khóa API cho ứng dụng di động",
  "description": "Khóa API được sử dụng bởi ứng dụng di động NextFlow CRM-AI",
  "key": "encrypted:api_key_abcdefghijklmnopqrstuvwxyz",
  "secret": "encrypted:api_secret_123456789abcdefghijklmnopqrstuvwxyz",
  "type": "client",
  "status": "active",
  "expires_at": "2024-12-31T23:59:59Z",
  "last_used_at": "2023-07-15T10:30:00Z",
  "usage_count": 1250,
  "ip_restrictions": [
    "203.0.113.0/24",
    "198.51.100.0/24"
  ],
  "rate_limit": 100,
  "quota": 100000,
  "quota_reset_at": "2023-08-01T00:00:00Z",
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-07-15T10:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG API_PERMISSIONS

### 4.1. Mô tả

Bảng `api_permissions` lưu trữ thông tin về quyền truy cập API trong hệ thống.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| api_key_id | uuid | false | | Khóa ngoại tới bảng api_keys |
| resource_code | varchar(100) | true | null | Mã tài nguyên API |
| resource_pattern | varchar(255) | true | null | Mẫu tài nguyên API (regex) |
| http_method | varchar(10) | true | null | Phương thức HTTP |
| action | varchar(20) | false | | Hành động: allow, deny |
| conditions | jsonb | true | null | Điều kiện áp dụng |
| priority | integer | false | 0 | Độ ưu tiên |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| api_permissions_pkey | PRIMARY KEY | id | Khóa chính |
| api_permissions_api_key_resource_method_idx | UNIQUE | api_key_id, resource_code, http_method | Đảm bảo quyền truy cập API là duy nhất cho mỗi khóa API, tài nguyên và phương thức |
| api_permissions_api_key_id_idx | INDEX | api_key_id | Tăng tốc truy vấn theo khóa API |
| api_permissions_resource_code_idx | INDEX | resource_code | Tăng tốc truy vấn theo mã tài nguyên |
| api_permissions_http_method_idx | INDEX | http_method | Tăng tốc truy vấn theo phương thức HTTP |
| api_permissions_action_idx | INDEX | action | Tăng tốc truy vấn theo hành động |
| api_permissions_priority_idx | INDEX | priority | Tăng tốc truy vấn theo độ ưu tiên |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| api_permissions_api_key_id_fkey | FOREIGN KEY | Tham chiếu đến bảng api_keys(id) |
| api_permissions_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| api_permissions_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| api_permissions_http_method_check | CHECK | Đảm bảo http_method chỉ nhận các giá trị cho phép |
| api_permissions_action_check | CHECK | Đảm bảo action chỉ nhận các giá trị cho phép |
| api_permissions_resource_check | CHECK | Đảm bảo resource_code hoặc resource_pattern phải có giá trị |

### 4.5. Ví dụ JSON

```json
{
  "id": "p1e2r3m4-i5s6-7890-abcd-ef1234567890",
  "api_key_id": "a1p2i3k4-e5y6-7890-abcd-ef1234567890",
  "resource_code": "customers.list",
  "resource_pattern": null,
  "http_method": "GET",
  "action": "allow",
  "conditions": {
    "ip_range": ["203.0.113.0/24"],
    "time_window": {
      "start": "08:00:00",
      "end": "18:00:00"
    },
    "max_results": 100
  },
  "priority": 10,
  "created_at": "2023-01-15T09:30:00Z",
  "updated_at": "2023-01-15T09:30:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
