# SCHEMA TÍNH NĂNG - QUẢN LÝ DỰ ÁN

## 1. GIỚI THIỆU

Schema Quản lý Dự án quản lý thông tin về các dự án, công việc, nhiệm vụ và các hoạt động liên quan đến quản lý dự án trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến quản lý dự án trong hệ thống.

### 1.1. Mục đích

Schema Quản lý Dự án phục vụ các mục đích sau:

- Lưu trữ thông tin về các dự án và công việc
- Quản lý nhiệm vụ và phân công công việc
- Theo dõi tiến độ và trạng thái dự án
- Quản lý tài nguyên và thời gian
- Hỗ trợ cộng tác và giao tiếp trong dự án
- Báo cáo và phân tích hiệu suất dự án

### 1.2. Các bảng chính

Schema Quản lý Dự án bao gồm các bảng chính sau:

1. `projects` - Lưu trữ thông tin về các dự án
2. `project_tasks` - Lưu trữ thông tin về các nhiệm vụ trong dự án
3. `project_milestones` - Lưu trữ thông tin về các cột mốc dự án
4. `project_members` - Lưu trữ thông tin về thành viên dự án
5. `project_comments` - Lưu trữ thông tin về bình luận trong dự án
6. `project_time_entries` - Lưu trữ thông tin về thời gian làm việc

## 2. BẢNG PROJECTS

### 2.1. Mô tả

Bảng `projects` lưu trữ thông tin về các dự án trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của dự án |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên dự án |
| code | varchar(20) | false | | Mã dự án |
| description | text | true | null | Mô tả dự án |
| customer_id | uuid | true | null | Khóa ngoại tới bảng customers, khách hàng |
| manager_id | uuid | true | null | Khóa ngoại tới bảng users, người quản lý dự án |
| status | varchar(20) | false | 'planning' | Trạng thái: planning, active, on_hold, completed, cancelled |
| priority | varchar(20) | false | 'medium' | Mức độ ưu tiên: low, medium, high, urgent |
| start_date | date | true | null | Ngày bắt đầu |
| end_date | date | true | null | Ngày kết thúc |
| estimated_hours | decimal(10,2) | true | null | Số giờ ước tính |
| actual_hours | decimal(10,2) | true | null | Số giờ thực tế |
| completion_percentage | decimal(5,2) | false | 0 | Phần trăm hoàn thành |
| budget | decimal(15,2) | true | null | Ngân sách |
| budget_spent | decimal(15,2) | true | null | Ngân sách đã chi |
| currency | varchar(3) | false | 'VND' | Đơn vị tiền tệ |
| billing_type | varchar(20) | false | 'fixed' | Loại thanh toán: fixed, hourly, non_billable |
| billing_rate | decimal(15,2) | true | null | Tỷ lệ thanh toán |
| is_billable | boolean | false | true | Đánh dấu là có thể thanh toán |
| is_internal | boolean | false | false | Đánh dấu là dự án nội bộ |
| is_template | boolean | false | false | Đánh dấu là mẫu dự án |
| color | varchar(7) | true | null | Mã màu dự án |
| tags | jsonb | true | null | Thẻ dự án |
| custom_fields | jsonb | true | null | Trường tùy chỉnh |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| projects_pkey | PRIMARY KEY | id | Khóa chính |
| projects_organization_code_idx | UNIQUE | organization_id, code | Đảm bảo mã dự án là duy nhất trong tổ chức |
| projects_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| projects_customer_id_idx | INDEX | customer_id | Tăng tốc truy vấn theo khách hàng |
| projects_manager_id_idx | INDEX | manager_id | Tăng tốc truy vấn theo người quản lý |
| projects_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| projects_priority_idx | INDEX | priority | Tăng tốc truy vấn theo mức độ ưu tiên |
| projects_start_date_idx | INDEX | start_date | Tăng tốc truy vấn theo ngày bắt đầu |
| projects_end_date_idx | INDEX | end_date | Tăng tốc truy vấn theo ngày kết thúc |
| projects_is_billable_idx | INDEX | is_billable | Tăng tốc truy vấn theo khả năng thanh toán |
| projects_is_internal_idx | INDEX | is_internal | Tăng tốc truy vấn theo dự án nội bộ |
| projects_is_template_idx | INDEX | is_template | Tăng tốc truy vấn theo mẫu dự án |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| projects_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| projects_customer_id_fkey | FOREIGN KEY | Tham chiếu đến bảng customers(id) |
| projects_manager_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| projects_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| projects_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| projects_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| projects_priority_check | CHECK | Đảm bảo priority chỉ nhận các giá trị cho phép |
| projects_billing_type_check | CHECK | Đảm bảo billing_type chỉ nhận các giá trị cho phép |
| projects_date_check | CHECK | Đảm bảo end_date >= start_date khi cả hai không null |
| projects_completion_percentage_check | CHECK | Đảm bảo completion_percentage >= 0 và completion_percentage <= 100 |
| projects_estimated_hours_check | CHECK | Đảm bảo estimated_hours > 0 khi không null |
| projects_actual_hours_check | CHECK | Đảm bảo actual_hours >= 0 khi không null |
| projects_budget_check | CHECK | Đảm bảo budget > 0 khi không null |
| projects_budget_spent_check | CHECK | Đảm bảo budget_spent >= 0 khi không null |
| projects_billing_rate_check | CHECK | Đảm bảo billing_rate > 0 khi không null |
| projects_color_check | CHECK | Đảm bảo color có định dạng mã màu hợp lệ |

