# TỔNG QUAN SCHEMA TÍCH HỢP

## 1. GIỚI THIỆU

Tài liệu này cung cấp tổng quan về schema tích hợp trong NextFlow CRM-AI. Schema tích hợp quản lý việc kết nối và tương tác với các hệ thống bên ngoài, bao gồm API, webhook, database, marketplace và các dịch vụ khác.

### 1.1. Mục đích

- Cung cấp cái nhìn tổng quan về cấu trúc schema tích hợp
- Mô tả các loại tích hợp và mối quan hệ giữa chúng
- Giải thích cách sử dụng schema tích hợp trong kiến trúc multi-tenant

### 1.2. Phạm vi

Tài liệu này bao gồm:

- Tổng quan về các loại tích hợp
- Mô tả các bảng dữ liệu chính
- Mối quan hệ giữa các bảng
- Cách sử dụng schema tích hợp trong kiến trúc multi-tenant

## 2. CÁC LOẠI TÍCH HỢP

NextFlow CRM-AI hỗ trợ nhiều loại tích hợp khác nhau:

### 2.1. API Integration

Tích hợp thông qua API cho phép NextFlow CRM-AI giao tiếp với các hệ thống bên ngoài thông qua REST API, GraphQL API hoặc SOAP API.

- **Outbound API**: NextFlow CRM-AI gọi API của hệ thống bên ngoài
- **Inbound API**: Hệ thống bên ngoài gọi API của NextFlow CRM-AI
- **API Authentication**: Xác thực API thông qua API key, OAuth, JWT, v.v.
- **API Rate Limiting**: Giới hạn số lượng API calls
- **API Versioning**: Quản lý phiên bản API

### 2.2. Webhook Integration

Tích hợp thông qua webhook cho phép NextFlow CRM-AI nhận thông báo từ các hệ thống bên ngoài khi có sự kiện xảy ra.

- **Inbound Webhook**: NextFlow CRM-AI nhận webhook từ hệ thống bên ngoài
- **Outbound Webhook**: NextFlow CRM-AI gửi webhook đến hệ thống bên ngoài
- **Webhook Authentication**: Xác thực webhook thông qua secret key, HMAC signature, v.v.
- **Webhook Retry**: Cơ chế thử lại khi webhook fails
- **Webhook Logging**: Ghi log webhook

### 2.3. Database Integration

Tích hợp với database cho phép NextFlow CRM-AI kết nối và tương tác với các cơ sở dữ liệu bên ngoài.

- **Database Connection**: Kết nối với các loại database khác nhau (MySQL, PostgreSQL, SQL Server, MongoDB, v.v.)
- **Data Import/Export**: Nhập/xuất dữ liệu từ/đến database
- **Data Synchronization**: Đồng bộ dữ liệu giữa NextFlow CRM-AI và database bên ngoài
- **Database Query**: Truy vấn dữ liệu từ database bên ngoài
- **Database Schema Mapping**: Mapping schema giữa NextFlow CRM-AI và database bên ngoài

### 2.4. Marketplace Integration

Tích hợp với marketplace cho phép NextFlow CRM-AI kết nối và tương tác với các sàn thương mại điện tử.

- **Product Synchronization**: Đồng bộ sản phẩm giữa NextFlow CRM-AI và marketplace
- **Order Synchronization**: Đồng bộ đơn hàng giữa NextFlow CRM-AI và marketplace
- **Inventory Management**: Quản lý tồn kho trên marketplace
- **Pricing Management**: Quản lý giá trên marketplace
- **Customer Data Integration**: Tích hợp dữ liệu khách hàng từ marketplace

### 2.5. File Storage Integration

Tích hợp với các dịch vụ lưu trữ file cho phép NextFlow CRM-AI lưu trữ và quản lý file trên các dịch vụ bên ngoài.

