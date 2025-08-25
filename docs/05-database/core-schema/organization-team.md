# SCHEMA HỆ THỐNG - ORGANIZATION VÀ TEAM

## 1. GIỚI THIỆU

Schema Organization và Team quản lý cấu trúc tổ chức và nhóm trong hệ thống NextFlow CRM-AI, hỗ trợ kiến trúc multi-tenant và phân cấp tổ chức. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến tổ chức và nhóm trong hệ thống.

### 1.1. Mục đích

Schema Organization và Team phục vụ các mục đích sau:

- Quản lý thông tin tổ chức (tenant) trong hệ thống multi-tenant
- Quản lý cấu trúc phân cấp của tổ chức (phòng ban, nhóm)
- Phân quyền theo tổ chức và nhóm
- Quản lý thành viên trong tổ chức và nhóm
- Hỗ trợ cấu hình riêng cho từng tổ chức

### 1.2. Các bảng chính

Schema Organization và Team bao gồm các bảng chính sau:

1. `organizations` - Lưu trữ thông tin về tổ chức (tenant)
2. `organization_settings` - Lưu trữ cài đặt của tổ chức
3. `teams` - Lưu trữ thông tin về nhóm/phòng ban
4. `team_members` - Bảng trung gian liên kết người dùng và nhóm
5. `organization_invitations` - Lưu trữ lời mời tham gia tổ chức
6. `organization_domains` - Lưu trữ tên miền được xác minh của tổ chức

## 2. BẢNG ORGANIZATIONS

### 2.1. Mô tả

Bảng `organizations` lưu trữ thông tin về các tổ chức (tenant) trong hệ thống. Mỗi tổ chức đại diện cho một tenant riêng biệt.

### 2.2. Cấu trúc

| Tên cột         | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                            |
| --------------- | ------------ | -------- | ----------------- | ------------------------------------------------ |
| id              | uuid         | false    | gen_random_uuid() | Khóa chính, định danh duy nhất của tổ chức       |
| name            | varchar(100) | false    |                   | Tên tổ chức                                      |
| display_name    | varchar(100) | false    |                   | Tên hiển thị của tổ chức                         |
| slug            | varchar(50)  | false    |                   | Định danh URL-friendly của tổ chức               |
| description     | text         | true     | null              | Mô tả về tổ chức                                 |
| logo_url        | varchar(255) | true     | null              | URL của logo tổ chức                             |
| website         | varchar(255) | true     | null              | Website của tổ chức                              |
| email           | varchar(255) | true     | null              | Email liên hệ của tổ chức                        |
| phone           | varchar(20)  | true     | null              | Số điện thoại của tổ chức                        |
| address         | text         | true     | null              | Địa chỉ của tổ chức                              |
| city            | varchar(100) | true     | null              | Thành phố                                        |
| state           | varchar(100) | true     | null              | Tỉnh/Thành                                       |
| country         | varchar(100) | true     | null              | Quốc gia                                         |
| postal_code     | varchar(20)  | true     | null              | Mã bưu điện                                      |
| tax_id          | varchar(50)  | true     | null              | Mã số thuế                                       |
| industry        | varchar(100) | true     | null              | Ngành nghề kinh doanh                            |
| size            | varchar(20)  | true     | null              | Quy mô tổ chức: small, medium, large, enterprise |
| status          | enum         | false    | 'active'          | Trạng thái: active, inactive, suspended, deleted |
| plan_id         | uuid         | true     | null              | Khóa ngoại tới bảng subscription_plans           |
| database_config | jsonb        | true     | null              | Cấu hình database cho tenant                     |
| created_at      | timestamp    | false    | now()             | Thời gian tạo bản ghi                            |
| updated_at      | timestamp    | false    | now()             | Thời gian cập nhật bản ghi                       |
| deleted_at      | timestamp    | true     | null              | Thời gian xóa bản ghi (soft delete)              |

### 2.3. Chỉ mục

| Tên chỉ mục               | Loại        | Cột     | Mô tả                              |
| ------------------------- | ----------- | ------- | ---------------------------------- |
| organizations_pkey        | PRIMARY KEY | id      | Khóa chính                         |
| organizations_slug_idx    | UNIQUE      | slug    | Đảm bảo slug là duy nhất           |
| organizations_name_idx    | INDEX       | name    | Tăng tốc truy vấn theo tên         |
| organizations_status_idx  | INDEX       | status  | Tăng tốc truy vấn theo trạng thái  |
| organizations_plan_id_idx | INDEX       | plan_id | Tăng tốc truy vấn theo gói dịch vụ |

