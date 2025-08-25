# SCHEMA HỆ THỐNG - USER VÀ AUTHENTICATION

## 1. GIỚI THIỆU

Schema User và Authentication là phần cốt lõi của hệ thống NextFlow CRM-AI, quản lý thông tin người dùng, xác thực và phân quyền. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến người dùng và xác thực trong hệ thống.

### 1.1. Mục đích

Schema User và Authentication phục vụ các mục đích sau:

- Lưu trữ thông tin người dùng trong hệ thống
- Quản lý xác thực và bảo mật
- Hỗ trợ đăng nhập đa phương thức
- Quản lý phiên làm việc
- Theo dõi hoạt động người dùng

### 1.2. Các bảng chính

Schema User và Authentication bao gồm các bảng chính sau:

1. `users` - Lưu trữ thông tin người dùng
2. `user_profiles` - Lưu trữ thông tin chi tiết của người dùng
3. `user_settings` - Lưu trữ cài đặt của người dùng
4. `authentication_methods` - Lưu trữ phương thức xác thực
5. `sessions` - Lưu trữ phiên làm việc
6. `password_reset_tokens` - Lưu trữ token đặt lại mật khẩu
7. `verification_tokens` - Lưu trữ token xác minh
8. `user_activities` - Lưu trữ hoạt động của người dùng

## 2. BẢNG USERS

### 2.1. Mô tả

Bảng `users` lưu trữ thông tin cơ bản của người dùng trong hệ thống. Đây là bảng trung tâm của schema User và Authentication.

### 2.2. Cấu trúc

| Tên cột         | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                                              |
| --------------- | ------------ | -------- | ----------------- | ------------------------------------------------------------------ |
| id              | uuid         | false    | gen_random_uuid() | Khóa chính, định danh duy nhất của người dùng                      |
| organization_id | uuid         | false    |                   | Khóa ngoại tới bảng organizations, xác định tổ chức của người dùng |
| email           | varchar(255) | false    |                   | Địa chỉ email của người dùng, dùng để đăng nhập                    |
| username        | varchar(50)  | true     | null              | Tên đăng nhập của người dùng                                       |
| password_hash   | varchar(255) | true     | null              | Mật khẩu đã được mã hóa                                            |
| first_name      | varchar(50)  | false    |                   | Tên của người dùng                                                 |
| last_name       | varchar(50)  | false    |                   | Họ của người dùng                                                  |
| full_name       | varchar(100) | false    |                   | Họ và tên đầy đủ của người dùng                                    |
| avatar_url      | varchar(255) | true     | null              | URL của ảnh đại diện                                               |
| phone_number    | varchar(20)  | true     | null              | Số điện thoại của người dùng                                       |
| status          | enum         | false    | 'active'          | Trạng thái của người dùng: active, inactive, suspended, deleted    |
| email_verified  | boolean      | false    | false             | Trạng thái xác minh email                                          |
| phone_verified  | boolean      | false    | false             | Trạng thái xác minh số điện thoại                                  |
| last_login_at   | timestamp    | true     | null              | Thời gian đăng nhập gần nhất                                       |
| created_at      | timestamp    | false    | now()             | Thời gian tạo bản ghi                                              |
| updated_at      | timestamp    | false    | now()             | Thời gian cập nhật bản ghi                                         |
| deleted_at      | timestamp    | true     | null              | Thời gian xóa bản ghi (soft delete)                                |

### 2.3. Chỉ mục

| Tên chỉ mục               | Loại        | Cột             | Mô tả                             |
| ------------------------- | ----------- | --------------- | --------------------------------- |
| users_pkey                | PRIMARY KEY | id              | Khóa chính                        |
| users_email_idx           | UNIQUE      | email           | Đảm bảo email là duy nhất         |
| users_username_idx        | UNIQUE      | username        | Đảm bảo username là duy nhất      |
| users_organization_id_idx | INDEX       | organization_id | Tăng tốc truy vấn theo tổ chức    |
| users_status_idx          | INDEX       | status          | Tăng tốc truy vấn theo trạng thái |

