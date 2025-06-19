# SCHEMA TÍNH NĂNG - HỖ TRỢ KHÁCH HÀNG

## 1. GIỚI THIỆU

Schema Hỗ trợ Khách hàng quản lý thông tin về các yêu cầu hỗ trợ, vé hỗ trợ, câu hỏi thường gặp và các hoạt động liên quan đến hỗ trợ khách hàng trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến hỗ trợ khách hàng trong hệ thống.

### 1.1. Mục đích

Schema Hỗ trợ Khách hàng phục vụ các mục đích sau:

- Lưu trữ thông tin về các yêu cầu hỗ trợ và vé hỗ trợ
- Quản lý quy trình xử lý yêu cầu hỗ trợ
- Theo dõi trạng thái và tiến độ xử lý
- Quản lý cơ sở kiến thức và câu hỏi thường gặp
- Đánh giá chất lượng dịch vụ hỗ trợ
- Phân tích và báo cáo hiệu suất hỗ trợ khách hàng

### 1.2. Các bảng chính

Schema Hỗ trợ Khách hàng bao gồm các bảng chính sau:

1. `support_tickets` - Lưu trữ thông tin về các vé hỗ trợ
2. `support_ticket_messages` - Lưu trữ thông tin về các tin nhắn trong vé hỗ trợ
3. `support_ticket_attachments` - Lưu trữ thông tin về các tệp đính kèm trong vé hỗ trợ
4. `support_agents` - Lưu trữ thông tin về các nhân viên hỗ trợ
5. `knowledge_base_articles` - Lưu trữ thông tin về các bài viết cơ sở kiến thức
6. `knowledge_base_categories` - Lưu trữ thông tin về các danh mục cơ sở kiến thức

## 2. BẢNG SUPPORT_TICKETS

### 2.1. Mô tả

Bảng `support_tickets` lưu trữ thông tin về các vé hỗ trợ trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của vé hỗ trợ |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| ticket_number | varchar(20) | false | | Số vé hỗ trợ |
| subject | varchar(255) | false | | Tiêu đề vé hỗ trợ |
| description | text | false | | Mô tả vé hỗ trợ |
| customer_id | uuid | false | | Khóa ngoại tới bảng customers, khách hàng |
| contact_id | uuid | true | null | Khóa ngoại tới bảng contacts, người liên hệ |
| agent_id | uuid | true | null | Khóa ngoại tới bảng users, nhân viên hỗ trợ |
| department_id | uuid | true | null | Khóa ngoại tới bảng departments, phòng ban |
| status | varchar(20) | false | 'open' | Trạng thái: open, in_progress, waiting, resolved, closed |
| priority | varchar(20) | false | 'medium' | Mức độ ưu tiên: low, medium, high, urgent |
| type | varchar(50) | false | 'question' | Loại vé: question, problem, incident, feature_request, etc. |
| source | varchar(50) | false | 'email' | Nguồn vé: email, web, phone, chat, social, etc. |
| channel | varchar(50) | true | null | Kênh liên hệ: email, web, phone, chat, social, etc. |
| category_id | uuid | true | null | Khóa ngoại tới bảng support_categories, danh mục |
| product_id | uuid | true | null | Khóa ngoại tới bảng products, sản phẩm |
| due_date | timestamp | true | null | Thời hạn xử lý |
| resolution | text | true | null | Giải pháp |
| resolution_time | integer | true | null | Thời gian xử lý (phút) |
| first_response_time | integer | true | null | Thời gian phản hồi đầu tiên (phút) |
| is_spam | boolean | false | false | Đánh dấu là thư rác |
| is_public | boolean | false | true | Đánh dấu là công khai |
| satisfaction_rating | integer | true | null | Đánh giá mức độ hài lòng (1-5) |
| satisfaction_comment | text | true | null | Nhận xét đánh giá |
| tags | jsonb | true | null | Thẻ vé hỗ trợ |
| custom_fields | jsonb | true | null | Trường tùy chỉnh |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| closed_at | timestamp | true | null | Thời gian đóng vé |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| support_tickets_pkey | PRIMARY KEY | id | Khóa chính |
| support_tickets_organization_number_idx | UNIQUE | organization_id, ticket_number | Đảm bảo số vé hỗ trợ là duy nhất trong tổ chức |
| support_tickets_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| support_tickets_customer_id_idx | INDEX | customer_id | Tăng tốc truy vấn theo khách hàng |
| support_tickets_contact_id_idx | INDEX | contact_id | Tăng tốc truy vấn theo người liên hệ |
| support_tickets_agent_id_idx | INDEX | agent_id | Tăng tốc truy vấn theo nhân viên hỗ trợ |
| support_tickets_department_id_idx | INDEX | department_id | Tăng tốc truy vấn theo phòng ban |
| support_tickets_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| support_tickets_priority_idx | INDEX | priority | Tăng tốc truy vấn theo mức độ ưu tiên |
| support_tickets_type_idx | INDEX | type | Tăng tốc truy vấn theo loại vé |
| support_tickets_source_idx | INDEX | source | Tăng tốc truy vấn theo nguồn vé |
| support_tickets_category_id_idx | INDEX | category_id | Tăng tốc truy vấn theo danh mục |
| support_tickets_product_id_idx | INDEX | product_id | Tăng tốc truy vấn theo sản phẩm |
| support_tickets_due_date_idx | INDEX | due_date | Tăng tốc truy vấn theo thời hạn xử lý |
| support_tickets_created_at_idx | INDEX | created_at | Tăng tốc truy vấn theo thời gian tạo |
| support_tickets_closed_at_idx | INDEX | closed_at | Tăng tốc truy vấn theo thời gian đóng |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| support_tickets_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| support_tickets_customer_id_fkey | FOREIGN KEY | Tham chiếu đến bảng customers(id) |
| support_tickets_contact_id_fkey | FOREIGN KEY | Tham chiếu đến bảng contacts(id) |
| support_tickets_agent_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| support_tickets_department_id_fkey | FOREIGN KEY | Tham chiếu đến bảng departments(id) |
| support_tickets_category_id_fkey | FOREIGN KEY | Tham chiếu đến bảng support_categories(id) |
| support_tickets_product_id_fkey | FOREIGN KEY | Tham chiếu đến bảng products(id) |
| support_tickets_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| support_tickets_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| support_tickets_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| support_tickets_priority_check | CHECK | Đảm bảo priority chỉ nhận các giá trị cho phép |
| support_tickets_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| support_tickets_source_check | CHECK | Đảm bảo source chỉ nhận các giá trị cho phép |
| support_tickets_channel_check | CHECK | Đảm bảo channel chỉ nhận các giá trị cho phép |
| support_tickets_resolution_time_check | CHECK | Đảm bảo resolution_time >= 0 khi không null |
| support_tickets_first_response_time_check | CHECK | Đảm bảo first_response_time >= 0 khi không null |
| support_tickets_satisfaction_rating_check | CHECK | Đảm bảo satisfaction_rating >= 1 và satisfaction_rating <= 5 khi không null |

