# SCHEMA TÍNH NĂNG - QUẢN LÝ NỘI DUNG

## 1. GIỚI THIỆU

Schema Quản lý Nội dung quản lý thông tin về các nội dung, bài viết, trang web, thư viện media và các hoạt động liên quan đến quản lý nội dung trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến quản lý nội dung trong hệ thống.

### 1.1. Mục đích

Schema Quản lý Nội dung phục vụ các mục đích sau:

- Lưu trữ thông tin về các bài viết, trang web và nội dung
- Quản lý thư viện media (hình ảnh, video, tài liệu)
- Phân loại và tổ chức nội dung
- Hỗ trợ SEO và tối ưu hóa nội dung
- Quản lý phiên bản và lịch sử nội dung
- Hỗ trợ xuất bản và lên lịch nội dung

### 1.2. Các bảng chính

Schema Quản lý Nội dung bao gồm các bảng chính sau:

1. `content_items` - Lưu trữ thông tin về các nội dung
2. `content_categories` - Lưu trữ thông tin về các danh mục nội dung
3. `content_tags` - Lưu trữ thông tin về các thẻ nội dung
4. `media_items` - Lưu trữ thông tin về các tệp media
5. `content_revisions` - Lưu trữ thông tin về các phiên bản nội dung
6. `content_seo` - Lưu trữ thông tin SEO của nội dung

## 2. BẢNG CONTENT_ITEMS

### 2.1. Mô tả

Bảng `content_items` lưu trữ thông tin về các nội dung trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của nội dung |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| title | varchar(255) | false | | Tiêu đề nội dung |
| slug | varchar(255) | false | | Định danh URL-friendly |
| content | text | true | null | Nội dung |
| excerpt | text | true | null | Tóm tắt nội dung |
| type | varchar(50) | false | 'post' | Loại nội dung: post, page, product, etc. |
| status | varchar(20) | false | 'draft' | Trạng thái: draft, published, archived |
| featured_image_id | uuid | true | null | Khóa ngoại tới bảng media_items, hình ảnh đại diện |
| author_id | uuid | true | null | Khóa ngoại tới bảng users, tác giả |
| parent_id | uuid | true | null | Khóa ngoại tới bảng content_items, nội dung cha |
| template | varchar(100) | true | null | Mẫu hiển thị |
| order | integer | false | 0 | Thứ tự hiển thị |
| is_featured | boolean | false | false | Đánh dấu là nội dung nổi bật |
| is_sticky | boolean | false | false | Đánh dấu là nội dung ghim |
| allow_comments | boolean | false | true | Cho phép bình luận |
| view_count | integer | false | 0 | Số lượt xem |
| published_at | timestamp | true | null | Thời gian xuất bản |
| expires_at | timestamp | true | null | Thời gian hết hạn |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| content_items_pkey | PRIMARY KEY | id | Khóa chính |
| content_items_organization_slug_idx | UNIQUE | organization_id, slug | Đảm bảo slug là duy nhất trong tổ chức |
| content_items_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| content_items_type_idx | INDEX | type | Tăng tốc truy vấn theo loại nội dung |
| content_items_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| content_items_author_id_idx | INDEX | author_id | Tăng tốc truy vấn theo tác giả |
| content_items_parent_id_idx | INDEX | parent_id | Tăng tốc truy vấn theo nội dung cha |
| content_items_is_featured_idx | INDEX | is_featured | Tăng tốc truy vấn theo nội dung nổi bật |
| content_items_is_sticky_idx | INDEX | is_sticky | Tăng tốc truy vấn theo nội dung ghim |
| content_items_published_at_idx | INDEX | published_at | Tăng tốc truy vấn theo thời gian xuất bản |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| content_items_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| content_items_featured_image_id_fkey | FOREIGN KEY | Tham chiếu đến bảng media_items(id) |
| content_items_author_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| content_items_parent_id_fkey | FOREIGN KEY | Tham chiếu đến bảng content_items(id) |
| content_items_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| content_items_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| content_items_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| content_items_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| content_items_order_check | CHECK | Đảm bảo order >= 0 |
| content_items_view_count_check | CHECK | Đảm bảo view_count >= 0 |
| content_items_no_self_reference | CHECK | Đảm bảo parent_id != id |

### 2.5. Ví dụ JSON