### 2.4. Ràng buộc

| Tên ràng buộc              | Loại        | Mô tả                                        |
| -------------------------- | ----------- | -------------------------------------------- |
| users_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id)        |
| users_email_check          | CHECK       | Đảm bảo email có định dạng hợp lệ            |
| users_status_check         | CHECK       | Đảm bảo status chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "email": "nguyen.van.a@example.com",
  "username": "nguyenvana",
  "password_hash": "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy",
  "first_name": "Văn A",
  "last_name": "Nguyễn",
  "full_name": "Nguyễn Văn A",
  "avatar_url": "https://assets.NextFlow.com/avatars/a1b2c3d4.jpg",
  "phone_number": "+84901234567",
  "status": "active",
  "email_verified": true,
  "phone_verified": true,
  "last_login_at": "2023-06-15T08:30:00Z",
  "created_at": "2023-01-10T09:00:00Z",
  "updated_at": "2023-06-15T08:30:00Z",
  "deleted_at": null
}
```

## 3. BẢNG USER_PROFILES

### 3.1. Mô tả

Bảng `user_profiles` lưu trữ thông tin chi tiết của người dùng, bổ sung cho thông tin cơ bản trong bảng `users`.

### 3.2. Cấu trúc

| Tên cột       | Kiểu dữ liệu | Nullable | Mặc định           | Mô tả                          |
| ------------- | ------------ | -------- | ------------------ | ------------------------------ |
| id            | uuid         | false    | gen_random_uuid()  | Khóa chính                     |
| user_id       | uuid         | false    |                    | Khóa ngoại tới bảng users      |
| date_of_birth | date         | true     | null               | Ngày sinh                      |
| gender        | enum         | true     | null               | Giới tính: male, female, other |
| address       | text         | true     | null               | Địa chỉ                        |
| city          | varchar(100) | true     | null               | Thành phố                      |
| state         | varchar(100) | true     | null               | Tỉnh/Thành                     |
| country       | varchar(100) | true     | null               | Quốc gia                       |
| postal_code   | varchar(20)  | true     | null               | Mã bưu điện                    |
| bio           | text         | true     | null               | Tiểu sử                        |
| job_title     | varchar(100) | true     | null               | Chức danh công việc            |
| department    | varchar(100) | true     | null               | Phòng ban                      |
| employee_id   | varchar(50)  | true     | null               | Mã nhân viên                   |
| hire_date     | date         | true     | null               | Ngày tuyển dụng                |
| manager_id    | uuid         | true     | null               | ID của người quản lý           |
| timezone      | varchar(50)  | true     | 'Asia/Ho_Chi_Minh' | Múi giờ                        |
| language      | varchar(10)  | true     | 'vi'               | Ngôn ngữ ưa thích              |
| created_at    | timestamp    | false    | now()              | Thời gian tạo bản ghi          |
| updated_at    | timestamp    | false    | now()              | Thời gian cập nhật bản ghi     |

### 3.3. Chỉ mục

| Tên chỉ mục                  | Loại        | Cột        | Mô tả                                     |
| ---------------------------- | ----------- | ---------- | ----------------------------------------- |
| user_profiles_pkey           | PRIMARY KEY | id         | Khóa chính                                |
| user_profiles_user_id_idx    | UNIQUE      | user_id    | Đảm bảo mỗi người dùng chỉ có một profile |
| user_profiles_manager_id_idx | INDEX       | manager_id | Tăng tốc truy vấn theo người quản lý      |

### 3.4. Ràng buộc

| Tên ràng buộc                 | Loại        | Mô tả                                        |
| ----------------------------- | ----------- | -------------------------------------------- |
| user_profiles_user_id_fkey    | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| user_profiles_manager_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| user_profiles_gender_check    | CHECK       | Đảm bảo gender chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "b1c2d3e4-f5g6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "date_of_birth": "1985-05-15",
  "gender": "male",
  "address": "123 Đường Lê Lợi",
  "city": "Quận 1",
  "state": "TP Hồ Chí Minh",
  "country": "Việt Nam",
  "postal_code": "70000",
  "bio": "Chuyên gia marketing với hơn 10 năm kinh nghiệm",
  "job_title": "Marketing Manager",
  "department": "Marketing",
  "employee_id": "MKT-2023-001",
  "hire_date": "2023-01-15",
  "manager_id": "c1d2e3f4-g5h6-7890-abcd-ef1234567890",
  "timezone": "Asia/Ho_Chi_Minh",
  "language": "vi",
  "created_at": "2023-01-10T09:00:00Z",
  "updated_at": "2023-06-15T08:30:00Z"
}
```