### 2.5. Ví dụ JSON

```json
{
  "id": "t1i2c3k4-e5t6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "ticket_number": "TKT-2023-0001",
  "subject": "Lỗi đăng nhập vào hệ thống NextFlow CRM",
  "description": "Tôi không thể đăng nhập vào hệ thống NextFlow CRM. Khi nhập tên đăng nhập và mật khẩu, hệ thống hiển thị thông báo lỗi 'Tài khoản không tồn tại'.",
  "customer_id": "c1u2s3t4-o5m6-7890-abcd-ef1234567890",
  "contact_id": "c1o2n3t4-a5c6-7890-abcd-ef1234567890",
  "agent_id": "a1g2e3n4-t5i6-7890-abcd-ef1234567890",
  "department_id": "d1e2p3t4-i5d6-7890-abcd-ef1234567890",
  "status": "in_progress",
  "priority": "high",
  "type": "problem",
  "source": "email",
  "channel": "email",
  "category_id": "c1a2t3e4-g5o6-7890-abcd-ef1234567890",
  "product_id": "p1r2o3d4-u5c6-7890-abcd-ef1234567890",
  "due_date": "2023-07-16T17:00:00Z",
  "resolution": null,
  "resolution_time": null,
  "first_response_time": 15,
  "is_spam": false,
  "is_public": true,
  "satisfaction_rating": null,
  "satisfaction_comment": null,
  "tags": ["đăng nhập", "lỗi", "tài khoản"],
  "custom_fields": {
    "browser": "Chrome 115.0.0.0",
    "operating_system": "Windows 10",
    "attempted_login_time": "2023-07-15T09:30:00Z"
  },
  "created_at": "2023-07-15T10:00:00Z",
  "updated_at": "2023-07-15T10:15:00Z",
  "closed_at": null,
  "deleted_at": null,
  "created_by": "c1o2n3t4-a5c6-7890-abcd-ef1234567890",
  "updated_by": "a1g2e3n4-t5i6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG SUPPORT_TICKET_MESSAGES

### 3.1. Mô tả

Bảng `support_ticket_messages` lưu trữ thông tin về các tin nhắn trong vé hỗ trợ.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| ticket_id | uuid | false | | Khóa ngoại tới bảng support_tickets |
| sender_type | varchar(20) | false | | Loại người gửi: customer, agent, system |
| sender_id | uuid | true | null | ID người gửi |
| content | text | false | | Nội dung tin nhắn |
| html_content | text | true | null | Nội dung HTML |
| is_internal | boolean | false | false | Đánh dấu là tin nhắn nội bộ |
| is_first_response | boolean | false | false | Đánh dấu là phản hồi đầu tiên |
| has_attachments | boolean | false | false | Đánh dấu có tệp đính kèm |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| support_ticket_messages_pkey | PRIMARY KEY | id | Khóa chính |
| support_ticket_messages_ticket_id_idx | INDEX | ticket_id | Tăng tốc truy vấn theo vé hỗ trợ |
| support_ticket_messages_sender_type_idx | INDEX | sender_type | Tăng tốc truy vấn theo loại người gửi |
| support_ticket_messages_sender_id_idx | INDEX | sender_id | Tăng tốc truy vấn theo người gửi |
| support_ticket_messages_is_internal_idx | INDEX | is_internal | Tăng tốc truy vấn theo tin nhắn nội bộ |
| support_ticket_messages_is_first_response_idx | INDEX | is_first_response | Tăng tốc truy vấn theo phản hồi đầu tiên |
| support_ticket_messages_created_at_idx | INDEX | created_at | Tăng tốc truy vấn theo thời gian tạo |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| support_ticket_messages_ticket_id_fkey | FOREIGN KEY | Tham chiếu đến bảng support_tickets(id) |
| support_ticket_messages_sender_type_check | CHECK | Đảm bảo sender_type chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "m1e2s3s4-a5g6-7890-abcd-ef1234567890",
  "ticket_id": "t1i2c3k4-e5t6-7890-abcd-ef1234567890",
  "sender_type": "agent",
  "sender_id": "a1g2e3n4-t5i6-7890-abcd-ef1234567890",
  "content": "Chào anh/chị,\n\nCảm ơn anh/chị đã liên hệ với bộ phận hỗ trợ của NextFlow CRM.\n\nTôi đã kiểm tra tài khoản của anh/chị và phát hiện rằng tài khoản đã bị khóa do nhập sai mật khẩu nhiều lần. Tôi đã mở khóa tài khoản và anh/chị có thể đăng nhập lại bình thường.\n\nNếu anh/chị vẫn gặp vấn đề, vui lòng cho chúng tôi biết.\n\nTrân trọng,\nNguyễn Văn A\nBộ phận Hỗ trợ Khách hàng",
  "html_content": "<p>Chào anh/chị,</p><p>Cảm ơn anh/chị đã liên hệ với bộ phận hỗ trợ của NextFlow CRM.</p><p>Tôi đã kiểm tra tài khoản của anh/chị và phát hiện rằng tài khoản đã bị khóa do nhập sai mật khẩu nhiều lần. Tôi đã mở khóa tài khoản và anh/chị có thể đăng nhập lại bình thường.</p><p>Nếu anh/chị vẫn gặp vấn đề, vui lòng cho chúng tôi biết.</p><p>Trân trọng,<br>Nguyễn Văn A<br>Bộ phận Hỗ trợ Khách hàng</p>",
  "is_internal": false,
  "is_first_response": true,
  "has_attachments": false,
  "created_at": "2023-07-15T10:15:00Z",
  "updated_at": "2023-07-15T10:15:00Z",
  "deleted_at": null
}
```

