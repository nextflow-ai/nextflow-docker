# SCHEMA HỆ THỐNG - ROLE VÀ PERMISSION

## 1. GIỚI THIỆU

Schema Role và Permission quản lý phân quyền và vai trò trong hệ thống NextFlow CRM-AI, cho phép kiểm soát chi tiết quyền truy cập của người dùng đến các tài nguyên và chức năng. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến vai trò và phân quyền trong hệ thống.

### 1.1. Mục đích

Schema Role và Permission phục vụ các mục đích sau:

- Quản lý vai trò (role) trong hệ thống
- Quản lý quyền (permission) chi tiết
- Phân quyền dựa trên vai trò (RBAC - Role-Based Access Control)
- Phân quyền dựa trên thuộc tính (ABAC - Attribute-Based Access Control)
- Hỗ trợ phân quyền đa cấp và kế thừa quyền

### 1.2. Các bảng chính

Schema Role và Permission bao gồm các bảng chính sau:

1. `roles` - Lưu trữ thông tin về vai trò
2. `permissions` - Lưu trữ thông tin về quyền
3. `role_permissions` - Bảng trung gian liên kết vai trò và quyền
4. `user_roles` - Bảng trung gian liên kết người dùng và vai trò
5. `permission_categories` - Lưu trữ thông tin về danh mục quyền
6. `role_hierarchies` - Lưu trữ thông tin về cấu trúc phân cấp vai trò
7. `user_permissions` - Lưu trữ quyền đặc biệt của người dùng

## 2. BẢNG ROLES

### 2.1. Mô tả

Bảng `roles` lưu trữ thông tin về các vai trò trong hệ thống. Mỗi vai trò đại diện cho một tập hợp các quyền và trách nhiệm.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của vai trò |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức của vai trò |
| name | varchar(50) | false | | Tên vai trò |
| display_name | varchar(100) | false | | Tên hiển thị của vai trò |
| description | text | true | null | Mô tả về vai trò |
| is_system | boolean | false | false | Đánh dấu vai trò hệ thống (không thể xóa) |
| is_default | boolean | false | false | Đánh dấu vai trò mặc định cho người dùng mới |
| scope | varchar(50) | false | 'organization' | Phạm vi của vai trò: organization, team, project |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| roles_pkey | PRIMARY KEY | id | Khóa chính |
| roles_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên vai trò là duy nhất trong tổ chức |
| roles_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| roles_is_system_idx | INDEX | is_system | Tăng tốc truy vấn vai trò hệ thống |
| roles_is_default_idx | INDEX | is_default | Tăng tốc truy vấn vai trò mặc định |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| roles_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| roles_scope_check | CHECK | Đảm bảo scope chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "r1s2t3u4-v5w6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "admin",
  "display_name": "Quản trị viên",
  "description": "Quản trị viên có toàn quyền truy cập và quản lý hệ thống",
  "is_system": true,
  "is_default": false,
  "scope": "organization",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null
}
```

## 3. BẢNG PERMISSIONS

### 3.1. Mô tả

Bảng `permissions` lưu trữ thông tin về các quyền trong hệ thống. Mỗi quyền đại diện cho một hành động cụ thể trên một tài nguyên.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của quyền |
| category_id | uuid | true | null | Khóa ngoại tới bảng permission_categories |
| name | varchar(100) | false | | Tên quyền, thường theo định dạng action:resource |
| display_name | varchar(100) | false | | Tên hiển thị của quyền |
| description | text | true | null | Mô tả về quyền |
| resource | varchar(50) | false | | Tài nguyên mà quyền áp dụng (users, customers, products, etc.) |
| action | varchar(50) | false | | Hành động trên tài nguyên (create, read, update, delete, etc.) |
| is_system | boolean | false | false | Đánh dấu quyền hệ thống (không thể xóa) |
| conditions | jsonb | true | null | Điều kiện áp dụng quyền (ABAC) |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| permissions_pkey | PRIMARY KEY | id | Khóa chính |
| permissions_name_idx | UNIQUE | name | Đảm bảo tên quyền là duy nhất |
| permissions_resource_action_idx | INDEX | resource, action | Tăng tốc truy vấn theo tài nguyên và hành động |
| permissions_category_id_idx | INDEX | category_id | Tăng tốc truy vấn theo danh mục |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| permissions_category_id_fkey | FOREIGN KEY | Tham chiếu đến bảng permission_categories(id) |
| permissions_action_check | CHECK | Đảm bảo action chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "p1q2r3s4-t5u6-7890-abcd-ef1234567890",
  "category_id": "c1a2t3e4-g5o6-7890-abcd-ef1234567890",
  "name": "create:customers",
  "display_name": "Tạo khách hàng",
  "description": "Cho phép tạo khách hàng mới trong hệ thống",
  "resource": "customers",
  "action": "create",
  "is_system": true,
  "conditions": {
    "attributes": {
      "organization_id": "${user.organization_id}"
    }
  },
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z"
}
```

