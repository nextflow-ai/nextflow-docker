# SCHEMA TÍNH NĂNG - ĐÁNH GIÁ HIỆU SUẤT

## 1. GIỚI THIỆU

Schema Đánh giá hiệu suất quản lý thông tin về đánh giá hiệu suất làm việc, mục tiêu, phản hồi và các hoạt động liên quan đến đánh giá nhân viên trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến đánh giá hiệu suất trong hệ thống.

### 1.1. Mục đích

Schema Đánh giá hiệu suất phục vụ các mục đích sau:

- Lưu trữ thông tin về các kỳ đánh giá hiệu suất
- Quản lý mục tiêu và KPI của nhân viên
- Theo dõi tiến độ đạt mục tiêu
- Lưu trữ phản hồi và đánh giá
- Hỗ trợ đánh giá 360 độ
- Quản lý kế hoạch phát triển cá nhân

### 1.2. Các bảng chính

Schema Đánh giá hiệu suất bao gồm các bảng chính sau:

1. `performance_cycles` - Lưu trữ thông tin về các kỳ đánh giá
2. `performance_reviews` - Lưu trữ thông tin đánh giá hiệu suất
3. `performance_goals` - Lưu trữ thông tin mục tiêu hiệu suất
4. `performance_criteria` - Lưu trữ thông tin tiêu chí đánh giá
5. `performance_ratings` - Lưu trữ thông tin xếp hạng đánh giá
6. `performance_feedbacks` - Lưu trữ thông tin phản hồi
7. `development_plans` - Lưu trữ thông tin kế hoạch phát triển

## 2. BẢNG PERFORMANCE_CYCLES

### 2.1. Mô tả

Bảng `performance_cycles` lưu trữ thông tin về các kỳ đánh giá hiệu suất trong tổ chức.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của kỳ đánh giá |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên kỳ đánh giá |
| description | text | true | null | Mô tả kỳ đánh giá |
| cycle_type | varchar(20) | false | 'annual' | Loại kỳ đánh giá: annual, semi_annual, quarterly, monthly |
| start_date | date | false | | Ngày bắt đầu kỳ đánh giá |
| end_date | date | false | | Ngày kết thúc kỳ đánh giá |
| goal_setting_start_date | date | true | null | Ngày bắt đầu thiết lập mục tiêu |
| goal_setting_end_date | date | true | null | Ngày kết thúc thiết lập mục tiêu |
| self_review_start_date | date | true | null | Ngày bắt đầu tự đánh giá |
| self_review_end_date | date | true | null | Ngày kết thúc tự đánh giá |
| manager_review_start_date | date | true | null | Ngày bắt đầu đánh giá của quản lý |
| manager_review_end_date | date | true | null | Ngày kết thúc đánh giá của quản lý |
| calibration_start_date | date | true | null | Ngày bắt đầu hiệu chuẩn đánh giá |
| calibration_end_date | date | true | null | Ngày kết thúc hiệu chuẩn đánh giá |
| status | varchar(20) | false | 'draft' | Trạng thái: draft, active, in_progress, completed, cancelled |
| is_current | boolean | false | false | Đánh dấu là kỳ đánh giá hiện tại |
| settings | jsonb | true | null | Cài đặt kỳ đánh giá |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| performance_cycles_pkey | PRIMARY KEY | id | Khóa chính |
| performance_cycles_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên kỳ đánh giá là duy nhất trong tổ chức |
| performance_cycles_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| performance_cycles_cycle_type_idx | INDEX | cycle_type | Tăng tốc truy vấn theo loại kỳ đánh giá |
| performance_cycles_start_date_idx | INDEX | start_date | Tăng tốc truy vấn theo ngày bắt đầu |
| performance_cycles_end_date_idx | INDEX | end_date | Tăng tốc truy vấn theo ngày kết thúc |
| performance_cycles_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| performance_cycles_is_current_idx | INDEX | is_current | Tăng tốc truy vấn theo kỳ đánh giá hiện tại |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| performance_cycles_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| performance_cycles_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| performance_cycles_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| performance_cycles_cycle_type_check | CHECK | Đảm bảo cycle_type chỉ nhận các giá trị cho phép |
| performance_cycles_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| performance_cycles_date_check | CHECK | Đảm bảo end_date >= start_date |
| performance_cycles_goal_setting_date_check | CHECK | Đảm bảo goal_setting_end_date >= goal_setting_start_date khi cả hai không null |
| performance_cycles_self_review_date_check | CHECK | Đảm bảo self_review_end_date >= self_review_start_date khi cả hai không null |
| performance_cycles_manager_review_date_check | CHECK | Đảm bảo manager_review_end_date >= manager_review_start_date khi cả hai không null |
| performance_cycles_calibration_date_check | CHECK | Đảm bảo calibration_end_date >= calibration_start_date khi cả hai không null |

