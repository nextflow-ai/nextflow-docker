# SCHEMA TÍNH NĂNG - QUẢN LÝ TÀI LIỆU

## 1. GIỚI THIỆU

Schema Quản lý Tài liệu quản lý thông tin về các tài liệu, thư mục, phiên bản tài liệu và các hoạt động liên quan đến quản lý tài liệu trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến quản lý tài liệu trong hệ thống.

### 1.1. Mục đích

Schema Quản lý Tài liệu phục vụ các mục đích sau:

- Lưu trữ thông tin về các tài liệu và thư mục
- Quản lý phiên bản và lịch sử tài liệu
- Phân quyền truy cập tài liệu
- Hỗ trợ chia sẻ và cộng tác trên tài liệu
- Theo dõi hoạt động trên tài liệu
- Tìm kiếm và phân loại tài liệu

### 1.2. Các bảng chính

Schema Quản lý Tài liệu bao gồm các bảng chính sau:

1. `documents` - Lưu trữ thông tin về các tài liệu
2. `document_folders` - Lưu trữ thông tin về các thư mục tài liệu
3. `document_versions` - Lưu trữ thông tin về các phiên bản tài liệu
4. `document_shares` - Lưu trữ thông tin về chia sẻ tài liệu
5. `document_permissions` - Lưu trữ thông tin về quyền truy cập tài liệu
6. `document_activities` - Lưu trữ thông tin về hoạt động trên tài liệu

## 2. BẢNG DOCUMENTS

### 2.1. Mô tả

Bảng `documents` lưu trữ thông tin về các tài liệu trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của tài liệu |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(255) | false | | Tên tài liệu |
| description | text | true | null | Mô tả tài liệu |
| folder_id | uuid | true | null | Khóa ngoại tới bảng document_folders, thư mục chứa tài liệu |
| file_id | uuid | true | null | Khóa ngoại tới bảng media_items, tệp tài liệu |
| file_name | varchar(255) | true | null | Tên tệp gốc |
| file_size | integer | true | null | Kích thước tệp (bytes) |
| file_type | varchar(50) | true | null | Loại tệp: pdf, docx, xlsx, etc. |
| mime_type | varchar(100) | true | null | MIME type |
| extension | varchar(10) | true | null | Phần mở rộng tệp |
| content | text | true | null | Nội dung tài liệu (cho tài liệu văn bản) |
| content_extracted | boolean | false | false | Đánh dấu đã trích xuất nội dung |
| status | varchar(20) | false | 'active' | Trạng thái: active, archived, deleted |
| version | varchar(20) | false | '1.0' | Phiên bản hiện tại |
| is_template | boolean | false | false | Đánh dấu là mẫu tài liệu |
| is_favorite | boolean | false | false | Đánh dấu là tài liệu yêu thích |
| is_pinned | boolean | false | false | Đánh dấu là tài liệu ghim |
| is_public | boolean | false | false | Đánh dấu là tài liệu công khai |
| owner_id | uuid | false | | Khóa ngoại tới bảng users, người sở hữu |
| locked_by | uuid | true | null | Khóa ngoại tới bảng users, người khóa |
| locked_at | timestamp | true | null | Thời gian khóa |
| last_viewed_at | timestamp | true | null | Thời gian xem gần nhất |
| last_modified_at | timestamp | true | null | Thời gian sửa đổi gần nhất |
| view_count | integer | false | 0 | Số lượt xem |
| download_count | integer | false | 0 | Số lượt tải xuống |
| metadata | jsonb | true | null | Metadata bổ sung |
| tags | jsonb | true | null | Thẻ tài liệu |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| documents_pkey | PRIMARY KEY | id | Khóa chính |
| documents_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| documents_folder_id_idx | INDEX | folder_id | Tăng tốc truy vấn theo thư mục |
| documents_file_id_idx | INDEX | file_id | Tăng tốc truy vấn theo tệp |
| documents_file_type_idx | INDEX | file_type | Tăng tốc truy vấn theo loại tệp |
| documents_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| documents_is_template_idx | INDEX | is_template | Tăng tốc truy vấn theo mẫu tài liệu |
| documents_is_public_idx | INDEX | is_public | Tăng tốc truy vấn theo tài liệu công khai |
| documents_owner_id_idx | INDEX | owner_id | Tăng tốc truy vấn theo người sở hữu |
| documents_locked_by_idx | INDEX | locked_by | Tăng tốc truy vấn theo người khóa |
| documents_content_idx | INDEX | content | Tăng tốc tìm kiếm nội dung (USING GIN) |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| documents_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| documents_folder_id_fkey | FOREIGN KEY | Tham chiếu đến bảng document_folders(id) |
| documents_file_id_fkey | FOREIGN KEY | Tham chiếu đến bảng media_items(id) |
| documents_owner_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| documents_locked_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| documents_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| documents_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| documents_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| documents_file_size_check | CHECK | Đảm bảo file_size > 0 khi không null |
| documents_view_count_check | CHECK | Đảm bảo view_count >= 0 |
| documents_download_count_check | CHECK | Đảm bảo download_count >= 0 |

### 2.5. Ví dụ JSON