## 4. BẢNG ROLE_PERMISSIONS

### 4.1. Mô tả

Bảng `role_permissions` là bảng trung gian liên kết vai trò và quyền, thể hiện mối quan hệ nhiều-nhiều giữa vai trò và quyền.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| role_id | uuid | false | | Khóa ngoại tới bảng roles |
| permission_id | uuid | false | | Khóa ngoại tới bảng permissions |
| conditions | jsonb | true | null | Điều kiện áp dụng quyền cho vai trò (ABAC) |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| role_permissions_pkey | PRIMARY KEY | id | Khóa chính |
| role_permissions_role_permission_idx | UNIQUE | role_id, permission_id | Đảm bảo mỗi quyền chỉ được gán một lần cho mỗi vai trò |
| role_permissions_role_id_idx | INDEX | role_id | Tăng tốc truy vấn theo vai trò |
| role_permissions_permission_id_idx | INDEX | permission_id | Tăng tốc truy vấn theo quyền |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| role_permissions_role_id_fkey | FOREIGN KEY | Tham chiếu đến bảng roles(id) |
| role_permissions_permission_id_fkey | FOREIGN KEY | Tham chiếu đến bảng permissions(id) |

### 4.5. Ví dụ JSON

```json
{
  "id": "rp1q2r3-s4t5-7890-abcd-ef1234567890",
  "role_id": "r1s2t3u4-v5w6-7890-abcd-ef1234567890",
  "permission_id": "p1q2r3s4-t5u6-7890-abcd-ef1234567890",
  "conditions": {
    "attributes": {
      "team_id": "${user.team_id}"
    }
  },
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z"
}
```

## 5. BẢNG USER_ROLES

### 5.1. Mô tả

Bảng `user_roles` là bảng trung gian liên kết người dùng và vai trò, thể hiện mối quan hệ nhiều-nhiều giữa người dùng và vai trò.

### 5.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| user_id | uuid | false | | Khóa ngoại tới bảng users |
| role_id | uuid | false | | Khóa ngoại tới bảng roles |
| scope_type | varchar(50) | true | null | Loại phạm vi: organization, team, project |
| scope_id | uuid | true | null | ID của phạm vi |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 5.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| user_roles_pkey | PRIMARY KEY | id | Khóa chính |
| user_roles_user_role_scope_idx | UNIQUE | user_id, role_id, scope_type, scope_id | Đảm bảo mỗi vai trò chỉ được gán một lần cho mỗi người dùng trong mỗi phạm vi |
| user_roles_user_id_idx | INDEX | user_id | Tăng tốc truy vấn theo người dùng |
| user_roles_role_id_idx | INDEX | role_id | Tăng tốc truy vấn theo vai trò |
| user_roles_scope_idx | INDEX | scope_type, scope_id | Tăng tốc truy vấn theo phạm vi |

### 5.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| user_roles_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| user_roles_role_id_fkey | FOREIGN KEY | Tham chiếu đến bảng roles(id) |
| user_roles_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| user_roles_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| user_roles_scope_type_check | CHECK | Đảm bảo scope_type chỉ nhận các giá trị cho phép |

### 5.5. Ví dụ JSON

```json
{
  "id": "ur1q2r3-s4t5-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "role_id": "r1s2t3u4-v5w6-7890-abcd-ef1234567890",
  "scope_type": "team",
  "scope_id": "t1e2a3m4-i5d6-7890-abcd-ef1234567890",
  "created_at": "2023-01-10T09:00:00Z",
  "updated_at": "2023-01-10T09:00:00Z",
  "created_by": "c1d2e3f4-g5h6-7890-abcd-ef1234567890",
  "updated_by": "c1d2e3f4-g5h6-7890-abcd-ef1234567890"
}
```

## 6. BẢNG PERMISSION_CATEGORIES

### 6.1. Mô tả

Bảng `permission_categories` lưu trữ thông tin về các danh mục quyền, giúp tổ chức và nhóm các quyền liên quan.

### 6.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| name | varchar(50) | false | | Tên danh mục |
| display_name | varchar(100) | false | | Tên hiển thị của danh mục |
| description | text | true | null | Mô tả về danh mục |
| parent_id | uuid | true | null | ID của danh mục cha |
| order | integer | false | 0 | Thứ tự hiển thị |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 6.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| permission_categories_pkey | PRIMARY KEY | id | Khóa chính |
| permission_categories_name_idx | UNIQUE | name | Đảm bảo tên danh mục là duy nhất |
| permission_categories_parent_id_idx | INDEX | parent_id | Tăng tốc truy vấn theo danh mục cha |