### 2.5. Ví dụ JSON

```json
{
  "id": "p1r2o3j4-e5c6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Triển khai NextFlow CRM-AI cho Công ty ABC",
  "code": "PRJ-2023-001",
  "description": "Dự án triển khai hệ thống NextFlow CRM-AI cho Công ty ABC, bao gồm các module quản lý khách hàng, bán hàng và marketing",
  "customer_id": "c1u2s3t4-o5m6-7890-abcd-ef1234567890",
  "manager_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "status": "active",
  "priority": "high",
  "start_date": "2023-07-01",
  "end_date": "2023-09-30",
  "estimated_hours": 320.00,
  "actual_hours": 180.50,
  "completion_percentage": 56.25,
  "budget": 150000000.00,
  "budget_spent": 85000000.00,
  "currency": "VND",
  "billing_type": "fixed",
  "billing_rate": null,
  "is_billable": true,
  "is_internal": false,
  "is_template": false,
  "color": "#1976d2",
  "tags": ["crm", "triển khai", "abc"],
  "custom_fields": {
    "contact_person": "Nguyễn Văn A",
    "contact_email": "nguyenvana@abc.com",
    "contact_phone": "+84901234567",
    "contract_number": "HD-2023-001"
  },
  "created_at": "2023-06-15T09:00:00Z",
  "updated_at": "2023-07-15T14:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG PROJECT_TASKS

### 3.1. Mô tả

Bảng `project_tasks` lưu trữ thông tin về các nhiệm vụ trong dự án.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| project_id | uuid | false | | Khóa ngoại tới bảng projects |
| milestone_id | uuid | true | null | Khóa ngoại tới bảng project_milestones |
| parent_id | uuid | true | null | Khóa ngoại tới bảng project_tasks, nhiệm vụ cha |
| name | varchar(255) | false | | Tên nhiệm vụ |
| description | text | true | null | Mô tả nhiệm vụ |
| status | varchar(20) | false | 'to_do' | Trạng thái: to_do, in_progress, review, done, cancelled |
| priority | varchar(20) | false | 'medium' | Mức độ ưu tiên: low, medium, high, urgent |
| assignee_id | uuid | true | null | Khóa ngoại tới bảng users, người được giao |
| reporter_id | uuid | true | null | Khóa ngoại tới bảng users, người báo cáo |
| start_date | date | true | null | Ngày bắt đầu |
| due_date | date | true | null | Ngày đến hạn |
| estimated_hours | decimal(10,2) | true | null | Số giờ ước tính |
| actual_hours | decimal(10,2) | true | null | Số giờ thực tế |
| completion_percentage | decimal(5,2) | false | 0 | Phần trăm hoàn thành |
| is_milestone | boolean | false | false | Đánh dấu là cột mốc |
| is_billable | boolean | false | true | Đánh dấu là có thể thanh toán |
| order | integer | false | 0 | Thứ tự hiển thị |
| tags | jsonb | true | null | Thẻ nhiệm vụ |
| custom_fields | jsonb | true | null | Trường tùy chỉnh |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| project_tasks_pkey | PRIMARY KEY | id | Khóa chính |
| project_tasks_project_id_idx | INDEX | project_id | Tăng tốc truy vấn theo dự án |
| project_tasks_milestone_id_idx | INDEX | milestone_id | Tăng tốc truy vấn theo cột mốc |
| project_tasks_parent_id_idx | INDEX | parent_id | Tăng tốc truy vấn theo nhiệm vụ cha |
| project_tasks_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| project_tasks_priority_idx | INDEX | priority | Tăng tốc truy vấn theo mức độ ưu tiên |
| project_tasks_assignee_id_idx | INDEX | assignee_id | Tăng tốc truy vấn theo người được giao |
| project_tasks_reporter_id_idx | INDEX | reporter_id | Tăng tốc truy vấn theo người báo cáo |
| project_tasks_start_date_idx | INDEX | start_date | Tăng tốc truy vấn theo ngày bắt đầu |
| project_tasks_due_date_idx | INDEX | due_date | Tăng tốc truy vấn theo ngày đến hạn |
| project_tasks_is_milestone_idx | INDEX | is_milestone | Tăng tốc truy vấn theo cột mốc |
| project_tasks_is_billable_idx | INDEX | is_billable | Tăng tốc truy vấn theo khả năng thanh toán |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| project_tasks_project_id_fkey | FOREIGN KEY | Tham chiếu đến bảng projects(id) |
| project_tasks_milestone_id_fkey | FOREIGN KEY | Tham chiếu đến bảng project_milestones(id) |
| project_tasks_parent_id_fkey | FOREIGN KEY | Tham chiếu đến bảng project_tasks(id) |
| project_tasks_assignee_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| project_tasks_reporter_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| project_tasks_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| project_tasks_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| project_tasks_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| project_tasks_priority_check | CHECK | Đảm bảo priority chỉ nhận các giá trị cho phép |
| project_tasks_date_check | CHECK | Đảm bảo due_date >= start_date khi cả hai không null |
| project_tasks_completion_percentage_check | CHECK | Đảm bảo completion_percentage >= 0 và completion_percentage <= 100 |
| project_tasks_estimated_hours_check | CHECK | Đảm bảo estimated_hours > 0 khi không null |
| project_tasks_actual_hours_check | CHECK | Đảm bảo actual_hours >= 0 khi không null |
| project_tasks_order_check | CHECK | Đảm bảo order >= 0 |
| project_tasks_no_self_reference | CHECK | Đảm bảo parent_id != id |

### 3.5. Ví dụ JSON

```json
{
  "id": "t1a2s3k4-i5d6-7890-abcd-ef1234567890",
  "project_id": "p1r2o3j4-e5c6-7890-abcd-ef1234567890",
  "milestone_id": "m1i2l3e4-s5t6-7890-abcd-ef1234567890",
  "parent_id": null,
  "name": "Cài đặt và cấu hình hệ thống NextFlow CRM-AI",
  "description": "Cài đặt và cấu hình hệ thống NextFlow CRM-AI trên máy chủ của khách hàng, bao gồm cấu hình cơ sở dữ liệu và kết nối với các hệ thống hiện có",
  "status": "in_progress",
  "priority": "high",
  "assignee_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "reporter_id": "m1a2n3a4-g5e6-7890-abcd-ef1234567890",
  "start_date": "2023-07-05",
  "due_date": "2023-07-15",
  "estimated_hours": 40.00,
  "actual_hours": 32.50,
  "completion_percentage": 80.00,
  "is_milestone": false,
  "is_billable": true,
  "order": 1,
  "tags": ["cài đặt", "cấu hình", "hệ thống"],
  "custom_fields": {
    "environment": "Production",
    "server_type": "On-premise",
    "complexity": "Medium"
  },
  "created_at": "2023-07-01T10:00:00Z",
  "updated_at": "2023-07-12T15:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG PROJECT_MEMBERS

### 4.1. Mô tả

Bảng `project_members` lưu trữ thông tin về các thành viên dự án.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| project_id | uuid | false | | Khóa ngoại tới bảng projects |
| user_id | uuid | false | | Khóa ngoại tới bảng users |
| role | varchar(50) | false | 'member' | Vai trò: manager, member, viewer, client |
| hourly_rate | decimal(15,2) | true | null | Tỷ lệ giờ |
| allocation_percentage | decimal(5,2) | false | 100 | Phần trăm phân bổ |
| start_date | date | true | null | Ngày bắt đầu |
| end_date | date | true | null | Ngày kết thúc |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| project_members_pkey | PRIMARY KEY | id | Khóa chính |
| project_members_project_user_idx | UNIQUE | project_id, user_id | Đảm bảo mỗi người dùng chỉ là một thành viên trong một dự án |
| project_members_project_id_idx | INDEX | project_id | Tăng tốc truy vấn theo dự án |
| project_members_user_id_idx | INDEX | user_id | Tăng tốc truy vấn theo người dùng |
| project_members_role_idx | INDEX | role | Tăng tốc truy vấn theo vai trò |
| project_members_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| project_members_project_id_fkey | FOREIGN KEY | Tham chiếu đến bảng projects(id) |
| project_members_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| project_members_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| project_members_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| project_members_role_check | CHECK | Đảm bảo role chỉ nhận các giá trị cho phép |
| project_members_hourly_rate_check | CHECK | Đảm bảo hourly_rate > 0 khi không null |
| project_members_allocation_percentage_check | CHECK | Đảm bảo allocation_percentage > 0 và allocation_percentage <= 100 |
| project_members_date_check | CHECK | Đảm bảo end_date >= start_date khi cả hai không null |

### 4.5. Ví dụ JSON

```json
{
  "id": "m1e2m3b4-e5r6-7890-abcd-ef1234567890",
  "project_id": "p1r2o3j4-e5c6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "role": "manager",
  "hourly_rate": 500000.00,
  "allocation_percentage": 50.00,
  "start_date": "2023-07-01",
  "end_date": "2023-09-30",
  "is_active": true,
  "created_at": "2023-06-15T09:30:00Z",
  "updated_at": "2023-06-15T09:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
