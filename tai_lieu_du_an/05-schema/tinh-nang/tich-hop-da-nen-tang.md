# SCHEMA TÍNH NĂNG - TÍCH HỢP ĐA NỀN TẢNG

## 1. GIỚI THIỆU

Schema Tích hợp đa nền tảng quản lý thông tin về các tích hợp với các nền tảng thương mại điện tử, mạng xã hội và các dịch vụ bên ngoài trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến tích hợp đa nền tảng trong hệ thống.

### 1.1. Mục đích

Schema Tích hợp đa nền tảng phục vụ các mục đích sau:

- Lưu trữ thông tin cấu hình tích hợp với các nền tảng thương mại điện tử
- Quản lý tài khoản và xác thực với các nền tảng bên ngoài
- Đồng bộ hóa sản phẩm, đơn hàng và khách hàng giữa các nền tảng
- Theo dõi trạng thái đồng bộ và lịch sử đồng bộ
- Quản lý webhook và callback từ các nền tảng

### 1.2. Các bảng chính

Schema Tích hợp đa nền tảng bao gồm các bảng chính sau:

1. `marketplace_integrations` - Lưu trữ thông tin cấu hình tích hợp với các sàn thương mại điện tử
2. `marketplace_accounts` - Lưu trữ thông tin tài khoản trên các sàn thương mại điện tử
3. `marketplace_shops` - Lưu trữ thông tin cửa hàng trên các sàn thương mại điện tử
4. `marketplace_webhooks` - Lưu trữ thông tin webhook từ các sàn thương mại điện tử
5. `sync_tasks` - Lưu trữ thông tin nhiệm vụ đồng bộ
6. `sync_logs` - Lưu trữ thông tin lịch sử đồng bộ
7. `product_mappings` - Lưu trữ thông tin ánh xạ sản phẩm giữa các nền tảng
8. `order_mappings` - Lưu trữ thông tin ánh xạ đơn hàng giữa các nền tảng

## 2. BẢNG MARKETPLACE_INTEGRATIONS

### 2.1. Mô tả

Bảng `marketplace_integrations` lưu trữ thông tin cấu hình tích hợp với các sàn thương mại điện tử và nền tảng bên ngoài.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của tích hợp |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên tích hợp |
| description | text | true | null | Mô tả tích hợp |
| platform | varchar(50) | false | | Nền tảng: shopee, lazada, tiktok, woocommerce, etc. |
| status | enum | false | 'active' | Trạng thái: active, inactive, error |
| config | jsonb | false | | Cấu hình tích hợp |
| credentials | jsonb | true | null | Thông tin xác thực (được mã hóa) |
| api_version | varchar(20) | true | null | Phiên bản API |
| api_base_url | varchar(255) | true | null | URL cơ sở API |
| webhook_url | varchar(255) | true | null | URL webhook |
| webhook_secret | varchar(255) | true | null | Mã bí mật webhook (được mã hóa) |
| rate_limit | integer | true | null | Giới hạn số lượng request |
| sync_interval | integer | true | null | Khoảng thời gian đồng bộ (phút) |
| last_sync_at | timestamp | true | null | Thời gian đồng bộ gần nhất |
| error_message | text | true | null | Thông báo lỗi gần nhất |
| metadata | jsonb | true | null | Dữ liệu bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| marketplace_integrations_pkey | PRIMARY KEY | id | Khóa chính |
| marketplace_integrations_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên tích hợp là duy nhất trong tổ chức |
| marketplace_integrations_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| marketplace_integrations_platform_idx | INDEX | platform | Tăng tốc truy vấn theo nền tảng |
| marketplace_integrations_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| marketplace_integrations_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| marketplace_integrations_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| marketplace_integrations_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| marketplace_integrations_platform_check | CHECK | Đảm bảo platform chỉ nhận các giá trị cho phép |
| marketplace_integrations_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "m1a2r3k4-e5t6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Shopee Integration",
  "description": "Tích hợp với nền tảng Shopee để đồng bộ sản phẩm và đơn hàng",
  "platform": "shopee",
  "status": "active",
  "config": {
    "partner_id": "123456",
    "shop_id": "789012",
    "region": "vn",
    "features": {
      "product_sync": true,
      "order_sync": true,
      "inventory_sync": true,
      "customer_sync": false
    },
    "sync_settings": {
      "product_sync_direction": "bidirectional",
      "order_sync_direction": "marketplace_to_crm",
      "inventory_sync_direction": "crm_to_marketplace"
    }
  },
  "credentials": {
    "partner_key": "encrypted:abcdefghijklmnopqrstuvwxyz",
    "access_token": "encrypted:123456789abcdefghijklmnopqrstuvwxyz",
    "refresh_token": "encrypted:abcdefghijklmnopqrstuvwxyz123456789"
  },
  "api_version": "v2",
  "api_base_url": "https://partner.shopeemobile.com/api/v2",
  "webhook_url": "https://api.NextFlow.com/webhooks/shopee/123456",
  "webhook_secret": "encrypted:webhook_secret_123456",
  "rate_limit": 1000,
  "sync_interval": 15,
  "last_sync_at": "2023-06-20T15:30:00Z",
  "error_message": null,
  "metadata": {
    "supported_categories": ["Electronics", "Fashion", "Home & Living"],
    "supported_logistics": ["Standard Delivery", "Express Delivery"]
  },
  "created_at": "2023-02-15T09:00:00Z",
  "updated_at": "2023-06-20T15:30:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG MARKETPLACE_ACCOUNTS

