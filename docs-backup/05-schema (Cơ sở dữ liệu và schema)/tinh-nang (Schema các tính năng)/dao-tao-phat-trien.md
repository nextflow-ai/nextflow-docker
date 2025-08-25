# SCHEMA TÍNH NĂNG - ĐÀO TẠO VÀ PHÁT TRIỂN

## 1. GIỚI THIỆU

Schema Đào tạo và Phát triển quản lý thông tin về các khóa đào tạo, chương trình phát triển, kỹ năng và chứng chỉ của nhân viên trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến đào tạo và phát triển trong hệ thống.

### 1.1. Mục đích

Schema Đào tạo và Phát triển phục vụ các mục đích sau:

- Lưu trữ thông tin về các khóa đào tạo
- Quản lý chương trình phát triển nhân viên
- Theo dõi kỹ năng và chứng chỉ
- Quản lý đăng ký và tham gia khóa học
- Đánh giá hiệu quả đào tạo
- Lập kế hoạch phát triển cá nhân

### 1.2. Các bảng chính

Schema Đào tạo và Phát triển bao gồm các bảng chính sau:

1. `training_courses` - Lưu trữ thông tin về các khóa đào tạo
2. `training_sessions` - Lưu trữ thông tin về các buổi đào tạo
3. `training_enrollments` - Lưu trữ thông tin đăng ký khóa đào tạo
4. `training_attendances` - Lưu trữ thông tin tham gia buổi đào tạo
5. `skills` - Lưu trữ thông tin về các kỹ năng
6. `employee_skills` - Lưu trữ thông tin kỹ năng của nhân viên
7. `certifications` - Lưu trữ thông tin về các chứng chỉ
8. `employee_certifications` - Lưu trữ thông tin chứng chỉ của nhân viên

## 2. BẢNG TRAINING_COURSES

### 2.1. Mô tả

Bảng `training_courses` lưu trữ thông tin về các khóa đào tạo trong tổ chức.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của khóa đào tạo |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(255) | false | | Tên khóa đào tạo |
| code | varchar(50) | false | | Mã khóa đào tạo |
| description | text | true | null | Mô tả khóa đào tạo |
| category | varchar(50) | true | null | Danh mục khóa đào tạo: technical, soft_skills, leadership, compliance, etc. |
| type | varchar(50) | false | 'internal' | Loại khóa đào tạo: internal, external, online, offline |
| level | varchar(20) | true | null | Cấp độ: beginner, intermediate, advanced, expert |
| duration | integer | true | null | Thời lượng (giờ) |
| cost | decimal(15,2) | true | null | Chi phí |
| currency | varchar(3) | true | 'VND' | Đơn vị tiền tệ |
| provider | varchar(100) | true | null | Nhà cung cấp đào tạo |
| instructor | varchar(100) | true | null | Giảng viên |
| location | varchar(255) | true | null | Địa điểm |
| prerequisites | jsonb | true | null | Yêu cầu tiên quyết |
| objectives | jsonb | true | null | Mục tiêu khóa học |
| content | jsonb | true | null | Nội dung khóa học |
| materials | jsonb | true | null | Tài liệu khóa học |
| evaluation_method | text | true | null | Phương pháp đánh giá |
| certification | boolean | false | false | Có cấp chứng chỉ |
| certification_validity | integer | true | null | Thời hạn chứng chỉ (tháng) |
| status | varchar(20) | false | 'active' | Trạng thái: draft, active, inactive, archived |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| training_courses_pkey | PRIMARY KEY | id | Khóa chính |
| training_courses_organization_code_idx | UNIQUE | organization_id, code | Đảm bảo mã khóa đào tạo là duy nhất trong tổ chức |
| training_courses_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| training_courses_category_idx | INDEX | category | Tăng tốc truy vấn theo danh mục |
| training_courses_type_idx | INDEX | type | Tăng tốc truy vấn theo loại khóa đào tạo |
| training_courses_level_idx | INDEX | level | Tăng tốc truy vấn theo cấp độ |
| training_courses_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| training_courses_certification_idx | INDEX | certification | Tăng tốc truy vấn theo chứng chỉ |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| training_courses_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| training_courses_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| training_courses_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| training_courses_category_check | CHECK | Đảm bảo category chỉ nhận các giá trị cho phép |
| training_courses_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| training_courses_level_check | CHECK | Đảm bảo level chỉ nhận các giá trị cho phép |
| training_courses_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| training_courses_duration_check | CHECK | Đảm bảo duration > 0 khi không null |
| training_courses_cost_check | CHECK | Đảm bảo cost >= 0 khi không null |
| training_courses_certification_validity_check | CHECK | Đảm bảo certification_validity > 0 khi không null |