## 4. BẢNG USER_SETTINGS

### 4.1. Mô tả

Bảng `user_settings` lưu trữ các cài đặt cá nhân của người dùng trong hệ thống.

### 4.2. Cấu trúc

| Tên cột            | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                            |
| ------------------ | ------------ | -------- | ----------------- | ------------------------------------------------ |
| id                 | uuid         | false    | gen_random_uuid() | Khóa chính                                       |
| user_id            | uuid         | false    |                   | Khóa ngoại tới bảng users                        |
| theme              | varchar(20)  | false    | 'light'           | Giao diện: light, dark, system                   |
| notification_email | boolean      | false    | true              | Nhận thông báo qua email                         |
| notification_sms   | boolean      | false    | false             | Nhận thông báo qua SMS                           |
| notification_push  | boolean      | false    | true              | Nhận thông báo đẩy                               |
| two_factor_enabled | boolean      | false    | false             | Bật xác thực hai yếu tố                          |
| two_factor_method  | varchar(20)  | true     | null              | Phương thức xác thực hai yếu tố: app, sms, email |
| dashboard_layout   | jsonb        | true     | null              | Cấu hình bố cục dashboard                        |
| sidebar_collapsed  | boolean      | false    | false             | Trạng thái thu gọn sidebar                       |
| created_at         | timestamp    | false    | now()             | Thời gian tạo bản ghi                            |
| updated_at         | timestamp    | false    | now()             | Thời gian cập nhật bản ghi                       |

### 4.3. Chỉ mục

| Tên chỉ mục               | Loại        | Cột     | Mô tả                                             |
| ------------------------- | ----------- | ------- | ------------------------------------------------- |
| user_settings_pkey        | PRIMARY KEY | id      | Khóa chính                                        |
| user_settings_user_id_idx | UNIQUE      | user_id | Đảm bảo mỗi người dùng chỉ có một bản ghi cài đặt |

### 4.4. Ràng buộc

| Tên ràng buộc                         | Loại        | Mô tả                                                   |
| ------------------------------------- | ----------- | ------------------------------------------------------- |
| user_settings_user_id_fkey            | FOREIGN KEY | Tham chiếu đến bảng users(id)                           |
| user_settings_theme_check             | CHECK       | Đảm bảo theme chỉ nhận các giá trị cho phép             |
| user_settings_two_factor_method_check | CHECK       | Đảm bảo two_factor_method chỉ nhận các giá trị cho phép |

### 4.5. Ví dụ JSON

```json
{
  "id": "c1d2e3f4-g5h6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "theme": "dark",
  "notification_email": true,
  "notification_sms": true,
  "notification_push": true,
  "two_factor_enabled": true,
  "two_factor_method": "app",
  "dashboard_layout": {
    "widgets": [
      { "id": "recent_activities", "position": { "x": 0, "y": 0, "w": 6, "h": 4 } },
      { "id": "sales_chart", "position": { "x": 6, "y": 0, "w": 6, "h": 4 } },
      { "id": "tasks", "position": { "x": 0, "y": 4, "w": 12, "h": 4 } }
    ]
  },
  "sidebar_collapsed": false,
  "created_at": "2023-01-10T09:00:00Z",
  "updated_at": "2023-06-15T08:30:00Z"
}
```

## 5. BẢNG AUTHENTICATION_METHODS

### 5.1. Mô tả

Bảng `authentication_methods` lưu trữ các phương thức xác thực của người dùng, hỗ trợ đăng nhập đa phương thức.