```json
{
  "id": "c1o2n3t4-e5n6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "title": "Hướng dẫn sử dụng NextFlow CRM",
  "slug": "huong-dan-su-dung-NextFlow-crm",
  "content": "<h1>Hướng dẫn sử dụng NextFlow CRM</h1><p>NextFlow CRM là hệ thống quản lý quan hệ khách hàng đa nền tảng...</p>",
  "excerpt": "Hướng dẫn chi tiết cách sử dụng NextFlow CRM cho người mới bắt đầu",
  "type": "page",
  "status": "published",
  "featured_image_id": "i1m2a3g4-e5i6-7890-abcd-ef1234567890",
  "author_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "parent_id": null,
  "template": "documentation",
  "order": 1,
  "is_featured": true,
  "is_sticky": false,
  "allow_comments": false,
  "view_count": 1250,
  "published_at": "2023-06-01T09:00:00Z",
  "expires_at": null,
  "created_at": "2023-05-15T10:00:00Z",
  "updated_at": "2023-06-01T09:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG MEDIA_ITEMS

### 3.1. Mô tả

Bảng `media_items` lưu trữ thông tin về các tệp media trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(255) | false | | Tên tệp |
| description | text | true | null | Mô tả tệp |
| file_name | varchar(255) | false | | Tên tệp gốc |
| file_path | varchar(255) | false | | Đường dẫn tệp |
| file_url | varchar(255) | false | | URL tệp |
| file_size | integer | false | | Kích thước tệp (bytes) |
| file_type | varchar(50) | false | | Loại tệp: image, video, document, etc. |
| mime_type | varchar(100) | false | | MIME type |
| extension | varchar(10) | false | | Phần mở rộng tệp |
| width | integer | true | null | Chiều rộng (cho hình ảnh/video) |
| height | integer | true | null | Chiều cao (cho hình ảnh/video) |
| duration | integer | true | null | Thời lượng (cho audio/video, giây) |
| alt_text | varchar(255) | true | null | Văn bản thay thế |
| caption | text | true | null | Chú thích |
| folder_id | uuid | true | null | Khóa ngoại tới bảng media_folders |
| is_public | boolean | false | true | Đánh dấu là công khai |
| metadata | jsonb | true | null | Metadata bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| media_items_pkey | PRIMARY KEY | id | Khóa chính |
| media_items_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| media_items_file_type_idx | INDEX | file_type | Tăng tốc truy vấn theo loại tệp |
| media_items_mime_type_idx | INDEX | mime_type | Tăng tốc truy vấn theo MIME type |
| media_items_folder_id_idx | INDEX | folder_id | Tăng tốc truy vấn theo thư mục |
| media_items_is_public_idx | INDEX | is_public | Tăng tốc truy vấn theo trạng thái công khai |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| media_items_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| media_items_folder_id_fkey | FOREIGN KEY | Tham chiếu đến bảng media_folders(id) |
| media_items_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| media_items_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| media_items_file_type_check | CHECK | Đảm bảo file_type chỉ nhận các giá trị cho phép |
| media_items_file_size_check | CHECK | Đảm bảo file_size > 0 |
| media_items_width_check | CHECK | Đảm bảo width > 0 khi không null |
| media_items_height_check | CHECK | Đảm bảo height > 0 khi không null |
| media_items_duration_check | CHECK | Đảm bảo duration > 0 khi không null |

### 3.5. Ví dụ JSON

```json
{
  "id": "i1m2a3g4-e5i6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Hình ảnh hướng dẫn NextFlow CRM",
  "description": "Hình ảnh minh họa cho hướng dẫn sử dụng NextFlow CRM",
  "file_name": "NextFlow-crm-guide.jpg",
  "file_path": "media/2023/06/NextFlow-crm-guide.jpg",
  "file_url": "https://assets.NextFlow.com/media/2023/06/NextFlow-crm-guide.jpg",
  "file_size": 256000,
  "file_type": "image",
  "mime_type": "image/jpeg",
  "extension": "jpg",
  "width": 1920,
  "height": 1080,
  "duration": null,
  "alt_text": "Giao diện NextFlow CRM với các tính năng chính",
  "caption": "Giao diện NextFlow CRM hiển thị dashboard và các tính năng chính",
  "folder_id": "f1o2l3d4-e5r6-7890-abcd-ef1234567890",
  "is_public": true,
  "metadata": {
    "camera": "Canon EOS R5",
    "taken_at": "2023-05-10T14:30:00Z",
    "location": "Văn phòng NextFlow",
    "keywords": ["crm", "dashboard", "interface", "guide"]
  },
  "created_at": "2023-05-15T09:30:00Z",
  "updated_at": "2023-05-15T09:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG CONTENT_CATEGORIES

### 4.1. Mô tả

Bảng `content_categories` lưu trữ thông tin về các danh mục nội dung trong hệ thống.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(100) | false | | Tên danh mục |
| slug | varchar(100) | false | | Định danh URL-friendly |
| description | text | true | null | Mô tả danh mục |
| parent_id | uuid | true | null | Khóa ngoại tới bảng content_categories, danh mục cha |
| icon | varchar(50) | true | null | Biểu tượng danh mục |
| image_id | uuid | true | null | Khóa ngoại tới bảng media_items, hình ảnh danh mục |
| order | integer | false | 0 | Thứ tự hiển thị |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| content_categories_pkey | PRIMARY KEY | id | Khóa chính |
| content_categories_organization_slug_idx | UNIQUE | organization_id, slug | Đảm bảo slug là duy nhất trong tổ chức |
| content_categories_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| content_categories_parent_id_idx | INDEX | parent_id | Tăng tốc truy vấn theo danh mục cha |
| content_categories_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| content_categories_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| content_categories_parent_id_fkey | FOREIGN KEY | Tham chiếu đến bảng content_categories(id) |
| content_categories_image_id_fkey | FOREIGN KEY | Tham chiếu đến bảng media_items(id) |
| content_categories_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| content_categories_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| content_categories_order_check | CHECK | Đảm bảo order >= 0 |
| content_categories_no_self_reference | CHECK | Đảm bảo parent_id != id |

### 4.5. Ví dụ JSON

```json
{
  "id": "c1a2t3e4-g5o6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Hướng dẫn sử dụng",
  "slug": "huong-dan-su-dung",
  "description": "Các bài viết hướng dẫn sử dụng NextFlow CRM",
  "parent_id": null,
  "icon": "book-open",
  "image_id": "i1m2a3g4-e5i6-7890-abcd-ef1234567890",
  "order": 1,
  "is_active": true,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
