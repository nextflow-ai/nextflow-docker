# SCHEMA TÍNH NĂNG - NHÂN SỰ

## 1. GIỚI THIỆU

Schema Nhân sự quản lý thông tin về nhân viên, chấm công, đánh giá hiệu suất và các hoạt động liên quan đến quản lý nhân sự trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến nhân sự trong hệ thống.

### 1.1. Mục đích

Schema Nhân sự phục vụ các mục đích sau:

- Lưu trữ thông tin chi tiết về nhân viên
- Quản lý cấu trúc tổ chức và phòng ban
- Theo dõi chấm công và giờ làm việc
- Quản lý đánh giá hiệu suất
- Theo dõi đào tạo và phát triển nhân viên
- Quản lý quyền lợi và phúc lợi

### 1.2. Các bảng chính

Schema Nhân sự bao gồm các bảng chính sau:

1. `employees` - Lưu trữ thông tin về nhân viên
2. `departments` - Lưu trữ thông tin về phòng ban
3. `positions` - Lưu trữ thông tin về vị trí công việc
4. `attendance` - Lưu trữ thông tin chấm công
5. `leave_requests` - Lưu trữ thông tin yêu cầu nghỉ phép
6. `performance_reviews` - Lưu trữ thông tin đánh giá hiệu suất
7. `training` - Lưu trữ thông tin đào tạo
8. `benefits` - Lưu trữ thông tin quyền lợi và phúc lợi

## 2. BẢNG EMPLOYEES

### 2.1. Mô tả

Bảng `employees` lưu trữ thông tin chi tiết về nhân viên trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của nhân viên |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| user_id | uuid | true | null | Khóa ngoại tới bảng users |
| employee_code | varchar(50) | false | | Mã nhân viên |
| first_name | varchar(50) | false | | Tên của nhân viên |
| last_name | varchar(50) | false | | Họ của nhân viên |
| full_name | varchar(100) | false | | Họ và tên đầy đủ |
| email | varchar(255) | false | | Địa chỉ email công việc |
| personal_email | varchar(255) | true | null | Địa chỉ email cá nhân |
| phone | varchar(20) | true | null | Số điện thoại công việc |
| personal_phone | varchar(20) | true | null | Số điện thoại cá nhân |
| date_of_birth | date | true | null | Ngày sinh |
| gender | varchar(10) | true | null | Giới tính: male, female, other |
| marital_status | varchar(20) | true | null | Tình trạng hôn nhân: single, married, divorced, etc. |
| nationality | varchar(50) | true | null | Quốc tịch |
| id_card_number | varchar(20) | true | null | Số CMND/CCCD |
| id_card_issue_date | date | true | null | Ngày cấp CMND/CCCD |
| id_card_issue_place | varchar(100) | true | null | Nơi cấp CMND/CCCD |
| passport_number | varchar(20) | true | null | Số hộ chiếu |
| passport_expiry_date | date | true | null | Ngày hết hạn hộ chiếu |
| tax_id | varchar(20) | true | null | Mã số thuế cá nhân |
| social_insurance | varchar(20) | true | null | Số bảo hiểm xã hội |
| health_insurance | varchar(20) | true | null | Số bảo hiểm y tế |
| address | text | true | null | Địa chỉ hiện tại |
| permanent_address | text | true | null | Địa chỉ thường trú |
| emergency_contact_name | varchar(100) | true | null | Tên người liên hệ khẩn cấp |
| emergency_contact_phone | varchar(20) | true | null | Số điện thoại liên hệ khẩn cấp |
| emergency_contact_relation | varchar(50) | true | null | Mối quan hệ với người liên hệ khẩn cấp |
| department_id | uuid | true | null | Khóa ngoại tới bảng departments |
| position_id | uuid | true | null | Khóa ngoại tới bảng positions |
| manager_id | uuid | true | null | Khóa ngoại tới bảng employees, người quản lý |
| employment_type | varchar(50) | false | 'full_time' | Loại hợp đồng: full_time, part_time, contract, intern, etc. |
| employment_status | varchar(50) | false | 'active' | Trạng thái làm việc: active, probation, terminated, resigned, etc. |
| hire_date | date | false | | Ngày tuyển dụng |
| probation_end_date | date | true | null | Ngày kết thúc thử việc |
| termination_date | date | true | null | Ngày nghỉ việc |
| termination_reason | text | true | null | Lý do nghỉ việc |
| salary | decimal(15,2) | true | null | Lương cơ bản |
| salary_currency | varchar(3) | true | 'VND' | Đơn vị tiền tệ lương |
| bank_name | varchar(100) | true | null | Tên ngân hàng |
| bank_account | varchar(50) | true | null | Số tài khoản ngân hàng |
| bank_account_name | varchar(100) | true | null | Tên chủ tài khoản |
| education_level | varchar(50) | true | null | Trình độ học vấn |
| education_major | varchar(100) | true | null | Chuyên ngành |
| skills | jsonb | true | null | Kỹ năng |
| notes | text | true | null | Ghi chú |
| avatar_url | varchar(255) | true | null | URL ảnh đại diện |
| documents | jsonb | true | null | Tài liệu liên quan |
| custom_fields | jsonb | true | null | Trường tùy chỉnh |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| employees_pkey | PRIMARY KEY | id | Khóa chính |
| employees_organization_code_idx | UNIQUE | organization_id, employee_code | Đảm bảo mã nhân viên là duy nhất trong tổ chức |
| employees_user_id_idx | UNIQUE | user_id | Đảm bảo mỗi user chỉ liên kết với một nhân viên |
| employees_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| employees_department_id_idx | INDEX | department_id | Tăng tốc truy vấn theo phòng ban |
| employees_position_id_idx | INDEX | position_id | Tăng tốc truy vấn theo vị trí |
| employees_manager_id_idx | INDEX | manager_id | Tăng tốc truy vấn theo người quản lý |
| employees_employment_type_idx | INDEX | employment_type | Tăng tốc truy vấn theo loại hợp đồng |
| employees_employment_status_idx | INDEX | employment_status | Tăng tốc truy vấn theo trạng thái làm việc |
| employees_hire_date_idx | INDEX | hire_date | Tăng tốc truy vấn theo ngày tuyển dụng |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| employees_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| employees_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| employees_department_id_fkey | FOREIGN KEY | Tham chiếu đến bảng departments(id) |
| employees_position_id_fkey | FOREIGN KEY | Tham chiếu đến bảng positions(id) |
| employees_manager_id_fkey | FOREIGN KEY | Tham chiếu đến bảng employees(id) |
| employees_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| employees_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| employees_employment_type_check | CHECK | Đảm bảo employment_type chỉ nhận các giá trị cho phép |
| employees_employment_status_check | CHECK | Đảm bảo employment_status chỉ nhận các giá trị cho phép |
| employees_gender_check | CHECK | Đảm bảo gender chỉ nhận các giá trị cho phép |
| employees_marital_status_check | CHECK | Đảm bảo marital_status chỉ nhận các giá trị cho phép |
| employees_email_check | CHECK | Đảm bảo email có định dạng hợp lệ |
| employees_personal_email_check | CHECK | Đảm bảo personal_email có định dạng hợp lệ |

