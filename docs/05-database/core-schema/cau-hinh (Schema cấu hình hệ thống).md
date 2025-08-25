# SCHEMA HỆ THỐNG - CẤU HÌNH

## 1. GIỚI THIỆU

Schema Cấu hình quản lý thông tin về các cấu hình hệ thống, cài đặt, tùy chọn và các thông số cấu hình khác trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến cấu hình hệ thống.

### 1.1. Mục đích

Schema Cấu hình phục vụ các mục đích sau:

- Lưu trữ thông tin cấu hình hệ thống
- Quản lý cài đặt cho từng tổ chức
- Lưu trữ tùy chọn người dùng
- Quản lý cấu hình tính năng và module
- Hỗ trợ cấu hình đa ngôn ngữ và đa vùng
- Quản lý cấu hình giao diện người dùng

### 1.2. Các bảng chính

Schema Cấu hình bao gồm các bảng chính sau:

1. `system_settings` - Lưu trữ thông tin cài đặt hệ thống
2. `organization_settings` - Lưu trữ thông tin cài đặt tổ chức
3. `user_preferences` - Lưu trữ thông tin tùy chọn người dùng
4. `feature_flags` - Lưu trữ thông tin cờ tính năng
5. `localization_settings` - Lưu trữ thông tin cài đặt địa phương hóa
6. `ui_settings` - Lưu trữ thông tin cài đặt giao diện người dùng

## 2. BẢNG SYSTEM_SETTINGS

### 2.1. Mô tả

Bảng `system_settings` lưu trữ thông tin về các cài đặt hệ thống trong NextFlow CRM-AI.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của cài đặt |
| key | varchar(100) | false | | Khóa cài đặt |
| value | text | true | null | Giá trị cài đặt |
| value_type | varchar(20) | false | 'string' | Kiểu giá trị: string, number, boolean, json |
| description | text | true | null | Mô tả cài đặt |
| category | varchar(50) | false | 'general' | Danh mục: general, security, email, stalwart_mail, ai, etc. |
| is_encrypted | boolean | false | false | Đánh dấu là giá trị được mã hóa |
| is_editable | boolean | false | true | Đánh dấu là có thể chỉnh sửa |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| system_settings_pkey | PRIMARY KEY | id | Khóa chính |
| system_settings_key_idx | UNIQUE | key | Đảm bảo khóa cài đặt là duy nhất |
| system_settings_category_idx | INDEX | category | Tăng tốc truy vấn theo danh mục |
| system_settings_is_editable_idx | INDEX | is_editable | Tăng tốc truy vấn theo khả năng chỉnh sửa |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| system_settings_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| system_settings_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| system_settings_value_type_check | CHECK | Đảm bảo value_type chỉ nhận các giá trị cho phép |
| system_settings_category_check | CHECK | Đảm bảo category chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "s1y2s3t4-e5m6-7890-abcd-ef1234567890",
  "key": "system.email.smtp_server",
  "value": "smtp.gmail.com",
  "value_type": "string",
  "description": "Địa chỉ máy chủ SMTP cho email hệ thống",
  "category": "email",
  "is_encrypted": false,
  "is_editable": true,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG ORGANIZATION_SETTINGS

### 3.1. Mô tả

Bảng `organization_settings` lưu trữ thông tin về các cài đặt tổ chức trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| key | varchar(100) | false | | Khóa cài đặt |
| value | text | true | null | Giá trị cài đặt |
| value_type | varchar(20) | false | 'string' | Kiểu giá trị: string, number, boolean, json |
| description | text | true | null | Mô tả cài đặt |
| category | varchar(50) | false | 'general' | Danh mục: general, security, email, etc. |
| is_encrypted | boolean | false | false | Đánh dấu là giá trị được mã hóa |
| is_editable | boolean | false | true | Đánh dấu là có thể chỉnh sửa |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| organization_settings_pkey | PRIMARY KEY | id | Khóa chính |
| organization_settings_org_key_idx | UNIQUE | organization_id, key | Đảm bảo khóa cài đặt là duy nhất trong tổ chức |
| organization_settings_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| organization_settings_category_idx | INDEX | category | Tăng tốc truy vấn theo danh mục |
| organization_settings_is_editable_idx | INDEX | is_editable | Tăng tốc truy vấn theo khả năng chỉnh sửa |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| organization_settings_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| organization_settings_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| organization_settings_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| organization_settings_value_type_check | CHECK | Đảm bảo value_type chỉ nhận các giá trị cho phép |
| organization_settings_category_check | CHECK | Đảm bảo category chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "o1r2g3s4-e5t6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "key": "organization.branding.primary_color",
  "value": "#1976d2",
  "value_type": "string",
  "description": "Màu chủ đạo của thương hiệu",
  "category": "branding",
  "is_encrypted": false,
  "is_editable": true,
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-06-01T10:30:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG USER_PREFERENCES