- **Cloud Storage**: Tích hợp với các dịch vụ lưu trữ đám mây (AWS S3, Google Cloud Storage, Azure Blob Storage, v.v.)
- **File Upload/Download**: Tải lên/tải xuống file từ/đến dịch vụ lưu trữ
- **File Sharing**: Chia sẻ file với người dùng bên ngoài
- **File Versioning**: Quản lý phiên bản file
- **File Metadata**: Quản lý metadata của file

### 2.6. Email Integration

Tích hợp với các dịch vụ email cho phép NextFlow CRM-AI gửi và nhận email.

- **SMTP Integration**: Tích hợp với SMTP server để gửi email
- **IMAP/POP3 Integration**: Tích hợp với IMAP/POP3 server để nhận email
- **Email Template**: Quản lý mẫu email
- **Email Tracking**: Theo dõi trạng thái email (đã gửi, đã mở, đã click, v.v.)
- **Email Automation**: Tự động hóa gửi email

### 2.7. SMS Integration

Tích hợp với các dịch vụ SMS cho phép NextFlow CRM-AI gửi và nhận SMS.

- **SMS Gateway**: Tích hợp với SMS gateway để gửi và nhận SMS
- **SMS Template**: Quản lý mẫu SMS
- **SMS Tracking**: Theo dõi trạng thái SMS (đã gửi, đã nhận, v.v.)
- **SMS Automation**: Tự động hóa gửi SMS

### 2.8. Social Media Integration

Tích hợp với các mạng xã hội cho phép NextFlow CRM-AI tương tác với người dùng trên mạng xã hội.

- **Social Media Account**: Quản lý tài khoản mạng xã hội
- **Social Media Posting**: Đăng bài viết lên mạng xã hội
- **Social Media Monitoring**: Theo dõi đề cập đến thương hiệu trên mạng xã hội
- **Social Media Engagement**: Tương tác với người dùng trên mạng xã hội
- **Social Media Analytics**: Phân tích hiệu suất trên mạng xã hội

### 2.9. Payment Gateway Integration

Tích hợp với các cổng thanh toán cho phép NextFlow CRM-AI xử lý thanh toán.

- **Payment Processing**: Xử lý thanh toán thông qua cổng thanh toán
- **Payment Method**: Quản lý phương thức thanh toán
- **Payment Status**: Theo dõi trạng thái thanh toán
- **Refund Processing**: Xử lý hoàn tiền
- **Payment Reconciliation**: Đối soát thanh toán

### 2.10. Shipping Integration

Tích hợp với các dịch vụ vận chuyển cho phép NextFlow CRM-AI quản lý vận chuyển.

- **Shipping Rate Calculation**: Tính toán phí vận chuyển
- **Shipping Label Generation**: Tạo nhãn vận chuyển
- **Shipment Tracking**: Theo dõi lô hàng
- **Delivery Status**: Cập nhật trạng thái giao hàng
- **Return Processing**: Xử lý trả hàng

### 2.11. AI Integration

Tích hợp với các dịch vụ AI cho phép NextFlow CRM-AI sử dụng các tính năng AI.

- **NLP Integration**: Tích hợp với dịch vụ xử lý ngôn ngữ tự nhiên
- **Computer Vision Integration**: Tích hợp với dịch vụ thị giác máy tính
- **Machine Learning Integration**: Tích hợp với dịch vụ học máy
- **Chatbot Integration**: Tích hợp với dịch vụ chatbot
- **Recommendation Engine**: Tích hợp với dịch vụ gợi ý

## 3. CÁC BẢNG DỮ LIỆU CHÍNH

### 3.1. API Integration

#### 3.1.1. Bảng api_integration