### 2.5. Ví dụ JSON

```json
{
  "id": "c1o2u3r4-s5e6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Lập trình React nâng cao",
  "code": "REACT-ADV-001",
  "description": "Khóa học nâng cao về React, bao gồm các kỹ thuật tối ưu hóa hiệu suất, quản lý state với Redux, và xây dựng ứng dụng lớn.",
  "category": "technical",
  "type": "internal",
  "level": "advanced",
  "duration": 24,
  "cost": 5000000.00,
  "currency": "VND",
  "provider": "NextFlow Academy",
  "instructor": "Nguyễn Văn A",
  "location": "Phòng đào tạo, Tầng 5, Tòa nhà ABC, Quận 1, TP.HCM",
  "prerequisites": [
    "Kiến thức cơ bản về JavaScript",
    "Kinh nghiệm làm việc với React",
    "Hiểu biết về ES6+"
  ],
  "objectives": [
    "Hiểu và áp dụng các kỹ thuật tối ưu hóa hiệu suất trong React",
    "Thành thạo quản lý state với Redux và Redux Toolkit",
    "Xây dựng và tổ chức ứng dụng React quy mô lớn",
    "Sử dụng React Hooks hiệu quả"
  ],
  "content": [
    {
      "module": "Module 1: Tổng quan về React nâng cao",
      "duration": 4,
      "topics": [
        "Kiến trúc ứng dụng React",
        "Virtual DOM và cơ chế render",
        "React Fiber"
      ]
    },
    {
      "module": "Module 2: Tối ưu hóa hiệu suất",
      "duration": 6,
      "topics": [
        "Memoization với React.memo, useMemo và useCallback",
        "Code splitting và lazy loading",
        "Profiling và debugging"
      ]
    },
    {
      "module": "Module 3: Quản lý state nâng cao",
      "duration": 8,
      "topics": [
        "Redux và Redux Toolkit",
        "Context API",
        "Recoil và Zustand"
      ]
    },
    {
      "module": "Module 4: Dự án thực tế",
      "duration": 6,
      "topics": [
        "Xây dựng ứng dụng thực tế",
        "Testing và deployment",
        "Best practices"
      ]
    }
  ],
  "materials": [
    {
      "name": "Slide bài giảng",
      "url": "https://docs.NextFlow.com/training/react-adv/slides.pdf"
    },
    {
      "name": "Mã nguồn dự án mẫu",
      "url": "https://github.com/NextFlow/react-adv-sample"
    },
    {
      "name": "Tài liệu tham khảo",
      "url": "https://docs.NextFlow.com/training/react-adv/references.pdf"
    }
  ],
  "evaluation_method": "Đánh giá dựa trên dự án cuối khóa (70%) và bài kiểm tra (30%)",
  "certification": true,
  "certification_validity": 24,
  "status": "active",
  "created_at": "2023-01-15T00:00:00Z",
  "updated_at": "2023-01-15T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG TRAINING_SESSIONS

### 3.1. Mô tả

Bảng `training_sessions` lưu trữ thông tin về các buổi đào tạo cụ thể của một khóa học.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| course_id | uuid | false | | Khóa ngoại tới bảng training_courses |
| name | varchar(255) | false | | Tên buổi đào tạo |
| description | text | true | null | Mô tả buổi đào tạo |
| start_date | timestamp | false | | Thời gian bắt đầu |
| end_date | timestamp | false | | Thời gian kết thúc |
| location | varchar(255) | true | null | Địa điểm |
| instructor | varchar(100) | true | null | Giảng viên |
| max_participants | integer | true | null | Số lượng người tham gia tối đa |
| current_participants | integer | false | 0 | Số lượng người tham gia hiện tại |
| status | varchar(20) | false | 'scheduled' | Trạng thái: scheduled, in_progress, completed, cancelled |
| materials | jsonb | true | null | Tài liệu buổi học |
| notes | text | true | null | Ghi chú |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| training_sessions_pkey | PRIMARY KEY | id | Khóa chính |
| training_sessions_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| training_sessions_course_id_idx | INDEX | course_id | Tăng tốc truy vấn theo khóa đào tạo |
| training_sessions_start_date_idx | INDEX | start_date | Tăng tốc truy vấn theo thời gian bắt đầu |
| training_sessions_end_date_idx | INDEX | end_date | Tăng tốc truy vấn theo thời gian kết thúc |
| training_sessions_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| training_sessions_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| training_sessions_course_id_fkey | FOREIGN KEY | Tham chiếu đến bảng training_courses(id) |
| training_sessions_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| training_sessions_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| training_sessions_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| training_sessions_date_check | CHECK | Đảm bảo end_date >= start_date |
| training_sessions_max_participants_check | CHECK | Đảm bảo max_participants > 0 khi không null |
| training_sessions_current_participants_check | CHECK | Đảm bảo current_participants >= 0 |
| training_sessions_participants_limit_check | CHECK | Đảm bảo current_participants <= max_participants khi max_participants không null |

### 3.5. Ví dụ JSON

```json
{
  "id": "s1e2s3s4-i5o6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "course_id": "c1o2u3r4-s5e6-7890-abcd-ef1234567890",
  "name": "Lập trình React nâng cao - Buổi 1: Tổng quan",
  "description": "Buổi học đầu tiên của khóa Lập trình React nâng cao, giới thiệu tổng quan về kiến trúc ứng dụng React, Virtual DOM và React Fiber.",
  "start_date": "2023-03-01T09:00:00Z",
  "end_date": "2023-03-01T13:00:00Z",
  "location": "Phòng đào tạo, Tầng 5, Tòa nhà ABC, Quận 1, TP.HCM",
  "instructor": "Nguyễn Văn A",
  "max_participants": 20,
  "current_participants": 18,
  "status": "completed",
  "materials": [
    {
      "name": "Slide buổi 1",
      "url": "https://docs.NextFlow.com/training/react-adv/session1/slides.pdf"
    },
    {
      "name": "Mã nguồn demo",
      "url": "https://github.com/NextFlow/react-adv-demo/session1"
    },
    {
      "name": "Bài tập",
      "url": "https://docs.NextFlow.com/training/react-adv/session1/exercises.pdf"
    }
  ],
  "notes": "Buổi học diễn ra tốt đẹp, học viên tích cực tham gia thảo luận và đặt câu hỏi.",
  "created_at": "2023-02-15T00:00:00Z",
  "updated_at": "2023-03-01T14:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG SKILLS

### 4.1. Mô tả

Bảng `skills` lưu trữ thông tin về các kỹ năng trong tổ chức.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(100) | false | | Tên kỹ năng |
| description | text | true | null | Mô tả kỹ năng |
| category | varchar(50) | true | null | Danh mục kỹ năng: technical, soft, leadership, etc. |
| type | varchar(50) | false | 'hard_skill' | Loại kỹ năng: hard_skill, soft_skill |
| is_core | boolean | false | false | Đánh dấu là kỹ năng cốt lõi |
| parent_id | uuid | true | null | Khóa ngoại tới bảng skills, kỹ năng cha |
| level_scale | integer | false | 5 | Thang điểm đánh giá |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| skills_pkey | PRIMARY KEY | id | Khóa chính |
| skills_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên kỹ năng là duy nhất trong tổ chức |
| skills_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| skills_category_idx | INDEX | category | Tăng tốc truy vấn theo danh mục |
| skills_type_idx | INDEX | type | Tăng tốc truy vấn theo loại kỹ năng |
| skills_is_core_idx | INDEX | is_core | Tăng tốc truy vấn theo kỹ năng cốt lõi |
| skills_parent_id_idx | INDEX | parent_id | Tăng tốc truy vấn theo kỹ năng cha |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| skills_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| skills_parent_id_fkey | FOREIGN KEY | Tham chiếu đến bảng skills(id) |
| skills_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| skills_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| skills_category_check | CHECK | Đảm bảo category chỉ nhận các giá trị cho phép |
| skills_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| skills_level_scale_check | CHECK | Đảm bảo level_scale > 0 |
| skills_no_self_reference | CHECK | Đảm bảo parent_id != id |

### 4.5. Ví dụ JSON

```json
{
  "id": "s1k2i3l4-l5i6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "React",
  "description": "Thư viện JavaScript để xây dựng giao diện người dùng",
  "category": "technical",
  "type": "hard_skill",
  "is_core": true,
  "parent_id": "f1r2o3n4-t5e6-7890-abcd-ef1234567890",
  "level_scale": 5,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
