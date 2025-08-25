# SCHEMA TÍNH NĂNG - KPI VÀ MỤC TIÊU

## 1. GIỚI THIỆU

Schema KPI và Mục tiêu quản lý thông tin về các chỉ số hiệu suất chính (KPI) và mục tiêu trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến KPI và mục tiêu trong hệ thống.

### 1.1. Mục đích

Schema KPI và Mục tiêu phục vụ các mục đích sau:

- Lưu trữ thông tin về các chỉ số KPI
- Quản lý mục tiêu và chỉ tiêu
- Theo dõi tiến độ đạt mục tiêu
- Đánh giá hiệu suất của cá nhân, nhóm và tổ chức
- Hỗ trợ ra quyết định dựa trên dữ liệu

### 1.2. Các bảng chính

Schema KPI và Mục tiêu bao gồm các bảng chính sau:

1. `kpis` - Lưu trữ thông tin về các chỉ số KPI
2. `kpi_targets` - Lưu trữ thông tin về mục tiêu KPI
3. `kpi_values` - Lưu trữ thông tin về giá trị KPI
4. `kpi_categories` - Lưu trữ thông tin về danh mục KPI
5. `objectives` - Lưu trữ thông tin về mục tiêu
6. `key_results` - Lưu trữ thông tin về kết quả chính

## 2. BẢNG KPIS

### 2.1. Mô tả

Bảng `kpis` lưu trữ thông tin về các chỉ số hiệu suất chính (KPI) trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của KPI |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| category_id | uuid | true | null | Khóa ngoại tới bảng kpi_categories |
| name | varchar(100) | false | | Tên KPI |
| code | varchar(50) | false | | Mã KPI |
| description | text | true | null | Mô tả KPI |
| type | varchar(50) | false | | Loại KPI: sales, marketing, customer, financial, etc. |
| data_type | varchar(20) | false | 'number' | Kiểu dữ liệu: number, percentage, currency, ratio, etc. |
| unit | varchar(20) | true | null | Đơn vị đo: VND, %, etc. |
| calculation_method | text | true | null | Phương pháp tính toán |
| calculation_formula | text | true | null | Công thức tính toán |
| data_source | varchar(50) | true | null | Nguồn dữ liệu |
| frequency | varchar(20) | false | 'monthly' | Tần suất: daily, weekly, monthly, quarterly, yearly |
| is_higher_better | boolean | false | true | Giá trị cao hơn là tốt hơn |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| is_system | boolean | false | false | Đánh dấu là KPI hệ thống |
| display_order | integer | false | 0 | Thứ tự hiển thị |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| kpis_pkey | PRIMARY KEY | id | Khóa chính |
| kpis_organization_code_idx | UNIQUE | organization_id, code | Đảm bảo mã KPI là duy nhất trong tổ chức |
| kpis_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| kpis_category_id_idx | INDEX | category_id | Tăng tốc truy vấn theo danh mục |
| kpis_type_idx | INDEX | type | Tăng tốc truy vấn theo loại KPI |
| kpis_frequency_idx | INDEX | frequency | Tăng tốc truy vấn theo tần suất |
| kpis_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |
| kpis_is_system_idx | INDEX | is_system | Tăng tốc truy vấn theo KPI hệ thống |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| kpis_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| kpis_category_id_fkey | FOREIGN KEY | Tham chiếu đến bảng kpi_categories(id) |
| kpis_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| kpis_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| kpis_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| kpis_data_type_check | CHECK | Đảm bảo data_type chỉ nhận các giá trị cho phép |
| kpis_frequency_check | CHECK | Đảm bảo frequency chỉ nhận các giá trị cho phép |
| kpis_display_order_check | CHECK | Đảm bảo display_order >= 0 |

### 2.5. Ví dụ JSON

