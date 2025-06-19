# SCHEMA TÍCH HỢP - MARKETPLACE

## 1. GIỚI THIỆU

Schema Marketplace quản lý thông tin về các tích hợp với các sàn thương mại điện tử như Shopee, Lazada, TikTok Shop và các nền tảng khác trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến tích hợp marketplace trong hệ thống.

### 1.1. Mục đích

Schema Marketplace phục vụ các mục đích sau:

- Lưu trữ thông tin kết nối với các sàn thương mại điện tử
- Quản lý đồng bộ hóa sản phẩm giữa CRM và các sàn
- Theo dõi đơn hàng từ các sàn thương mại điện tử
- Quản lý thông tin vận chuyển và thanh toán từ các sàn
- Hỗ trợ phân tích hiệu suất bán hàng trên các sàn
- Tự động hóa quy trình xử lý đơn hàng đa kênh

### 1.2. Các bảng chính

Schema Marketplace bao gồm các bảng chính sau:

1. `marketplace_connections` - Lưu trữ thông tin kết nối với các sàn thương mại điện tử
2. `marketplace_shops` - Lưu trữ thông tin về các cửa hàng trên các sàn
3. `marketplace_products` - Lưu trữ thông tin về sản phẩm trên các sàn
4. `marketplace_orders` - Lưu trữ thông tin về đơn hàng từ các sàn
5. `marketplace_sync_logs` - Lưu trữ thông tin lịch sử đồng bộ
6. `marketplace_webhooks` - Lưu trữ thông tin webhook từ các sàn

## 2. BẢNG MARKETPLACE_CONNECTIONS

### 2.1. Mô tả

Bảng `marketplace_connections` lưu trữ thông tin về các kết nối với các sàn thương mại điện tử.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của kết nối |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên kết nối |
| description | text | true | null | Mô tả kết nối |
| platform | varchar(50) | false | | Nền tảng: shopee, lazada, tiktok, woocommerce, etc. |
| api_url | varchar(255) | false | | URL API của nền tảng |
| api_version | varchar(20) | true | null | Phiên bản API |
| app_id | varchar(100) | true | null | ID ứng dụng |
| app_key | varchar(255) | true | null | Khóa ứng dụng (được mã hóa) |
| app_secret | varchar(255) | true | null | Bí mật ứng dụng (được mã hóa) |
| access_token | varchar(255) | true | null | Token truy cập (được mã hóa) |
| refresh_token | varchar(255) | true | null | Token làm mới (được mã hóa) |
| token_expires_at | timestamp | true | null | Thời gian hết hạn token |
| status | varchar(20) | false | 'inactive' | Trạng thái: active, inactive, error |
| is_authorized | boolean | false | false | Đánh dấu đã được ủy quyền |
| auth_callback_url | varchar(255) | true | null | URL callback ủy quyền |
| auth_scope | varchar(255) | true | null | Phạm vi ủy quyền |
| settings | jsonb | true | null | Cài đặt kết nối |
| last_sync_at | timestamp | true | null | Thời gian đồng bộ gần nhất |
| error_message | text | true | null | Thông báo lỗi gần nhất |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| marketplace_connections_pkey | PRIMARY KEY | id | Khóa chính |
| marketplace_connections_organization_platform_idx | UNIQUE | organization_id, platform | Đảm bảo mỗi tổ chức chỉ có một kết nối cho mỗi nền tảng |
| marketplace_connections_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| marketplace_connections_platform_idx | INDEX | platform | Tăng tốc truy vấn theo nền tảng |
| marketplace_connections_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| marketplace_connections_is_authorized_idx | INDEX | is_authorized | Tăng tốc truy vấn theo trạng thái ủy quyền |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| marketplace_connections_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| marketplace_connections_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| marketplace_connections_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| marketplace_connections_platform_check | CHECK | Đảm bảo platform chỉ nhận các giá trị cho phép |
| marketplace_connections_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "m1a2r3k4-e5t6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Kết nối Shopee",
  "description": "Kết nối với cửa hàng Shopee của công ty",
  "platform": "shopee",
  "api_url": "https://partner.shopeemobile.com/api/v2",
  "api_version": "v2",
  "app_id": "123456",
  "app_key": "encrypted:app_key_abcdefghijklmnopqrstuvwxyz",
  "app_secret": "encrypted:app_secret_123456789abcdefghijklmnopqrstuvwxyz",
  "access_token": "encrypted:access_token_abcdefghijklmnopqrstuvwxyz",
  "refresh_token": "encrypted:refresh_token_123456789abcdefghijklmnopqrstuvwxyz",
  "token_expires_at": "2023-08-15T00:00:00Z",
  "status": "active",
  "is_authorized": true,
  "auth_callback_url": "https://api.NextFlow.com/integrations/shopee/callback",
  "auth_scope": "product,order,logistics,shop",
  "settings": {
    "auto_sync_interval": 15,
    "sync_products": true,
    "sync_orders": true,
    "sync_inventory": true,
    "auto_fulfill_orders": true,
    "default_logistics": "Standard Delivery"
  },
  "last_sync_at": "2023-07-15T10:30:00Z",
  "error_message": null,
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-07-15T10:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG MARKETPLACE_SHOPS