### 2.5. Ví dụ JSON

```json
{
  "id": "e1m2p3l4-o5y6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "employee_code": "EMP-2023-001",
  "first_name": "Văn A",
  "last_name": "Nguyễn",
  "full_name": "Nguyễn Văn A",
  "email": "nguyenvana@NextFlow.com",
  "personal_email": "nguyenvana@gmail.com",
  "phone": "+84901234567",
  "personal_phone": "+84987654321",
  "date_of_birth": "1990-05-15",
  "gender": "male",
  "marital_status": "married",
  "nationality": "Việt Nam",
  "id_card_number": "012345678901",
  "id_card_issue_date": "2015-01-01",
  "id_card_issue_place": "Công an TP.HCM",
  "passport_number": "P1234567",
  "passport_expiry_date": "2030-01-01",
  "tax_id": "1234567890",
  "social_insurance": "0123456789",
  "health_insurance": "0123456789",
  "address": "123 Đường Lê Lợi, Quận 1, TP.HCM",
  "permanent_address": "456 Đường Nguyễn Huệ, Quận 1, TP.HCM",
  "emergency_contact_name": "Nguyễn Thị B",
  "emergency_contact_phone": "+84912345678",
  "emergency_contact_relation": "Vợ",
  "department_id": "d1e2p3t4-i5d6-7890-abcd-ef1234567890",
  "position_id": "p1o2s3i4-t5i6-7890-abcd-ef1234567890",
  "manager_id": "m1a2n3a4-g5e6-7890-abcd-ef1234567890",
  "employment_type": "full_time",
  "employment_status": "active",
  "hire_date": "2023-01-15",
  "probation_end_date": "2023-04-15",
  "termination_date": null,
  "termination_reason": null,
  "salary": 15000000.00,
  "salary_currency": "VND",
  "bank_name": "Vietcombank",
  "bank_account": "1234567890",
  "bank_account_name": "NGUYEN VAN A",
  "education_level": "bachelor",
  "education_major": "Computer Science",
  "skills": [
    {"name": "JavaScript", "level": "expert"},
    {"name": "React", "level": "advanced"},
    {"name": "Node.js", "level": "intermediate"},
    {"name": "SQL", "level": "advanced"}
  ],
  "notes": "Nhân viên xuất sắc, có tinh thần làm việc nhóm tốt",
  "avatar_url": "https://assets.NextFlow.com/employees/nguyenvana.jpg",
  "documents": [
    {"name": "Hợp đồng lao động", "url": "https://docs.NextFlow.com/contracts/EMP-2023-001.pdf"},
    {"name": "Bằng cấp", "url": "https://docs.NextFlow.com/certificates/EMP-2023-001.pdf"}
  ],
  "custom_fields": {
    "preferred_working_hours": "9:00 - 18:00",
    "t_shirt_size": "L",
    "food_preference": "No restrictions"
  },
  "created_at": "2023-01-10T09:00:00Z",
  "updated_at": "2023-06-15T14:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG DEPARTMENTS

### 3.1. Mô tả

Bảng `departments` lưu trữ thông tin về các phòng ban trong tổ chức.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(100) | false | | Tên phòng ban |
| code | varchar(50) | false | | Mã phòng ban |
| description | text | true | null | Mô tả phòng ban |
| parent_id | uuid | true | null | Khóa ngoại tới bảng departments, phòng ban cha |
| manager_id | uuid | true | null | Khóa ngoại tới bảng employees, trưởng phòng |
| location | varchar(100) | true | null | Địa điểm phòng ban |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| departments_pkey | PRIMARY KEY | id | Khóa chính |
| departments_organization_code_idx | UNIQUE | organization_id, code | Đảm bảo mã phòng ban là duy nhất trong tổ chức |
| departments_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| departments_parent_id_idx | INDEX | parent_id | Tăng tốc truy vấn theo phòng ban cha |
| departments_manager_id_idx | INDEX | manager_id | Tăng tốc truy vấn theo trưởng phòng |
| departments_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| departments_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| departments_parent_id_fkey | FOREIGN KEY | Tham chiếu đến bảng departments(id) |
| departments_manager_id_fkey | FOREIGN KEY | Tham chiếu đến bảng employees(id) |
| departments_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| departments_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| departments_no_self_reference | CHECK | Đảm bảo parent_id != id |

### 3.5. Ví dụ JSON

```json
{
  "id": "d1e2p3t4-i5d6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Phòng Công nghệ",
  "code": "TECH",
  "description": "Phòng phát triển và quản lý công nghệ của công ty",
  "parent_id": null,
  "manager_id": "m1a2n3a4-g5e6-7890-abcd-ef1234567890",
  "location": "Tầng 5, Tòa nhà ABC, Quận 1, TP.HCM",
  "is_active": true,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG POSITIONS

### 4.1. Mô tả

Bảng `positions` lưu trữ thông tin về các vị trí công việc trong tổ chức.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(100) | false | | Tên vị trí |
| code | varchar(50) | false | | Mã vị trí |
| description | text | true | null | Mô tả vị trí |
| department_id | uuid | true | null | Khóa ngoại tới bảng departments |
| job_level | varchar(50) | true | null | Cấp bậc: entry, junior, senior, lead, manager, director, etc. |
| min_salary | decimal(15,2) | true | null | Lương tối thiểu |
| max_salary | decimal(15,2) | true | null | Lương tối đa |
| salary_currency | varchar(3) | true | 'VND' | Đơn vị tiền tệ lương |
| responsibilities | text | true | null | Trách nhiệm công việc |
| requirements | text | true | null | Yêu cầu công việc |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| positions_pkey | PRIMARY KEY | id | Khóa chính |
| positions_organization_code_idx | UNIQUE | organization_id, code | Đảm bảo mã vị trí là duy nhất trong tổ chức |
| positions_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| positions_department_id_idx | INDEX | department_id | Tăng tốc truy vấn theo phòng ban |
| positions_job_level_idx | INDEX | job_level | Tăng tốc truy vấn theo cấp bậc |
| positions_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| positions_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| positions_department_id_fkey | FOREIGN KEY | Tham chiếu đến bảng departments(id) |
| positions_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| positions_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| positions_job_level_check | CHECK | Đảm bảo job_level chỉ nhận các giá trị cho phép |
| positions_salary_check | CHECK | Đảm bảo min_salary <= max_salary khi cả hai không null |

### 4.5. Ví dụ JSON

```json
{
  "id": "p1o2s3i4-t5i6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Kỹ sư Phát triển Phần mềm",
  "code": "SDE",
  "description": "Phát triển và bảo trì các ứng dụng phần mềm của công ty",
  "department_id": "d1e2p3t4-i5d6-7890-abcd-ef1234567890",
  "job_level": "senior",
  "min_salary": 20000000.00,
  "max_salary": 35000000.00,
  "salary_currency": "VND",
  "responsibilities": "- Phát triển và bảo trì các ứng dụng phần mềm\n- Tham gia vào quá trình thiết kế và kiến trúc hệ thống\n- Viết mã nguồn chất lượng cao và có thể tái sử dụng\n- Tối ưu hóa hiệu suất ứng dụng",
  "requirements": "- Tối thiểu 3 năm kinh nghiệm phát triển phần mềm\n- Thành thạo JavaScript, TypeScript, React, Node.js\n- Hiểu biết về cơ sở dữ liệu SQL và NoSQL\n- Kinh nghiệm làm việc với Docker, Kubernetes là một lợi thế",
  "is_active": true,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