### 3.1. Mô tả

Bảng `marketplace_accounts` lưu trữ thông tin về các tài khoản trên các sàn thương mại điện tử và nền tảng bên ngoài.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| integration_id | uuid | false | | Khóa ngoại tới bảng marketplace_integrations |
| name | varchar(100) | false | | Tên tài khoản |
| platform | varchar(50) | false | | Nền tảng: shopee, lazada, tiktok, woocommerce, etc. |
| platform_account_id | varchar(100) | false | | ID tài khoản trên nền tảng |
| status | enum | false | 'active' | Trạng thái: active, inactive, error |
| auth_type | varchar(50) | false | 'oauth' | Loại xác thực: oauth, api_key, etc. |
| auth_data | jsonb | true | null | Dữ liệu xác thực (được mã hóa) |
| access_token | text | true | null | Token truy cập (được mã hóa) |
| refresh_token | text | true | null | Token làm mới (được mã hóa) |
| token_expires_at | timestamp | true | null | Thời gian hết hạn token |
| scopes | jsonb | true | null | Phạm vi quyền truy cập |
| last_connected_at | timestamp | true | null | Thời gian kết nối gần nhất |
| error_message | text | true | null | Thông báo lỗi gần nhất |
| metadata | jsonb | true | null | Dữ liệu bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| marketplace_accounts_pkey | PRIMARY KEY | id | Khóa chính |
| marketplace_accounts_organization_platform_account_idx | UNIQUE | organization_id, platform, platform_account_id | Đảm bảo tài khoản nền tảng là duy nhất trong tổ chức |
| marketplace_accounts_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| marketplace_accounts_integration_id_idx | INDEX | integration_id | Tăng tốc truy vấn theo tích hợp |
| marketplace_accounts_platform_idx | INDEX | platform | Tăng tốc truy vấn theo nền tảng |
| marketplace_accounts_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| marketplace_accounts_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| marketplace_accounts_integration_id_fkey | FOREIGN KEY | Tham chiếu đến bảng marketplace_integrations(id) |
| marketplace_accounts_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| marketplace_accounts_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| marketplace_accounts_platform_check | CHECK | Đảm bảo platform chỉ nhận các giá trị cho phép |
| marketplace_accounts_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| marketplace_accounts_auth_type_check | CHECK | Đảm bảo auth_type chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "a1c2c3o4-u5n6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "integration_id": "m1a2r3k4-e5t6-7890-abcd-ef1234567890",
  "name": "Shopee - Cửa hàng điện tử ABC",
  "platform": "shopee",
  "platform_account_id": "789012",
  "status": "active",
  "auth_type": "oauth",
  "auth_data": {
    "partner_id": "123456",
    "shop_id": "789012",
    "region": "vn"
  },
  "access_token": "encrypted:123456789abcdefghijklmnopqrstuvwxyz",
  "refresh_token": "encrypted:abcdefghijklmnopqrstuvwxyz123456789",
  "token_expires_at": "2023-07-20T15:30:00Z",
  "scopes": ["product", "order", "logistics", "shop", "payment"],
  "last_connected_at": "2023-06-20T15:30:00Z",
  "error_message": null,
  "metadata": {
    "shop_name": "Cửa hàng điện tử ABC",
    "shop_region": "Vietnam",
    "shop_status": "active",
    "seller_tier": "preferred"
  },
  "created_at": "2023-02-15T09:30:00Z",
  "updated_at": "2023-06-20T15:30:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG MARKETPLACE_SHOPS