```json
{
  "id": "k1p2i3i4-d5i6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "category_id": "c1a2t3e4-g5o6-7890-abcd-ef1234567890",
  "name": "Doanh thu bán hàng",
  "code": "SALES_REVENUE",
  "description": "Tổng doanh thu từ việc bán hàng trong kỳ",
  "type": "sales",
  "data_type": "currency",
  "unit": "VND",
  "calculation_method": "Tổng doanh thu từ tất cả đơn hàng đã hoàn thành trong kỳ",
  "calculation_formula": "SUM(orders.total_amount) WHERE orders.status = 'completed' AND orders.order_date BETWEEN period_start AND period_end",
  "data_source": "orders",
  "frequency": "monthly",
  "is_higher_better": true,
  "is_active": true,
  "is_system": true,
  "display_order": 1,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG KPI_TARGETS

### 3.1. Mô tả

Bảng `kpi_targets` lưu trữ thông tin về mục tiêu của các chỉ số KPI.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| kpi_id | uuid | false | | Khóa ngoại tới bảng kpis |
| target_for | varchar(50) | false | 'organization' | Đối tượng áp dụng: organization, team, user |
| target_id | uuid | true | null | ID của đối tượng áp dụng |
| period_type | varchar(20) | false | 'monthly' | Loại kỳ: daily, weekly, monthly, quarterly, yearly |
| period_start | timestamp | false | | Thời gian bắt đầu kỳ |
| period_end | timestamp | false | | Thời gian kết thúc kỳ |
| target_value | decimal(15,2) | false | | Giá trị mục tiêu |
| min_value | decimal(15,2) | true | null | Giá trị tối thiểu |
| max_value | decimal(15,2) | true | null | Giá trị tối đa |
| actual_value | decimal(15,2) | true | null | Giá trị thực tế |
| achievement_percentage | decimal(5,2) | true | null | Phần trăm đạt được |
| status | varchar(20) | false | 'pending' | Trạng thái: pending, in_progress, achieved, not_achieved |
| notes | text | true | null | Ghi chú |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| kpi_targets_pkey | PRIMARY KEY | id | Khóa chính |
| kpi_targets_unique_idx | UNIQUE | organization_id, kpi_id, target_for, target_id, period_type, period_start, period_end | Đảm bảo mục tiêu KPI là duy nhất |
| kpi_targets_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| kpi_targets_kpi_id_idx | INDEX | kpi_id | Tăng tốc truy vấn theo KPI |
| kpi_targets_target_for_idx | INDEX | target_for | Tăng tốc truy vấn theo đối tượng áp dụng |
| kpi_targets_target_id_idx | INDEX | target_id | Tăng tốc truy vấn theo ID đối tượng |
| kpi_targets_period_type_idx | INDEX | period_type | Tăng tốc truy vấn theo loại kỳ |
| kpi_targets_period_start_idx | INDEX | period_start | Tăng tốc truy vấn theo thời gian bắt đầu |
| kpi_targets_period_end_idx | INDEX | period_end | Tăng tốc truy vấn theo thời gian kết thúc |
| kpi_targets_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| kpi_targets_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| kpi_targets_kpi_id_fkey | FOREIGN KEY | Tham chiếu đến bảng kpis(id) |
| kpi_targets_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| kpi_targets_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| kpi_targets_target_for_check | CHECK | Đảm bảo target_for chỉ nhận các giá trị cho phép |
| kpi_targets_period_type_check | CHECK | Đảm bảo period_type chỉ nhận các giá trị cho phép |
| kpi_targets_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| kpi_targets_period_check | CHECK | Đảm bảo period_end >= period_start |
| kpi_targets_value_check | CHECK | Đảm bảo min_value <= target_value <= max_value khi min_value và max_value không null |

### 3.5. Ví dụ JSON

```json
{
  "id": "t1a2r3g4-e5t6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "kpi_id": "k1p2i3i4-d5i6-7890-abcd-ef1234567890",
  "target_for": "team",
  "target_id": "t1e2a3m4-i5d6-7890-abcd-ef1234567890",
  "period_type": "monthly",
  "period_start": "2023-07-01T00:00:00Z",
  "period_end": "2023-07-31T23:59:59Z",
  "target_value": 500000000.00,
  "min_value": 450000000.00,
  "max_value": 550000000.00,
  "actual_value": 520000000.00,
  "achievement_percentage": 104.00,
  "status": "achieved",
  "notes": "Vượt chỉ tiêu 4% nhờ chiến dịch khuyến mãi hè 2023",
  "created_at": "2023-06-25T10:00:00Z",
  "updated_at": "2023-08-01T09:00:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG KPI_VALUES

### 4.1. Mô tả

Bảng `kpi_values` lưu trữ thông tin về giá trị thực tế của các chỉ số KPI theo thời gian.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| kpi_id | uuid | false | | Khóa ngoại tới bảng kpis |
| target_id | uuid | true | null | Khóa ngoại tới bảng kpi_targets |
| value_for | varchar(50) | false | 'organization' | Đối tượng áp dụng: organization, team, user |
| entity_id | uuid | true | null | ID của đối tượng áp dụng |
| period_type | varchar(20) | false | 'daily' | Loại kỳ: daily, weekly, monthly, quarterly, yearly |
| period_date | timestamp | false | | Ngày của kỳ |
| value | decimal(15,2) | false | | Giá trị |
| target_value | decimal(15,2) | true | null | Giá trị mục tiêu |
| variance | decimal(15,2) | true | null | Chênh lệch so với mục tiêu |
| variance_percentage | decimal(5,2) | true | null | Phần trăm chênh lệch |
| is_calculated | boolean | false | false | Đánh dấu là giá trị được tính toán |
| calculation_method | varchar(50) | true | null | Phương pháp tính toán |
| source | varchar(50) | true | null | Nguồn dữ liệu |
| notes | text | true | null | Ghi chú |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| kpi_values_pkey | PRIMARY KEY | id | Khóa chính |
| kpi_values_unique_idx | UNIQUE | organization_id, kpi_id, value_for, entity_id, period_type, period_date | Đảm bảo giá trị KPI là duy nhất |
| kpi_values_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| kpi_values_kpi_id_idx | INDEX | kpi_id | Tăng tốc truy vấn theo KPI |
| kpi_values_target_id_idx | INDEX | target_id | Tăng tốc truy vấn theo mục tiêu |
| kpi_values_value_for_idx | INDEX | value_for | Tăng tốc truy vấn theo đối tượng áp dụng |
| kpi_values_entity_id_idx | INDEX | entity_id | Tăng tốc truy vấn theo ID đối tượng |
| kpi_values_period_type_idx | INDEX | period_type | Tăng tốc truy vấn theo loại kỳ |
| kpi_values_period_date_idx | INDEX | period_date | Tăng tốc truy vấn theo ngày của kỳ |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| kpi_values_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| kpi_values_kpi_id_fkey | FOREIGN KEY | Tham chiếu đến bảng kpis(id) |
| kpi_values_target_id_fkey | FOREIGN KEY | Tham chiếu đến bảng kpi_targets(id) |
| kpi_values_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| kpi_values_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| kpi_values_value_for_check | CHECK | Đảm bảo value_for chỉ nhận các giá trị cho phép |
| kpi_values_period_type_check | CHECK | Đảm bảo period_type chỉ nhận các giá trị cho phép |

### 4.5. Ví dụ JSON

```json
{
  "id": "v1a2l3u4-e5i6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "kpi_id": "k1p2i3i4-d5i6-7890-abcd-ef1234567890",
  "target_id": "t1a2r3g4-e5t6-7890-abcd-ef1234567890",
  "value_for": "team",
  "entity_id": "t1e2a3m4-i5d6-7890-abcd-ef1234567890",
  "period_type": "daily",
  "period_date": "2023-07-15T00:00:00Z",
  "value": 18500000.00,
  "target_value": 16666666.67,
  "variance": 1833333.33,
  "variance_percentage": 11.00,
  "is_calculated": true,
  "calculation_method": "sum",
  "source": "orders",
  "notes": "Doanh thu cao hơn mục tiêu nhờ chương trình flash sale",
  "created_at": "2023-07-16T01:00:00Z",
  "updated_at": "2023-07-16T01:00:00Z",
  "created_by": null,
  "updated_by": null
}
```