### 2.4. Ràng buộc

| Tên ràng buộc              | Loại        | Mô tả                                        |
| -------------------------- | ----------- | -------------------------------------------- |
| organizations_plan_id_fkey | FOREIGN KEY | Tham chiếu đến bảng subscription_plans(id)   |
| organizations_status_check | CHECK       | Đảm bảo status chỉ nhận các giá trị cho phép |
| organizations_size_check   | CHECK       | Đảm bảo size chỉ nhận các giá trị cho phép   |
| organizations_slug_check   | CHECK       | Đảm bảo slug chỉ chứa các ký tự hợp lệ       |

### 2.5. Ví dụ JSON

```json
{
  "id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Công ty TNHH ABC",
  "display_name": "ABC Company",
  "slug": "abc-company",
  "description": "Công ty chuyên cung cấp giải pháp phần mềm cho doanh nghiệp",
  "logo_url": "https://assets.NextFlow.com/logos/abc-company.png",
  "website": "https://www.abccompany.com",
  "email": "contact@abccompany.com",
  "phone": "+84901234567",
  "address": "123 Đường Nguyễn Huệ",
  "city": "Quận 1",
  "state": "TP Hồ Chí Minh",
  "country": "Việt Nam",
  "postal_code": "70000",
  "tax_id": "0123456789",
  "industry": "Công nghệ thông tin",
  "size": "medium",
  "status": "active",
  "plan_id": "p1l2a3n4-i5d6-7890-abcd-ef1234567890",
  "database_config": {
    "host": "db-tenant-123.NextFlow.internal",
    "port": 5432,
    "name": "tenant_abc_company",
    "schema": "public"
  },
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null
}
```

## 3. BẢNG ORGANIZATION_SETTINGS

### 3.1. Mô tả

Bảng `organization_settings` lưu trữ các cài đặt riêng của từng tổ chức trong hệ thống.

### 3.2. Cấu trúc

| Tên cột           | Kiểu dữ liệu | Nullable | Mặc định           | Mô tả                              |
| ----------------- | ------------ | -------- | ------------------ | ---------------------------------- |
| id                | uuid         | false    | gen_random_uuid()  | Khóa chính                         |
| organization_id   | uuid         | false    |                    | Khóa ngoại tới bảng organizations  |
| locale            | varchar(10)  | false    | 'vi-VN'            | Ngôn ngữ và định dạng địa phương   |
| timezone          | varchar(50)  | false    | 'Asia/Ho_Chi_Minh' | Múi giờ                            |
| date_format       | varchar(20)  | false    | 'DD/MM/YYYY'       | Định dạng ngày                     |
| time_format       | varchar(20)  | false    | 'HH:mm'            | Định dạng giờ                      |
| currency          | varchar(3)   | false    | 'VND'              | Đơn vị tiền tệ                     |
| fiscal_year_start | varchar(5)   | false    | '01-01'            | Ngày bắt đầu năm tài chính (MM-DD) |
| theme             | jsonb        | true     | null               | Cài đặt giao diện                  |
| features          | jsonb        | true     | null               | Cấu hình tính năng                 |
| security          | jsonb        | true     | null               | Cài đặt bảo mật                    |
| notifications     | jsonb        | true     | null               | Cài đặt thông báo                  |
| integrations      | jsonb        | true     | null               | Cấu hình tích hợp                  |
| custom_fields     | jsonb        | true     | null               | Cấu hình trường tùy chỉnh          |
| created_at        | timestamp    | false    | now()              | Thời gian tạo bản ghi              |
| updated_at        | timestamp    | false    | now()              | Thời gian cập nhật bản ghi         |

### 3.3. Chỉ mục

| Tên chỉ mục                               | Loại        | Cột             | Mô tả                                          |
| ----------------------------------------- | ----------- | --------------- | ---------------------------------------------- |
| organization_settings_pkey                | PRIMARY KEY | id              | Khóa chính                                     |
| organization_settings_organization_id_idx | UNIQUE      | organization_id | Đảm bảo mỗi tổ chức chỉ có một bản ghi cài đặt |

### 3.4. Ràng buộc

| Tên ràng buộc                              | Loại        | Mô tả                                 |
| ------------------------------------------ | ----------- | ------------------------------------- |
| organization_settings_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| organization_settings_currency_check       | CHECK       | Đảm bảo currency là mã tiền tệ hợp lệ |
| organization_settings_locale_check         | CHECK       | Đảm bảo locale có định dạng hợp lệ    |