Bảng `api_integration` lưu trữ thông tin về các tích hợp API.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| name | VARCHAR(255) | Tên tích hợp |
| description | TEXT | Mô tả |
| type | ENUM | Loại API (rest, graphql, soap) |
| direction | ENUM | Hướng (inbound, outbound, bidirectional) |
| base_url | VARCHAR(255) | URL cơ sở |
| auth_type | ENUM | Loại xác thực (api_key, oauth, jwt, basic, none) |
| auth_config | JSONB | Cấu hình xác thực |
| headers | JSONB | Headers mặc định |
| rate_limit | INTEGER | Giới hạn số lượng requests |
| timeout | INTEGER | Thời gian timeout (ms) |
| retry_config | JSONB | Cấu hình retry |
| status | ENUM | Trạng thái (active, inactive, testing) |
| is_system | BOOLEAN | Là tích hợp hệ thống hay không |
| created_by | UUID | Người tạo |
| updated_by | UUID | Người cập nhật |
| created_at | TIMESTAMP | Thời gian tạo |
| updated_at | TIMESTAMP | Thời gian cập nhật |
| deleted_at | TIMESTAMP | Thời gian xóa (soft delete) |

#### 3.1.2. Bảng api_endpoint

Bảng `api_endpoint` lưu trữ thông tin về các endpoint API.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| integration_id | UUID | ID của tích hợp API |
| name | VARCHAR(255) | Tên endpoint |
| description | TEXT | Mô tả |
| path | VARCHAR(255) | Đường dẫn endpoint |
| method | ENUM | Phương thức HTTP (GET, POST, PUT, PATCH, DELETE) |
| request_schema | JSONB | Schema của request |
| response_schema | JSONB | Schema của response |
| headers | JSONB | Headers riêng cho endpoint |
| params | JSONB | Parameters |
| timeout | INTEGER | Thời gian timeout (ms) |
| retry_config | JSONB | Cấu hình retry |
| rate_limit | INTEGER | Giới hạn số lượng requests |
| cache_config | JSONB | Cấu hình cache |
| transform_config | JSONB | Cấu hình transform dữ liệu |
| status | ENUM | Trạng thái (active, inactive, testing) |
| created_by | UUID | Người tạo |
| updated_by | UUID | Người cập nhật |
| created_at | TIMESTAMP | Thời gian tạo |
| updated_at | TIMESTAMP | Thời gian cập nhật |
| deleted_at | TIMESTAMP | Thời gian xóa (soft delete) |

#### 3.1.3. Bảng api_log

Bảng `api_log` lưu trữ log của các API calls.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| integration_id | UUID | ID của tích hợp API |
| endpoint_id | UUID | ID của endpoint API |
| direction | ENUM | Hướng (inbound, outbound) |
| request_url | TEXT | URL của request |
| request_method | VARCHAR(10) | Phương thức HTTP |
| request_headers | JSONB | Headers của request |
| request_body | JSONB | Body của request |
| response_status | INTEGER | Status code của response |
| response_headers | JSONB | Headers của response |
| response_body | JSONB | Body của response |
| error | TEXT | Lỗi (nếu có) |
| duration | INTEGER | Thời gian xử lý (ms) |
| ip_address | VARCHAR(50) | Địa chỉ IP |
| user_agent | VARCHAR(255) | User agent |
| created_at | TIMESTAMP | Thời gian tạo |

### 3.2. Webhook Integration

#### 3.2.1. Bảng webhook_integration

Bảng `webhook_integration` lưu trữ thông tin về các tích hợp webhook.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| name | VARCHAR(255) | Tên tích hợp |
| description | TEXT | Mô tả |
| direction | ENUM | Hướng (inbound, outbound) |
| url | VARCHAR(255) | URL webhook |
| events | JSONB | Các sự kiện |
| headers | JSONB | Headers |
| auth_type | ENUM | Loại xác thực (none, basic, hmac, token) |
| auth_config | JSONB | Cấu hình xác thực |
| secret | VARCHAR(255) | Secret key |
| payload_format | ENUM | Định dạng payload (json, xml, form) |
| retry_config | JSONB | Cấu hình retry |
| status | ENUM | Trạng thái (active, inactive, testing) |
| created_by | UUID | Người tạo |
| updated_by | UUID | Người cập nhật |
| created_at | TIMESTAMP | Thời gian tạo |
| updated_at | TIMESTAMP | Thời gian cập nhật |
| deleted_at | TIMESTAMP | Thời gian xóa (soft delete) |