### 3.1. Mô tả

Bảng `marketplace_shops` lưu trữ thông tin về các cửa hàng trên các sàn thương mại điện tử.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| connection_id | uuid | false | | Khóa ngoại tới bảng marketplace_connections |
| shop_id | varchar(100) | false | | ID cửa hàng trên sàn |
| name | varchar(100) | false | | Tên cửa hàng |
| description | text | true | null | Mô tả cửa hàng |
| url | varchar(255) | true | null | URL cửa hàng |
| logo_url | varchar(255) | true | null | URL logo cửa hàng |
| country | varchar(50) | true | null | Quốc gia |
| region | varchar(50) | true | null | Khu vực |
| status | varchar(20) | false | 'active' | Trạng thái: active, inactive, banned |
| seller_id | varchar(100) | true | null | ID người bán |
| seller_email | varchar(255) | true | null | Email người bán |
| seller_phone | varchar(20) | true | null | Số điện thoại người bán |
| metadata | jsonb | true | null | Metadata bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| marketplace_shops_pkey | PRIMARY KEY | id | Khóa chính |
| marketplace_shops_connection_shop_id_idx | UNIQUE | connection_id, shop_id | Đảm bảo ID cửa hàng là duy nhất cho mỗi kết nối |
| marketplace_shops_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| marketplace_shops_connection_id_idx | INDEX | connection_id | Tăng tốc truy vấn theo kết nối |
| marketplace_shops_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| marketplace_shops_country_idx | INDEX | country | Tăng tốc truy vấn theo quốc gia |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| marketplace_shops_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| marketplace_shops_connection_id_fkey | FOREIGN KEY | Tham chiếu đến bảng marketplace_connections(id) |
| marketplace_shops_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| marketplace_shops_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| marketplace_shops_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "s1h2o3p4-i5d6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "connection_id": "m1a2r3k4-e5t6-7890-abcd-ef1234567890",
  "shop_id": "123456789",
  "name": "NextFlow Official Store",
  "description": "Cửa hàng chính thức của NextFlow trên Shopee",
  "url": "https://shopee.vn/NextFlow.official",
  "logo_url": "https://cf.shopee.vn/file/abcdef1234567890",
  "country": "Vietnam",
  "region": "Ho Chi Minh City",
  "status": "active",
  "seller_id": "seller_123456",
  "seller_email": "shop@NextFlow.com",
  "seller_phone": "+84901234567",
  "metadata": {
    "rating": 4.9,
    "followers": 5000,
    "response_rate": 98,
    "response_time": "within an hour",
    "joined_date": "2022-01-01"
  },
  "created_at": "2023-01-15T09:30:00Z",
  "updated_at": "2023-01-15T09:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG MARKETPLACE_PRODUCTS

### 4.1. Mô tả