### 6.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| permission_categories_parent_id_fkey | FOREIGN KEY | Tham chiếu đến bảng permission_categories(id) |

### 6.5. Ví dụ JSON

```json
{
  "id": "c1a2t3e4-g5o6-7890-abcd-ef1234567890",
  "name": "customer_management",
  "display_name": "Quản lý khách hàng",
  "description": "Các quyền liên quan đến quản lý khách hàng",
  "parent_id": null,
  "order": 1,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z"
}
```

## 7. BẢNG ROLE_HIERARCHIES

### 7.1. Mô tả

Bảng `role_hierarchies` lưu trữ thông tin về cấu trúc phân cấp vai trò, cho phép kế thừa quyền từ vai trò cha.

### 7.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| parent_role_id | uuid | false | | Khóa ngoại tới bảng roles, vai trò cha |
| child_role_id | uuid | false | | Khóa ngoại tới bảng roles, vai trò con |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 7.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| role_hierarchies_pkey | PRIMARY KEY | id | Khóa chính |
| role_hierarchies_parent_child_idx | UNIQUE | parent_role_id, child_role_id | Đảm bảo mỗi quan hệ cha-con chỉ tồn tại một lần |
| role_hierarchies_parent_role_id_idx | INDEX | parent_role_id | Tăng tốc truy vấn theo vai trò cha |
| role_hierarchies_child_role_id_idx | INDEX | child_role_id | Tăng tốc truy vấn theo vai trò con |

### 7.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| role_hierarchies_parent_role_id_fkey | FOREIGN KEY | Tham chiếu đến bảng roles(id) |
| role_hierarchies_child_role_id_fkey | FOREIGN KEY | Tham chiếu đến bảng roles(id) |
| role_hierarchies_no_self_reference | CHECK | Đảm bảo vai trò không tham chiếu đến chính nó |

### 7.5. Ví dụ JSON

```json
{
  "id": "rh1q2r3-s4t5-7890-abcd-ef1234567890",
  "parent_role_id": "r1s2t3u4-v5w6-7890-abcd-ef1234567890",
  "child_role_id": "c1h2i3l4-d5r6-7890-abcd-ef1234567890",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z"
}
```

## 8. BẢNG USER_PERMISSIONS

### 8.1. Mô tả

Bảng `user_permissions` lưu trữ quyền đặc biệt của người dùng, cho phép gán quyền trực tiếp cho người dùng mà không thông qua vai trò.

### 8.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| user_id | uuid | false | | Khóa ngoại tới bảng users |
| permission_id | uuid | false | | Khóa ngoại tới bảng permissions |
| granted | boolean | false | true | Trạng thái cấp quyền (true) hoặc từ chối quyền (false) |
| conditions | jsonb | true | null | Điều kiện áp dụng quyền (ABAC) |
| scope_type | varchar(50) | true | null | Loại phạm vi: organization, team, project |
| scope_id | uuid | true | null | ID của phạm vi |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 8.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| user_permissions_pkey | PRIMARY KEY | id | Khóa chính |
| user_permissions_user_permission_scope_idx | UNIQUE | user_id, permission_id, scope_type, scope_id | Đảm bảo mỗi quyền chỉ được gán một lần cho mỗi người dùng trong mỗi phạm vi |
| user_permissions_user_id_idx | INDEX | user_id | Tăng tốc truy vấn theo người dùng |
| user_permissions_permission_id_idx | INDEX | permission_id | Tăng tốc truy vấn theo quyền |
| user_permissions_scope_idx | INDEX | scope_type, scope_id | Tăng tốc truy vấn theo phạm vi |

### 8.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| user_permissions_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| user_permissions_permission_id_fkey | FOREIGN KEY | Tham chiếu đến bảng permissions(id) |
| user_permissions_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| user_permissions_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| user_permissions_scope_type_check | CHECK | Đảm bảo scope_type chỉ nhận các giá trị cho phép |

### 8.5. Ví dụ JSON

```json
{
  "id": "up1q2r3-s4t5-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "permission_id": "p1q2r3s4-t5u6-7890-abcd-ef1234567890",
  "granted": true,
  "conditions": {
    "attributes": {
      "customer_id": ["${user.managed_customer_ids}"]
    }
  },
  "scope_type": "team",
  "scope_id": "t1e2a3m4-i5d6-7890-abcd-ef1234567890",
  "created_at": "2023-01-10T09:00:00Z",
  "updated_at": "2023-01-10T09:00:00Z",
  "created_by": "c1d2e3f4-g5h6-7890-abcd-ef1234567890",
  "updated_by": "c1d2e3f4-g5h6-7890-abcd-ef1234567890"
}
```
