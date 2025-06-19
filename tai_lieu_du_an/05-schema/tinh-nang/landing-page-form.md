# SCHEMA TÍNH NĂNG - LANDING PAGE VÀ FORM

## 1. GIỚI THIỆU

Schema Landing Page và Form quản lý thông tin về các trang đích (landing page), biểu mẫu thu thập thông tin (form) và dữ liệu thu thập được trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến landing page và form trong hệ thống.

### 1.1. Mục đích

Schema Landing Page và Form phục vụ các mục đích sau:

- Lưu trữ thông tin về các trang đích (landing page)
- Quản lý biểu mẫu thu thập thông tin (form)
- Theo dõi hiệu quả của landing page và form
- Lưu trữ dữ liệu thu thập được từ form
- Tích hợp với chiến dịch marketing
- Phân tích hành vi người dùng trên landing page

### 1.2. Các bảng chính

Schema Landing Page và Form bao gồm các bảng chính sau:

1. `landing_pages` - Lưu trữ thông tin về các trang đích
2. `forms` - Lưu trữ thông tin về các biểu mẫu
3. `form_fields` - Lưu trữ thông tin về các trường trong biểu mẫu
4. `form_submissions` - Lưu trữ thông tin về các lần gửi biểu mẫu
5. `page_views` - Lưu trữ thông tin về lượt xem trang
6. `page_events` - Lưu trữ thông tin về các sự kiện trên trang

## 2. BẢNG LANDING_PAGES

### 2.1. Mô tả

Bảng `landing_pages` lưu trữ thông tin về các trang đích (landing page) trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của trang đích |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| campaign_id | uuid | true | null | Khóa ngoại tới bảng marketing_campaigns |
| name | varchar(100) | false | | Tên trang đích |
| slug | varchar(100) | false | | Định danh URL-friendly |
| title | varchar(255) | false | | Tiêu đề trang |
| description | text | true | null | Mô tả trang |
| content | text | false | | Nội dung HTML của trang |
| template_id | uuid | true | null | ID mẫu trang |
| status | enum | false | 'draft' | Trạng thái: draft, published, archived |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| publish_start | timestamp | true | null | Thời gian bắt đầu xuất bản |
| publish_end | timestamp | true | null | Thời gian kết thúc xuất bản |
| url | varchar(255) | true | null | URL đầy đủ của trang |
| custom_domain | varchar(255) | true | null | Tên miền tùy chỉnh |
| meta_title | varchar(255) | true | null | Tiêu đề meta cho SEO |
| meta_description | text | true | null | Mô tả meta cho SEO |
| meta_keywords | varchar(255) | true | null | Từ khóa meta cho SEO |
| og_title | varchar(255) | true | null | Tiêu đề Open Graph |
| og_description | text | true | null | Mô tả Open Graph |
| og_image | varchar(255) | true | null | URL hình ảnh Open Graph |
| css | text | true | null | CSS tùy chỉnh |
| javascript | text | true | null | JavaScript tùy chỉnh |
| settings | jsonb | true | null | Cài đặt trang |
| analytics | jsonb | true | null | Dữ liệu phân tích |
| utm_parameters | jsonb | true | null | Tham số UTM |
| tags | jsonb | true | null | Thẻ trang |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| landing_pages_pkey | PRIMARY KEY | id | Khóa chính |
| landing_pages_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên trang đích là duy nhất trong tổ chức |
| landing_pages_organization_slug_idx | UNIQUE | organization_id, slug | Đảm bảo slug là duy nhất trong tổ chức |
| landing_pages_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| landing_pages_campaign_id_idx | INDEX | campaign_id | Tăng tốc truy vấn theo chiến dịch |
| landing_pages_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| landing_pages_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |
| landing_pages_publish_start_idx | INDEX | publish_start | Tăng tốc truy vấn theo thời gian bắt đầu xuất bản |
| landing_pages_publish_end_idx | INDEX | publish_end | Tăng tốc truy vấn theo thời gian kết thúc xuất bản |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| landing_pages_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| landing_pages_campaign_id_fkey | FOREIGN KEY | Tham chiếu đến bảng marketing_campaigns(id) |
| landing_pages_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| landing_pages_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| landing_pages_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| landing_pages_publish_date_check | CHECK | Đảm bảo publish_end >= publish_start khi cả hai không null |
| landing_pages_slug_check | CHECK | Đảm bảo slug chỉ chứa các ký tự hợp lệ |

### 2.5. Ví dụ JSON