#### 3.2.2. Bảng webhook_log

Bảng `webhook_log` lưu trữ log của các webhook.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| integration_id | UUID | ID của tích hợp webhook |
| direction | ENUM | Hướng (inbound, outbound) |
| event | VARCHAR(255) | Sự kiện |
| request_url | TEXT | URL của request |
| request_headers | JSONB | Headers của request |
| request_body | JSONB | Body của request |
| response_status | INTEGER | Status code của response |
| response_headers | JSONB | Headers của response |
| response_body | JSONB | Body của response |
| error | TEXT | Lỗi (nếu có) |
| duration | INTEGER | Thời gian xử lý (ms) |
| ip_address | VARCHAR(50) | Địa chỉ IP |
| retry_count | INTEGER | Số lần thử lại |
| status | ENUM | Trạng thái (success, failed, retrying) |
| created_at | TIMESTAMP | Thời gian tạo |

### 3.3. Database Integration

#### 3.3.1. Bảng database_integration

Bảng `database_integration` lưu trữ thông tin về các tích hợp database.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| name | VARCHAR(255) | Tên tích hợp |
| description | TEXT | Mô tả |
| type | ENUM | Loại database (mysql, postgresql, sqlserver, mongodb, oracle) |
| host | VARCHAR(255) | Host |
| port | INTEGER | Port |
| database | VARCHAR(255) | Tên database |
| username | VARCHAR(255) | Tên đăng nhập |
| password | VARCHAR(255) | Mật khẩu (được mã hóa) |
| ssl | BOOLEAN | Sử dụng SSL hay không |
| ssl_config | JSONB | Cấu hình SSL |
| connection_pool | JSONB | Cấu hình connection pool |
| schema_mapping | JSONB | Mapping schema |
| sync_config | JSONB | Cấu hình đồng bộ |
| status | ENUM | Trạng thái (active, inactive, testing) |
| created_by | UUID | Người tạo |
| updated_by | UUID | Người cập nhật |
| created_at | TIMESTAMP | Thời gian tạo |
| updated_at | TIMESTAMP | Thời gian cập nhật |
| deleted_at | TIMESTAMP | Thời gian xóa (soft delete) |

#### 3.3.2. Bảng database_query

Bảng `database_query` lưu trữ thông tin về các truy vấn database.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| integration_id | UUID | ID của tích hợp database |
| name | VARCHAR(255) | Tên truy vấn |
| description | TEXT | Mô tả |
| query | TEXT | Truy vấn SQL/NoSQL |
| params | JSONB | Parameters |
| result_mapping | JSONB | Mapping kết quả |
| cache_ttl | INTEGER | Thời gian cache (giây) |
| timeout | INTEGER | Thời gian timeout (ms) |
| is_read_only | BOOLEAN | Chỉ đọc hay không |
| status | ENUM | Trạng thái (active, inactive, testing) |
| created_by | UUID | Người tạo |
| updated_by | UUID | Người cập nhật |
| created_at | TIMESTAMP | Thời gian tạo |
| updated_at | TIMESTAMP | Thời gian cập nhật |
| deleted_at | TIMESTAMP | Thời gian xóa (soft delete) |

#### 3.3.3. Bảng database_sync