```json
{
  "id": "d1o2c3u4-m5e6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Hợp đồng dịch vụ NextFlow CRM",
  "description": "Hợp đồng cung cấp dịch vụ NextFlow CRM cho khách hàng",
  "folder_id": "f1o2l3d4-e5r6-7890-abcd-ef1234567890",
  "file_id": "f1i2l3e4-i5d6-7890-abcd-ef1234567890",
  "file_name": "hop-dong-dich-vu-NextFlow-crm.pdf",
  "file_size": 1250000,
  "file_type": "pdf",
  "mime_type": "application/pdf",
  "extension": "pdf",
  "content": null,
  "content_extracted": true,
  "status": "active",
  "version": "1.2",
  "is_template": true,
  "is_favorite": false,
  "is_pinned": true,
  "is_public": false,
  "owner_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "locked_by": null,
  "locked_at": null,
  "last_viewed_at": "2023-07-15T10:30:00Z",
  "last_modified_at": "2023-06-01T14:00:00Z",
  "view_count": 45,
  "download_count": 12,
  "metadata": {
    "author": "Phòng Pháp lý",
    "keywords": ["hợp đồng", "dịch vụ", "crm"],
    "revision_date": "2023-06-01",
    "expiry_date": "2024-06-01",
    "document_number": "HD-2023-001"
  },
  "tags": ["hợp đồng", "mẫu", "pháp lý"],
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-06-01T14:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG DOCUMENT_FOLDERS

### 3.1. Mô tả

Bảng `document_folders` lưu trữ thông tin về các thư mục tài liệu trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(100) | false | | Tên thư mục |
| description | text | true | null | Mô tả thư mục |
| parent_id | uuid | true | null | Khóa ngoại tới bảng document_folders, thư mục cha |
| path | varchar(255) | false | '/' | Đường dẫn thư mục |
| color | varchar(7) | true | null | Mã màu thư mục |
| icon | varchar(50) | true | null | Biểu tượng thư mục |
| is_system | boolean | false | false | Đánh dấu là thư mục hệ thống |
| is_default | boolean | false | false | Đánh dấu là thư mục mặc định |
| is_public | boolean | false | false | Đánh dấu là thư mục công khai |
| owner_id | uuid | false | | Khóa ngoại tới bảng users, người sở hữu |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| document_folders_pkey | PRIMARY KEY | id | Khóa chính |
| document_folders_organization_path_idx | UNIQUE | organization_id, path | Đảm bảo đường dẫn thư mục là duy nhất trong tổ chức |
| document_folders_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| document_folders_parent_id_idx | INDEX | parent_id | Tăng tốc truy vấn theo thư mục cha |
| document_folders_is_system_idx | INDEX | is_system | Tăng tốc truy vấn theo thư mục hệ thống |
| document_folders_is_default_idx | INDEX | is_default | Tăng tốc truy vấn theo thư mục mặc định |
| document_folders_is_public_idx | INDEX | is_public | Tăng tốc truy vấn theo thư mục công khai |
| document_folders_owner_id_idx | INDEX | owner_id | Tăng tốc truy vấn theo người sở hữu |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| document_folders_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| document_folders_parent_id_fkey | FOREIGN KEY | Tham chiếu đến bảng document_folders(id) |
| document_folders_owner_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| document_folders_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| document_folders_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| document_folders_no_self_reference | CHECK | Đảm bảo parent_id != id |
| document_folders_color_check | CHECK | Đảm bảo color có định dạng mã màu hợp lệ |

### 3.5. Ví dụ JSON

```json
{
  "id": "f1o2l3d4-e5r6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Hợp đồng",
  "description": "Thư mục chứa các hợp đồng và tài liệu pháp lý",
  "parent_id": null,
  "path": "/hop-dong",
  "color": "#4caf50",
  "icon": "file-contract",
  "is_system": false,
  "is_default": false,
  "is_public": false,
  "owner_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG DOCUMENT_VERSIONS

### 4.1. Mô tả

Bảng `document_versions` lưu trữ thông tin về các phiên bản tài liệu trong hệ thống.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| document_id | uuid | false | | Khóa ngoại tới bảng documents |
| version | varchar(20) | false | | Số phiên bản |
| file_id | uuid | false | | Khóa ngoại tới bảng media_items, tệp phiên bản |
| file_size | integer | false | | Kích thước tệp (bytes) |
| content | text | true | null | Nội dung tài liệu (cho tài liệu văn bản) |
| changes | text | true | null | Mô tả thay đổi |
| is_major | boolean | false | true | Đánh dấu là phiên bản chính |
| is_current | boolean | false | false | Đánh dấu là phiên bản hiện tại |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| created_by | uuid | true | null | ID người tạo |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| document_versions_pkey | PRIMARY KEY | id | Khóa chính |
| document_versions_document_version_idx | UNIQUE | document_id, version | Đảm bảo số phiên bản là duy nhất cho mỗi tài liệu |
| document_versions_document_id_idx | INDEX | document_id | Tăng tốc truy vấn theo tài liệu |
| document_versions_file_id_idx | INDEX | file_id | Tăng tốc truy vấn theo tệp |
| document_versions_is_major_idx | INDEX | is_major | Tăng tốc truy vấn theo phiên bản chính |
| document_versions_is_current_idx | INDEX | is_current | Tăng tốc truy vấn theo phiên bản hiện tại |
| document_versions_created_by_idx | INDEX | created_by | Tăng tốc truy vấn theo người tạo |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| document_versions_document_id_fkey | FOREIGN KEY | Tham chiếu đến bảng documents(id) |
| document_versions_file_id_fkey | FOREIGN KEY | Tham chiếu đến bảng media_items(id) |
| document_versions_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| document_versions_file_size_check | CHECK | Đảm bảo file_size > 0 |

### 4.5. Ví dụ JSON

```json
{
  "id": "v1e2r3s4-i5o6-7890-abcd-ef1234567890",
  "document_id": "d1o2c3u4-m5e6-7890-abcd-ef1234567890",
  "version": "1.2",
  "file_id": "f1i2l3e4-i5d6-7890-abcd-ef1234567891",
  "file_size": 1250000,
  "content": null,
  "changes": "Cập nhật điều khoản thanh toán và thời hạn hợp đồng",
  "is_major": true,
  "is_current": true,
  "created_at": "2023-06-01T14:00:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
