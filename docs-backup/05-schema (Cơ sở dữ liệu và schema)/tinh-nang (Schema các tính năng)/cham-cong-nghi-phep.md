# SCHEMA TÍNH NĂNG - CHẤM CÔNG VÀ NGHỈ PHÉP

## 1. GIỚI THIỆU

Schema Chấm công và Nghỉ phép quản lý thông tin về chấm công, giờ làm việc, nghỉ phép và các hoạt động liên quan đến theo dõi thời gian làm việc của nhân viên trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến chấm công và nghỉ phép trong hệ thống.

### 1.1. Mục đích

Schema Chấm công và Nghỉ phép phục vụ các mục đích sau:

- Lưu trữ thông tin chấm công của nhân viên
- Quản lý giờ làm việc và ca làm việc
- Theo dõi nghỉ phép và vắng mặt
- Tính toán thời gian làm việc thực tế
- Hỗ trợ tính lương dựa trên thời gian làm việc
- Quản lý ngày nghỉ lễ và ngày nghỉ đặc biệt

### 1.2. Các bảng chính

Schema Chấm công và Nghỉ phép bao gồm các bảng chính sau:

1. `attendance` - Lưu trữ thông tin chấm công
2. `work_shifts` - Lưu trữ thông tin ca làm việc
3. `employee_shifts` - Lưu trữ thông tin phân ca cho nhân viên
4. `leave_types` - Lưu trữ thông tin loại nghỉ phép
5. `leave_balances` - Lưu trữ thông tin số ngày phép còn lại
6. `leave_requests` - Lưu trữ thông tin yêu cầu nghỉ phép
7. `holidays` - Lưu trữ thông tin ngày nghỉ lễ
8. `overtime` - Lưu trữ thông tin làm thêm giờ

## 2. BẢNG ATTENDANCE

### 2.1. Mô tả

Bảng `attendance` lưu trữ thông tin chấm công của nhân viên trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của bản ghi chấm công |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| employee_id | uuid | false | | Khóa ngoại tới bảng employees |
| date | date | false | | Ngày chấm công |
| check_in | timestamp | true | null | Thời gian check-in |
| check_out | timestamp | true | null | Thời gian check-out |
| shift_id | uuid | true | null | Khóa ngoại tới bảng work_shifts |
| status | varchar(20) | false | 'present' | Trạng thái: present, absent, late, early_leave, half_day, etc. |
| work_hours | decimal(5,2) | true | null | Số giờ làm việc |
| break_hours | decimal(5,2) | true | null | Số giờ nghỉ giữa ca |
| overtime_hours | decimal(5,2) | true | null | Số giờ làm thêm |
| check_in_location | jsonb | true | null | Vị trí check-in |
| check_out_location | jsonb | true | null | Vị trí check-out |
| check_in_device | varchar(100) | true | null | Thiết bị check-in |
| check_out_device | varchar(100) | true | null | Thiết bị check-out |
| check_in_note | text | true | null | Ghi chú check-in |
| check_out_note | text | true | null | Ghi chú check-out |
| is_manual | boolean | false | false | Đánh dấu là chấm công thủ công |
| notes | text | true | null | Ghi chú |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| attendance_pkey | PRIMARY KEY | id | Khóa chính |
| attendance_employee_date_idx | UNIQUE | employee_id, date | Đảm bảo mỗi nhân viên chỉ có một bản ghi chấm công mỗi ngày |
| attendance_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| attendance_employee_id_idx | INDEX | employee_id | Tăng tốc truy vấn theo nhân viên |
| attendance_date_idx | INDEX | date | Tăng tốc truy vấn theo ngày |
| attendance_shift_id_idx | INDEX | shift_id | Tăng tốc truy vấn theo ca làm việc |
| attendance_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| attendance_is_manual_idx | INDEX | is_manual | Tăng tốc truy vấn theo loại chấm công |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| attendance_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| attendance_employee_id_fkey | FOREIGN KEY | Tham chiếu đến bảng employees(id) |
| attendance_shift_id_fkey | FOREIGN KEY | Tham chiếu đến bảng work_shifts(id) |
| attendance_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| attendance_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| attendance_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| attendance_work_hours_check | CHECK | Đảm bảo work_hours >= 0 khi không null |
| attendance_break_hours_check | CHECK | Đảm bảo break_hours >= 0 khi không null |
| attendance_overtime_hours_check | CHECK | Đảm bảo overtime_hours >= 0 khi không null |
| attendance_check_time_check | CHECK | Đảm bảo check_out > check_in khi cả hai không null |