### 4.1. Mô tả

Bảng `marketplace_shops` lưu trữ thông tin về các cửa hàng trên các sàn thương mại điện tử.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| account_id | uuid | false | | Khóa ngoại tới bảng marketplace_accounts |
| platform | varchar(50) | false | | Nền tảng: shopee, lazada, tiktok, etc. |
| shop_id | varchar(100) | false | | ID cửa hàng trên nền tảng |
| shop_name | varchar(255) | false | | Tên cửa hàng |
| shop_url | varchar(255) | true | null | URL cửa hàng |
| shop_logo | varchar(255) | true | null | URL logo cửa hàng |
| shop_status | varchar(50) | false | 'active' | Trạng thái cửa hàng trên nền tảng |
| shop_region | varchar(50) | true | null | Khu vực cửa hàng |
| shop_category | varchar(100) | true | null | Danh mục cửa hàng |
| shop_rating | decimal(3,2) | true | null | Đánh giá cửa hàng |
| shop_created_at | timestamp | true | null | Thời gian tạo cửa hàng trên nền tảng |
| shop_data | jsonb | true | null | Dữ liệu cửa hàng bổ sung |
| sync_status | enum | false | 'pending' | Trạng thái đồng bộ: pending, syncing, synced, error |
| last_sync_at | timestamp | true | null | Thời gian đồng bộ gần nhất |
| error_message | text | true | null | Thông báo lỗi gần nhất |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| marketplace_shops_pkey | PRIMARY KEY | id | Khóa chính |
| marketplace_shops_organization_platform_shop_idx | UNIQUE | organization_id, platform, shop_id | Đảm bảo cửa hàng nền tảng là duy nhất trong tổ chức |
| marketplace_shops_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| marketplace_shops_account_id_idx | INDEX | account_id | Tăng tốc truy vấn theo tài khoản |
| marketplace_shops_platform_idx | INDEX | platform | Tăng tốc truy vấn theo nền tảng |
| marketplace_shops_shop_status_idx | INDEX | shop_status | Tăng tốc truy vấn theo trạng thái cửa hàng |
| marketplace_shops_sync_status_idx | INDEX | sync_status | Tăng tốc truy vấn theo trạng thái đồng bộ |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| marketplace_shops_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| marketplace_shops_account_id_fkey | FOREIGN KEY | Tham chiếu đến bảng marketplace_accounts(id) |
| marketplace_shops_platform_check | CHECK | Đảm bảo platform chỉ nhận các giá trị cho phép |
| marketplace_shops_sync_status_check | CHECK | Đảm bảo sync_status chỉ nhận các giá trị cho phép |

### 4.5. Ví dụ JSON

```json
{
  "id": "s1h2o3p4-i5d6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "account_id": "a1c2c3o4-u5n6-7890-abcd-ef1234567890",
  "platform": "shopee",
  "shop_id": "789012",
  "shop_name": "Cửa hàng điện tử ABC",
  "shop_url": "https://shopee.vn/cuahangdientuabc",
  "shop_logo": "https://cf.shopee.vn/file/abcdef123456",
  "shop_status": "active",
  "shop_region": "Vietnam",
  "shop_category": "Electronics",
  "shop_rating": 4.85,
  "shop_created_at": "2020-01-15T00:00:00Z",
  "shop_data": {
    "follower_count": 5000,
    "item_count": 250,
    "response_rate": 98,
    "response_time": "within an hour",
    "seller_tier": "preferred",
    "is_official_shop": false
  },
  "sync_status": "synced",
  "last_sync_at": "2023-06-20T15:30:00Z",
  "error_message": null,
  "created_at": "2023-02-15T09:30:00Z",
  "updated_at": "2023-06-20T15:30:00Z"
}
```

## 5. BẢNG SYNC_TASKS

### 5.1. Mô tả

Bảng `sync_tasks` lưu trữ thông tin về các nhiệm vụ đồng bộ giữa NextFlow CRM và các nền tảng bên ngoài.

