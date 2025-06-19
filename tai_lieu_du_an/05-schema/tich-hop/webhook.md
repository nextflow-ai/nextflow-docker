# SCHEMA TÍCH HỢP - WEBHOOK

## 1. GIỚI THIỆU

Schema Webhook quản lý thông tin về các webhook trong hệ thống NextFlow CRM, cho phép tích hợp với các hệ thống bên ngoài thông qua cơ chế webhook. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến webhook trong hệ thống.

### 1.1. Mục đích

Schema Webhook phục vụ các mục đích sau:

- Lưu trữ thông tin cấu hình webhook
- Quản lý các sự kiện kích hoạt webhook
- Theo dõi lịch sử gửi webhook
- Đảm bảo tính bảo mật của webhook
- Hỗ trợ tích hợp với các hệ thống bên ngoài
- Xử lý webhook đến từ các hệ thống bên ngoài

### 1.2. Các bảng chính

Schema Webhook bao gồm các bảng chính sau:

1. `webhooks` - Lưu trữ thông tin cấu hình webhook
2. `webhook_events` - Lưu trữ thông tin sự kiện kích hoạt webhook
3. `webhook_deliveries` - Lưu trữ thông tin lịch sử gửi webhook
4. `webhook_subscriptions` - Lưu trữ thông tin đăng ký webhook
5. `webhook_endpoints` - Lưu trữ thông tin endpoint webhook

## 2. BẢNG WEBHOOKS

### 2.1. Mô tả

Bảng `webhooks` lưu trữ thông tin cấu hình webhook trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của webhook |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên webhook |
| description | text | true | null | Mô tả webhook |
| url | varchar(255) | false | | URL endpoint của webhook |
| http_method | varchar(10) | false | 'POST' | Phương thức HTTP: GET, POST, PUT, PATCH, DELETE |
| content_type | varchar(100) | false | 'application/json' | Kiểu nội dung: application/json, application/xml, etc. |
| headers | jsonb | true | null | Headers HTTP bổ sung |
| events | jsonb | false | | Danh sách sự kiện kích hoạt webhook |
| payload_template | text | true | null | Mẫu nội dung gửi đi |
| secret | varchar(255) | true | null | Khóa bí mật để xác thực webhook (được mã hóa) |
| signature_algorithm | varchar(20) | true | 'sha256' | Thuật toán chữ ký: sha256, sha512, etc. |
| status | varchar(20) | false | 'active' | Trạng thái: active, inactive, error |
| is_system | boolean | false | false | Đánh dấu là webhook hệ thống |
| retry_limit | integer | false | 3 | Số lần thử lại tối đa |
| retry_interval | integer | false | 60 | Khoảng thời gian giữa các lần thử lại (giây) |
| timeout | integer | false | 30 | Thời gian chờ phản hồi (giây) |
| last_triggered_at | timestamp | true | null | Thời gian kích hoạt gần nhất |
| last_success_at | timestamp | true | null | Thời gian thành công gần nhất |
| last_failure_at | timestamp | true | null | Thời gian thất bại gần nhất |
| failure_count | integer | false | 0 | Số lần thất bại liên tiếp |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| webhooks_pkey | PRIMARY KEY | id | Khóa chính |
| webhooks_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên webhook là duy nhất trong tổ chức |
| webhooks_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| webhooks_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| webhooks_is_system_idx | INDEX | is_system | Tăng tốc truy vấn theo webhook hệ thống |
| webhooks_last_triggered_at_idx | INDEX | last_triggered_at | Tăng tốc truy vấn theo thời gian kích hoạt gần nhất |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| webhooks_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| webhooks_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| webhooks_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| webhooks_http_method_check | CHECK | Đảm bảo http_method chỉ nhận các giá trị cho phép |
| webhooks_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| webhooks_retry_limit_check | CHECK | Đảm bảo retry_limit >= 0 |
| webhooks_retry_interval_check | CHECK | Đảm bảo retry_interval > 0 |
| webhooks_timeout_check | CHECK | Đảm bảo timeout > 0 |

### 2.5. Ví dụ JSON

