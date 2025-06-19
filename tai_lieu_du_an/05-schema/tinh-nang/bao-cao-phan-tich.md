# SCHEMA TÍNH NĂNG - BÁO CÁO VÀ PHÂN TÍCH

## 1. GIỚI THIỆU

Schema Báo cáo và Phân tích quản lý thông tin về các báo cáo, dashboard, chỉ số KPI và dữ liệu phân tích trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến báo cáo và phân tích trong hệ thống.

### 1.1. Mục đích

Schema Báo cáo và Phân tích phục vụ các mục đích sau:

- Lưu trữ cấu hình báo cáo và dashboard
- Quản lý chỉ số KPI và mục tiêu
- Lưu trữ dữ liệu phân tích tổng hợp
- Theo dõi hiệu suất kinh doanh
- Cung cấp dữ liệu cho việc ra quyết định
- Hỗ trợ phân tích dự đoán và đề xuất

### 1.2. Các bảng chính

Schema Báo cáo và Phân tích bao gồm các bảng chính sau:

1. `reports` - Lưu trữ thông tin về các báo cáo
2. `dashboards` - Lưu trữ thông tin về các dashboard
3. `dashboard_widgets` - Lưu trữ thông tin về các widget trong dashboard
4. `kpis` - Lưu trữ thông tin về các chỉ số KPI
5. `kpi_targets` - Lưu trữ thông tin về mục tiêu KPI
6. `analytics_data` - Lưu trữ dữ liệu phân tích tổng hợp
7. `report_schedules` - Lưu trữ thông tin lịch gửi báo cáo

## 2. BẢNG REPORTS

### 2.1. Mô tả

Bảng `reports` lưu trữ thông tin về các báo cáo trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của báo cáo |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên báo cáo |
| description | text | true | null | Mô tả báo cáo |
| type | varchar(50) | false | | Loại báo cáo: sales, marketing, customer, inventory, etc. |
| category | varchar(50) | true | null | Danh mục báo cáo |
| report_query | text | true | null | Truy vấn báo cáo (SQL, etc.) |
| data_source | varchar(50) | false | 'database' | Nguồn dữ liệu: database, api, file, etc. |
| parameters | jsonb | true | null | Tham số báo cáo |
| filters | jsonb | true | null | Bộ lọc báo cáo |
| columns | jsonb | true | null | Cấu hình cột báo cáo |
| sorting | jsonb | true | null | Cấu hình sắp xếp |
| grouping | jsonb | true | null | Cấu hình nhóm |
| aggregation | jsonb | true | null | Cấu hình tổng hợp |
| visualization | jsonb | true | null | Cấu hình hiển thị |
| chart_config | jsonb | true | null | Cấu hình biểu đồ |
| is_system | boolean | false | false | Đánh dấu là báo cáo hệ thống |
| is_public | boolean | false | false | Đánh dấu là báo cáo công khai |
| is_favorite | boolean | false | false | Đánh dấu là báo cáo yêu thích |
| last_run_at | timestamp | true | null | Thời gian chạy gần nhất |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| reports_pkey | PRIMARY KEY | id | Khóa chính |
| reports_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên báo cáo là duy nhất trong tổ chức |
| reports_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| reports_type_idx | INDEX | type | Tăng tốc truy vấn theo loại báo cáo |
| reports_category_idx | INDEX | category | Tăng tốc truy vấn theo danh mục |
| reports_is_system_idx | INDEX | is_system | Tăng tốc truy vấn theo báo cáo hệ thống |
| reports_is_public_idx | INDEX | is_public | Tăng tốc truy vấn theo báo cáo công khai |
| reports_created_by_idx | INDEX | created_by | Tăng tốc truy vấn theo người tạo |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| reports_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| reports_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| reports_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| reports_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| reports_data_source_check | CHECK | Đảm bảo data_source chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "r1e2p3o4-r5t6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Báo cáo Doanh số theo Sản phẩm - Q2 2023",
  "description": "Báo cáo doanh số bán hàng theo sản phẩm cho quý 2 năm 2023",
  "type": "sales",
  "category": "product_performance",
  "report_query": "SELECT p.name AS product_name, SUM(oi.quantity) AS total_quantity, SUM(oi.total) AS total_revenue FROM order_items oi JOIN products p ON oi.product_id = p.id JOIN orders o ON oi.order_id = o.id WHERE o.order_date BETWEEN :start_date AND :end_date GROUP BY p.name ORDER BY total_revenue DESC",
  "data_source": "database",
  "parameters": {
    "start_date": {
      "type": "date",
      "default": "2023-04-01",
      "required": true,
      "label": "Ngày bắt đầu"
    },
    "end_date": {
      "type": "date",
      "default": "2023-06-30",
      "required": true,
      "label": "Ngày kết thúc"
    }
  },
  "filters": [
    {
      "field": "product_category",
      "operator": "in",
      "value": ["Electronics", "Accessories"],
      "label": "Danh mục sản phẩm"
    },
    {
      "field": "order_status",
      "operator": "=",
      "value": "completed",
      "label": "Trạng thái đơn hàng"
    }
  ],
  "columns": [
    {
      "name": "product_name",
      "label": "Tên sản phẩm",
      "type": "string",
      "sortable": true,
      "visible": true,
      "width": "40%"
    },
    {
      "name": "total_quantity",
      "label": "Số lượng bán",
      "type": "number",
      "format": "number",
      "sortable": true,
      "visible": true,
      "width": "30%"
    },
    {
      "name": "total_revenue",
      "label": "Doanh thu",
      "type": "number",
      "format": "currency",
      "sortable": true,
      "visible": true,
      "width": "30%"
    }
  ],
  "sorting": [
    {
      "column": "total_revenue",
      "direction": "desc"
    }
  ],
  "grouping": {
    "enabled": false
  },
  "aggregation": {
    "total_quantity": "sum",
    "total_revenue": "sum"
  },
  "visualization": {
    "type": "table",
    "show_totals": true,
    "pagination": {
      "enabled": true,
      "page_size": 10
    }
  },
  "chart_config": {
    "type": "bar",
    "x_axis": "product_name",
    "y_axis": "total_revenue",
    "stacked": false,
    "colors": ["#1976d2", "#2196f3", "#64b5f6"],
    "show_labels": true,
    "show_legend": true,
    "title": "Doanh số theo Sản phẩm - Q2 2023"
  },
  "is_system": false,
  "is_public": true,
  "is_favorite": true,
  "last_run_at": "2023-07-01T10:30:00Z",
  "created_at": "2023-06-15T09:00:00Z",
  "updated_at": "2023-07-01T10:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG DASHBOARDS

