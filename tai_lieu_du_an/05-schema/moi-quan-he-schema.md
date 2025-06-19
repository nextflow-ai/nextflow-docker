# MỐI QUAN HỆ GIỮA CÁC SCHEMA NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Tổng quan kiến trúc dữ liệu](#2-tổng-quan-kiến-trúc-dữ-liệu)
3. [Mối quan hệ schema hệ thống](#3-mối-quan-hệ-schema-hệ-thống)
4. [Mối quan hệ schema tính năng](#4-mối-quan-hệ-schema-tính-năng)
5. [Mối quan hệ schema tích hợp](#5-mối-quan-hệ-schema-tích-hợp)
6. [Mối quan hệ schema multi-tenant](#6-mối-quan-hệ-schema-multi-tenant)
7. [Quan hệ chéo giữa các schema](#7-quan-hệ-chéo-giữa-các-schema)
8. [Kết luận](#8-kết-luận)
9. [Tài liệu tham khảo](#9-tài-liệu-tham-khảo)

## 1. GIỚI THIỆU

Tài liệu này mô tả chi tiết về mối quan hệ giữa các schema trong hệ thống NextFlow CRM. Hiểu rõ mối quan hệ giữa các schema là rất quan trọng để thiết kế, phát triển và bảo trì hệ thống NextFlow CRM một cách hiệu quả.

### 1.1. Mục đích

- Cung cấp cái nhìn tổng quan về cấu trúc dữ liệu của hệ thống
- Mô tả mối quan hệ giữa các bảng và schema
- Hỗ trợ nhà phát triển hiểu rõ cách dữ liệu được tổ chức và liên kết
- Làm cơ sở cho việc thiết kế truy vấn và tối ưu hóa hiệu suất

### 1.2. Phạm vi

Tài liệu này bao gồm mối quan hệ giữa các schema chính trong hệ thống NextFlow CRM:

- Schema hệ thống (users, organizations, roles, permissions)
- Schema tính năng (customers, products, orders, marketing)
- Schema tích hợp (integrations, webhooks, api)
- Schema multi-tenant

## 2. TỔNG QUAN KIẾN TRÚC DỮ LIỆU

### 2.1. Mô hình dữ liệu

NextFlow CRM sử dụng mô hình dữ liệu quan hệ với PostgreSQL làm hệ quản trị cơ sở dữ liệu chính. Dữ liệu được tổ chức thành các schema và bảng có mối quan hệ với nhau.

### 2.2. Nguyên tắc thiết kế

- **Normalization**: Dữ liệu được chuẩn hóa để giảm thiểu dư thừa
- **Referential Integrity**: Sử dụng khóa ngoại để đảm bảo tính toàn vẹn dữ liệu
- **Multi-tenant**: Thiết kế hỗ trợ nhiều tenant trên cùng một hệ thống
- **Scalability**: Thiết kế cho phép mở rộng theo chiều ngang
- **Performance**: Tối ưu hóa cho hiệu suất truy vấn

### 2.3. Phân loại schema

- **Common Schema**: Chứa các bảng dùng chung cho tất cả các tenant
- **Tenant Schema**: Chứa các bảng riêng cho từng tenant
- **System Schema**: Chứa các bảng hệ thống
- **Feature Schema**: Chứa các bảng tính năng
- **Integration Schema**: Chứa các bảng tích hợp

## 3. MỐI QUAN HỆ SCHEMA HỆ THỐNG

### 3.1. User và Authentication

```
users
  ↑ 1:1
user_profiles
  ↑ 1:1
user_settings
  ↑ 1:N
authentication_methods
  ↑ 1:N
sessions
  ↑ 1:N
password_reset_tokens
  ↑ 1:N
verification_tokens
  ↑ 1:N
user_activities
```

#### 3.1.1. Mô tả mối quan hệ

- **users → user_profiles**: Mỗi user có một profile
- **users → user_settings**: Mỗi user có một settings
- **users → authentication_methods**: Mỗi user có thể có nhiều phương thức xác thực
- **users → sessions**: Mỗi user có thể có nhiều phiên đăng nhập
- **users → password_reset_tokens**: Mỗi user có thể có nhiều token đặt lại mật khẩu
- **users → verification_tokens**: Mỗi user có thể có nhiều token xác minh
- **users → user_activities**: Mỗi user có thể có nhiều hoạt động

#### 3.1.2. Ý nghĩa nghiệp vụ

- Mô hình này cho phép quản lý thông tin người dùng một cách linh hoạt
- Hỗ trợ đăng nhập đa phương thức (email/password, social login, v.v.)
- Theo dõi hoạt động người dùng để phân tích và bảo mật
- Quản lý phiên đăng nhập và token an toàn

### 3.2. Organization và Team

```
organizations
  ↑ 1:N
organization_settings
  ↑ 1:N
teams
  ↑ 1:N
team_members
  ↑ 1:N
team_settings
```

#### 3.2.1. Mô tả mối quan hệ

- **organizations → organization_settings**: Mỗi tổ chức có một cài đặt
- **organizations → teams**: Mỗi tổ chức có thể có nhiều team
- **teams → team_members**: Mỗi team có thể có nhiều thành viên
- **teams → team_settings**: Mỗi team có một cài đặt
- **users → team_members**: Mỗi user có thể là thành viên của nhiều team

#### 3.2.2. Ý nghĩa nghiệp vụ

- Hỗ trợ cấu trúc tổ chức phân cấp
- Cho phép phân nhóm người dùng theo team
- Cài đặt có thể được tùy chỉnh ở cấp tổ chức và team
- Một người dùng có thể thuộc nhiều team khác nhau

### 3.3. Role và Permission

```
roles
  ↑ 1:N
role_permissions
  ↑ N:1
permissions
  ↑ 1:N
user_roles
  ↑ N:1
users
```

#### 3.3.1. Mô tả mối quan hệ

- **roles → role_permissions**: Mỗi vai trò có thể có nhiều quyền
- **permissions → role_permissions**: Mỗi quyền có thể thuộc nhiều vai trò
- **users → user_roles**: Mỗi người dùng có thể có nhiều vai trò
- **roles → user_roles**: Mỗi vai trò có thể được gán cho nhiều người dùng

#### 3.3.2. Ý nghĩa nghiệp vụ

- Hệ thống phân quyền linh hoạt dựa trên vai trò (RBAC)
- Một người dùng có thể có nhiều vai trò
- Vai trò có thể được tùy chỉnh với các quyền khác nhau
- Hỗ trợ phân quyền chi tiết đến cấp hành động và đối tượng

### 3.4. Subscription và Billing

```
organizations
  ↑ 1:N
subscriptions
  ↑ 1:N
subscription_items
  ↑ 1:N
invoices
  ↑ 1:N
invoice_items
  ↑ 1:N
payments
```

#### 3.4.1. Mô tả mối quan hệ

- **organizations → subscriptions**: Mỗi tổ chức có thể có nhiều gói đăng ký
- **subscriptions → subscription_items**: Mỗi gói đăng ký có thể có nhiều mục
- **organizations → invoices**: Mỗi tổ chức có thể có nhiều hóa đơn
- **invoices → invoice_items**: Mỗi hóa đơn có thể có nhiều mục
- **invoices → payments**: Mỗi hóa đơn có thể có nhiều thanh toán

#### 3.4.2. Ý nghĩa nghiệp vụ

- Hỗ trợ mô hình kinh doanh subscription-based
- Quản lý gói dịch vụ và tính năng theo từng gói
- Theo dõi hóa đơn và thanh toán
- Hỗ trợ nhiều phương thức thanh toán

## 4. MỐI QUAN HỆ SCHEMA TÍNH NĂNG

### 4.1. Customer Management

```
customers
  ↑ 1:N
customer_contacts
  ↑ 1:N
customer_activities
  ↑ 1:N
customer_notes
  ↑ 1:N
customer_documents
  ↑ 1:N
customer_tags
```

#### 4.1.1. Mô tả mối quan hệ

- **customers → customer_contacts**: Mỗi khách hàng có thể có nhiều liên hệ
- **customers → customer_activities**: Mỗi khách hàng có thể có nhiều hoạt động
- **customers → customer_notes**: Mỗi khách hàng có thể có nhiều ghi chú
- **customers → customer_documents**: Mỗi khách hàng có thể có nhiều tài liệu
- **customers → customer_tags**: Mỗi khách hàng có thể có nhiều tag

#### 4.1.2. Ý nghĩa nghiệp vụ

- Quản lý thông tin khách hàng toàn diện
- Theo dõi lịch sử tương tác với khách hàng
- Lưu trữ tài liệu và ghi chú liên quan đến khách hàng
- Phân loại khách hàng bằng tag

### 4.2. Sales Management

```
leads
  ↑ 1:1
opportunities
  ↑ 1:N
opportunity_stages
  ↑ 1:N
quotes
  ↑ 1:N
quote_items
  ↑ 1:1
orders
  ↑ 1:N
order_items
  ↑ N:1
products
```

#### 4.2.1. Mô tả mối quan hệ

- **leads → opportunities**: Mỗi lead có thể chuyển thành một cơ hội
- **opportunities → opportunity_stages**: Mỗi cơ hội thuộc một giai đoạn
- **opportunities → quotes**: Mỗi cơ hội có thể có nhiều báo giá
- **quotes → quote_items**: Mỗi báo giá có thể có nhiều mục
- **quotes → orders**: Mỗi báo giá có thể chuyển thành một đơn hàng
- **orders → order_items**: Mỗi đơn hàng có thể có nhiều mục
- **products → quote_items**: Mỗi sản phẩm có thể xuất hiện trong nhiều mục báo giá
- **products → order_items**: Mỗi sản phẩm có thể xuất hiện trong nhiều mục đơn hàng

#### 4.2.2. Ý nghĩa nghiệp vụ

- Theo dõi quy trình bán hàng từ lead đến đơn hàng
- Quản lý cơ hội bán hàng theo giai đoạn
- Tạo báo giá và chuyển đổi thành đơn hàng
- Liên kết sản phẩm với báo giá và đơn hàng

### 4.3. Marketing Management

```
campaigns
  ↑ 1:N
campaign_members
  ↑ N:1
leads
  ↑ 1:N
email_templates
  ↑ 1:N
email_campaigns
  ↑ 1:N
email_sends
  ↑ 1:N
email_events
```

#### 4.3.1. Mô tả mối quan hệ

- **campaigns → campaign_members**: Mỗi chiến dịch có thể có nhiều thành viên
- **leads → campaign_members**: Mỗi lead có thể tham gia nhiều chiến dịch
- **email_templates → email_campaigns**: Mỗi mẫu email có thể được sử dụng trong nhiều chiến dịch email
- **email_campaigns → email_sends**: Mỗi chiến dịch email có thể có nhiều lần gửi
- **email_sends → email_events**: Mỗi lần gửi email có thể có nhiều sự kiện (mở, nhấp, v.v.)

#### 4.3.2. Ý nghĩa nghiệp vụ

- Quản lý chiến dịch marketing
- Theo dõi lead từ các chiến dịch
- Tạo và quản lý chiến dịch email
- Phân tích hiệu quả chiến dịch qua các sự kiện email

### 4.4. Product Management

```
products
  ↑ 1:N
product_variants
  ↑ N:1
product_categories
  ↑ 1:N
product_attributes
  ↑ 1:N
product_prices
  ↑ 1:N
product_inventories
```

#### 4.4.1. Mô tả mối quan hệ

- **products → product_variants**: Mỗi sản phẩm có thể có nhiều biến thể
- **product_categories → products**: Mỗi danh mục có thể có nhiều sản phẩm
- **products → product_attributes**: Mỗi sản phẩm có thể có nhiều thuộc tính
- **products → product_prices**: Mỗi sản phẩm có thể có nhiều giá (theo thị trường, khách hàng)
- **products → product_inventories**: Mỗi sản phẩm có thể có nhiều kho

#### 4.4.2. Ý nghĩa nghiệp vụ

- Quản lý sản phẩm với nhiều biến thể
- Phân loại sản phẩm theo danh mục
- Định giá linh hoạt theo thị trường, khách hàng
- Quản lý tồn kho theo nhiều địa điểm

## 5. MỐI QUAN HỆ SCHEMA TÍCH HỢP

### 5.1. Marketplace Integration

```
marketplace_accounts
  ↑ 1:N
marketplace_products
  ↑ N:1
products
  ↑ 1:N
marketplace_orders
  ↑ N:1
orders
  ↑ 1:N
marketplace_customers
  ↑ N:1
customers
```

#### 5.1.1. Mô tả mối quan hệ

- **marketplace_accounts → marketplace_products**: Mỗi tài khoản marketplace có thể có nhiều sản phẩm
- **products → marketplace_products**: Mỗi sản phẩm có thể được đăng trên nhiều marketplace
- **marketplace_accounts → marketplace_orders**: Mỗi tài khoản marketplace có thể có nhiều đơn hàng
- **orders → marketplace_orders**: Mỗi đơn hàng có thể liên kết với một đơn hàng marketplace
- **marketplace_accounts → marketplace_customers**: Mỗi tài khoản marketplace có thể có nhiều khách hàng
- **customers → marketplace_customers**: Mỗi khách hàng có thể liên kết với một khách hàng marketplace

#### 5.1.2. Ý nghĩa nghiệp vụ

- Tích hợp với nhiều marketplace (Shopee, Lazada, TikTok Shop)
- Đồng bộ sản phẩm giữa CRM và marketplace
- Quản lý đơn hàng từ nhiều marketplace
- Liên kết khách hàng giữa CRM và marketplace

### 5.2. AI Integration

```
ai_model
  ↑ 1:N
ai_provider
  ↑ 1:N
ai_credential
  ↑ 1:N
ai_workflow
  ↑ 1:N
ai_node
  ↑ 1:N
ai_connection
  ↑ 1:N
ai_execution
  ↑ 1:N
ai_execution_data
  ↑ 1:N
ai_chatbot
  ↑ 1:N
ai_chatflow
  ↑ 1:N
ai_conversation
  ↑ 1:N
ai_message
  ↑ 1:N
ai_knowledge_base
  ↑ 1:N
ai_document
  ↑ 1:N
ai_embedding
  ↑ 1:N
ai_schedule
  ↑ 1:N
ai_webhook
  ↑ 1:N
ai_log
```

#### 5.2.1. Mô tả mối quan hệ

- **ai_provider → ai_model**: Mỗi nhà cung cấp có thể có nhiều mô hình AI
- **ai_provider → ai_credential**: Mỗi nhà cung cấp có thể có nhiều thông tin xác thực
- **ai_workflow → ai_node**: Mỗi workflow có thể có nhiều node
- **ai_workflow → ai_connection**: Mỗi workflow có thể có nhiều kết nối giữa các node
- **ai_workflow → ai_execution**: Mỗi workflow có thể có nhiều lần thực thi
- **ai_execution → ai_execution_data**: Mỗi lần thực thi có thể có nhiều dữ liệu thực thi
- **ai_chatbot → ai_chatflow**: Mỗi chatbot có thể có nhiều luồng hội thoại
- **ai_chatbot → ai_conversation**: Mỗi chatbot có thể có nhiều cuộc hội thoại
- **ai_conversation → ai_message**: Mỗi cuộc hội thoại có thể có nhiều tin nhắn
- **ai_knowledge_base → ai_document**: Mỗi knowledge base có thể có nhiều tài liệu
- **ai_document → ai_embedding**: Mỗi tài liệu có thể có nhiều embedding
- **ai_workflow → ai_schedule**: Mỗi workflow có thể có nhiều lịch trình
- **ai_workflow → ai_webhook**: Mỗi workflow có thể có nhiều webhook
- **ai_model → ai_node**: Mỗi mô hình có thể được sử dụng trong nhiều node
- **ai_credential → ai_node**: Mỗi thông tin xác thực có thể được sử dụng trong nhiều node

#### 5.2.2. Ý nghĩa nghiệp vụ

- Tích hợp với n8n và Flowise để tự động hóa quy trình
- Quản lý và theo dõi thực thi workflow
- Quản lý các mô hình AI và nhà cung cấp
- Quản lý chatbot đa kênh và hội thoại
- Quản lý cơ sở kiến thức và embedding
- Lên lịch và tự động hóa workflow
- Ghi log chi tiết để phân tích và debug

### 5.3. API và Webhook

```
api_keys
  ↑ 1:N
api_usages
  ↑ 1:N
webhooks
  ↑ 1:N
webhook_events
  ↑ 1:N
webhook_deliveries
  ↑ 1:N
webhook_delivery_attempts
```

#### 5.3.1. Mô tả mối quan hệ

- **api_keys → api_usages**: Mỗi API key có thể có nhiều lần sử dụng
- **webhooks → webhook_events**: Mỗi webhook đăng ký nhiều loại sự kiện
- **webhooks → webhook_deliveries**: Mỗi webhook có thể có nhiều lần gửi
- **webhook_deliveries → webhook_delivery_attempts**: Mỗi lần gửi webhook có thể có nhiều lần thử

#### 5.3.2. Ý nghĩa nghiệp vụ

- Quản lý API key và theo dõi sử dụng
- Đăng ký webhook cho các sự kiện khác nhau
- Theo dõi việc gửi webhook và thử lại khi thất bại
- Đảm bảo tính tin cậy của webhook

## 6. MỐI QUAN HỆ SCHEMA MULTI-TENANT

### 6.1. Tenant Management

```
tenants
  ↑ 1:N
tenant_databases
  ↑ 1:N
tenant_settings
  ↑ 1:N
tenant_features
  ↑ 1:N
tenant_limits
```

#### 6.1.1. Mô tả mối quan hệ

- **tenants → tenant_databases**: Mỗi tenant có thể có nhiều database
- **tenants → tenant_settings**: Mỗi tenant có một cài đặt
- **tenants → tenant_features**: Mỗi tenant có thể có nhiều tính năng được kích hoạt
- **tenants → tenant_limits**: Mỗi tenant có một giới hạn sử dụng

#### 6.1.2. Ý nghĩa nghiệp vụ

- Quản lý nhiều tenant trên cùng một hệ thống
- Cấu hình database riêng cho từng tenant
- Tùy chỉnh cài đặt và tính năng theo tenant
- Giới hạn sử dụng tài nguyên theo gói dịch vụ

### 6.2. Tenant Isolation

```
tenants
  ↑ 1:N
organizations
  ↑ 1:N
users
  ↑ 1:N
tenant_admins
```

#### 6.2.1. Mô tả mối quan hệ

- **tenants → organizations**: Mỗi tenant có thể có nhiều tổ chức
- **organizations → users**: Mỗi tổ chức có thể có nhiều người dùng
- **tenants → tenant_admins**: Mỗi tenant có thể có nhiều quản trị viên

#### 6.2.2. Ý nghĩa nghiệp vụ

- Cách ly dữ liệu giữa các tenant
- Phân cấp quản lý: tenant > organization > user
- Quản trị viên tenant có quyền quản lý tenant
- Đảm bảo bảo mật và riêng tư dữ liệu

## 7. QUAN HỆ CHÉO GIỮA CÁC SCHEMA

### 7.1. User và Customer

```
users
  ↑ 1:N
user_customers
  ↑ N:1
customers
```

#### 7.1.1. Mô tả mối quan hệ

- **users → user_customers**: Mỗi người dùng có thể được gán cho nhiều khách hàng
- **customers → user_customers**: Mỗi khách hàng có thể được gán cho nhiều người dùng

#### 7.1.2. Ý nghĩa nghiệp vụ

- Phân công người dùng phụ trách khách hàng
- Hỗ trợ mô hình quản lý khách hàng theo team
- Theo dõi hiệu suất của người dùng với khách hàng

### 7.2. User và Sales

```
users
  ↑ 1:N
opportunities
  ↑ 1:N
quotes
  ↑ 1:N
orders
```

#### 7.2.1. Mô tả mối quan hệ

- **users → opportunities**: Mỗi người dùng có thể sở hữu nhiều cơ hội
- **users → quotes**: Mỗi người dùng có thể tạo nhiều báo giá
- **users → orders**: Mỗi người dùng có thể xử lý nhiều đơn hàng

#### 7.2.2. Ý nghĩa nghiệp vụ

- Theo dõi hiệu suất bán hàng của người dùng
- Phân công trách nhiệm cho cơ hội, báo giá, đơn hàng
- Tính toán hoa hồng dựa trên doanh số

### 7.3. Organization và Integration

```
organizations
  ↑ 1:N
marketplace_accounts
  ↑ 1:N
ai_workflows
  ↑ 1:N
webhooks
```

#### 7.3.1. Mô tả mối quan hệ

- **organizations → marketplace_accounts**: Mỗi tổ chức có thể có nhiều tài khoản marketplace
- **organizations → ai_workflows**: Mỗi tổ chức có thể có nhiều workflow AI
- **organizations → webhooks**: Mỗi tổ chức có thể có nhiều webhook

#### 7.3.2. Ý nghĩa nghiệp vụ

- Quản lý tích hợp theo tổ chức
- Cấu hình workflow AI riêng cho từng tổ chức
- Đảm bảo cách ly dữ liệu tích hợp giữa các tổ chức

## 8. CHIẾN LƯỢC TRUY VẤN VÀ TỐI ƯU HÓA

### 8.1. Indexing Strategy

- **Primary Keys**: Sử dụng UUID cho tất cả các bảng
- **Foreign Keys**: Index tất cả các khóa ngoại
- **Composite Indexes**: Tạo index tổng hợp cho các truy vấn phổ biến
- **Partial Indexes**: Sử dụng cho các truy vấn có điều kiện lọc cụ thể
- **Expression Indexes**: Sử dụng cho các truy vấn có biểu thức phức tạp

### 8.2. Query Optimization

- **Eager Loading**: Sử dụng JOIN để tải dữ liệu liên quan
- **Lazy Loading**: Sử dụng cho dữ liệu ít khi truy cập
- **Pagination**: Giới hạn số lượng bản ghi trả về
- **Caching**: Cache kết quả truy vấn phổ biến
- **Query Hints**: Sử dụng khi cần điều khiển cách thực thi truy vấn

### 8.3. Multi-tenant Query Strategy

- **Schema-based Isolation**: Sử dụng schema riêng cho từng tenant
- **Row-level Security**: Áp dụng RLS cho các bảng dùng chung
- **Tenant Context**: Luôn kiểm tra tenant_id trong mọi truy vấn
- **Connection Pooling**: Sử dụng pool riêng cho từng tenant
- **Sharding**: Phân chia dữ liệu theo tenant khi cần mở rộng

## 9. QUẢN LÝ SCHEMA MIGRATION

### 9.1. Migration Strategy

- **Versioned Migrations**: Mỗi thay đổi schema được đánh version
- **Forward-only**: Chỉ hỗ trợ migration tiến, không hỗ trợ rollback
- **Tenant-aware**: Migration có thể áp dụng cho tất cả hoặc một số tenant
- **Dependency Management**: Quản lý phụ thuộc giữa các migration
- **Testing**: Kiểm thử migration trước khi áp dụng

### 9.2. Migration Tools

- **TypeORM Migrations**: Sử dụng cho schema migration
- **Database Versioning**: Theo dõi phiên bản schema
- **Migration Scripts**: Script tự động hóa quá trình migration
- **Rollback Plans**: Kế hoạch dự phòng khi migration thất bại
- **Monitoring**: Giám sát quá trình migration

## 8. KẾT LUẬN

Mối quan hệ giữa các schema trong NextFlow CRM được thiết kế để đảm bảo tính toàn vẹn dữ liệu, hiệu suất cao và khả năng mở rộng. Việc hiểu rõ các mối quan hệ này là cơ sở để phát triển và bảo trì hệ thống hiệu quả.

### 8.1. Nguyên tắc thiết kế schema

- **Consistency**: Nhất quán trong cách đặt tên và cấu trúc
- **Flexibility**: Linh hoạt để đáp ứng yêu cầu thay đổi
- **Scalability**: Có thể mở rộng khi số lượng tenant và dữ liệu tăng
- **Performance**: Tối ưu hóa cho hiệu suất truy vấn
- **Security**: Đảm bảo cách ly dữ liệu và bảo mật

### 8.2. Thực hành tốt nhất

- **Documentation**: Tài liệu hóa schema và mối quan hệ
- **Versioning**: Quản lý phiên bản schema
- **Testing**: Kiểm thử kỹ lưỡng trước khi thay đổi schema
- **Monitoring**: Giám sát hiệu suất database
- **Backup**: Sao lưu dữ liệu thường xuyên

### 8.3. Phát triển trong tương lai

- **Graph Database**: Tích hợp với graph database cho các mối quan hệ phức tạp
- **Time-series Data**: Hỗ trợ dữ liệu chuỗi thời gian cho phân tích
- **Distributed Database**: Mở rộng sang database phân tán
- **Polyglot Persistence**: Sử dụng nhiều loại database cho các nhu cầu khác nhau
- **AI-driven Schema Optimization**: Tối ưu hóa schema dựa trên AI

### 8.4. Tài liệu liên quan

- [Tổng quan Schema](./tong-quan-schema.md)
- [Schema Hệ thống](./he-thong/tong-quan.md)
- [Schema Tính năng](./tinh-nang/tong-quan.md)
- [Schema Tích hợp](./tich-hop/tong-quan.md)
- [Schema Bảo mật](./bao-mat/security.md)

## 9. TÀI LIỆU THAM KHẢO

### 9.1. Tài liệu NextFlow CRM
- [Kiến trúc Hệ thống](../02-kien-truc/kien-truc-tong-the.md)
- [API Documentation](../06-api/tong-quan-api.md)
- [Triển khai Database](../07-trien-khai/cai-dat.md)

### 9.2. Database Design
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Database Design Patterns](https://martinfowler.com/articles/dblogicaldesign.html)
- [Multi-tenant Architecture](https://docs.microsoft.com/en-us/azure/sql-database/saas-tenancy-app-design-patterns)

### 9.3. Migration và Versioning
- [TypeORM Migrations](https://typeorm.io/migrations)
- [Database Versioning Best Practices](https://www.liquibase.org/best-practices)
- [Schema Evolution Patterns](https://martinfowler.com/articles/evodb.html)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 1.0.0
**Tác giả**: NextFlow Development Team
