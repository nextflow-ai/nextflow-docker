# SCHEMA HỆ THỐNG - SUBSCRIPTION VÀ BILLING

## 1. GIỚI THIỆU

Schema Subscription và Billing quản lý thông tin về gói dịch vụ, đăng ký và thanh toán trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến đăng ký và thanh toán trong hệ thống.

### 1.1. Mục đích

Schema Subscription và Billing phục vụ các mục đích sau:

- Quản lý các gói dịch vụ (plans) trong hệ thống
- Quản lý đăng ký (subscriptions) của tổ chức
- Quản lý hóa đơn (invoices) và thanh toán (payments)
- Theo dõi lịch sử thanh toán và giao dịch
- Quản lý giới hạn sử dụng (usage limits) và tính phí theo mức sử dụng

### 1.2. Các bảng chính

Schema Subscription và Billing bao gồm các bảng chính sau:

1. `subscription_plans` - Lưu trữ thông tin về các gói dịch vụ
2. `plan_features` - Lưu trữ thông tin về tính năng của gói dịch vụ
3. `subscriptions` - Lưu trữ thông tin về đăng ký của tổ chức
4. `invoices` - Lưu trữ thông tin về hóa đơn
5. `payments` - Lưu trữ thông tin về thanh toán
6. `usage_records` - Lưu trữ thông tin về mức sử dụng
7. `price_tiers` - Lưu trữ thông tin về các mức giá

## 2. BẢNG SUBSCRIPTION_PLANS

### 2.1. Mô tả

Bảng `subscription_plans` lưu trữ thông tin về các gói dịch vụ trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của gói dịch vụ |
| name | varchar(50) | false | | Tên gói dịch vụ |
| display_name | varchar(100) | false | | Tên hiển thị của gói dịch vụ |
| description | text | true | null | Mô tả về gói dịch vụ |
| price | decimal(12,2) | false | | Giá gói dịch vụ |
| currency | varchar(3) | false | 'VND' | Đơn vị tiền tệ |
| billing_interval | varchar(20) | false | 'monthly' | Chu kỳ thanh toán: monthly, quarterly, yearly |
| trial_days | integer | false | 0 | Số ngày dùng thử |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| is_public | boolean | false | true | Hiển thị công khai |
| sort_order | integer | false | 0 | Thứ tự hiển thị |
| metadata | jsonb | true | null | Dữ liệu bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| subscription_plans_pkey | PRIMARY KEY | id | Khóa chính |
| subscription_plans_name_idx | UNIQUE | name | Đảm bảo tên gói dịch vụ là duy nhất |
| subscription_plans_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |
| subscription_plans_is_public_idx | INDEX | is_public | Tăng tốc truy vấn theo trạng thái công khai |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| subscription_plans_price_check | CHECK | Đảm bảo price >= 0 |
| subscription_plans_trial_days_check | CHECK | Đảm bảo trial_days >= 0 |
| subscription_plans_billing_interval_check | CHECK | Đảm bảo billing_interval chỉ nhận các giá trị cho phép |
| subscription_plans_currency_check | CHECK | Đảm bảo currency là mã tiền tệ hợp lệ |

### 2.5. Ví dụ JSON

```json
{
  "id": "p1l2a3n4-i5d6-7890-abcd-ef1234567890",
  "name": "standard",
  "display_name": "Gói Standard",
  "description": "Gói dịch vụ tiêu chuẩn cho doanh nghiệp vừa và nhỏ",
  "price": 1500000.00,
  "currency": "VND",
  "billing_interval": "monthly",
  "trial_days": 14,
  "is_active": true,
  "is_public": true,
  "sort_order": 2,
  "metadata": {
    "recommended": true,
    "badge": "Phổ biến",
    "color": "#1976d2"
  },
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null
}
```

## 3. BẢNG PLAN_FEATURES

### 3.1. Mô tả