### 3.1. Mô tả

Bảng `dashboards` lưu trữ thông tin về các dashboard trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| name | varchar(100) | false | | Tên dashboard |
| description | text | true | null | Mô tả dashboard |
| type | varchar(50) | false | 'custom' | Loại dashboard: custom, system, role_based |
| category | varchar(50) | true | null | Danh mục dashboard |
| layout | jsonb | true | null | Cấu hình bố cục |
| theme | varchar(50) | false | 'light' | Giao diện: light, dark |
| refresh_interval | integer | true | null | Khoảng thời gian làm mới (giây) |
| is_default | boolean | false | false | Đánh dấu là dashboard mặc định |
| is_system | boolean | false | false | Đánh dấu là dashboard hệ thống |
| is_public | boolean | false | false | Đánh dấu là dashboard công khai |
| is_favorite | boolean | false | false | Đánh dấu là dashboard yêu thích |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| dashboards_pkey | PRIMARY KEY | id | Khóa chính |
| dashboards_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên dashboard là duy nhất trong tổ chức |
| dashboards_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| dashboards_type_idx | INDEX | type | Tăng tốc truy vấn theo loại dashboard |
| dashboards_category_idx | INDEX | category | Tăng tốc truy vấn theo danh mục |
| dashboards_is_default_idx | INDEX | is_default | Tăng tốc truy vấn theo dashboard mặc định |
| dashboards_is_system_idx | INDEX | is_system | Tăng tốc truy vấn theo dashboard hệ thống |
| dashboards_is_public_idx | INDEX | is_public | Tăng tốc truy vấn theo dashboard công khai |
| dashboards_created_by_idx | INDEX | created_by | Tăng tốc truy vấn theo người tạo |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| dashboards_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| dashboards_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| dashboards_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| dashboards_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| dashboards_theme_check | CHECK | Đảm bảo theme chỉ nhận các giá trị cho phép |
| dashboards_refresh_interval_check | CHECK | Đảm bảo refresh_interval > 0 khi không null |

### 3.5. Ví dụ JSON