### 5.2. Cấu trúc

| Tên cột          | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                                       |
| ---------------- | ------------ | -------- | ----------------- | ----------------------------------------------------------- |
| id               | uuid         | false    | gen_random_uuid() | Khóa chính                                                  |
| user_id          | uuid         | false    |                   | Khóa ngoại tới bảng users                                   |
| provider         | varchar(50)  | false    |                   | Nhà cung cấp xác thực: local, google, facebook, apple, etc. |
| provider_user_id | varchar(255) | true     | null              | ID người dùng từ nhà cung cấp                               |
| provider_data    | jsonb        | true     | null              | Dữ liệu bổ sung từ nhà cung cấp                             |
| is_primary       | boolean      | false    | false             | Phương thức xác thực chính                                  |
| last_used_at     | timestamp    | true     | null              | Thời gian sử dụng gần nhất                                  |
| created_at       | timestamp    | false    | now()             | Thời gian tạo bản ghi                                       |
| updated_at       | timestamp    | false    | now()             | Thời gian cập nhật bản ghi                                  |

### 5.3. Chỉ mục

| Tên chỉ mục                                 | Loại        | Cột                        | Mô tả                                                                       |
| ------------------------------------------- | ----------- | -------------------------- | --------------------------------------------------------------------------- |
| authentication_methods_pkey                 | PRIMARY KEY | id                         | Khóa chính                                                                  |
| authentication_methods_user_provider_idx    | UNIQUE      | user_id, provider          | Đảm bảo mỗi người dùng chỉ có một phương thức xác thực cho mỗi nhà cung cấp |
| authentication_methods_provider_user_id_idx | INDEX       | provider, provider_user_id | Tăng tốc truy vấn theo provider và provider_user_id                         |

### 5.4. Ràng buộc

| Tên ràng buộc                         | Loại        | Mô tả                                          |
| ------------------------------------- | ----------- | ---------------------------------------------- |
| authentication_methods_user_id_fkey   | FOREIGN KEY | Tham chiếu đến bảng users(id)                  |
| authentication_methods_provider_check | CHECK       | Đảm bảo provider chỉ nhận các giá trị cho phép |

### 5.5. Ví dụ JSON

```json
{
  "id": "d1e2f3g4-h5i6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "provider": "google",
  "provider_user_id": "109876543210987654321",
  "provider_data": {
    "email": "nguyen.van.a@gmail.com",
    "name": "Nguyễn Văn A",
    "picture": "https://lh3.googleusercontent.com/a-/AOh14Gi..."
  },
  "is_primary": false,
  "last_used_at": "2023-06-15T08:30:00Z",
  "created_at": "2023-01-15T10:00:00Z",
  "updated_at": "2023-06-15T08:30:00Z"
}
```

## 6. BẢNG SESSIONS

### 6.1. Mô tả

Bảng `sessions` lưu trữ thông tin về các phiên làm việc của người dùng trong hệ thống.

### 6.2. Cấu trúc

| Tên cột          | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                        |
| ---------------- | ------------ | -------- | ----------------- | ---------------------------- |
| id               | uuid         | false    | gen_random_uuid() | Khóa chính                   |
| user_id          | uuid         | false    |                   | Khóa ngoại tới bảng users    |
| token            | varchar(255) | false    |                   | Token phiên làm việc         |
| refresh_token    | varchar(255) | true     | null              | Token làm mới phiên          |
| ip_address       | varchar(50)  | true     | null              | Địa chỉ IP                   |
| user_agent       | text         | true     | null              | Thông tin user agent         |
| device_info      | jsonb        | true     | null              | Thông tin thiết bị           |
| location         | jsonb        | true     | null              | Thông tin vị trí             |
| expires_at       | timestamp    | false    |                   | Thời gian hết hạn            |
| last_activity_at | timestamp    | false    | now()             | Thời gian hoạt động gần nhất |
| created_at       | timestamp    | false    | now()             | Thời gian tạo bản ghi        |
| updated_at       | timestamp    | false    | now()             | Thời gian cập nhật bản ghi   |