```json
{
  "id": "l1a2n3d4-i5n6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "campaign_id": "c1a2m3p4-a5i6-7890-abcd-ef1234567890",
  "name": "Khuyến mãi Hè 2023 - Sản phẩm Điện tử",
  "slug": "khuyen-mai-he-2023-dien-tu",
  "title": "Khuyến mãi Hè 2023 - Giảm giá lên đến 50% cho sản phẩm điện tử",
  "description": "Trang đích cho chiến dịch khuyến mãi mùa hè 2023 với các ưu đãi đặc biệt cho sản phẩm điện tử",
  "content": "<!DOCTYPE html><html><head>...</head><body>...</body></html>",
  "template_id": null,
  "status": "published",
  "is_active": true,
  "publish_start": "2023-06-01T00:00:00Z",
  "publish_end": "2023-08-31T23:59:59Z",
  "url": "https://promo.NextFlow.com/khuyen-mai-he-2023-dien-tu",
  "custom_domain": null,
  "meta_title": "Khuyến mãi Hè 2023 - Giảm giá lên đến 50% cho sản phẩm điện tử | NextFlow",
  "meta_description": "Khám phá ưu đãi đặc biệt mùa hè 2023 với giảm giá lên đến 50% cho các sản phẩm điện tử. Chỉ từ 01/06 đến 31/08/2023.",
  "meta_keywords": "khuyến mãi, giảm giá, điện tử, mùa hè, 2023",
  "og_title": "Khuyến mãi Hè 2023 - Giảm giá lên đến 50% cho sản phẩm điện tử",
  "og_description": "Khám phá ưu đãi đặc biệt mùa hè 2023 với giảm giá lên đến 50% cho các sản phẩm điện tử. Chỉ từ 01/06 đến 31/08/2023.",
  "og_image": "https://assets.NextFlow.com/campaigns/summer_2023/og_image.jpg",
  "css": ".hero { background-color: #f5f5f5; padding: 50px 0; } ...",
  "javascript": "document.addEventListener('DOMContentLoaded', function() { ... });",
  "settings": {
    "show_header": true,
    "show_footer": true,
    "show_social_sharing": true,
    "enable_analytics": true,
    "enable_chat": true,
    "redirect_after_submission": "https://NextFlow.com/thank-you"
  },
  "analytics": {
    "views": 15000,
    "unique_visitors": 12500,
    "conversions": 750,
    "conversion_rate": 6.0,
    "bounce_rate": 35.0,
    "average_time_on_page": 120
  },
  "utm_parameters": {
    "source": "summer_campaign_2023",
    "medium": "landing_page",
    "campaign": "summer_sale_2023",
    "content": "electronics"
  },
  "tags": ["summer", "electronics", "promotion", "2023"],
  "created_at": "2023-05-15T11:00:00Z",
  "updated_at": "2023-06-01T09:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG FORMS

### 3.1. Mô tả

Bảng `forms` lưu trữ thông tin về các biểu mẫu thu thập thông tin trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| landing_page_id | uuid | true | null | Khóa ngoại tới bảng landing_pages |
| campaign_id | uuid | true | null | Khóa ngoại tới bảng marketing_campaigns |
| name | varchar(100) | false | | Tên biểu mẫu |
| title | varchar(255) | false | | Tiêu đề biểu mẫu |
| description | text | true | null | Mô tả biểu mẫu |
| type | varchar(50) | false | 'standard' | Loại biểu mẫu: standard, popup, embedded, etc. |
| status | enum | false | 'draft' | Trạng thái: draft, active, inactive |
| submit_button_text | varchar(100) | false | 'Gửi' | Văn bản nút gửi |
| success_message | text | true | null | Thông báo thành công |
| redirect_url | varchar(255) | true | null | URL chuyển hướng sau khi gửi |
| notification_emails | jsonb | true | null | Email nhận thông báo |
| settings | jsonb | true | null | Cài đặt biểu mẫu |
| style | jsonb | true | null | Kiểu dáng biểu mẫu |
| analytics | jsonb | true | null | Dữ liệu phân tích |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| start_date | timestamp | true | null | Ngày bắt đầu |
| end_date | timestamp | true | null | Ngày kết thúc |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| forms_pkey | PRIMARY KEY | id | Khóa chính |
| forms_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên biểu mẫu là duy nhất trong tổ chức |
| forms_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| forms_landing_page_id_idx | INDEX | landing_page_id | Tăng tốc truy vấn theo trang đích |
| forms_campaign_id_idx | INDEX | campaign_id | Tăng tốc truy vấn theo chiến dịch |
| forms_type_idx | INDEX | type | Tăng tốc truy vấn theo loại biểu mẫu |
| forms_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| forms_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| forms_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| forms_landing_page_id_fkey | FOREIGN KEY | Tham chiếu đến bảng landing_pages(id) |
| forms_campaign_id_fkey | FOREIGN KEY | Tham chiếu đến bảng marketing_campaigns(id) |
| forms_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| forms_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| forms_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| forms_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| forms_date_check | CHECK | Đảm bảo end_date >= start_date khi cả hai không null |

### 3.5. Ví dụ JSON

```json
{
  "id": "f1o2r3m4-i5d6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "landing_page_id": "l1a2n3d4-i5n6-7890-abcd-ef1234567890",
  "campaign_id": "c1a2m3p4-a5i6-7890-abcd-ef1234567890",
  "name": "Đăng ký nhận ưu đãi Hè 2023",
  "title": "Đăng ký nhận ưu đãi đặc biệt",
  "description": "Điền thông tin để nhận ưu đãi đặc biệt và cập nhật về chương trình khuyến mãi Hè 2023",
  "type": "embedded",
  "status": "active",
  "submit_button_text": "Đăng ký ngay",
  "success_message": "Cảm ơn bạn đã đăng ký! Chúng tôi sẽ gửi ưu đãi đặc biệt qua email của bạn.",
  "redirect_url": "https://NextFlow.com/thank-you",
  "notification_emails": ["marketing@NextFlow.com", "sales@NextFlow.com"],
  "settings": {
    "store_submissions": true,
    "send_confirmation_email": true,
    "confirmation_email_template_id": "t1e2m3p4-l5a6-7890-abcd-ef1234567890",
    "create_lead": true,
    "lead_source": "summer_campaign_2023",
    "recaptcha_enabled": true,
    "double_opt_in": true
  },
  "style": {
    "theme": "light",
    "primary_color": "#1976d2",
    "font_family": "Roboto, sans-serif",
    "border_radius": "4px",
    "padding": "20px",
    "width": "100%",
    "max_width": "500px"
  },
  "analytics": {
    "views": 12000,
    "submissions": 750,
    "conversion_rate": 6.25,
    "average_completion_time": 45
  },
  "is_active": true,
  "start_date": "2023-06-01T00:00:00Z",
  "end_date": "2023-08-31T23:59:59Z",
  "created_at": "2023-05-15T11:30:00Z",
  "updated_at": "2023-06-01T09:45:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG FORM_FIELDS

### 4.1. Mô tả

Bảng `form_fields` lưu trữ thông tin về các trường trong biểu mẫu.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| form_id | uuid | false | | Khóa ngoại tới bảng forms |
| name | varchar(100) | false | | Tên trường |
| label | varchar(255) | false | | Nhãn hiển thị |
| type | varchar(50) | false | | Loại trường: text, email, number, select, checkbox, etc. |
| placeholder | varchar(255) | true | null | Văn bản gợi ý |
| default_value | varchar(255) | true | null | Giá trị mặc định |
| help_text | text | true | null | Văn bản trợ giúp |
| options | jsonb | true | null | Tùy chọn cho select, radio, checkbox |
| validation | jsonb | true | null | Quy tắc xác thực |
| is_required | boolean | false | false | Yêu cầu nhập |
| is_hidden | boolean | false | false | Ẩn trường |
| is_system | boolean | false | false | Trường hệ thống |
| sort_order | integer | false | 0 | Thứ tự hiển thị |
| conditional_logic | jsonb | true | null | Logic điều kiện |
| mapping | jsonb | true | null | Ánh xạ với trường trong CRM |
| css_class | varchar(255) | true | null | Lớp CSS tùy chỉnh |
| style | jsonb | true | null | Kiểu dáng trường |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| form_fields_pkey | PRIMARY KEY | id | Khóa chính |
| form_fields_form_name_idx | UNIQUE | form_id, name | Đảm bảo tên trường là duy nhất trong biểu mẫu |
| form_fields_form_id_idx | INDEX | form_id | Tăng tốc truy vấn theo biểu mẫu |
| form_fields_type_idx | INDEX | type | Tăng tốc truy vấn theo loại trường |
| form_fields_is_required_idx | INDEX | is_required | Tăng tốc truy vấn theo yêu cầu nhập |
| form_fields_is_hidden_idx | INDEX | is_hidden | Tăng tốc truy vấn theo trạng thái ẩn |
| form_fields_is_system_idx | INDEX | is_system | Tăng tốc truy vấn theo trường hệ thống |
| form_fields_sort_order_idx | INDEX | sort_order | Tăng tốc truy vấn theo thứ tự hiển thị |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| form_fields_form_id_fkey | FOREIGN KEY | Tham chiếu đến bảng forms(id) |
| form_fields_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| form_fields_sort_order_check | CHECK | Đảm bảo sort_order >= 0 |

### 4.5. Ví dụ JSON

```json
{
  "id": "f1i2e3l4-d5i6-7890-abcd-ef1234567890",
  "form_id": "f1o2r3m4-i5d6-7890-abcd-ef1234567890",
  "name": "email",
  "label": "Email của bạn",
  "type": "email",
  "placeholder": "Nhập địa chỉ email",
  "default_value": "",
  "help_text": "Chúng tôi sẽ gửi ưu đãi đặc biệt qua email này",
  "options": null,
  "validation": {
    "required": true,
    "pattern": "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
    "error_message": "Vui lòng nhập địa chỉ email hợp lệ"
  },
  "is_required": true,
  "is_hidden": false,
  "is_system": true,
  "sort_order": 1,
  "conditional_logic": null,
  "mapping": {
    "crm_field": "contact.email",
    "is_primary": true
  },
  "css_class": "form-control email-field",
  "style": {
    "width": "100%",
    "padding": "10px",
    "margin_bottom": "15px"
  },
  "created_at": "2023-05-15T11:35:00Z",
  "updated_at": "2023-05-15T11:35:00Z"
}
```