## 4. BẢNG KNOWLEDGE_BASE_ARTICLES

### 4.1. Mô tả

Bảng `knowledge_base_articles` lưu trữ thông tin về các bài viết cơ sở kiến thức trong hệ thống.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| title | varchar(255) | false | | Tiêu đề bài viết |
| slug | varchar(255) | false | | Định danh URL-friendly |
| content | text | false | | Nội dung bài viết |
| excerpt | text | true | null | Tóm tắt bài viết |
| category_id | uuid | true | null | Khóa ngoại tới bảng knowledge_base_categories |
| author_id | uuid | true | null | Khóa ngoại tới bảng users, tác giả |
| status | varchar(20) | false | 'draft' | Trạng thái: draft, published, archived |
| is_featured | boolean | false | false | Đánh dấu là bài viết nổi bật |
| is_internal | boolean | false | false | Đánh dấu là bài viết nội bộ |
| view_count | integer | false | 0 | Số lượt xem |
| helpful_count | integer | false | 0 | Số lượt đánh giá hữu ích |
| not_helpful_count | integer | false | 0 | Số lượt đánh giá không hữu ích |
| related_articles | jsonb | true | null | Các bài viết liên quan |
| tags | jsonb | true | null | Thẻ bài viết |
| seo_title | varchar(255) | true | null | Tiêu đề SEO |
| seo_description | text | true | null | Mô tả SEO |
| seo_keywords | varchar(255) | true | null | Từ khóa SEO |
| published_at | timestamp | true | null | Thời gian xuất bản |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| knowledge_base_articles_pkey | PRIMARY KEY | id | Khóa chính |
| knowledge_base_articles_organization_slug_idx | UNIQUE | organization_id, slug | Đảm bảo slug là duy nhất trong tổ chức |
| knowledge_base_articles_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| knowledge_base_articles_category_id_idx | INDEX | category_id | Tăng tốc truy vấn theo danh mục |
| knowledge_base_articles_author_id_idx | INDEX | author_id | Tăng tốc truy vấn theo tác giả |
| knowledge_base_articles_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| knowledge_base_articles_is_featured_idx | INDEX | is_featured | Tăng tốc truy vấn theo bài viết nổi bật |
| knowledge_base_articles_is_internal_idx | INDEX | is_internal | Tăng tốc truy vấn theo bài viết nội bộ |
| knowledge_base_articles_published_at_idx | INDEX | published_at | Tăng tốc truy vấn theo thời gian xuất bản |
| knowledge_base_articles_content_idx | INDEX | content | Tăng tốc tìm kiếm nội dung (USING GIN) |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| knowledge_base_articles_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| knowledge_base_articles_category_id_fkey | FOREIGN KEY | Tham chiếu đến bảng knowledge_base_categories(id) |
| knowledge_base_articles_author_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| knowledge_base_articles_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| knowledge_base_articles_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| knowledge_base_articles_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| knowledge_base_articles_view_count_check | CHECK | Đảm bảo view_count >= 0 |
| knowledge_base_articles_helpful_count_check | CHECK | Đảm bảo helpful_count >= 0 |
| knowledge_base_articles_not_helpful_count_check | CHECK | Đảm bảo not_helpful_count >= 0 |