Bảng `database_sync` lưu trữ thông tin về các đồng bộ database.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| integration_id | UUID | ID của tích hợp database |
| name | VARCHAR(255) | Tên đồng bộ |
| description | TEXT | Mô tả |
| source_entity | VARCHAR(255) | Entity nguồn |
| target_entity | VARCHAR(255) | Entity đích |
| mapping | JSONB | Mapping dữ liệu |
| filter | JSONB | Điều kiện lọc |
| sync_type | ENUM | Loại đồng bộ (one_way, two_way) |
| sync_schedule | JSONB | Lịch đồng bộ |
| conflict_resolution | JSONB | Cách giải quyết xung đột |
| batch_size | INTEGER | Kích thước batch |
| status | ENUM | Trạng thái (active, inactive, testing) |
| last_sync_time | TIMESTAMP | Thời gian đồng bộ cuối cùng |
| created_by | UUID | Người tạo |
| updated_by | UUID | Người cập nhật |
| created_at | TIMESTAMP | Thời gian tạo |
| updated_at | TIMESTAMP | Thời gian cập nhật |
| deleted_at | TIMESTAMP | Thời gian xóa (soft delete) |

### 3.4. Marketplace Integration

#### 3.4.1. Bảng marketplace_integration

Bảng `marketplace_integration` lưu trữ thông tin về các tích hợp marketplace.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| name | VARCHAR(255) | Tên tích hợp |
| description | TEXT | Mô tả |
| type | ENUM | Loại marketplace (shopee, lazada, tiktok, woocommerce, magento) |
| credentials | JSONB | Thông tin xác thực |
| settings | JSONB | Cài đặt |
| sync_config | JSONB | Cấu hình đồng bộ |
| webhook_url | VARCHAR(255) | URL webhook |
| status | ENUM | Trạng thái (active, inactive, testing) |
| created_by | UUID | Người tạo |
| updated_by | UUID | Người cập nhật |
| created_at | TIMESTAMP | Thời gian tạo |
| updated_at | TIMESTAMP | Thời gian cập nhật |
| deleted_at | TIMESTAMP | Thời gian xóa (soft delete) |

#### 3.4.2. Bảng marketplace_product

Bảng `marketplace_product` lưu trữ thông tin về các sản phẩm trên marketplace.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| integration_id | UUID | ID của tích hợp marketplace |
| product_id | UUID | ID của sản phẩm trong NextFlow CRM-AI |
| marketplace_id | VARCHAR(255) | ID của sản phẩm trên marketplace |
| name | VARCHAR(255) | Tên sản phẩm |
| description | TEXT | Mô tả |
| price | DECIMAL | Giá |
| sale_price | DECIMAL | Giá khuyến mãi |
| currency | VARCHAR(10) | Đơn vị tiền tệ |
| stock | INTEGER | Tồn kho |
| sku | VARCHAR(255) | SKU |
| status | ENUM | Trạng thái (active, inactive, pending) |
| attributes | JSONB | Thuộc tính |
| images | JSONB | Hình ảnh |
| categories | JSONB | Danh mục |
| last_sync_time | TIMESTAMP | Thời gian đồng bộ cuối cùng |
| created_at | TIMESTAMP | Thời gian tạo |
| updated_at | TIMESTAMP | Thời gian cập nhật |
| deleted_at | TIMESTAMP | Thời gian xóa (soft delete) |

#### 3.4.3. Bảng marketplace_order

Bảng `marketplace_order` lưu trữ thông tin về các đơn hàng từ marketplace.