### 6.3. Chỉ mục

| Tên chỉ mục             | Loại        | Cột        | Mô tả                                    |
| ----------------------- | ----------- | ---------- | ---------------------------------------- |
| sessions_pkey           | PRIMARY KEY | id         | Khóa chính                               |
| sessions_token_idx      | UNIQUE      | token      | Đảm bảo token là duy nhất                |
| sessions_user_id_idx    | INDEX       | user_id    | Tăng tốc truy vấn theo người dùng        |
| sessions_expires_at_idx | INDEX       | expires_at | Tăng tốc truy vấn theo thời gian hết hạn |

### 6.4. Ràng buộc

| Tên ràng buộc         | Loại        | Mô tả                         |
| --------------------- | ----------- | ----------------------------- |
| sessions_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |

### 6.5. Ví dụ JSON

```json
{
  "id": "e1f2g3h4-i5j6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "ip_address": "192.168.1.1",
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
  "device_info": {
    "type": "desktop",
    "os": "Windows 10",
    "browser": "Chrome 91.0.4472.124"
  },
  "location": {
    "country": "Vietnam",
    "city": "Ho Chi Minh City",
    "latitude": 10.8231,
    "longitude": 106.6297
  },
  "expires_at": "2023-06-16T08:30:00Z",
  "last_activity_at": "2023-06-15T08:30:00Z",
  "created_at": "2023-06-15T07:30:00Z",
  "updated_at": "2023-06-15T08:30:00Z"
}
```

## 7. BẢNG PASSWORD_RESET_TOKENS

### 7.1. Mô tả

Bảng `password_reset_tokens` lưu trữ các token dùng để đặt lại mật khẩu của người dùng.

### 7.2. Cấu trúc

| Tên cột    | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                        |
| ---------- | ------------ | -------- | ----------------- | ---------------------------- |
| id         | uuid         | false    | gen_random_uuid() | Khóa chính                   |
| user_id    | uuid         | false    |                   | Khóa ngoại tới bảng users    |
| token      | varchar(255) | false    |                   | Token đặt lại mật khẩu       |
| expires_at | timestamp    | false    |                   | Thời gian hết hạn            |
| used       | boolean      | false    | false             | Đã sử dụng hay chưa          |
| used_at    | timestamp    | true     | null              | Thời gian sử dụng            |
| ip_address | varchar(50)  | true     | null              | Địa chỉ IP khi tạo           |
| user_agent | text         | true     | null              | Thông tin user agent khi tạo |
| created_at | timestamp    | false    | now()             | Thời gian tạo bản ghi        |

### 7.3. Chỉ mục

| Tên chỉ mục                          | Loại        | Cột        | Mô tả                                    |
| ------------------------------------ | ----------- | ---------- | ---------------------------------------- |
| password_reset_tokens_pkey           | PRIMARY KEY | id         | Khóa chính                               |
| password_reset_tokens_token_idx      | UNIQUE      | token      | Đảm bảo token là duy nhất                |
| password_reset_tokens_user_id_idx    | INDEX       | user_id    | Tăng tốc truy vấn theo người dùng        |
| password_reset_tokens_expires_at_idx | INDEX       | expires_at | Tăng tốc truy vấn theo thời gian hết hạn |

### 7.4. Ràng buộc

| Tên ràng buộc                      | Loại        | Mô tả                         |
| ---------------------------------- | ----------- | ----------------------------- |
| password_reset_tokens_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |

### 7.5. Ví dụ JSON

```json
{
  "id": "f1g2h3i4-j5k6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "token": "5f4dcc3b5aa765d61d8327deb882cf99",
  "expires_at": "2023-06-16T07:30:00Z",
  "used": false,
  "used_at": null,
  "ip_address": "192.168.1.1",
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
  "created_at": "2023-06-15T07:30:00Z"
}
```

## 8. BẢNG VERIFICATION_TOKENS

### 8.1. Mô tả

Bảng `verification_tokens` lưu trữ các token dùng để xác minh email, số điện thoại hoặc các thông tin khác của người dùng.