Bảng `plan_features` lưu trữ thông tin về các tính năng và giới hạn của từng gói dịch vụ.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| plan_id | uuid | false | | Khóa ngoại tới bảng subscription_plans |
| feature_key | varchar(100) | false | | Khóa định danh của tính năng |
| feature_name | varchar(100) | false | | Tên hiển thị của tính năng |
| feature_description | text | true | null | Mô tả về tính năng |
| feature_type | varchar(20) | false | 'boolean' | Loại tính năng: boolean, numeric, text |
| feature_value | varchar(255) | true | null | Giá trị của tính năng |
| is_visible | boolean | false | true | Hiển thị trong bảng so sánh |
| sort_order | integer | false | 0 | Thứ tự hiển thị |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| plan_features_pkey | PRIMARY KEY | id | Khóa chính |
| plan_features_plan_key_idx | UNIQUE | plan_id, feature_key | Đảm bảo mỗi tính năng chỉ được định nghĩa một lần cho mỗi gói |
| plan_features_plan_id_idx | INDEX | plan_id | Tăng tốc truy vấn theo gói dịch vụ |
| plan_features_feature_key_idx | INDEX | feature_key | Tăng tốc truy vấn theo khóa tính năng |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| plan_features_plan_id_fkey | FOREIGN KEY | Tham chiếu đến bảng subscription_plans(id) |
| plan_features_feature_type_check | CHECK | Đảm bảo feature_type chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "f1e2a3t4-u5r6-7890-abcd-ef1234567890",
  "plan_id": "p1l2a3n4-i5d6-7890-abcd-ef1234567890",
  "feature_key": "max_users",
  "feature_name": "Số lượng người dùng",
  "feature_description": "Số lượng người dùng tối đa được phép trong tổ chức",
  "feature_type": "numeric",
  "feature_value": "10",
  "is_visible": true,
  "sort_order": 1,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z"
}
```

## 4. BẢNG SUBSCRIPTIONS

### 4.1. Mô tả

Bảng `subscriptions` lưu trữ thông tin về đăng ký gói dịch vụ của các tổ chức.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| plan_id | uuid | false | | Khóa ngoại tới bảng subscription_plans |
| status | enum | false | 'active' | Trạng thái: active, canceled, expired, past_due, trialing |
| start_date | timestamp | false | now() | Ngày bắt đầu đăng ký |
| end_date | timestamp | true | null | Ngày kết thúc đăng ký |
| trial_end_date | timestamp | true | null | Ngày kết thúc dùng thử |
| canceled_at | timestamp | true | null | Thời gian hủy đăng ký |
| price_override | decimal(12,2) | true | null | Giá ghi đè (nếu có) |
| billing_cycle_anchor | timestamp | false | now() | Mốc thời gian cho chu kỳ thanh toán |
| next_billing_date | timestamp | true | null | Ngày thanh toán tiếp theo |
| payment_method_id | uuid | true | null | Khóa ngoại tới bảng payment_methods |
| auto_renew | boolean | false | true | Tự động gia hạn |
| metadata | jsonb | true | null | Dữ liệu bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| subscriptions_pkey | PRIMARY KEY | id | Khóa chính |
| subscriptions_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| subscriptions_plan_id_idx | INDEX | plan_id | Tăng tốc truy vấn theo gói dịch vụ |
| subscriptions_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| subscriptions_next_billing_date_idx | INDEX | next_billing_date | Tăng tốc truy vấn theo ngày thanh toán tiếp theo |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| subscriptions_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| subscriptions_plan_id_fkey | FOREIGN KEY | Tham chiếu đến bảng subscription_plans(id) |
| subscriptions_payment_method_id_fkey | FOREIGN KEY | Tham chiếu đến bảng payment_methods(id) |
| subscriptions_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| subscriptions_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| subscriptions_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| subscriptions_price_override_check | CHECK | Đảm bảo price_override >= 0 khi không null |

### 4.5. Ví dụ JSON

```json
{
  "id": "s1u2b3s4-c5r6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "plan_id": "p1l2a3n4-i5d6-7890-abcd-ef1234567890",
  "status": "active",
  "start_date": "2023-01-15T00:00:00Z",
  "end_date": "2024-01-15T00:00:00Z",
  "trial_end_date": "2023-01-29T00:00:00Z",
  "canceled_at": null,
  "price_override": 1350000.00,
  "billing_cycle_anchor": "2023-01-15T00:00:00Z",
  "next_billing_date": "2023-02-15T00:00:00Z",
  "payment_method_id": "p1m2i3d4-5678-abcd-efgh-ijklmnopqrst",
  "auto_renew": true,
  "metadata": {
    "promotion_code": "WELCOME10",
    "discount_percent": 10,
    "sales_rep": "Nguyễn Văn A"
  },
  "created_at": "2023-01-15T00:00:00Z",
  "updated_at": "2023-01-15T00:00:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 5. BẢNG INVOICES

### 5.1. Mô tả

Bảng `invoices` lưu trữ thông tin về hóa đơn thanh toán của các tổ chức.

### 5.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| subscription_id | uuid | true | null | Khóa ngoại tới bảng subscriptions |
| invoice_number | varchar(50) | false | | Số hóa đơn |
| status | enum | false | 'draft' | Trạng thái: draft, open, paid, void, uncollectible |
| currency | varchar(3) | false | 'VND' | Đơn vị tiền tệ |
| subtotal | decimal(12,2) | false | 0 | Tổng tiền trước thuế và giảm giá |
| discount | decimal(12,2) | false | 0 | Giảm giá |
| tax | decimal(12,2) | false | 0 | Thuế |
| total | decimal(12,2) | false | 0 | Tổng tiền |
| amount_paid | decimal(12,2) | false | 0 | Số tiền đã thanh toán |
| amount_due | decimal(12,2) | false | 0 | Số tiền còn nợ |
| issue_date | timestamp | false | now() | Ngày phát hành |
| due_date | timestamp | false | | Ngày đến hạn |
| paid_date | timestamp | true | null | Ngày thanh toán |
| billing_address | jsonb | true | null | Địa chỉ thanh toán |
| billing_reason | varchar(50) | false | 'subscription_create' | Lý do xuất hóa đơn |
| description | text | true | null | Mô tả |
| metadata | jsonb | true | null | Dữ liệu bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 5.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| invoices_pkey | PRIMARY KEY | id | Khóa chính |
| invoices_invoice_number_idx | UNIQUE | invoice_number | Đảm bảo số hóa đơn là duy nhất |
| invoices_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| invoices_subscription_id_idx | INDEX | subscription_id | Tăng tốc truy vấn theo đăng ký |
| invoices_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| invoices_due_date_idx | INDEX | due_date | Tăng tốc truy vấn theo ngày đến hạn |

### 5.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| invoices_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| invoices_subscription_id_fkey | FOREIGN KEY | Tham chiếu đến bảng subscriptions(id) |
| invoices_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| invoices_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| invoices_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| invoices_currency_check | CHECK | Đảm bảo currency là mã tiền tệ hợp lệ |
| invoices_amount_check | CHECK | Đảm bảo total = subtotal - discount + tax |
| invoices_amount_due_check | CHECK | Đảm bảo amount_due = total - amount_paid |

### 5.5. Ví dụ JSON

```json
{
  "id": "i1n2v3o4-i5c6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "subscription_id": "s1u2b3s4-c5r6-7890-abcd-ef1234567890",
  "invoice_number": "INV-2023-0001",
  "status": "paid",
  "currency": "VND",
  "subtotal": 1500000.00,
  "discount": 150000.00,
  "tax": 135000.00,
  "total": 1485000.00,
  "amount_paid": 1485000.00,
  "amount_due": 0.00,
  "issue_date": "2023-01-15T00:00:00Z",
  "due_date": "2023-01-22T00:00:00Z",
  "paid_date": "2023-01-16T10:30:00Z",
  "billing_address": {
    "name": "Công ty TNHH ABC",
    "address": "123 Đường Nguyễn Huệ",
    "city": "Quận 1",
    "state": "TP Hồ Chí Minh",
    "country": "Việt Nam",
    "postal_code": "70000",
    "tax_id": "0123456789"
  },
  "billing_reason": "subscription_create",
  "description": "Thanh toán gói Standard - Tháng 1/2023",
  "metadata": {
    "payment_method": "bank_transfer",
    "bank_reference": "CT123456789"
  },
  "created_at": "2023-01-15T00:00:00Z",
  "updated_at": "2023-01-16T10:30:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