### 3.5. Ví dụ JSON

```json
{
  "id": "os1q2r3-s4t5-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "locale": "vi-VN",
  "timezone": "Asia/Ho_Chi_Minh",
  "date_format": "DD/MM/YYYY",
  "time_format": "HH:mm",
  "currency": "VND",
  "fiscal_year_start": "01-01",
  "theme": {
    "primary_color": "#1976d2",
    "secondary_color": "#424242",
    "logo_position": "left",
    "menu_layout": "vertical",
    "dark_mode": false
  },
  "features": {
    "ai_chatbot": true,
    "multi_marketplace": true,
    "advanced_analytics": false,
    "api_access": true
  },
  "security": {
    "password_policy": {
      "min_length": 8,
      "require_uppercase": true,
      "require_lowercase": true,
      "require_number": true,
      "require_special": true
    },
    "session_timeout": 30,
    "two_factor_required": false,
    "ip_restrictions": []
  },
  "notifications": {
    "email": true,
    "sms": false,
    "push": true,
    "slack": false
  },
  "integrations": {
    "google": {
      "enabled": true,
      "client_id": "google-client-id"
    },
    "facebook": {
      "enabled": true,
      "app_id": "facebook-app-id"
    }
  },
  "custom_fields": {
    "customer": [
      {
        "name": "loyalty_points",
        "label": "Điểm tích lũy",
        "type": "number",
        "required": false
      }
    ]
  },
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z"
}
```

## 4. BẢNG TEAMS

### 4.1. Mô tả

Bảng `teams` lưu trữ thông tin về các nhóm/phòng ban trong tổ chức.

### 4.2. Cấu trúc

| Tên cột         | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                         |
| --------------- | ------------ | -------- | ----------------- | --------------------------------------------- |
| id              | uuid         | false    | gen_random_uuid() | Khóa chính                                    |
| organization_id | uuid         | false    |                   | Khóa ngoại tới bảng organizations             |
| name            | varchar(100) | false    |                   | Tên nhóm                                      |
| display_name    | varchar(100) | false    |                   | Tên hiển thị của nhóm                         |
| description     | text         | true     | null              | Mô tả về nhóm                                 |
| parent_id       | uuid         | true     | null              | ID của nhóm cha                               |
| leader_id       | uuid         | true     | null              | ID của người dùng là trưởng nhóm              |
| type            | varchar(50)  | false    | 'team'            | Loại nhóm: team, department, division, branch |
| status          | enum         | false    | 'active'          | Trạng thái: active, inactive                  |
| settings        | jsonb        | true     | null              | Cài đặt riêng của nhóm                        |
| created_at      | timestamp    | false    | now()             | Thời gian tạo bản ghi                         |
| updated_at      | timestamp    | false    | now()             | Thời gian cập nhật bản ghi                    |
| deleted_at      | timestamp    | true     | null              | Thời gian xóa bản ghi (soft delete)           |
| created_by      | uuid         | true     | null              | ID người tạo                                  |
| updated_by      | uuid         | true     | null              | ID người cập nhật                             |

### 4.3. Chỉ mục

| Tên chỉ mục                 | Loại        | Cột                   | Mô tả                                      |
| --------------------------- | ----------- | --------------------- | ------------------------------------------ |
| teams_pkey                  | PRIMARY KEY | id                    | Khóa chính                                 |
| teams_organization_name_idx | UNIQUE      | organization_id, name | Đảm bảo tên nhóm là duy nhất trong tổ chức |
| teams_organization_id_idx   | INDEX       | organization_id       | Tăng tốc truy vấn theo tổ chức             |
| teams_parent_id_idx         | INDEX       | parent_id             | Tăng tốc truy vấn theo nhóm cha            |
| teams_leader_id_idx         | INDEX       | leader_id             | Tăng tốc truy vấn theo trưởng nhóm         |
| teams_status_idx            | INDEX       | status                | Tăng tốc truy vấn theo trạng thái          |

### 4.4. Ràng buộc

| Tên ràng buộc              | Loại        | Mô tả                                        |
| -------------------------- | ----------- | -------------------------------------------- |
| teams_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id)        |
| teams_parent_id_fkey       | FOREIGN KEY | Tham chiếu đến bảng teams(id)                |
| teams_leader_id_fkey       | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| teams_created_by_fkey      | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| teams_updated_by_fkey      | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| teams_status_check         | CHECK       | Đảm bảo status chỉ nhận các giá trị cho phép |
| teams_type_check           | CHECK       | Đảm bảo type chỉ nhận các giá trị cho phép   |