```json
{
  "id": "d1a2s3h4-b5o6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Tổng quan Kinh doanh",
  "description": "Dashboard tổng quan về hiệu suất kinh doanh",
  "type": "custom",
  "category": "sales",
  "layout": {
    "columns": 12,
    "rows": [
      {
        "height": 200,
        "widgets": [
          {
            "id": "w1i2d3g4-e5t6-7890-abcd-ef1234567890",
            "x": 0,
            "y": 0,
            "width": 4,
            "height": 1
          },
          {
            "id": "w2i2d3g4-e5t6-7890-abcd-ef1234567891",
            "x": 4,
            "y": 0,
            "width": 4,
            "height": 1
          },
          {
            "id": "w3i2d3g4-e5t6-7890-abcd-ef1234567892",
            "x": 8,
            "y": 0,
            "width": 4,
            "height": 1
          }
        ]
      },
      {
        "height": 400,
        "widgets": [
          {
            "id": "w4i2d3g4-e5t6-7890-abcd-ef1234567893",
            "x": 0,
            "y": 1,
            "width": 8,
            "height": 2
          },
          {
            "id": "w5i2d3g4-e5t6-7890-abcd-ef1234567894",
            "x": 8,
            "y": 1,
            "width": 4,
            "height": 2
          }
        ]
      }
    ]
  },
  "theme": "light",
  "refresh_interval": 300,
  "is_default": true,
  "is_system": false,
  "is_public": true,
  "is_favorite": true,
  "created_at": "2023-06-01T09:00:00Z",
  "updated_at": "2023-07-01T10:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG DASHBOARD_WIDGETS

### 4.1. Mô tả

Bảng `dashboard_widgets` lưu trữ thông tin về các widget trong dashboard.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| dashboard_id | uuid | false | | Khóa ngoại tới bảng dashboards |
| report_id | uuid | true | null | Khóa ngoại tới bảng reports |
| name | varchar(100) | false | | Tên widget |
| description | text | true | null | Mô tả widget |
| type | varchar(50) | false | | Loại widget: chart, metric, table, list, custom |
| data_source | varchar(50) | false | 'report' | Nguồn dữ liệu: report, api, custom |
| data_config | jsonb | true | null | Cấu hình dữ liệu |
| visualization | jsonb | true | null | Cấu hình hiển thị |
| filters | jsonb | true | null | Bộ lọc widget |
| position | jsonb | true | null | Vị trí trong dashboard |
| size | jsonb | true | null | Kích thước widget |
| refresh_interval | integer | true | null | Khoảng thời gian làm mới (giây) |
| is_system | boolean | false | false | Đánh dấu là widget hệ thống |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| dashboard_widgets_pkey | PRIMARY KEY | id | Khóa chính |
| dashboard_widgets_dashboard_name_idx | UNIQUE | dashboard_id, name | Đảm bảo tên widget là duy nhất trong dashboard |
| dashboard_widgets_dashboard_id_idx | INDEX | dashboard_id | Tăng tốc truy vấn theo dashboard |
| dashboard_widgets_report_id_idx | INDEX | report_id | Tăng tốc truy vấn theo báo cáo |
| dashboard_widgets_type_idx | INDEX | type | Tăng tốc truy vấn theo loại widget |
| dashboard_widgets_data_source_idx | INDEX | data_source | Tăng tốc truy vấn theo nguồn dữ liệu |
| dashboard_widgets_is_system_idx | INDEX | is_system | Tăng tốc truy vấn theo widget hệ thống |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| dashboard_widgets_dashboard_id_fkey | FOREIGN KEY | Tham chiếu đến bảng dashboards(id) |
| dashboard_widgets_report_id_fkey | FOREIGN KEY | Tham chiếu đến bảng reports(id) |
| dashboard_widgets_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| dashboard_widgets_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| dashboard_widgets_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| dashboard_widgets_data_source_check | CHECK | Đảm bảo data_source chỉ nhận các giá trị cho phép |
| dashboard_widgets_refresh_interval_check | CHECK | Đảm bảo refresh_interval > 0 khi không null |

### 4.5. Ví dụ JSON

```json
{
  "id": "w1i2d3g4-e5t6-7890-abcd-ef1234567890",
  "dashboard_id": "d1a2s3h4-b5o6-7890-abcd-ef1234567890",
  "report_id": "r1e2p3o4-r5t6-7890-abcd-ef1234567890",
  "name": "Doanh thu theo tháng",
  "description": "Biểu đồ doanh thu theo tháng trong năm 2023",
  "type": "chart",
  "data_source": "report",
  "data_config": {
    "query": "SELECT DATE_TRUNC('month', o.order_date) AS month, SUM(o.total_amount) AS revenue FROM orders o WHERE o.order_date BETWEEN :start_date AND :end_date AND o.status = 'completed' GROUP BY month ORDER BY month",
    "parameters": {
      "start_date": "2023-01-01",
      "end_date": "2023-12-31"
    }
  },
  "visualization": {
    "chart_type": "line",
    "x_axis": {
      "field": "month",
      "label": "Tháng",
      "format": "MM/YYYY"
    },
    "y_axis": {
      "field": "revenue",
      "label": "Doanh thu",
      "format": "currency"
    },
    "colors": ["#1976d2"],
    "show_labels": true,
    "show_legend": false,
    "show_grid": true,
    "title": "Doanh thu theo tháng (2023)"
  },
  "filters": [
    {
      "field": "order_status",
      "operator": "=",
      "value": "completed",
      "label": "Trạng thái đơn hàng"
    }
  ],
  "position": {
    "x": 0,
    "y": 1
  },
  "size": {
    "width": 8,
    "height": 2
  },
  "refresh_interval": 600,
  "is_system": false,
  "created_at": "2023-06-01T09:30:00Z",
  "updated_at": "2023-07-01T10:15:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
