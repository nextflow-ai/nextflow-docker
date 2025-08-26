# TỔNG QUAN SCHEMA TÍNH NĂNG

## 1. GIỚI THIỆU

Tài liệu này cung cấp tổng quan về schema tính năng trong NextFlow CRM-AI. Schema tính năng quản lý các tính năng nghiệp vụ của hệ thống, bao gồm khách hàng, sản phẩm, đơn hàng, marketing, bán hàng, hỗ trợ khách hàng, và nhiều tính năng khác.

### 1.1. Mục đích

- Cung cấp cái nhìn tổng quan về cấu trúc schema tính năng
- Mô tả các module chính và mối quan hệ giữa chúng
- Giải thích cách sử dụng schema tính năng trong kiến trúc multi-tenant

### 1.2. Phạm vi

Tài liệu này bao gồm:

- Tổng quan về các module trong schema tính năng
- Mối quan hệ giữa các module
- Cách sử dụng schema tính năng trong kiến trúc multi-tenant

## 2. CÁC MODULE CHÍNH

### 2.1. Khách hàng (Customer)

Module Khách hàng quản lý thông tin khách hàng và các tương tác với khách hàng, bao gồm các bảng chính:

- **customer**: Lưu trữ thông tin khách hàng
- **customer_contact**: Lưu trữ thông tin liên hệ của khách hàng
- **customer_address**: Lưu trữ địa chỉ của khách hàng
- **customer_group**: Lưu trữ nhóm khách hàng
- **customer_segment**: Lưu trữ phân khúc khách hàng
- **customer_note**: Lưu trữ ghi chú về khách hàng
- **customer_activity**: Lưu trữ hoạt động của khách hàng
- **customer_tag**: Lưu trữ tag của khách hàng

Chi tiết về schema Khách hàng có thể được tìm thấy trong tài liệu [Khách hàng](./khach-hang.md).

### 2.2. Sản phẩm (Product)

Module Sản phẩm quản lý thông tin sản phẩm và dịch vụ, bao gồm các bảng chính:

- **product**: Lưu trữ thông tin sản phẩm
- **product_category**: Lưu trữ danh mục sản phẩm
- **product_variant**: Lưu trữ biến thể sản phẩm
- **product_attribute**: Lưu trữ thuộc tính sản phẩm
- **product_option**: Lưu trữ tùy chọn sản phẩm
- **product_price**: Lưu trữ giá sản phẩm
- **product_inventory**: Lưu trữ tồn kho sản phẩm
- **product_image**: Lưu trữ hình ảnh sản phẩm
- **product_review**: Lưu trữ đánh giá sản phẩm
- **product_tag**: Lưu trữ tag của sản phẩm

Chi tiết về schema Sản phẩm có thể được tìm thấy trong tài liệu [Sản phẩm](./san-pham.md).

### 2.3. Đơn hàng (Order)

Module Đơn hàng quản lý thông tin đơn hàng và giao dịch, bao gồm các bảng chính:

- **order**: Lưu trữ thông tin đơn hàng
- **order_item**: Lưu trữ các mục trong đơn hàng
- **order_status**: Lưu trữ trạng thái đơn hàng
- **order_payment**: Lưu trữ thanh toán đơn hàng
- **order_shipment**: Lưu trữ thông tin vận chuyển
- **order_discount**: Lưu trữ giảm giá đơn hàng
- **order_tax**: Lưu trữ thuế đơn hàng
- **order_note**: Lưu trữ ghi chú đơn hàng
- **order_history**: Lưu trữ lịch sử đơn hàng
- **cart**: Lưu trữ giỏ hàng
- **cart_item**: Lưu trữ các mục trong giỏ hàng

Chi tiết về schema Đơn hàng có thể được tìm thấy trong tài liệu [Đơn hàng](./don-hang.md).

### 2.4. Marketing

Module Marketing quản lý các chiến dịch marketing và truyền thông, bao gồm các bảng chính:

- **campaign**: Lưu trữ thông tin chiến dịch
- **campaign_audience**: Lưu trữ đối tượng chiến dịch
- **campaign_content**: Lưu trữ nội dung chiến dịch
- **campaign_schedule**: Lưu trữ lịch trình chiến dịch
- **campaign_metric**: Lưu trữ số liệu chiến dịch
- **email_template**: Lưu trữ mẫu email
- **email_campaign**: Lưu trữ chiến dịch email
- **sms_template**: Lưu trữ mẫu SMS
- **sms_campaign**: Lưu trữ chiến dịch SMS
- **social_post**: Lưu trữ bài đăng mạng xã hội
- **landing_page**: Lưu trữ trang đích
- **form**: Lưu trữ biểu mẫu

Chi tiết về schema Marketing có thể được tìm thấy trong tài liệu [Marketing](./marketing.md).

### 2.5. Bán hàng (Sales)

Module Bán hàng quản lý quy trình bán hàng, bao gồm các bảng chính:

- **lead**: Lưu trữ thông tin lead
- **lead_source**: Lưu trữ nguồn lead
- **lead_status**: Lưu trữ trạng thái lead
- **opportunity**: Lưu trữ thông tin cơ hội
- **opportunity_stage**: Lưu trữ giai đoạn cơ hội
- **opportunity_product**: Lưu trữ sản phẩm trong cơ hội
- **quote**: Lưu trữ thông tin báo giá
- **quote_item**: Lưu trữ các mục trong báo giá
- **sales_activity**: Lưu trữ hoạt động bán hàng
- **sales_pipeline**: Lưu trữ pipeline bán hàng
- **sales_forecast**: Lưu trữ dự báo bán hàng
- **sales_goal**: Lưu trữ mục tiêu bán hàng

Chi tiết về schema Bán hàng có thể được tìm thấy trong tài liệu [Bán hàng](./ban-hang.md).

### 2.6. Hỗ trợ khách hàng (Customer Support)

Module Hỗ trợ khách hàng quản lý ticket và hỗ trợ, bao gồm các bảng chính:

- **ticket**: Lưu trữ thông tin ticket
- **ticket_type**: Lưu trữ loại ticket
- **ticket_priority**: Lưu trữ mức độ ưu tiên ticket
- **ticket_status**: Lưu trữ trạng thái ticket
- **ticket_comment**: Lưu trữ bình luận ticket
- **ticket_attachment**: Lưu trữ tệp đính kèm ticket
- **ticket_assignment**: Lưu trữ phân công ticket
- **ticket_sla**: Lưu trữ SLA ticket
- **knowledge_base**: Lưu trữ cơ sở kiến thức
- **knowledge_article**: Lưu trữ bài viết kiến thức
- **knowledge_category**: Lưu trữ danh mục kiến thức

Chi tiết về schema Hỗ trợ khách hàng có thể được tìm thấy trong tài liệu [Hỗ trợ khách hàng](./ho-tro-khach-hang.md).

### 2.7. Tích hợp đa nền tảng (Multi-platform Integration)

Module Tích hợp đa nền tảng quản lý tích hợp với các nền tảng khác, bao gồm các bảng chính:

- **platform**: Lưu trữ thông tin nền tảng
- **platform_account**: Lưu trữ tài khoản nền tảng
- **platform_product**: Lưu trữ sản phẩm trên nền tảng
- **platform_order**: Lưu trữ đơn hàng từ nền tảng
- **platform_customer**: Lưu trữ khách hàng từ nền tảng
- **platform_sync**: Lưu trữ trạng thái đồng bộ
- **platform_mapping**: Lưu trữ mapping giữa các nền tảng
- **platform_setting**: Lưu trữ cài đặt nền tảng
- **platform_webhook**: Lưu trữ webhook từ nền tảng
- **platform_log**: Lưu trữ log tích hợp

Chi tiết về schema Tích hợp đa nền tảng có thể được tìm thấy trong tài liệu [Tích hợp đa nền tảng](./tich-hop-da-nen-tang.md).

### 2.8. AI Integration

Module AI Integration quản lý tích hợp AI, bao gồm các bảng chính:

- **ai_model**: Lưu trữ thông tin mô hình AI
- **ai_workflow**: Lưu trữ workflow AI
- **ai_node**: Lưu trữ node trong workflow AI
- **ai_connection**: Lưu trữ kết nối giữa các node
- **ai_credential**: Lưu trữ thông tin xác thực AI
- **ai_execution**: Lưu trữ thông tin thực thi AI
- **ai_execution_data**: Lưu trữ dữ liệu thực thi
- **ai_schedule**: Lưu trữ lịch trình thực thi AI
- **ai_webhook**: Lưu trữ webhook AI
- **ai_log**: Lưu trữ log AI

Chi tiết về schema AI Integration có thể được tìm thấy trong tài liệu [AI Integration](./ai-integration.md).

### 2.9. Các module khác

NextFlow CRM-AI còn có nhiều module khác để đáp ứng nhu cầu của các lĩnh vực khác nhau:

- **Nhân sự**: Quản lý nhân viên và tổ chức
- **Tài chính**: Quản lý tài chính và kế toán
- **Dự án**: Quản lý dự án và công việc
- **Tổng đài**: Quản lý tổng đài và cuộc gọi
- **Báo cáo và phân tích**: Quản lý báo cáo và phân tích
- **Quản lý nội dung**: Quản lý nội dung và tài liệu
- **Chatbot và NLP**: Quản lý chatbot và xử lý ngôn ngữ tự nhiên

Chi tiết về các module này có thể được tìm thấy trong các tài liệu tương ứng.

## 3. MỐI QUAN HỆ GIỮA CÁC MODULE

### 3.1. Khách hàng và Bán hàng

- Mỗi lead có thể được chuyển đổi thành khách hàng (customer)
- Mỗi cơ hội (opportunity) liên kết với một khách hàng
- Mỗi báo giá (quote) liên kết với một khách hàng và có thể liên kết với một cơ hội