### 4.5. Ví dụ JSON

```json
{
  "id": "t1e2a3m4-i5d6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "marketing",
  "display_name": "Phòng Marketing",
  "description": "Phòng Marketing chịu trách nhiệm về các hoạt động tiếp thị và quảng cáo",
  "parent_id": null,
  "leader_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "type": "department",
  "status": "active",
  "settings": {
    "can_invite_members": true,
    "visible_to_all": true,
    "default_role_id": "r1s2t3u4-v5w6-7890-abcd-ef1234567890"
  },
  "created_at": "2023-01-10T09:00:00Z",
  "updated_at": "2023-01-10T09:00:00Z",
  "deleted_at": null,
  "created_by": "c1d2e3f4-g5h6-7890-abcd-ef1234567890",
  "updated_by": "c1d2e3f4-g5h6-7890-abcd-ef1234567890"
}
```

## 5. BẢNG TEAM_MEMBERS

### 5.1. Mô tả

Bảng `team_members` là bảng trung gian liên kết người dùng và nhóm, thể hiện mối quan hệ nhiều-nhiều giữa người dùng và nhóm.

### 5.2. Cấu trúc

| Tên cột    | Kiểu dữ liệu | Nullable | Mặc định          | Mô tả                                    |
| ---------- | ------------ | -------- | ----------------- | ---------------------------------------- |
| id         | uuid         | false    | gen_random_uuid() | Khóa chính                               |
| team_id    | uuid         | false    |                   | Khóa ngoại tới bảng teams                |
| user_id    | uuid         | false    |                   | Khóa ngoại tới bảng users                |
| role       | varchar(50)  | false    | 'member'          | Vai trò trong nhóm: member, admin, owner |
| status     | enum         | false    | 'active'          | Trạng thái: active, inactive             |
| joined_at  | timestamp    | false    | now()             | Thời gian tham gia nhóm                  |
| created_at | timestamp    | false    | now()             | Thời gian tạo bản ghi                    |
| updated_at | timestamp    | false    | now()             | Thời gian cập nhật bản ghi               |
| created_by | uuid         | true     | null              | ID người tạo                             |
| updated_by | uuid         | true     | null              | ID người cập nhật                        |

### 5.3. Chỉ mục

| Tên chỉ mục                | Loại        | Cột              | Mô tả                                                         |
| -------------------------- | ----------- | ---------------- | ------------------------------------------------------------- |
| team_members_pkey          | PRIMARY KEY | id               | Khóa chính                                                    |
| team_members_team_user_idx | UNIQUE      | team_id, user_id | Đảm bảo mỗi người dùng chỉ là thành viên của một nhóm một lần |
| team_members_team_id_idx   | INDEX       | team_id          | Tăng tốc truy vấn theo nhóm                                   |
| team_members_user_id_idx   | INDEX       | user_id          | Tăng tốc truy vấn theo người dùng                             |
| team_members_status_idx    | INDEX       | status           | Tăng tốc truy vấn theo trạng thái                             |

### 5.4. Ràng buộc

| Tên ràng buộc                | Loại        | Mô tả                                        |
| ---------------------------- | ----------- | -------------------------------------------- |
| team_members_team_id_fkey    | FOREIGN KEY | Tham chiếu đến bảng teams(id)                |
| team_members_user_id_fkey    | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| team_members_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| team_members_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id)                |
| team_members_role_check      | CHECK       | Đảm bảo role chỉ nhận các giá trị cho phép   |
| team_members_status_check    | CHECK       | Đảm bảo status chỉ nhận các giá trị cho phép |

### 5.5. Ví dụ JSON

```json
{
  "id": "tm1q2r3-s4t5-7890-abcd-ef1234567890",
  "team_id": "t1e2a3m4-i5d6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "role": "admin",
  "status": "active",
  "joined_at": "2023-01-15T10:00:00Z",
  "created_at": "2023-01-15T10:00:00Z",
  "updated_at": "2023-01-15T10:00:00Z",
  "created_by": "c1d2e3f4-g5h6-7890-abcd-ef1234567890",
  "updated_by": "c1d2e3f4-g5h6-7890-abcd-ef1234567890"
}
```