### 2.5. Ví dụ JSON

```json
{
  "id": "a1t2t3e4-n5d6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "employee_id": "e1m2p3l4-o5y6-7890-abcd-ef1234567890",
  "date": "2023-07-15",
  "check_in": "2023-07-15T08:55:30Z",
  "check_out": "2023-07-15T18:05:45Z",
  "shift_id": "s1h2i3f4-t5i6-7890-abcd-ef1234567890",
  "status": "present",
  "work_hours": 8.50,
  "break_hours": 0.50,
  "overtime_hours": 0.00,
  "check_in_location": {
    "latitude": 10.7769,
    "longitude": 106.7009,
    "address": "123 Đường Nguyễn Huệ, Quận 1, TP.HCM"
  },
  "check_out_location": {
    "latitude": 10.7769,
    "longitude": 106.7009,
    "address": "123 Đường Nguyễn Huệ, Quận 1, TP.HCM"
  },
  "check_in_device": "Mobile App (iPhone 13)",
  "check_out_device": "Mobile App (iPhone 13)",
  "check_in_note": "Check-in tại văn phòng",
  "check_out_note": "Hoàn thành công việc trong ngày",
  "is_manual": false,
  "notes": "Làm việc bình thường",
  "created_at": "2023-07-15T08:55:30Z",
  "updated_at": "2023-07-15T18:05:45Z",
  "created_by": null,
  "updated_by": null
}
```

## 3. BẢNG WORK_SHIFTS

### 3.1. Mô tả

Bảng `work_shifts` lưu trữ thông tin về các ca làm việc trong tổ chức.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(100) | false | | Tên ca làm việc |
| code | varchar(50) | false | | Mã ca làm việc |
| description | text | true | null | Mô tả ca làm việc |
| start_time | time | false | | Thời gian bắt đầu ca |
| end_time | time | false | | Thời gian kết thúc ca |
| break_start | time | true | null | Thời gian bắt đầu nghỉ giữa ca |
| break_end | time | true | null | Thời gian kết thúc nghỉ giữa ca |
| work_hours | decimal(5,2) | false | | Số giờ làm việc |
| grace_check_in | integer | false | 0 | Thời gian ân hạn check-in (phút) |
| grace_check_out | integer | false | 0 | Thời gian ân hạn check-out (phút) |
| is_night_shift | boolean | false | false | Đánh dấu là ca đêm |
| color | varchar(7) | true | null | Mã màu hiển thị |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| work_shifts_pkey | PRIMARY KEY | id | Khóa chính |
| work_shifts_organization_code_idx | UNIQUE | organization_id, code | Đảm bảo mã ca làm việc là duy nhất trong tổ chức |
| work_shifts_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| work_shifts_is_night_shift_idx | INDEX | is_night_shift | Tăng tốc truy vấn theo ca đêm |
| work_shifts_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| work_shifts_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| work_shifts_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| work_shifts_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| work_shifts_work_hours_check | CHECK | Đảm bảo work_hours > 0 |
| work_shifts_grace_check_in_check | CHECK | Đảm bảo grace_check_in >= 0 |
| work_shifts_grace_check_out_check | CHECK | Đảm bảo grace_check_out >= 0 |
| work_shifts_color_check | CHECK | Đảm bảo color có định dạng mã màu hợp lệ |