### 2.5. Ví dụ JSON

```json
{
  "id": "c1y2c3l4-e5i6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Đánh giá Hiệu suất Năm 2023",
  "description": "Kỳ đánh giá hiệu suất hàng năm cho năm 2023",
  "cycle_type": "annual",
  "start_date": "2023-01-01",
  "end_date": "2023-12-31",
  "goal_setting_start_date": "2023-01-01",
  "goal_setting_end_date": "2023-01-15",
  "self_review_start_date": "2023-12-01",
  "self_review_end_date": "2023-12-10",
  "manager_review_start_date": "2023-12-11",
  "manager_review_end_date": "2023-12-20",
  "calibration_start_date": "2023-12-21",
  "calibration_end_date": "2023-12-25",
  "status": "active",
  "is_current": true,
  "settings": {
    "enable_peer_review": true,
    "enable_self_review": true,
    "rating_scale": 5,
    "review_visibility": "manager_only",
    "allow_attachments": true,
    "require_comments": true
  },
  "created_at": "2022-12-15T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG PERFORMANCE_REVIEWS

### 3.1. Mô tả

Bảng `performance_reviews` lưu trữ thông tin về các đánh giá hiệu suất của nhân viên.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| cycle_id | uuid | false | | Khóa ngoại tới bảng performance_cycles |
| employee_id | uuid | false | | Khóa ngoại tới bảng employees, nhân viên được đánh giá |
| reviewer_id | uuid | false | | Khóa ngoại tới bảng employees, người đánh giá |
| review_type | varchar(20) | false | 'manager' | Loại đánh giá: self, manager, peer, subordinate, 360 |
| status | varchar(20) | false | 'pending' | Trạng thái: pending, in_progress, submitted, approved, rejected |
| overall_rating | decimal(3,2) | true | null | Điểm đánh giá tổng thể |
| overall_comments | text | true | null | Nhận xét tổng thể |
| strengths | text | true | null | Điểm mạnh |
| areas_for_improvement | text | true | null | Điểm cần cải thiện |
| goals_achievement | jsonb | true | null | Đánh giá mức độ đạt mục tiêu |
| competencies_rating | jsonb | true | null | Đánh giá năng lực |
| submitted_at | timestamp | true | null | Thời gian nộp đánh giá |
| approved_at | timestamp | true | null | Thời gian phê duyệt đánh giá |
| rejected_at | timestamp | true | null | Thời gian từ chối đánh giá |
| rejection_reason | text | true | null | Lý do từ chối |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| performance_reviews_pkey | PRIMARY KEY | id | Khóa chính |
| performance_reviews_unique_idx | UNIQUE | cycle_id, employee_id, reviewer_id, review_type | Đảm bảo mỗi người đánh giá chỉ có một đánh giá cho mỗi nhân viên trong mỗi kỳ đánh giá và loại đánh giá |
| performance_reviews_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| performance_reviews_cycle_id_idx | INDEX | cycle_id | Tăng tốc truy vấn theo kỳ đánh giá |
| performance_reviews_employee_id_idx | INDEX | employee_id | Tăng tốc truy vấn theo nhân viên được đánh giá |
| performance_reviews_reviewer_id_idx | INDEX | reviewer_id | Tăng tốc truy vấn theo người đánh giá |
| performance_reviews_review_type_idx | INDEX | review_type | Tăng tốc truy vấn theo loại đánh giá |
| performance_reviews_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| performance_reviews_overall_rating_idx | INDEX | overall_rating | Tăng tốc truy vấn theo điểm đánh giá |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| performance_reviews_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| performance_reviews_cycle_id_fkey | FOREIGN KEY | Tham chiếu đến bảng performance_cycles(id) |
| performance_reviews_employee_id_fkey | FOREIGN KEY | Tham chiếu đến bảng employees(id) |
| performance_reviews_reviewer_id_fkey | FOREIGN KEY | Tham chiếu đến bảng employees(id) |
| performance_reviews_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| performance_reviews_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| performance_reviews_review_type_check | CHECK | Đảm bảo review_type chỉ nhận các giá trị cho phép |
| performance_reviews_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| performance_reviews_overall_rating_check | CHECK | Đảm bảo overall_rating nằm trong khoảng hợp lệ |

### 3.5. Ví dụ JSON

```json
{
  "id": "r1e2v3i4-e5w6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "cycle_id": "c1y2c3l4-e5i6-7890-abcd-ef1234567890",
  "employee_id": "e1m2p3l4-o5y6-7890-abcd-ef1234567890",
  "reviewer_id": "m1a2n3a4-g5e6-7890-abcd-ef1234567890",
  "review_type": "manager",
  "status": "submitted",
  "overall_rating": 4.50,
  "overall_comments": "Nguyễn Văn A đã có một năm làm việc xuất sắc, hoàn thành tốt các mục tiêu đề ra và thể hiện tinh thần làm việc nhóm tuyệt vời.",
  "strengths": "- Kỹ năng lập trình và giải quyết vấn đề xuất sắc\n- Tinh thần làm việc nhóm tốt\n- Chủ động trong công việc\n- Khả năng học hỏi nhanh",
  "areas_for_improvement": "- Cần cải thiện kỹ năng thuyết trình\n- Nên chủ động chia sẻ kiến thức với đồng nghiệp hơn",
  "goals_achievement": [
    {
      "goal_id": "g1o2a3l4-i5d6-7890-abcd-ef1234567890",
      "achievement_percentage": 100,
      "rating": 5,
      "comments": "Hoàn thành xuất sắc mục tiêu này"
    },
    {
      "goal_id": "g2o2a3l4-i5d6-7890-abcd-ef1234567891",
      "achievement_percentage": 90,
      "rating": 4,
      "comments": "Hoàn thành tốt mục tiêu này"
    }
  ],
  "competencies_rating": [
    {
      "competency_id": "c1o2m3p4-e5t6-7890-abcd-ef1234567890",
      "name": "Kỹ năng kỹ thuật",
      "rating": 5,
      "comments": "Có kiến thức chuyên môn sâu rộng và áp dụng hiệu quả vào công việc"
    },
    {
      "competency_id": "c2o2m3p4-e5t6-7890-abcd-ef1234567891",
      "name": "Làm việc nhóm",
      "rating": 4,
      "comments": "Hợp tác tốt với đồng nghiệp và hỗ trợ khi cần thiết"
    },
    {
      "competency_id": "c3o2m3p4-e5t6-7890-abcd-ef1234567892",
      "name": "Giao tiếp",
      "rating": 3,
      "comments": "Giao tiếp rõ ràng nhưng cần cải thiện kỹ năng thuyết trình"
    }
  ],
  "submitted_at": "2023-12-15T10:30:00Z",
  "approved_at": null,
  "rejected_at": null,
  "rejection_reason": null,
  "created_at": "2023-12-11T09:00:00Z",
  "updated_at": "2023-12-15T10:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG PERFORMANCE_GOALS

### 4.1. Mô tả

Bảng `performance_goals` lưu trữ thông tin về các mục tiêu hiệu suất của nhân viên.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| cycle_id | uuid | false | | Khóa ngoại tới bảng performance_cycles |
| employee_id | uuid | false | | Khóa ngoại tới bảng employees |
| title | varchar(255) | false | | Tiêu đề mục tiêu |
| description | text | true | null | Mô tả mục tiêu |
| category | varchar(50) | true | null | Danh mục mục tiêu: business, development, personal, etc. |
| priority | varchar(20) | false | 'medium' | Mức độ ưu tiên: high, medium, low |
| weight | decimal(5,2) | false | 0 | Trọng số (%) |
| start_date | date | false | | Ngày bắt đầu |
| due_date | date | false | | Ngày đến hạn |
| status | varchar(20) | false | 'pending' | Trạng thái: pending, in_progress, completed, cancelled |
| progress | integer | false | 0 | Tiến độ (%) |
| measurement_criteria | text | true | null | Tiêu chí đo lường |
| key_results | jsonb | true | null | Kết quả chính |
| alignment | jsonb | true | null | Sự liên kết với mục tiêu tổ chức |
| attachments | jsonb | true | null | Tài liệu đính kèm |
| comments | jsonb | true | null | Bình luận |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| performance_goals_pkey | PRIMARY KEY | id | Khóa chính |
| performance_goals_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| performance_goals_cycle_id_idx | INDEX | cycle_id | Tăng tốc truy vấn theo kỳ đánh giá |
| performance_goals_employee_id_idx | INDEX | employee_id | Tăng tốc truy vấn theo nhân viên |
| performance_goals_category_idx | INDEX | category | Tăng tốc truy vấn theo danh mục |
| performance_goals_priority_idx | INDEX | priority | Tăng tốc truy vấn theo mức độ ưu tiên |
| performance_goals_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| performance_goals_start_date_idx | INDEX | start_date | Tăng tốc truy vấn theo ngày bắt đầu |
| performance_goals_due_date_idx | INDEX | due_date | Tăng tốc truy vấn theo ngày đến hạn |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| performance_goals_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| performance_goals_cycle_id_fkey | FOREIGN KEY | Tham chiếu đến bảng performance_cycles(id) |
| performance_goals_employee_id_fkey | FOREIGN KEY | Tham chiếu đến bảng employees(id) |
| performance_goals_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| performance_goals_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| performance_goals_priority_check | CHECK | Đảm bảo priority chỉ nhận các giá trị cho phép |
| performance_goals_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| performance_goals_weight_check | CHECK | Đảm bảo weight >= 0 và weight <= 100 |
| performance_goals_progress_check | CHECK | Đảm bảo progress >= 0 và progress <= 100 |
| performance_goals_date_check | CHECK | Đảm bảo due_date >= start_date |

### 4.5. Ví dụ JSON

```json
{
  "id": "g1o2a3l4-i5d6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "cycle_id": "c1y2c3l4-e5i6-7890-abcd-ef1234567890",
  "employee_id": "e1m2p3l4-o5y6-7890-abcd-ef1234567890",
  "title": "Phát triển tính năng mới cho sản phẩm XYZ",
  "description": "Phát triển và triển khai tính năng tích hợp AI cho sản phẩm XYZ để tăng hiệu suất và trải nghiệm người dùng",
  "category": "business",
  "priority": "high",
  "weight": 30.00,
  "start_date": "2023-01-15",
  "due_date": "2023-06-30",
  "status": "completed",
  "progress": 100,
  "measurement_criteria": "- Tính năng được triển khai đúng thời hạn\n- Tính năng hoạt động ổn định, không có lỗi nghiêm trọng\n- Tăng 20% hiệu suất xử lý\n- Đạt 90% đánh giá tích cực từ người dùng",
  "key_results": [
    {
      "title": "Hoàn thành phát triển tính năng",
      "due_date": "2023-05-31",
      "status": "completed",
      "progress": 100
    },
    {
      "title": "Triển khai tính năng lên môi trường production",
      "due_date": "2023-06-15",
      "status": "completed",
      "progress": 100
    },
    {
      "title": "Thu thập phản hồi từ người dùng",
      "due_date": "2023-06-30",
      "status": "completed",
      "progress": 100
    }
  ],
  "alignment": {
    "organization_goal_id": "o1g2o3a4-l5i6-7890-abcd-ef1234567890",
    "organization_goal_title": "Tăng cường trải nghiệm người dùng với AI"
  },
  "attachments": [
    {
      "name": "Tài liệu thiết kế",
      "url": "https://docs.NextFlow.com/goals/design_doc.pdf",
      "uploaded_at": "2023-01-20T10:00:00Z"
    },
    {
      "name": "Báo cáo kết quả",
      "url": "https://docs.NextFlow.com/goals/result_report.pdf",
      "uploaded_at": "2023-06-25T15:30:00Z"
    }
  ],
  "comments": [
    {
      "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "user_name": "Nguyễn Văn A",
      "content": "Đã hoàn thành phát triển tính năng đúng tiến độ",
      "created_at": "2023-05-31T16:00:00Z"
    },
    {
      "user_id": "m1a2n3a4-g5e6-7890-abcd-ef1234567890",
      "user_name": "Trần Văn B",
      "content": "Tính năng hoạt động tốt, nhận được phản hồi tích cực từ người dùng",
      "created_at": "2023-06-30T14:30:00Z"
    }
  ],
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-06-30T14:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