| Tên trường | Kiểu dữ liệu | Mô tả |
|------------|--------------|-------|
| id | UUID | Khóa chính |
| tenant_id | UUID | ID của tenant |
| integration_id | UUID | ID của tích hợp marketplace |
| order_id | UUID | ID của đơn hàng trong NextFlow CRM-AI |
| marketplace_id | VARCHAR(255) | ID của đơn hàng trên marketplace |
| customer_name | VARCHAR(255) | Tên khách hàng |
| customer_email | VARCHAR(255) | Email khách hàng |
| customer_phone | VARCHAR(50) | Số điện thoại khách hàng |
| shipping_address | JSONB | Địa chỉ giao hàng |
| billing_address | JSONB | Địa chỉ thanh toán |
| items | JSONB | Các mục trong đơn hàng |
| total | DECIMAL | Tổng tiền |
| currency | VARCHAR(10) | Đơn vị tiền tệ |
| status | ENUM | Trạng thái đơn hàng |
| payment_method | VARCHAR(255) | Phương thức thanh toán |
| payment_status | ENUM | Trạng thái thanh toán |
| shipping_method | VARCHAR(255) | Phương thức vận chuyển |
| shipping_status | ENUM | Trạng thái vận chuyển |
| tracking_number | VARCHAR(255) | Số tracking |
| notes | TEXT | Ghi chú |
| marketplace_data | JSONB | Dữ liệu gốc từ marketplace |
| last_sync_time | TIMESTAMP | Thời gian đồng bộ cuối cùng |
| created_at | TIMESTAMP | Thời gian tạo |
| updated_at | TIMESTAMP | Thời gian cập nhật |
| deleted_at | TIMESTAMP | Thời gian xóa (soft delete) |

## 4. MULTI-TENANT TRONG SCHEMA TÍCH HỢP

### 4.1. Tenant Isolation

Schema tích hợp được thiết kế để hỗ trợ kiến trúc multi-tenant:

- Mỗi bảng trong schema tích hợp có cột tenant_id để phân biệt dữ liệu giữa các tenant
- Truy vấn luôn bao gồm điều kiện tenant_id để đảm bảo cách ly dữ liệu
- Mỗi tenant có thể có cấu hình tích hợp riêng

### 4.2. Shared Integration

Một số tích hợp có thể được chia sẻ giữa các tenant:

- **System Integration**: Tích hợp hệ thống được chia sẻ giữa các tenant
- **Marketplace Integration**: Một số cấu hình marketplace có thể được chia sẻ
- **Payment Gateway Integration**: Một số cấu hình cổng thanh toán có thể được chia sẻ

### 4.3. Tenant-specific Integration

Hầu hết các tích hợp là riêng biệt cho từng tenant:

- **API Integration**: Mỗi tenant có thể có cấu hình API riêng
- **Webhook Integration**: Mỗi tenant có thể có cấu hình webhook riêng
- **Database Integration**: Mỗi tenant có thể có cấu hình database riêng
- **Marketplace Account**: Mỗi tenant có thể có tài khoản marketplace riêng

### 4.4. Cross-tenant Integration

Trong một số trường hợp, cần tích hợp dữ liệu giữa các tenant:

- **Data Sharing**: Chia sẻ dữ liệu giữa các tenant
- **Cross-tenant Workflow**: Quy trình làm việc xuyên tenant
- **Multi-tenant Reporting**: Báo cáo trên nhiều tenant

## 5. TỔNG KẾT

Schema tích hợp là phần quan trọng của NextFlow CRM-AI, cho phép kết nối và tương tác với các hệ thống bên ngoài. Schema được thiết kế để hỗ trợ nhiều loại tích hợp khác nhau, từ API, webhook, database đến marketplace và các dịch vụ khác.

Schema tích hợp được thiết kế để hỗ trợ kiến trúc multi-tenant, đảm bảo cách ly dữ liệu giữa các tenant, đồng thời vẫn cho phép chia sẻ một số tích hợp khi cần thiết.

Để hiểu rõ hơn về từng loại tích hợp, vui lòng tham khảo các tài liệu chi tiết:

- [API Integration](./api-integration.md)
- [Webhook Integration](./webhook-integration.md)
- [Database Integration](./database-integration.md)
- [Marketplace Integration](./marketplace-integration.md)
- [File Storage Integration](./file-storage-integration.md)
- [Email Integration](./email-integration.md)
- [SMS Integration](./sms-integration.md)
- [Social Media Integration](./social-media-integration.md)
- [Payment Gateway Integration](./payment-gateway-integration.md)
- [Shipping Integration](./shipping-integration.md)
- [AI Integration](./ai-integration.md)