```json
{
  "id": "w1e2b3h4-o5o6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Thông báo đơn hàng mới",
  "description": "Gửi thông báo khi có đơn hàng mới được tạo",
  "url": "https://api.example.com/webhooks/new-order",
  "http_method": "POST",
  "content_type": "application/json",
  "headers": {
    "X-API-Key": "encrypted:abcdefghijklmnopqrstuvwxyz",
    "X-Source": "NextFlow CRM"
  },
  "events": ["order.created", "order.updated"],
  "payload_template": "{\n  \"event\": \"{{event}}\",\n  \"timestamp\": \"{{timestamp}}\",\n  \"data\": {\n    \"order_id\": \"{{order.id}}\",\n    \"customer_id\": \"{{order.customer_id}}\",\n    \"total_amount\": {{order.total_amount}},\n    \"status\": \"{{order.status}}\"\n  }\n}",
  "secret": "encrypted:webhook_secret_123456789",
  "signature_algorithm": "sha256",
  "status": "active",
  "is_system": false,
  "retry_limit": 3,
  "retry_interval": 60,
  "timeout": 30,
  "last_triggered_at": "2023-07-15T10:30:00Z",
  "last_success_at": "2023-07-15T10:30:02Z",
  "last_failure_at": null,
  "failure_count": 0,
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-07-15T10:30:02Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG WEBHOOK_EVENTS

### 3.1. Mô tả

Bảng `webhook_events` lưu trữ thông tin về các sự kiện kích hoạt webhook trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(100) | false | | Tên sự kiện |
| code | varchar(100) | false | | Mã sự kiện |
| description | text | true | null | Mô tả sự kiện |
| category | varchar(50) | true | null | Danh mục sự kiện: order, customer, product, etc. |
| payload_schema | jsonb | true | null | Schema của dữ liệu sự kiện |
| is_system | boolean | false | false | Đánh dấu là sự kiện hệ thống |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| webhook_events_pkey | PRIMARY KEY | id | Khóa chính |
| webhook_events_organization_code_idx | UNIQUE | organization_id, code | Đảm bảo mã sự kiện là duy nhất trong tổ chức |
| webhook_events_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| webhook_events_category_idx | INDEX | category | Tăng tốc truy vấn theo danh mục |
| webhook_events_is_system_idx | INDEX | is_system | Tăng tốc truy vấn theo sự kiện hệ thống |
| webhook_events_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| webhook_events_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| webhook_events_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| webhook_events_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| webhook_events_category_check | CHECK | Đảm bảo category chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "e1v2e3n4-t5i6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Đơn hàng được tạo",
  "code": "order.created",
  "description": "Sự kiện khi một đơn hàng mới được tạo trong hệ thống",
  "category": "order",
  "payload_schema": {
    "type": "object",
    "properties": {
      "order_id": {
        "type": "string",
        "description": "ID của đơn hàng"
      },
      "customer_id": {
        "type": "string",
        "description": "ID của khách hàng"
      },
      "total_amount": {
        "type": "number",
        "description": "Tổng giá trị đơn hàng"
      },
      "status": {
        "type": "string",
        "description": "Trạng thái đơn hàng"
      },
      "created_at": {
        "type": "string",
        "format": "date-time",
        "description": "Thời gian tạo đơn hàng"
      }
    },
    "required": ["order_id", "customer_id", "total_amount", "status", "created_at"]
  },
  "is_system": true,
  "is_active": true,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG WEBHOOK_DELIVERIES

### 4.1. Mô tả

Bảng `webhook_deliveries` lưu trữ thông tin về lịch sử gửi webhook trong hệ thống.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| webhook_id | uuid | false | | Khóa ngoại tới bảng webhooks |
| event_code | varchar(100) | false | | Mã sự kiện |
| status | varchar(20) | false | 'pending' | Trạng thái: pending, success, failed, retrying |
| url | varchar(255) | false | | URL đích |
| http_method | varchar(10) | false | | Phương thức HTTP |
| headers | jsonb | true | null | Headers HTTP |
| payload | jsonb | false | | Nội dung gửi đi |
| response_status | integer | true | null | Mã trạng thái phản hồi |
| response_headers | jsonb | true | null | Headers phản hồi |
| response_body | text | true | null | Nội dung phản hồi |
| error_message | text | true | null | Thông báo lỗi |
| attempt_count | integer | false | 0 | Số lần thử |
| next_retry_at | timestamp | true | null | Thời gian thử lại tiếp theo |
| processing_time | integer | true | null | Thời gian xử lý (ms) |
| ip_address | varchar(45) | true | null | Địa chỉ IP |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| webhook_deliveries_pkey | PRIMARY KEY | id | Khóa chính |
| webhook_deliveries_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| webhook_deliveries_webhook_id_idx | INDEX | webhook_id | Tăng tốc truy vấn theo webhook |
| webhook_deliveries_event_code_idx | INDEX | event_code | Tăng tốc truy vấn theo mã sự kiện |
| webhook_deliveries_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| webhook_deliveries_created_at_idx | INDEX | created_at | Tăng tốc truy vấn theo thời gian tạo |
| webhook_deliveries_next_retry_at_idx | INDEX | next_retry_at | Tăng tốc truy vấn theo thời gian thử lại |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| webhook_deliveries_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| webhook_deliveries_webhook_id_fkey | FOREIGN KEY | Tham chiếu đến bảng webhooks(id) |
| webhook_deliveries_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| webhook_deliveries_http_method_check | CHECK | Đảm bảo http_method chỉ nhận các giá trị cho phép |
| webhook_deliveries_attempt_count_check | CHECK | Đảm bảo attempt_count >= 0 |
| webhook_deliveries_processing_time_check | CHECK | Đảm bảo processing_time >= 0 khi không null |

### 4.5. Ví dụ JSON

```json
{
  "id": "d1e2l3i4-v5e6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "webhook_id": "w1e2b3h4-o5o6-7890-abcd-ef1234567890",
  "event_code": "order.created",
  "status": "success",
  "url": "https://api.example.com/webhooks/new-order",
  "http_method": "POST",
  "headers": {
    "Content-Type": "application/json",
    "X-API-Key": "encrypted:abcdefghijklmnopqrstuvwxyz",
    "X-Source": "NextFlow CRM",
    "X-Webhook-Signature": "sha256=abcdef1234567890abcdef1234567890"
  },
  "payload": {
    "event": "order.created",
    "timestamp": "2023-07-15T10:30:00Z",
    "data": {
      "order_id": "ORD-2023-0001",
      "customer_id": "CUST-2023-0001",
      "total_amount": 1500000,
      "status": "pending"
    }
  },
  "response_status": 200,
  "response_headers": {
    "Content-Type": "application/json",
    "Server": "nginx/1.18.0"
  },
  "response_body": "{\"success\":true,\"message\":\"Webhook received successfully\"}",
  "error_message": null,
  "attempt_count": 1,
  "next_retry_at": null,
  "processing_time": 245,
  "ip_address": "203.0.113.1",
  "created_at": "2023-07-15T10:30:00Z",
  "updated_at": "2023-07-15T10:30:02Z"
}
```
