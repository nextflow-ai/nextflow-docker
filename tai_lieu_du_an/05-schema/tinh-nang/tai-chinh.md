# SCHEMA TÍNH NĂNG - TÀI CHÍNH

## 1. GIỚI THIỆU

Schema Tài chính quản lý thông tin về các giao dịch tài chính, hóa đơn, thanh toán và báo cáo tài chính trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến tài chính trong hệ thống.

### 1.1. Mục đích

Schema Tài chính phục vụ các mục đích sau:

- Lưu trữ thông tin về các giao dịch tài chính
- Quản lý hóa đơn và thanh toán
- Theo dõi công nợ khách hàng và nhà cung cấp
- Quản lý chi phí và doanh thu
- Tạo báo cáo tài chính
- Hỗ trợ kế toán và quản lý tài chính

### 1.2. Các bảng chính

Schema Tài chính bao gồm các bảng chính sau:

1. `financial_accounts` - Lưu trữ thông tin về tài khoản tài chính
2. `transactions` - Lưu trữ thông tin về các giao dịch tài chính
3. `invoices` - Lưu trữ thông tin về hóa đơn
4. `payments` - Lưu trữ thông tin về thanh toán
5. `payment_methods` - Lưu trữ thông tin về phương thức thanh toán
6. `expenses` - Lưu trữ thông tin về chi phí
7. `revenue` - Lưu trữ thông tin về doanh thu
8. `financial_periods` - Lưu trữ thông tin về kỳ tài chính

## 2. BẢNG FINANCIAL_ACCOUNTS

### 2.1. Mô tả

Bảng `financial_accounts` lưu trữ thông tin về các tài khoản tài chính trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của tài khoản |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên tài khoản |
| code | varchar(50) | false | | Mã tài khoản |
| description | text | true | null | Mô tả tài khoản |
| type | varchar(50) | false | | Loại tài khoản: cash, bank, credit_card, etc. |
| currency | varchar(3) | false | 'VND' | Đơn vị tiền tệ |
| balance | decimal(15,2) | false | 0 | Số dư hiện tại |
| initial_balance | decimal(15,2) | false | 0 | Số dư ban đầu |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| bank_name | varchar(100) | true | null | Tên ngân hàng |
| account_number | varchar(50) | true | null | Số tài khoản |
| account_holder | varchar(100) | true | null | Chủ tài khoản |
| branch | varchar(100) | true | null | Chi nhánh ngân hàng |
| swift_code | varchar(20) | true | null | Mã SWIFT |
| notes | text | true | null | Ghi chú |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| financial_accounts_pkey | PRIMARY KEY | id | Khóa chính |
| financial_accounts_organization_code_idx | UNIQUE | organization_id, code | Đảm bảo mã tài khoản là duy nhất trong tổ chức |
| financial_accounts_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| financial_accounts_type_idx | INDEX | type | Tăng tốc truy vấn theo loại tài khoản |
| financial_accounts_currency_idx | INDEX | currency | Tăng tốc truy vấn theo đơn vị tiền tệ |
| financial_accounts_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| financial_accounts_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| financial_accounts_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| financial_accounts_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| financial_accounts_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| financial_accounts_currency_check | CHECK | Đảm bảo currency là mã tiền tệ hợp lệ |

### 2.5. Ví dụ JSON