### 5.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| integration_id | uuid | false | | Khóa ngoại tới bảng marketplace_integrations |
| account_id | uuid | true | null | Khóa ngoại tới bảng marketplace_accounts |
| shop_id | uuid | true | null | Khóa ngoại tới bảng marketplace_shops |
| task_type | varchar(50) | false | | Loại nhiệm vụ: product_sync, order_sync, inventory_sync, etc. |
| direction | varchar(20) | false | | Hướng đồng bộ: crm_to_marketplace, marketplace_to_crm, bidirectional |
| status | enum | false | 'pending' | Trạng thái: pending, processing, completed, failed, cancelled |
| priority | integer | false | 5 | Độ ưu tiên (1-10) |
| scheduled_at | timestamp | false | now() | Thời gian lên lịch |
| started_at | timestamp | true | null | Thời gian bắt đầu |
| completed_at | timestamp | true | null | Thời gian hoàn thành |
| progress | integer | false | 0 | Tiến độ (0-100) |
| total_items | integer | false | 0 | Tổng số mục cần đồng bộ |
| processed_items | integer | false | 0 | Số mục đã xử lý |
| successful_items | integer | false | 0 | Số mục thành công |
| failed_items | integer | false | 0 | Số mục thất bại |
| filter_criteria | jsonb | true | null | Tiêu chí lọc |
| error_message | text | true | null | Thông báo lỗi |
| retry_count | integer | false | 0 | Số lần thử lại |
| max_retries | integer | false | 3 | Số lần thử lại tối đa |
| next_retry_at | timestamp | true | null | Thời gian thử lại tiếp theo |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |

### 5.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| sync_tasks_pkey | PRIMARY KEY | id | Khóa chính |
| sync_tasks_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| sync_tasks_integration_id_idx | INDEX | integration_id | Tăng tốc truy vấn theo tích hợp |
| sync_tasks_account_id_idx | INDEX | account_id | Tăng tốc truy vấn theo tài khoản |
| sync_tasks_shop_id_idx | INDEX | shop_id | Tăng tốc truy vấn theo cửa hàng |
| sync_tasks_task_type_idx | INDEX | task_type | Tăng tốc truy vấn theo loại nhiệm vụ |
| sync_tasks_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| sync_tasks_scheduled_at_idx | INDEX | scheduled_at | Tăng tốc truy vấn theo thời gian lên lịch |

### 5.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| sync_tasks_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| sync_tasks_integration_id_fkey | FOREIGN KEY | Tham chiếu đến bảng marketplace_integrations(id) |
| sync_tasks_account_id_fkey | FOREIGN KEY | Tham chiếu đến bảng marketplace_accounts(id) |
| sync_tasks_shop_id_fkey | FOREIGN KEY | Tham chiếu đến bảng marketplace_shops(id) |
| sync_tasks_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| sync_tasks_task_type_check | CHECK | Đảm bảo task_type chỉ nhận các giá trị cho phép |
| sync_tasks_direction_check | CHECK | Đảm bảo direction chỉ nhận các giá trị cho phép |
| sync_tasks_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| sync_tasks_priority_check | CHECK | Đảm bảo priority trong khoảng 1-10 |
| sync_tasks_progress_check | CHECK | Đảm bảo progress trong khoảng 0-100 |

### 5.5. Ví dụ JSON

```json
{
  "id": "t1a2s3k4-i5d6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "integration_id": "m1a2r3k4-e5t6-7890-abcd-ef1234567890",
  "account_id": "a1c2c3o4-u5n6-7890-abcd-ef1234567890",
  "shop_id": "s1h2o3p4-i5d6-7890-abcd-ef1234567890",
  "task_type": "product_sync",
  "direction": "crm_to_marketplace",
  "status": "completed",
  "priority": 7,
  "scheduled_at": "2023-06-20T15:00:00Z",
  "started_at": "2023-06-20T15:00:05Z",
  "completed_at": "2023-06-20T15:10:30Z",
  "progress": 100,
  "total_items": 50,
  "processed_items": 50,
  "successful_items": 48,
  "failed_items": 2,
  "filter_criteria": {
    "categories": ["Electronics", "Accessories"],
    "updated_after": "2023-06-19T00:00:00Z",
    "status": "active"
  },
  "error_message": "2 sản phẩm không thể đồng bộ do thiếu thông tin bắt buộc",
  "retry_count": 0,
  "max_retries": 3,
  "next_retry_at": null,
  "created_at": "2023-06-20T14:55:00Z",
  "updated_at": "2023-06-20T15:10:30Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