Bảng `marketplace_products` lưu trữ thông tin về các sản phẩm trên các sàn thương mại điện tử.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| connection_id | uuid | false | | Khóa ngoại tới bảng marketplace_connections |
| shop_id | uuid | false | | Khóa ngoại tới bảng marketplace_shops |
| product_id | varchar(100) | false | | ID sản phẩm trên sàn |
| local_product_id | uuid | true | null | Khóa ngoại tới bảng products, sản phẩm trong CRM |
| name | varchar(255) | false | | Tên sản phẩm |
| description | text | true | null | Mô tả sản phẩm |
| category_id | varchar(100) | true | null | ID danh mục trên sàn |
| brand | varchar(100) | true | null | Thương hiệu |
| sku | varchar(100) | true | null | Mã SKU |
| price | decimal(15,2) | false | | Giá bán |
| original_price | decimal(15,2) | true | null | Giá gốc |
| currency | varchar(3) | false | 'VND' | Đơn vị tiền tệ |
| stock | integer | false | 0 | Số lượng tồn kho |
| weight | decimal(10,2) | true | null | Trọng lượng (gram) |
| length | decimal(10,2) | true | null | Chiều dài (cm) |
| width | decimal(10,2) | true | null | Chiều rộng (cm) |
| height | decimal(10,2) | true | null | Chiều cao (cm) |
| images | jsonb | true | null | Danh sách hình ảnh |
| variations | jsonb | true | null | Danh sách biến thể |
| attributes | jsonb | true | null | Thuộc tính sản phẩm |
| status | varchar(20) | false | 'inactive' | Trạng thái: active, inactive, deleted, banned |
| condition | varchar(20) | false | 'new' | Tình trạng: new, used, refurbished |
| url | varchar(255) | true | null | URL sản phẩm |
| rating | decimal(3,2) | true | null | Đánh giá trung bình |
| rating_count | integer | true | null | Số lượng đánh giá |
| sold_count | integer | true | null | Số lượng đã bán |
| is_synced | boolean | false | false | Đánh dấu đã đồng bộ |
| last_sync_at | timestamp | true | null | Thời gian đồng bộ gần nhất |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| marketplace_products_pkey | PRIMARY KEY | id | Khóa chính |
| marketplace_products_connection_product_idx | UNIQUE | connection_id, product_id | Đảm bảo ID sản phẩm là duy nhất cho mỗi kết nối |
| marketplace_products_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| marketplace_products_connection_id_idx | INDEX | connection_id | Tăng tốc truy vấn theo kết nối |
| marketplace_products_shop_id_idx | INDEX | shop_id | Tăng tốc truy vấn theo cửa hàng |
| marketplace_products_local_product_id_idx | INDEX | local_product_id | Tăng tốc truy vấn theo sản phẩm trong CRM |
| marketplace_products_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| marketplace_products_is_synced_idx | INDEX | is_synced | Tăng tốc truy vấn theo trạng thái đồng bộ |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| marketplace_products_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| marketplace_products_connection_id_fkey | FOREIGN KEY | Tham chiếu đến bảng marketplace_connections(id) |
| marketplace_products_shop_id_fkey | FOREIGN KEY | Tham chiếu đến bảng marketplace_shops(id) |
| marketplace_products_local_product_id_fkey | FOREIGN KEY | Tham chiếu đến bảng products(id) |
| marketplace_products_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| marketplace_products_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| marketplace_products_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| marketplace_products_condition_check | CHECK | Đảm bảo condition chỉ nhận các giá trị cho phép |
| marketplace_products_price_check | CHECK | Đảm bảo price >= 0 |
| marketplace_products_stock_check | CHECK | Đảm bảo stock >= 0 |
| marketplace_products_rating_check | CHECK | Đảm bảo rating >= 0 và rating <= 5 khi không null |

### 4.5. Ví dụ JSON

```json
{
  "id": "p1r2o3d4-u5c6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "connection_id": "m1a2r3k4-e5t6-7890-abcd-ef1234567890",
  "shop_id": "s1h2o3p4-i5d6-7890-abcd-ef1234567890",
  "product_id": "987654321",
  "local_product_id": "l1o2c3a4-l5p6-7890-abcd-ef1234567890",
  "name": "NextFlow CRM - Gói Premium",
  "description": "Phần mềm quản lý quan hệ khách hàng NextFlow CRM - Gói Premium với đầy đủ tính năng cao cấp",
  "category_id": "100001234",
  "brand": "NextFlow",
  "sku": "NextFlow-CRM-PREMIUM",
  "price": 5000000.00,
  "original_price": 6000000.00,
  "currency": "VND",
  "stock": 999,
  "weight": 0.00,
  "length": 0.00,
  "width": 0.00,
  "height": 0.00,
  "images": [
    {
      "url": "https://cf.shopee.vn/file/image1.jpg",
      "position": 1
    },
    {
      "url": "https://cf.shopee.vn/file/image2.jpg",
      "position": 2
    }
  ],
  "variations": [
    {
      "variation_id": "var_123456",
      "name": "Gói 1 năm",
      "sku": "NextFlow-CRM-PREMIUM-1Y",
      "price": 5000000.00,
      "stock": 999
    },
    {
      "variation_id": "var_123457",
      "name": "Gói 2 năm",
      "sku": "NextFlow-CRM-PREMIUM-2Y",
      "price": 9000000.00,
      "stock": 999
    }
  ],
  "attributes": [
    {
      "name": "Thời hạn",
      "value": "1 năm, 2 năm"
    },
    {
      "name": "Số người dùng",
      "value": "Không giới hạn"
    }
  ],
  "status": "active",
  "condition": "new",
  "url": "https://shopee.vn/NextFlow-CRM-Goi-Premium-i.123456789.987654321",
  "rating": 4.90,
  "rating_count": 50,
  "sold_count": 120,
  "is_synced": true,
  "last_sync_at": "2023-07-15T10:30:00Z",
  "created_at": "2023-01-15T10:00:00Z",
  "updated_at": "2023-07-15T10:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
