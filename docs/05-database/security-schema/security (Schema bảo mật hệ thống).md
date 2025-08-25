# SCHEMA BẢO MẬT

## 1. GIỚI THIỆU

Schema Bảo mật quản lý thông tin về các chính sách bảo mật, kiểm soát truy cập, xác thực hai yếu tố, nhật ký bảo mật và các hoạt động liên quan đến bảo mật trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến bảo mật trong hệ thống.

### 1.1. Mục đích

Schema Bảo mật phục vụ các mục đích sau:

- Lưu trữ thông tin về các chính sách bảo mật
- Quản lý xác thực hai yếu tố (2FA)
- Theo dõi phiên đăng nhập và hoạt động người dùng
- Ghi nhận nhật ký bảo mật và sự kiện
- Quản lý mã thông báo truy cập (access token)
- Kiểm soát truy cập dựa trên vai trò và quyền hạn

### 1.2. Các bảng chính

Schema Bảo mật bao gồm các bảng chính sau:

1. `security_policies` - Lưu trữ thông tin về các chính sách bảo mật
2. `two_factor_auth` - Lưu trữ thông tin xác thực hai yếu tố
3. `user_sessions` - Lưu trữ thông tin phiên đăng nhập
4. `access_tokens` - Lưu trữ thông tin mã thông báo truy cập
5. `security_logs` - Lưu trữ thông tin nhật ký bảo mật
6. `security_events` - Lưu trữ thông tin sự kiện bảo mật

## 2. BẢNG SECURITY_POLICIES

### 2.1. Mô tả

Bảng `security_policies` lưu trữ thông tin về các chính sách bảo mật trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của chính sách |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên chính sách |
| description | text | true | null | Mô tả chính sách |
| type | varchar(50) | false | | Loại chính sách: password, session, access_control, etc. |
| settings | jsonb | false | | Cài đặt chính sách |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| applies_to | jsonb | true | null | Đối tượng áp dụng |
| priority | integer | false | 0 | Độ ưu tiên |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| security_policies_pkey | PRIMARY KEY | id | Khóa chính |
| security_policies_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên chính sách là duy nhất trong tổ chức |
| security_policies_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| security_policies_type_idx | INDEX | type | Tăng tốc truy vấn theo loại chính sách |
| security_policies_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |
| security_policies_priority_idx | INDEX | priority | Tăng tốc truy vấn theo độ ưu tiên |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| security_policies_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| security_policies_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| security_policies_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| security_policies_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "p1o2l3i4-c5y6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Chính sách mật khẩu mạnh",
  "description": "Yêu cầu mật khẩu mạnh cho tất cả người dùng trong tổ chức",
  "type": "password",
  "settings": {
    "min_length": 12,
    "require_uppercase": true,
    "require_lowercase": true,
    "require_numbers": true,
    "require_special_chars": true,
    "max_age_days": 90,
    "prevent_reuse": 5,
    "lockout_threshold": 5,
    "lockout_duration_minutes": 30
  },
  "is_active": true,
  "applies_to": {
    "roles": ["all"],
    "departments": ["all"],
    "exceptions": {
      "users": [],
      "roles": []
    }
  },
  "priority": 10,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG TWO_FACTOR_AUTH

### 3.1. Mô tả