### 3.2. Sản phẩm và Đơn hàng

- Mỗi đơn hàng (order) có nhiều mục đơn hàng (order_item)
- Mỗi mục đơn hàng liên kết với một sản phẩm (product) hoặc biến thể sản phẩm (product_variant)
- Mỗi báo giá (quote) có nhiều mục báo giá (quote_item) liên kết với sản phẩm

### 3.3. Marketing và Khách hàng

- Mỗi chiến dịch (campaign) nhắm đến nhiều khách hàng thông qua campaign_audience
- Mỗi lead có thể được tạo từ một chiến dịch marketing
- Mỗi form có thể tạo ra lead hoặc khách hàng

### 3.4. Hỗ trợ khách hàng và Khách hàng

- Mỗi ticket liên kết với một khách hàng
- Mỗi ticket có thể liên kết với một đơn hàng
- Mỗi bài viết kiến thức (knowledge_article) có thể được gợi ý cho nhiều ticket

### 3.5. Tích hợp đa nền tảng và các Module khác

- Mỗi sản phẩm có thể được đồng bộ với nhiều nền tảng thông qua platform_product
- Mỗi đơn hàng từ nền tảng (platform_order) được đồng bộ thành đơn hàng trong hệ thống
- Mỗi khách hàng từ nền tảng (platform_customer) được đồng bộ thành khách hàng trong hệ thống

### 3.6. AI Integration và các Module khác

- Mỗi workflow AI (ai_workflow) có thể tương tác với nhiều module khác
- Mỗi thực thi AI (ai_execution) có thể xử lý dữ liệu từ nhiều module
- Mỗi mô hình AI (ai_model) có thể được sử dụng trong nhiều workflow

## 4. MULTI-TENANT TRONG SCHEMA TÍNH NĂNG

### 4.1. Tenant Isolation

Schema tính năng được thiết kế để hỗ trợ kiến trúc multi-tenant:

- Mỗi bảng trong schema tính năng có cột tenant_id để phân biệt dữ liệu giữa các tenant
- Truy vấn luôn bao gồm điều kiện tenant_id để đảm bảo cách ly dữ liệu
- Mỗi tenant có thể có cấu hình riêng cho từng module

### 4.2. Shared Configuration

Một số cấu hình được chia sẻ giữa các tenant:

- **product_category**: Danh mục sản phẩm có thể được chia sẻ giữa các tenant
- **knowledge_category**: Danh mục kiến thức có thể được chia sẻ
- **ticket_type**: Loại ticket có thể được chia sẻ
- **ai_model**: Mô hình AI có thể được chia sẻ

### 4.3. Tenant-specific Data

Hầu hết dữ liệu là riêng biệt cho từng tenant:

- **customer**: Khách hàng thuộc về một tenant cụ thể
- **product**: Sản phẩm thuộc về một tenant cụ thể
- **order**: Đơn hàng thuộc về một tenant cụ thể
- **campaign**: Chiến dịch thuộc về một tenant cụ thể
- **ticket**: Ticket thuộc về một tenant cụ thể

### 4.4. Cross-tenant Integration

Trong một số trường hợp, cần tích hợp dữ liệu giữa các tenant:

- **Marketplace Integration**: Sản phẩm từ nhiều tenant có thể được đăng trên cùng một marketplace
- **AI Model Sharing**: Mô hình AI có thể được chia sẻ giữa các tenant
- **Knowledge Sharing**: Bài viết kiến thức có thể được chia sẻ giữa các tenant

## 5. TỔNG KẾT

Schema tính năng là phần quan trọng của NextFlow CRM-AI, quản lý các tính năng nghiệp vụ như khách hàng, sản phẩm, đơn hàng, marketing, bán hàng, hỗ trợ khách hàng, và nhiều tính năng khác. Schema được thiết kế để hỗ trợ kiến trúc multi-tenant, đảm bảo cách ly dữ liệu giữa các tenant.

Để hiểu rõ hơn về từng module trong schema tính năng, vui lòng tham khảo các tài liệu chi tiết:

- [Khách hàng](./khach-hang.md)
- [Sản phẩm](./san-pham.md)
- [Đơn hàng](./don-hang.md)
- [Marketing](./marketing.md)
- [Bán hàng](./ban-hang.md)
- [Hỗ trợ khách hàng](./ho-tro-khach-hang.md)
- [Tích hợp đa nền tảng](./tich-hop-da-nen-tang.md)
- [AI Integration](./ai-integration.md)
- [Nhân sự](./nhan-su.md)
- [Tài chính](./tai-chinh.md)
- [Dự án](./quan-ly-du-an.md)
- [Tổng đài](./tong-dai.md)
- [Báo cáo và phân tích](./bao-cao-phan-tich.md)
- [Quản lý nội dung](./quan-ly-noi-dung.md)
- [Chatbot và NLP](./chatbot-nlp.md)