### 4.1. Mô tả

Bảng `user_preferences` lưu trữ thông tin về các tùy chọn của người dùng trong hệ thống.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| user_id | uuid | false | | Khóa ngoại tới bảng users |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| key | varchar(100) | false | | Khóa tùy chọn |
| value | text | true | null | Giá trị tùy chọn |
| value_type | varchar(20) | false | 'string' | Kiểu giá trị: string, number, boolean, json |
| category | varchar(50) | false | 'general' | Danh mục: general, ui, notification, etc. |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| user_preferences_pkey | PRIMARY KEY | id | Khóa chính |
| user_preferences_user_org_key_idx | UNIQUE | user_id, organization_id, key | Đảm bảo khóa tùy chọn là duy nhất cho mỗi người dùng trong tổ chức |
| user_preferences_user_id_idx | INDEX | user_id | Tăng tốc truy vấn theo người dùng |
| user_preferences_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| user_preferences_category_idx | INDEX | category | Tăng tốc truy vấn theo danh mục |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| user_preferences_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| user_preferences_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| user_preferences_value_type_check | CHECK | Đảm bảo value_type chỉ nhận các giá trị cho phép |
| user_preferences_category_check | CHECK | Đảm bảo category chỉ nhận các giá trị cho phép |

### 4.5. Ví dụ JSON

```json
{
  "id": "u1s2e3r4-p5r6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "key": "user.ui.theme",
  "value": "dark",
  "value_type": "string",
  "category": "ui",
  "created_at": "2023-06-15T10:00:00Z",
  "updated_at": "2023-06-15T10:00:00Z"
}
```

## 5. BẢNG FEATURE_FLAGS

### 5.1. Mô tả

Bảng `feature_flags` lưu trữ thông tin về các cờ tính năng trong hệ thống.

### 5.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| key | varchar(100) | false | | Khóa cờ tính năng |
| name | varchar(100) | false | | Tên cờ tính năng |
| description | text | true | null | Mô tả cờ tính năng |
| is_enabled | boolean | false | false | Trạng thái kích hoạt |
| is_system | boolean | false | false | Đánh dấu là cờ hệ thống |
| rules | jsonb | true | null | Quy tắc áp dụng |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 5.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| feature_flags_pkey | PRIMARY KEY | id | Khóa chính |
| feature_flags_key_idx | UNIQUE | key | Đảm bảo khóa cờ tính năng là duy nhất |
| feature_flags_is_enabled_idx | INDEX | is_enabled | Tăng tốc truy vấn theo trạng thái kích hoạt |
| feature_flags_is_system_idx | INDEX | is_system | Tăng tốc truy vấn theo cờ hệ thống |

### 5.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| feature_flags_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| feature_flags_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |

### 5.5. Ví dụ JSON

```json
{
  "id": "f1e2a3t4-u5r6-7890-abcd-ef1234567890",
  "key": "feature.ai_chatbot",
  "name": "AI Chatbot",
  "description": "Kích hoạt tính năng chatbot AI cho hệ thống",
  "is_enabled": true,
  "is_system": false,
  "rules": {
    "organizations": ["o1p2q3r4-s5t6-7890-uvwx-yz1234567890"],
    "plans": ["premium", "enterprise"],
    "percentage": 100,
    "start_date": "2023-06-01T00:00:00Z",
    "end_date": null
  },
  "created_at": "2023-05-15T09:00:00Z",
  "updated_at": "2023-06-01T00:00:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 7. CẤU HÌNH STALWART MAIL SERVER

### 7.1. Mô tả

Stalwart Mail là mail server tự triển khai được NextFlow CRM-AI sử dụng để xử lý tất cả email hệ thống, transactional emails và internal communications. Việc sử dụng Stalwart Mail giúp giảm thiểu chi phí và tăng cường bảo mật.

### 7.2. Cấu hình Stalwart Mail trong system_settings

#### 7.2.1. Cấu hình kết nối

```json
{
  "key": "stalwart_mail.host",
  "value": "mail.nextflow-crm.com",
  "value_type": "string",
  "category": "stalwart_mail",
  "description": "Hostname của Stalwart Mail server"
}

{
  "key": "stalwart_mail.port",
  "value": "587",
  "value_type": "number",
  "category": "stalwart_mail",
  "description": "Port SMTP cho Stalwart Mail (587 cho STARTTLS)"
}

{
  "key": "stalwart_mail.encryption",
  "value": "STARTTLS",
  "value_type": "string",
  "category": "stalwart_mail",
  "description": "Phương thức mã hóa: STARTTLS, SSL/TLS"
}