Bảng `two_factor_auth` lưu trữ thông tin về xác thực hai yếu tố của người dùng trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| user_id | uuid | false | | Khóa ngoại tới bảng users |
| type | varchar(20) | false | | Loại xác thực: totp, sms, email, app |
| identifier | varchar(255) | true | null | Định danh (email, số điện thoại) |
| secret | varchar(255) | true | null | Khóa bí mật (được mã hóa) |
| backup_codes | jsonb | true | null | Mã dự phòng (được mã hóa) |
| is_enabled | boolean | false | false | Trạng thái kích hoạt |
| last_verified_at | timestamp | true | null | Thời gian xác thực gần nhất |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| two_factor_auth_pkey | PRIMARY KEY | id | Khóa chính |
| two_factor_auth_user_type_idx | UNIQUE | user_id, type | Đảm bảo mỗi người dùng chỉ có một loại xác thực hai yếu tố |
| two_factor_auth_user_id_idx | INDEX | user_id | Tăng tốc truy vấn theo người dùng |
| two_factor_auth_type_idx | INDEX | type | Tăng tốc truy vấn theo loại xác thực |
| two_factor_auth_is_enabled_idx | INDEX | is_enabled | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| two_factor_auth_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| two_factor_auth_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "t1f2a3i4-d5i6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "type": "totp",
  "identifier": "nguyenvana@NextFlow.com",
  "secret": "encrypted:totp_secret_abcdefghijklmnopqrstuvwxyz",
  "backup_codes": [
    "encrypted:backup_code_1",
    "encrypted:backup_code_2",
    "encrypted:backup_code_3",
    "encrypted:backup_code_4",
    "encrypted:backup_code_5"
  ],
  "is_enabled": true,
  "last_verified_at": "2023-07-15T10:30:00Z",
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-07-15T10:30:00Z",
  "deleted_at": null
}
```

## 4. BẢNG USER_SESSIONS

### 4.1. Mô tả

Bảng `user_sessions` lưu trữ thông tin về các phiên đăng nhập của người dùng trong hệ thống.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| user_id | uuid | false | | Khóa ngoại tới bảng users |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| session_token | varchar(255) | false | | Mã thông báo phiên (được mã hóa) |
| refresh_token | varchar(255) | true | null | Mã thông báo làm mới (được mã hóa) |
| ip_address | varchar(45) | true | null | Địa chỉ IP |
| user_agent | text | true | null | User-Agent |
| device_info | jsonb | true | null | Thông tin thiết bị |
| location_info | jsonb | true | null | Thông tin vị trí |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| is_remembered | boolean | false | false | Đánh dấu là "Ghi nhớ đăng nhập" |
| last_activity_at | timestamp | false | now() | Thời gian hoạt động gần nhất |
| expires_at | timestamp | false | | Thời gian hết hạn |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| terminated_at | timestamp | true | null | Thời gian kết thúc phiên |
| termination_reason | varchar(50) | true | null | Lý do kết thúc phiên |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| user_sessions_pkey | PRIMARY KEY | id | Khóa chính |
| user_sessions_session_token_idx | UNIQUE | session_token | Đảm bảo mã thông báo phiên là duy nhất |
| user_sessions_refresh_token_idx | UNIQUE | refresh_token | Đảm bảo mã thông báo làm mới là duy nhất |
| user_sessions_user_id_idx | INDEX | user_id | Tăng tốc truy vấn theo người dùng |
| user_sessions_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| user_sessions_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |
| user_sessions_last_activity_at_idx | INDEX | last_activity_at | Tăng tốc truy vấn theo thời gian hoạt động gần nhất |
| user_sessions_expires_at_idx | INDEX | expires_at | Tăng tốc truy vấn theo thời gian hết hạn |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| user_sessions_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| user_sessions_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| user_sessions_termination_reason_check | CHECK | Đảm bảo termination_reason chỉ nhận các giá trị cho phép |
| user_sessions_expires_check | CHECK | Đảm bảo expires_at > created_at |

### 4.5. Ví dụ JSON

```json
{
  "id": "s1e2s3s4-i5o6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "session_token": "encrypted:session_token_abcdefghijklmnopqrstuvwxyz",
  "refresh_token": "encrypted:refresh_token_123456789abcdefghijklmnopqrstuvwxyz",
  "ip_address": "203.0.113.1",
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
  "device_info": {
    "type": "desktop",
    "os": "Windows 10",
    "browser": "Chrome",
    "browser_version": "115.0.0.0",
    "device_id": "device_fingerprint_abcdef123456"
  },
  "location_info": {
    "country": "Vietnam",
    "city": "Ho Chi Minh City",
    "latitude": 10.8231,
    "longitude": 106.6297
  },
  "is_active": true,
  "is_remembered": true,
  "last_activity_at": "2023-07-15T10:45:00Z",
  "expires_at": "2023-08-15T10:00:00Z",
  "created_at": "2023-07-15T10:00:00Z",
  "updated_at": "2023-07-15T10:45:00Z",
  "terminated_at": null,
  "termination_reason": null
}
```

## 5. BẢNG SECURITY_LOGS

### 5.1. Mô tả

Bảng `security_logs` lưu trữ thông tin về các nhật ký bảo mật trong hệ thống.

### 5.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| user_id | uuid | true | null | Khóa ngoại tới bảng users |
| session_id | uuid | true | null | Khóa ngoại tới bảng user_sessions |
| event_type | varchar(50) | false | | Loại sự kiện: login, logout, password_change, etc. |
| event_category | varchar(50) | false | | Danh mục sự kiện: authentication, authorization, data_access, etc. |
| severity | varchar(20) | false | 'info' | Mức độ nghiêm trọng: info, warning, error, critical |
| description | text | false | | Mô tả sự kiện |
| ip_address | varchar(45) | true | null | Địa chỉ IP |
| user_agent | text | true | null | User-Agent |
| request_method | varchar(10) | true | null | Phương thức HTTP |
| request_url | varchar(255) | true | null | URL yêu cầu |
| request_data | jsonb | true | null | Dữ liệu yêu cầu |
| response_code | integer | true | null | Mã phản hồi HTTP |
| resource_type | varchar(50) | true | null | Loại tài nguyên |
| resource_id | varchar(100) | true | null | ID tài nguyên |
| status | varchar(20) | false | 'success' | Trạng thái: success, failure |
| error_code | varchar(50) | true | null | Mã lỗi |
| error_message | text | true | null | Thông báo lỗi |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |

### 5.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| security_logs_pkey | PRIMARY KEY | id | Khóa chính |
| security_logs_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| security_logs_user_id_idx | INDEX | user_id | Tăng tốc truy vấn theo người dùng |
| security_logs_session_id_idx | INDEX | session_id | Tăng tốc truy vấn theo phiên |
| security_logs_event_type_idx | INDEX | event_type | Tăng tốc truy vấn theo loại sự kiện |
| security_logs_event_category_idx | INDEX | event_category | Tăng tốc truy vấn theo danh mục sự kiện |
| security_logs_severity_idx | INDEX | severity | Tăng tốc truy vấn theo mức độ nghiêm trọng |
| security_logs_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| security_logs_created_at_idx | INDEX | created_at | Tăng tốc truy vấn theo thời gian tạo |
| security_logs_ip_address_idx | INDEX | ip_address | Tăng tốc truy vấn theo địa chỉ IP |
| security_logs_resource_type_id_idx | INDEX | resource_type, resource_id | Tăng tốc truy vấn theo tài nguyên |

### 5.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| security_logs_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| security_logs_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| security_logs_session_id_fkey | FOREIGN KEY | Tham chiếu đến bảng user_sessions(id) |
| security_logs_event_type_check | CHECK | Đảm bảo event_type chỉ nhận các giá trị cho phép |
| security_logs_event_category_check | CHECK | Đảm bảo event_category chỉ nhận các giá trị cho phép |
| security_logs_severity_check | CHECK | Đảm bảo severity chỉ nhận các giá trị cho phép |
| security_logs_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| security_logs_request_method_check | CHECK | Đảm bảo request_method chỉ nhận các giá trị cho phép |

### 5.5. Ví dụ JSON

```json
{
  "id": "l1o2g3i4-d5i6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "session_id": "s1e2s3s4-i5o6-7890-abcd-ef1234567890",
  "event_type": "login",
  "event_category": "authentication",
  "severity": "info",
  "description": "Đăng nhập thành công",
  "ip_address": "203.0.113.1",
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
  "request_method": "POST",
  "request_url": "https://api.NextFlow.com/auth/login",
  "request_data": {
    "email": "nguyenvana@NextFlow.com",
    "remember_me": true
  },
  "response_code": 200,
  "resource_type": "user",
  "resource_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "success",
  "error_code": null,
  "error_message": null,
  "created_at": "2023-07-15T10:00:00Z"
}
```