### 3.5. Ví dụ JSON

```json
{
  "id": "s1h2i3f4-t5i6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Ca Hành chính",
  "code": "OFFICE",
  "description": "Ca làm việc hành chính từ 9h đến 18h",
  "start_time": "09:00:00",
  "end_time": "18:00:00",
  "break_start": "12:00:00",
  "break_end": "13:00:00",
  "work_hours": 8.00,
  "grace_check_in": 15,
  "grace_check_out": 15,
  "is_night_shift": false,
  "color": "#1976d2",
  "is_active": true,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG LEAVE_TYPES

### 4.1. Mô tả

Bảng `leave_types` lưu trữ thông tin về các loại nghỉ phép trong tổ chức.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(100) | false | | Tên loại nghỉ phép |
| code | varchar(50) | false | | Mã loại nghỉ phép |
| description | text | true | null | Mô tả loại nghỉ phép |
| color | varchar(7) | true | null | Mã màu hiển thị |
| is_paid | boolean | false | true | Đánh dấu là nghỉ phép có lương |
| is_carry_forward | boolean | false | false | Đánh dấu được phép chuyển sang năm sau |
| carry_forward_max | decimal(5,2) | true | null | Số ngày tối đa được chuyển sang năm sau |
| default_days | decimal(5,2) | true | null | Số ngày mặc định mỗi năm |
| accrual_method | varchar(20) | false | 'yearly' | Phương thức tích lũy: yearly, monthly, quarterly |
| accrual_interval | decimal(5,2) | true | null | Số ngày tích lũy mỗi kỳ |
| min_service_days | integer | true | null | Số ngày làm việc tối thiểu để được hưởng |
| max_consecutive_days | integer | true | null | Số ngày liên tục tối đa được phép nghỉ |
| requires_approval | boolean | false | true | Yêu cầu phê duyệt |
| requires_attachment | boolean | false | false | Yêu cầu đính kèm tài liệu |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| leave_types_pkey | PRIMARY KEY | id | Khóa chính |
| leave_types_organization_code_idx | UNIQUE | organization_id, code | Đảm bảo mã loại nghỉ phép là duy nhất trong tổ chức |
| leave_types_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| leave_types_is_paid_idx | INDEX | is_paid | Tăng tốc truy vấn theo nghỉ phép có lương |
| leave_types_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| leave_types_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| leave_types_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| leave_types_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| leave_types_accrual_method_check | CHECK | Đảm bảo accrual_method chỉ nhận các giá trị cho phép |
| leave_types_default_days_check | CHECK | Đảm bảo default_days >= 0 khi không null |
| leave_types_carry_forward_max_check | CHECK | Đảm bảo carry_forward_max >= 0 khi không null |
| leave_types_accrual_interval_check | CHECK | Đảm bảo accrual_interval >= 0 khi không null |
| leave_types_min_service_days_check | CHECK | Đảm bảo min_service_days >= 0 khi không null |
| leave_types_max_consecutive_days_check | CHECK | Đảm bảo max_consecutive_days >= 0 khi không null |
| leave_types_color_check | CHECK | Đảm bảo color có định dạng mã màu hợp lệ |

### 4.5. Ví dụ JSON

```json
{
  "id": "l1e2a3v4-e5t6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Nghỉ phép năm",
  "code": "ANNUAL",
  "description": "Nghỉ phép năm có lương theo quy định của Luật Lao động",
  "color": "#4caf50",
  "is_paid": true,
  "is_carry_forward": true,
  "carry_forward_max": 5.00,
  "default_days": 12.00,
  "accrual_method": "yearly",
  "accrual_interval": 12.00,
  "min_service_days": 30,
  "max_consecutive_days": 30,
  "requires_approval": true,
  "requires_attachment": false,
  "is_active": true,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