```json
{
  "id": "a1c2c3o4-u5n6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Tài khoản Vietcombank",
  "code": "BANK-VCB-001",
  "description": "Tài khoản ngân hàng Vietcombank chính của công ty",
  "type": "bank",
  "currency": "VND",
  "balance": 1250000000.00,
  "initial_balance": 500000000.00,
  "is_active": true,
  "bank_name": "Vietcombank",
  "account_number": "1234567890",
  "account_holder": "Công ty TNHH NextFlow",
  "branch": "Chi nhánh Quận 1, TP.HCM",
  "swift_code": "BFTVVNVX",
  "notes": "Tài khoản chính dùng cho giao dịch hàng ngày",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-07-01T10:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG TRANSACTIONS

### 3.1. Mô tả

Bảng `transactions` lưu trữ thông tin về các giao dịch tài chính trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| transaction_number | varchar(50) | false | | Số giao dịch |
| account_id | uuid | false | | Khóa ngoại tới bảng financial_accounts |
| type | varchar(50) | false | | Loại giao dịch: income, expense, transfer, etc. |
| amount | decimal(15,2) | false | | Số tiền giao dịch |
| currency | varchar(3) | false | 'VND' | Đơn vị tiền tệ |
| exchange_rate | decimal(10,6) | false | 1 | Tỷ giá hối đoái |
| date | timestamp | false | now() | Ngày giao dịch |
| description | text | true | null | Mô tả giao dịch |
| reference | varchar(100) | true | null | Tham chiếu |
| category_id | uuid | true | null | Khóa ngoại tới bảng transaction_categories |
| contact_id | uuid | true | null | Khóa ngoại tới bảng contacts |
| payment_method_id | uuid | true | null | Khóa ngoại tới bảng payment_methods |
| status | varchar(20) | false | 'completed' | Trạng thái: pending, completed, failed, cancelled |
| is_reconciled | boolean | false | false | Đánh dấu đã đối chiếu |
| reconciled_at | timestamp | true | null | Thời gian đối chiếu |
| tags | jsonb | true | null | Thẻ giao dịch |
| metadata | jsonb | true | null | Dữ liệu bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| transactions_pkey | PRIMARY KEY | id | Khóa chính |
| transactions_organization_number_idx | UNIQUE | organization_id, transaction_number | Đảm bảo số giao dịch là duy nhất trong tổ chức |
| transactions_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| transactions_account_id_idx | INDEX | account_id | Tăng tốc truy vấn theo tài khoản |
| transactions_type_idx | INDEX | type | Tăng tốc truy vấn theo loại giao dịch |
| transactions_date_idx | INDEX | date | Tăng tốc truy vấn theo ngày giao dịch |
| transactions_category_id_idx | INDEX | category_id | Tăng tốc truy vấn theo danh mục |
| transactions_contact_id_idx | INDEX | contact_id | Tăng tốc truy vấn theo liên hệ |
| transactions_payment_method_id_idx | INDEX | payment_method_id | Tăng tốc truy vấn theo phương thức thanh toán |
| transactions_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| transactions_is_reconciled_idx | INDEX | is_reconciled | Tăng tốc truy vấn theo trạng thái đối chiếu |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| transactions_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| transactions_account_id_fkey | FOREIGN KEY | Tham chiếu đến bảng financial_accounts(id) |
| transactions_category_id_fkey | FOREIGN KEY | Tham chiếu đến bảng transaction_categories(id) |
| transactions_contact_id_fkey | FOREIGN KEY | Tham chiếu đến bảng contacts(id) |
| transactions_payment_method_id_fkey | FOREIGN KEY | Tham chiếu đến bảng payment_methods(id) |
| transactions_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| transactions_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| transactions_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| transactions_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| transactions_amount_check | CHECK | Đảm bảo amount != 0 |
| transactions_exchange_rate_check | CHECK | Đảm bảo exchange_rate > 0 |

### 3.5. Ví dụ JSON

```json
{
  "id": "t1r2a3n4-s5a6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "transaction_number": "TRX-2023-0001",
  "account_id": "a1c2c3o4-u5n6-7890-abcd-ef1234567890",
  "type": "income",
  "amount": 15000000.00,
  "currency": "VND",
  "exchange_rate": 1.000000,
  "date": "2023-07-15T10:30:00Z",
  "description": "Thanh toán đơn hàng ORD-2023-0001",
  "reference": "ORD-2023-0001",
  "category_id": "c1a2t3e4-g5o6-7890-abcd-ef1234567890",
  "contact_id": "c1o2n3t4-a5c6-7890-abcd-ef1234567890",
  "payment_method_id": "p1a2y3m4-e5n6-7890-abcd-ef1234567890",
  "status": "completed",
  "is_reconciled": true,
  "reconciled_at": "2023-07-16T09:00:00Z",
  "tags": ["sales", "online"],
  "metadata": {
    "invoice_id": "i1n2v3o4-i5c6-7890-abcd-ef1234567890",
    "payment_id": "p1a2y3m4-e5n6-7890-abcd-ef1234567890"
  },
  "created_at": "2023-07-15T10:30:00Z",
  "updated_at": "2023-07-16T09:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG PAYMENT_METHODS

### 4.1. Mô tả

Bảng `payment_methods` lưu trữ thông tin về các phương thức thanh toán trong hệ thống.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(100) | false | | Tên phương thức thanh toán |
| code | varchar(50) | false | | Mã phương thức thanh toán |
| description | text | true | null | Mô tả phương thức thanh toán |
| type | varchar(50) | false | | Loại phương thức: cash, bank_transfer, credit_card, e_wallet, etc. |
| provider | varchar(100) | true | null | Nhà cung cấp dịch vụ thanh toán |
| account_id | uuid | true | null | Khóa ngoại tới bảng financial_accounts |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| is_default | boolean | false | false | Đánh dấu là phương thức mặc định |
| settings | jsonb | true | null | Cài đặt phương thức thanh toán |
| instructions | text | true | null | Hướng dẫn thanh toán |
| icon | varchar(255) | true | null | Biểu tượng phương thức thanh toán |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| payment_methods_pkey | PRIMARY KEY | id | Khóa chính |
| payment_methods_organization_code_idx | UNIQUE | organization_id, code | Đảm bảo mã phương thức thanh toán là duy nhất trong tổ chức |
| payment_methods_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| payment_methods_type_idx | INDEX | type | Tăng tốc truy vấn theo loại phương thức |
| payment_methods_provider_idx | INDEX | provider | Tăng tốc truy vấn theo nhà cung cấp |
| payment_methods_account_id_idx | INDEX | account_id | Tăng tốc truy vấn theo tài khoản |
| payment_methods_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |
| payment_methods_is_default_idx | INDEX | is_default | Tăng tốc truy vấn theo phương thức mặc định |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| payment_methods_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| payment_methods_account_id_fkey | FOREIGN KEY | Tham chiếu đến bảng financial_accounts(id) |
| payment_methods_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| payment_methods_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| payment_methods_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |

### 4.5. Ví dụ JSON

```json
{
  "id": "p1a2y3m4-e5n6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Chuyển khoản ngân hàng",
  "code": "BANK_TRANSFER",
  "description": "Thanh toán bằng chuyển khoản ngân hàng",
  "type": "bank_transfer",
  "provider": "Vietcombank",
  "account_id": "a1c2c3o4-u5n6-7890-abcd-ef1234567890",
  "is_active": true,
  "is_default": true,
  "settings": {
    "processing_time": "1-2 ngày làm việc",
    "verification_required": true
  },
  "instructions": "Vui lòng chuyển khoản đến tài khoản:\nNgân hàng: Vietcombank\nSố tài khoản: 1234567890\nChủ tài khoản: Công ty TNHH NextFlow\nNội dung: [Mã đơn hàng]",
  "icon": "https://assets.NextFlow.com/payment_methods/bank_transfer.png",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