{
  "key": "stalwart_mail.username",
  "value": "nextflow@nextflow-crm.com",
  "value_type": "string",
  "category": "stalwart_mail",
  "description": "Username để authenticate với Stalwart Mail"
}

{
  "key": "stalwart_mail.password",
  "value": "encrypted_password_here",
  "value_type": "string",
  "category": "stalwart_mail",
  "description": "Password để authenticate với Stalwart Mail",
  "is_encrypted": true
}
```

#### 7.2.2. Cấu hình email templates

```json
{
  "key": "stalwart_mail.default_from_name",
  "value": "NextFlow CRM-AI",
  "value_type": "string",
  "category": "stalwart_mail",
  "description": "Tên người gửi mặc định"
}

{
  "key": "stalwart_mail.default_from_email",
  "value": "noreply@nextflow-crm.com",
  "value_type": "string",
  "category": "stalwart_mail",
  "description": "Email người gửi mặc định"
}

{
  "key": "stalwart_mail.reply_to_email",
  "value": "support@nextflow-crm.com",
  "value_type": "string",
  "category": "stalwart_mail",
  "description": "Email reply-to mặc định"
}
```

#### 7.2.3. Cấu hình email routing

```json
{
  "key": "stalwart_mail.routing_rules",
  "value": {
    "transactional": {
      "patterns": ["otp_*", "password_reset_*", "account_*"],
      "priority": "high",
      "retry_attempts": 3
    },
    "system": {
      "patterns": ["system_*", "alert_*", "notification_*"],
      "priority": "medium",
      "retry_attempts": 2
    },
    "internal": {
      "patterns": ["internal_*", "team_*"],
      "priority": "low",
      "retry_attempts": 1
    }
  },
  "value_type": "json",
  "category": "stalwart_mail",
  "description": "Quy tắc routing email theo loại"
}
```

#### 7.2.4. Cấu hình bảo mật

```json
{
  "key": "stalwart_mail.dkim_enabled",
  "value": "true",
  "value_type": "boolean",
  "category": "stalwart_mail",
  "description": "Bật DKIM signing cho email"
}

{
  "key": "stalwart_mail.spf_record",
  "value": "v=spf1 include:nextflow-crm.com ~all",
  "value_type": "string",
  "category": "stalwart_mail",
  "description": "SPF record cho domain"
}

{
  "key": "stalwart_mail.dmarc_policy",
  "value": "v=DMARC1; p=quarantine; rua=mailto:dmarc@nextflow-crm.com",
  "value_type": "string",
  "category": "stalwart_mail",
  "description": "DMARC policy cho domain"
}
```

#### 7.2.5. Cấu hình monitoring

```json
{
  "key": "stalwart_mail.max_retry_attempts",
  "value": "3",
  "value_type": "number",
  "category": "stalwart_mail",
  "description": "Số lần retry tối đa khi gửi email thất bại"
}

{
  "key": "stalwart_mail.queue_timeout",
  "value": "3600",
  "value_type": "number",
  "category": "stalwart_mail",
  "description": "Timeout cho email queue (giây)"
}

{
  "key": "stalwart_mail.enable_logging",
  "value": "true",
  "value_type": "boolean",
  "category": "stalwart_mail",
  "description": "Bật logging cho Stalwart Mail"
}

{
  "key": "stalwart_mail.log_level",
  "value": "INFO",
  "value_type": "string",
  "category": "stalwart_mail",
  "description": "Mức độ logging: DEBUG, INFO, WARN, ERROR"
}
```

### 7.3. Lợi ích của Stalwart Mail

#### 7.3.1. Tối ưu chi phí
- **$0 license fee**: Open source, không phí bản quyền
- **Chi phí server thấp**: Chỉ $50-100/tháng cho VPS
- **Không giới hạn email**: Gửi không giới hạn số lượng
- **ROI cao**: Tiết kiệm 60-80% so với SaaS email services

#### 7.3.2. Bảo mật và kiểm soát
- **Dữ liệu tại chỗ**: Email không rời khỏi infrastructure
- **Tuân thủ GDPR**: Kiểm soát hoàn toàn dữ liệu khách hàng
- **Tùy chỉnh bảo mật**: Cấu hình theo yêu cầu cụ thể
- **Audit trail**: Theo dõi chi tiết mọi hoạt động email

#### 7.3.3. Tích hợp với NextFlow CRM-AI
- **API native**: Tích hợp trực tiếp với hệ thống
- **Multi-tenant**: Hỗ trợ nhiều tổ chức trên cùng server
- **Scalable**: Mở rộng theo nhu cầu sử dụng
- **Monitoring**: Tích hợp với hệ thống giám sát NextFlow
