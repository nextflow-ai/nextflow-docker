# SCHEMA HỆ THỐNG - ORGANIZATIONS

## 1. GIỚI THIỆU

Schema Organizations quản lý thông tin về tổ chức, cấu trúc tổ chức, cài đặt tổ chức và các thông tin liên quan đến quản lý tổ chức trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến quản lý tổ chức trong hệ thống.

### 1.1. Mục đích

Schema Organizations phục vụ các mục đích sau:

- Lưu trữ thông tin tổ chức
- Quản lý cấu trúc tổ chức
- Quản lý cài đặt tổ chức
- Quản lý phân quyền theo tổ chức
- Quản lý gói dịch vụ và thanh toán
- Quản lý tích hợp với các dịch vụ bên ngoài

### 1.2. Các bảng chính

Schema Organizations bao gồm các bảng chính sau:

1. `organizations` - Lưu trữ thông tin tổ chức
2. `organization_settings` - Lưu trữ thông tin cài đặt tổ chức
3. `organization_users` - Lưu trữ thông tin người dùng trong tổ chức
4. `organization_departments` - Lưu trữ thông tin phòng ban
5. `organization_teams` - Lưu trữ thông tin nhóm
6. `organization_subscriptions` - Lưu trữ thông tin gói dịch vụ
7. `organization_billing` - Lưu trữ thông tin thanh toán
8. `organization_integrations` - Lưu trữ thông tin tích hợp

## 2. BẢNG ORGANIZATIONS

### 2.1. Mô tả

Bảng `organizations` lưu trữ thông tin cơ bản về tổ chức trong hệ thống, bao gồm thông tin doanh nghiệp, thông tin liên hệ và trạng thái tổ chức.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của tổ chức |
| name | varchar(100) | false | | Tên tổ chức |
| slug | varchar(100) | false | | Định danh URL-friendly của tổ chức |
| description | text | true | null | Mô tả tổ chức |
| type | enum | false | 'business' | Loại tổ chức: business, individual, nonprofit, government, education |
| status | enum | false | 'active' | Trạng thái: active, inactive, suspended, pending |
| logo_url | varchar(255) | true | null | URL của logo tổ chức |
| website | varchar(255) | true | null | Website của tổ chức |
| email | varchar(255) | true | null | Email liên hệ chính |
| phone | varchar(20) | true | null | Số điện thoại liên hệ chính |
| address | jsonb | true | null | Địa chỉ của tổ chức |
| tax_id | varchar(50) | true | null | Mã số thuế |
| registration_number | varchar(50) | true | null | Số đăng ký kinh doanh |
| industry | varchar(100) | true | null | Ngành nghề kinh doanh |
| size | enum | true | null | Quy mô: small, medium, large, enterprise |
| founded_year | integer | true | null | Năm thành lập |
| parent_id | uuid | true | null | ID của tổ chức cha |
| owner_id | uuid | false | | ID của người dùng là chủ sở hữu |
| timezone | varchar(50) | false | 'Asia/Ho_Chi_Minh' | Múi giờ mặc định |
| locale | varchar(10) | false | 'vi' | Ngôn ngữ mặc định |
| currency | varchar(3) | false | 'VND' | Đơn vị tiền tệ mặc định |
| subscription_plan | varchar(50) | false | 'free' | Gói dịch vụ: free, basic, professional, enterprise |
| subscription_status | enum | false | 'active' | Trạng thái gói dịch vụ: active, trial, expired, cancelled |
| trial_ends_at | timestamp | true | null | Thời gian kết thúc dùng thử |
| subscription_ends_at | timestamp | true | null | Thời gian kết thúc gói dịch vụ |
| max_users | integer | false | 5 | Số lượng người dùng tối đa |
| max_storage | integer | false | 1024 | Dung lượng lưu trữ tối đa (MB) |
| used_storage | integer | false | 0 | Dung lượng đã sử dụng (MB) |
| features | jsonb | true | null | Tính năng được kích hoạt |
| metadata | jsonb | true | null | Dữ liệu bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| organizations_pkey | PRIMARY KEY | id | Khóa chính |
| organizations_slug_idx | UNIQUE | slug | Đảm bảo slug là duy nhất |
| organizations_name_idx | INDEX | name | Tăng tốc truy vấn theo tên |
| organizations_type_idx | INDEX | type | Tăng tốc truy vấn theo loại tổ chức |
| organizations_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| organizations_parent_id_idx | INDEX | parent_id | Tăng tốc truy vấn theo tổ chức cha |
| organizations_owner_id_idx | INDEX | owner_id | Tăng tốc truy vấn theo chủ sở hữu |
| organizations_subscription_plan_idx | INDEX | subscription_plan | Tăng tốc truy vấn theo gói dịch vụ |
| organizations_subscription_status_idx | INDEX | subscription_status | Tăng tốc truy vấn theo trạng thái gói dịch vụ |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| organizations_parent_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| organizations_owner_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| organizations_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| organizations_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| organizations_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| organizations_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| organizations_size_check | CHECK | Đảm bảo size chỉ nhận các giá trị cho phép |
| organizations_subscription_status_check | CHECK | Đảm bảo subscription_status chỉ nhận các giá trị cho phép |
| organizations_max_users_check | CHECK | Đảm bảo max_users > 0 |
| organizations_max_storage_check | CHECK | Đảm bảo max_storage > 0 |
| organizations_used_storage_check | CHECK | Đảm bảo used_storage >= 0 |
| organizations_no_self_reference | CHECK | Đảm bảo parent_id != id |

### 2.5. Ví dụ JSON

```json
{
  "id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Công ty TNHH NextFlow",
  "slug": "NextFlow",
  "description": "Công ty phát triển phần mềm CRM hàng đầu Việt Nam",
  "type": "business",
  "status": "active",
  "logo_url": "https://assets.NextFlow.com/logos/NextFlow.png",
  "website": "https://NextFlow.vn",
  "email": "contact@NextFlow.vn",
  "phone": "+84901234567",
  "address": {
    "street": "123 Đường Nguyễn Văn Linh",
    "city": "Quận 7",
    "state": "TP Hồ Chí Minh",
    "country": "Việt Nam",
    "postal_code": "70000"
  },
  "tax_id": "0123456789",
  "registration_number": "0123456789",
  "industry": "Công nghệ thông tin",
  "size": "medium",
  "founded_year": 2020,
  "parent_id": null,
  "owner_id": "a1d2m3i4-n5i6-7890-abcd-ef1234567890",
  "timezone": "Asia/Ho_Chi_Minh",
  "locale": "vi",
  "currency": "VND",
  "subscription_plan": "professional",
  "subscription_status": "active",
  "trial_ends_at": null,
  "subscription_ends_at": "2024-01-01T00:00:00Z",
  "max_users": 50,
  "max_storage": 10240,
  "used_storage": 2048,
  "features": {
    "ai_integration": true,
    "multi_channel": true,
    "advanced_analytics": true,
    "api_access": true
  },
  "metadata": {
    "account_manager": "Trần Văn B",
    "support_level": "premium",
    "notes": "Khách hàng VIP"
  },
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-06-15T10:30:00Z",
  "deleted_at": null,
  "created_by": "a1d2m3i4-n5i6-7890-abcd-ef1234567890",
  "updated_by": "a1d2m3i4-n5i6-7890-abcd-ef1234567890"
}
```
