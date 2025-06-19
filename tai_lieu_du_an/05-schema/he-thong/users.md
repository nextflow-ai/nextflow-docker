# SCHEMA HỆ THỐNG - USERS

## 1. GIỚI THIỆU

Schema Users quản lý thông tin về người dùng, vai trò, quyền hạn và các thông tin liên quan đến quản lý người dùng trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến quản lý người dùng trong hệ thống.

### 1.1. Mục đích

Schema Users phục vụ các mục đích sau:

- Lưu trữ thông tin người dùng
- Quản lý vai trò và quyền hạn
- Quản lý phân quyền theo tổ chức
- Quản lý xác thực và phiên làm việc
- Theo dõi hoạt động người dùng
- Quản lý cài đặt và tùy chọn người dùng

### 1.2. Các bảng chính

Schema Users bao gồm các bảng chính sau:

1. `users` - Lưu trữ thông tin người dùng
2. `roles` - Lưu trữ thông tin vai trò
3. `permissions` - Lưu trữ thông tin quyền hạn
4. `role_permissions` - Lưu trữ thông tin quyền hạn của vai trò
5. `user_roles` - Lưu trữ thông tin vai trò của người dùng
6. `user_permissions` - Lưu trữ thông tin quyền hạn của người dùng
7. `user_sessions` - Lưu trữ thông tin phiên làm việc
8. `user_activities` - Lưu trữ thông tin hoạt động người dùng
9. `user_settings` - Lưu trữ thông tin cài đặt người dùng

## 2. BẢNG USERS

### 2.1. Mô tả

Bảng `users` lưu trữ thông tin cơ bản về người dùng trong hệ thống, bao gồm thông tin cá nhân, thông tin đăng nhập và trạng thái tài khoản.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của người dùng |
| username | varchar(50) | false | | Tên đăng nhập |
| email | varchar(255) | false | | Địa chỉ email |
| phone | varchar(20) | true | null | Số điện thoại |
| password_hash | varchar(255) | false | | Mật khẩu đã được mã hóa |
| first_name | varchar(50) | true | null | Tên |
| last_name | varchar(50) | true | null | Họ |
| full_name | varchar(100) | true | null | Họ và tên đầy đủ |
| avatar_url | varchar(255) | true | null | URL của ảnh đại diện |
| status | enum | false | 'active' | Trạng thái: active, inactive, suspended, pending |
| email_verified | boolean | false | false | Đánh dấu email đã được xác thực |
| phone_verified | boolean | false | false | Đánh dấu số điện thoại đã được xác thực |
| verification_token | varchar(255) | true | null | Token xác thực |
| verification_token_expires_at | timestamp | true | null | Thời gian hết hạn token xác thực |
| reset_password_token | varchar(255) | true | null | Token đặt lại mật khẩu |
| reset_password_token_expires_at | timestamp | true | null | Thời gian hết hạn token đặt lại mật khẩu |
| last_login_at | timestamp | true | null | Thời gian đăng nhập gần nhất |
| last_login_ip | varchar(45) | true | null | Địa chỉ IP đăng nhập gần nhất |
| failed_login_attempts | integer | false | 0 | Số lần đăng nhập thất bại liên tiếp |
| locked_until | timestamp | true | null | Thời gian khóa tài khoản đến |
| is_system_admin | boolean | false | false | Đánh dấu là quản trị viên hệ thống |
| is_super_admin | boolean | false | false | Đánh dấu là quản trị viên cấp cao |
| locale | varchar(10) | false | 'vi' | Ngôn ngữ mặc định |
| timezone | varchar(50) | false | 'Asia/Ho_Chi_Minh' | Múi giờ mặc định |
| metadata | jsonb | true | null | Dữ liệu bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| users_pkey | PRIMARY KEY | id | Khóa chính |
| users_username_idx | UNIQUE | username | Đảm bảo tên đăng nhập là duy nhất |
| users_email_idx | UNIQUE | email | Đảm bảo địa chỉ email là duy nhất |
| users_phone_idx | UNIQUE | phone | Đảm bảo số điện thoại là duy nhất |
| users_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| users_verification_token_idx | INDEX | verification_token | Tăng tốc truy vấn theo token xác thực |
| users_reset_password_token_idx | INDEX | reset_password_token | Tăng tốc truy vấn theo token đặt lại mật khẩu |
| users_is_system_admin_idx | INDEX | is_system_admin | Tăng tốc truy vấn theo quản trị viên hệ thống |
| users_is_super_admin_idx | INDEX | is_super_admin | Tăng tốc truy vấn theo quản trị viên cấp cao |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| users_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| users_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| users_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| users_email_check | CHECK | Đảm bảo email có định dạng hợp lệ |
| users_phone_check | CHECK | Đảm bảo phone có định dạng hợp lệ |
| users_failed_login_attempts_check | CHECK | Đảm bảo failed_login_attempts >= 0 |

### 2.5. Ví dụ JSON

```json
{
  "id": "u1s2e3r4-i5d6-7890-abcd-ef1234567890",
  "username": "nguyenvana",
  "email": "nguyenvana@example.com",
  "phone": "+84901234567",
  "password_hash": "$2a$10$abcdefghijklmnopqrstuvwxyz0123456789",
  "first_name": "Văn A",
  "last_name": "Nguyễn",
  "full_name": "Nguyễn Văn A",
  "avatar_url": "https://assets.NextFlow.com/avatars/nguyenvana.jpg",
  "status": "active",
  "email_verified": true,
  "phone_verified": true,
  "verification_token": null,
  "verification_token_expires_at": null,
  "reset_password_token": null,
  "reset_password_token_expires_at": null,
  "last_login_at": "2023-06-15T10:30:00Z",
  "last_login_ip": "192.168.1.1",
  "failed_login_attempts": 0,
  "locked_until": null,
  "is_system_admin": false,
  "is_super_admin": false,
  "locale": "vi",
  "timezone": "Asia/Ho_Chi_Minh",
  "metadata": {
    "department": "IT",
    "position": "Developer",
    "employee_id": "EMP-2023-001"
  },
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-06-15T10:30:00Z",
  "deleted_at": null,
  "created_by": "a1d2m3i4-n5i6-7890-abcd-ef1234567890",
  "updated_by": "a1d2m3i4-n5i6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG ROLES

### 3.1. Mô tả

Bảng `roles` lưu trữ thông tin về các vai trò trong hệ thống, được sử dụng để phân quyền cho người dùng.