### 8.2. Cấu trúc

| Tên cột    | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                 |
| ---------- | ------------ | -------- | ----------------- | ------------------------------------- |
| id         | uuid         | false    | gen_random_uuid() | Khóa chính                            |
| user_id    | uuid         | false    |                   | Khóa ngoại tới bảng users             |
| type       | varchar(50)  | false    |                   | Loại token: email, phone, two_factor  |
| token      | varchar(255) | false    |                   | Token xác minh                        |
| identifier | varchar(255) | true     | null              | Định danh cần xác minh (email, phone) |
| expires_at | timestamp    | false    |                   | Thời gian hết hạn                     |
| used       | boolean      | false    | false             | Đã sử dụng hay chưa                   |
| used_at    | timestamp    | true     | null              | Thời gian sử dụng                     |
| ip_address | varchar(50)  | true     | null              | Địa chỉ IP khi tạo                    |
| created_at | timestamp    | false    | now()             | Thời gian tạo bản ghi                 |

### 8.3. Chỉ mục

| Tên chỉ mục                          | Loại        | Cột           | Mô tả                                     |
| ------------------------------------ | ----------- | ------------- | ----------------------------------------- |
| verification_tokens_pkey             | PRIMARY KEY | id            | Khóa chính                                |
| verification_tokens_token_idx        | UNIQUE      | token         | Đảm bảo token là duy nhất                 |
| verification_tokens_user_id_type_idx | INDEX       | user_id, type | Tăng tốc truy vấn theo người dùng và loại |
| verification_tokens_expires_at_idx   | INDEX       | expires_at    | Tăng tốc truy vấn theo thời gian hết hạn  |

### 8.4. Ràng buộc

| Tên ràng buộc                    | Loại        | Mô tả                                      |
| -------------------------------- | ----------- | ------------------------------------------ |
| verification_tokens_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id)              |
| verification_tokens_type_check   | CHECK       | Đảm bảo type chỉ nhận các giá trị cho phép |

### 8.5. Ví dụ JSON

```json
{
  "id": "g1h2i3j4-k5l6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "type": "email",
  "token": "7c4a8d09ca3762af61e59520943dc26494f8941b",
  "identifier": "new.email@example.com",
  "expires_at": "2023-06-16T07:30:00Z",
  "used": false,
  "used_at": null,
  "ip_address": "192.168.1.1",
  "created_at": "2023-06-15T07:30:00Z"
}
```

## 9. BẢNG USER_ACTIVITIES

### 9.1. Mô tả

Bảng `user_activities` lưu trữ thông tin về các hoạt động của người dùng trong hệ thống, phục vụ cho mục đích theo dõi, phân tích và bảo mật.

### 9.2. Cấu trúc

| Tên cột     | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                                  |
| ----------- | ------------ | -------- | ----------------- | ------------------------------------------------------ |
| id          | uuid         | false    | gen_random_uuid() | Khóa chính                                             |
| user_id     | uuid         | false    |                   | Khóa ngoại tới bảng users                              |
| session_id  | uuid         | true     | null              | Khóa ngoại tới bảng sessions                           |
| action      | varchar(100) | false    |                   | Hành động: login, logout, update_profile, etc.         |
| entity_type | varchar(100) | true     | null              | Loại đối tượng tác động: user, customer, product, etc. |
| entity_id   | uuid         | true     | null              | ID của đối tượng tác động                              |
| description | text         | true     | null              | Mô tả chi tiết                                         |
| metadata    | jsonb        | true     | null              | Dữ liệu bổ sung                                        |
| ip_address  | varchar(50)  | true     | null              | Địa chỉ IP                                             |
| user_agent  | text         | true     | null              | Thông tin user agent                                   |
| created_at  | timestamp    | false    | now()             | Thời gian tạo bản ghi                                  |

### 9.3. Chỉ mục