### 4.5. Ví dụ JSON

```json
{
  "id": "a1r2t3i4-c5l6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "title": "Cách khắc phục lỗi đăng nhập vào NextFlow CRM",
  "slug": "cach-khac-phuc-loi-dang-nhap-vao-NextFlow-crm",
  "content": "<h1>Cách khắc phục lỗi đăng nhập vào NextFlow CRM</h1><p>Bài viết này hướng dẫn cách khắc phục các lỗi thường gặp khi đăng nhập vào hệ thống NextFlow CRM.</p><h2>1. Lỗi 'Tài khoản không tồn tại'</h2><p>Nguyên nhân thường gặp:</p><ul><li>Nhập sai địa chỉ email</li><li>Tài khoản chưa được tạo trong hệ thống</li></ul><p>Cách khắc phục:</p><ul><li>Kiểm tra lại địa chỉ email đăng nhập</li><li>Liên hệ quản trị viên để xác nhận tài khoản đã được tạo</li></ul><h2>2. Lỗi 'Mật khẩu không đúng'</h2><p>...</p>",
  "excerpt": "Hướng dẫn cách khắc phục các lỗi thường gặp khi đăng nhập vào hệ thống NextFlow CRM như lỗi tài khoản không tồn tại, mật khẩu không đúng, tài khoản bị khóa.",
  "category_id": "c1a2t3e4-g5o6-7890-abcd-ef1234567890",
  "author_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "published",
  "is_featured": true,
  "is_internal": false,
  "view_count": 1250,
  "helpful_count": 120,
  "not_helpful_count": 5,
  "related_articles": [
    "r1e2l3a4-t5e6-7890-abcd-ef1234567890",
    "r1e2l3a4-t5e6-7890-abcd-ef1234567891"
  ],
  "tags": ["đăng nhập", "lỗi", "khắc phục", "tài khoản"],
  "seo_title": "Cách khắc phục lỗi đăng nhập vào NextFlow CRM | Hỗ trợ NextFlow",
  "seo_description": "Hướng dẫn chi tiết cách khắc phục các lỗi thường gặp khi đăng nhập vào hệ thống NextFlow CRM. Giải quyết vấn đề tài khoản không tồn tại, mật khẩu không đúng, tài khoản bị khóa.",
  "seo_keywords": "lỗi đăng nhập, NextFlow crm, khắc phục lỗi, tài khoản không tồn tại, mật khẩu không đúng, tài khoản bị khóa",
  "published_at": "2023-06-01T09:00:00Z",
  "created_at": "2023-05-15T10:00:00Z",
  "updated_at": "2023-06-01T09:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