| Tên chỉ mục                    | Loại        | Cột                    | Mô tả                             |
| ------------------------------ | ----------- | ---------------------- | --------------------------------- |
| user_activities_pkey           | PRIMARY KEY | id                     | Khóa chính                        |
| user_activities_user_id_idx    | INDEX       | user_id                | Tăng tốc truy vấn theo người dùng |
| user_activities_session_id_idx | INDEX       | session_id             | Tăng tốc truy vấn theo phiên      |
| user_activities_action_idx     | INDEX       | action                 | Tăng tốc truy vấn theo hành động  |
| user_activities_entity_idx     | INDEX       | entity_type, entity_id | Tăng tốc truy vấn theo đối tượng  |
| user_activities_created_at_idx | INDEX       | created_at             | Tăng tốc truy vấn theo thời gian  |

### 9.4. Ràng buộc

| Tên ràng buộc                   | Loại        | Mô tả                                        |
| ------------------------------- | ----------- | -------------------------------------------- |
| user_activities_user_id_fkey    | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| user_activities_session_id_fkey | FOREIGN KEY | Tham chiếu đến bảng sessions(id)             |
| user_activities_action_check    | CHECK       | Đảm bảo action chỉ nhận các giá trị cho phép |

### 9.5. Ví dụ JSON

```json
{
  "id": "h1i2j3k4-l5m6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "session_id": "e1f2g3h4-i5j6-7890-abcd-ef1234567890",
  "action": "update_profile",
  "entity_type": "user",
  "entity_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "description": "Cập nhật thông tin hồ sơ",
  "metadata": {
    "changes": {
      "job_title": {
        "old": "Marketing Specialist",
        "new": "Marketing Manager"
      },
      "department": {
        "old": "Marketing",
        "new": "Marketing"
      }
    }
  },
  "ip_address": "192.168.1.1",
  "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
  "created_at": "2023-06-15T08:15:00Z"
}
```

## 10. MỐI QUAN HỆ GIỮA CÁC BẢNG

### 10.1. Sơ đồ mối quan hệ

```
users
  ↑ 1:1
  ├── user_profiles
  ├── user_settings
  ├── authentication_methods (1:N)
  ├── sessions (1:N)
  ├── password_reset_tokens (1:N)
  ├── verification_tokens (1:N)
  └── user_activities (1:N)
```

### 10.2. Mô tả mối quan hệ

- **users → user_profiles**: Mỗi người dùng có một hồ sơ chi tiết
- **users → user_settings**: Mỗi người dùng có một bản ghi cài đặt
- **users → authentication_methods**: Mỗi người dùng có thể có nhiều phương thức xác thực
- **users → sessions**: Mỗi người dùng có thể có nhiều phiên làm việc
- **users → password_reset_tokens**: Mỗi người dùng có thể có nhiều token đặt lại mật khẩu
- **users → verification_tokens**: Mỗi người dùng có thể có nhiều token xác minh
- **users → user_activities**: Mỗi người dùng có thể có nhiều hoạt động
- **sessions → user_activities**: Mỗi phiên có thể có nhiều hoạt động

## 11. TỔNG KẾT

Schema User và Authentication là phần cốt lõi của hệ thống NextFlow CRM-AI, quản lý thông tin người dùng, xác thực và phân quyền. Schema này bao gồm 8 bảng chính:

1. `users`: Lưu trữ thông tin cơ bản của người dùng
2. `user_profiles`: Lưu trữ thông tin chi tiết của người dùng
3. `user_settings`: Lưu trữ cài đặt của người dùng
4. `authentication_methods`: Lưu trữ phương thức xác thực
5. `sessions`: Lưu trữ phiên làm việc
6. `password_reset_tokens`: Lưu trữ token đặt lại mật khẩu
7. `verification_tokens`: Lưu trữ token xác minh
8. `user_activities`: Lưu trữ hoạt động của người dùng

Schema này được thiết kế để hỗ trợ:

- Đăng nhập đa phương thức (local, social)
- Xác thực hai yếu tố
- Quản lý phiên làm việc
- Đặt lại mật khẩu
- Xác minh email và số điện thoại
- Theo dõi hoạt động người dùng
- Hỗ trợ kiến trúc multi-tenant
