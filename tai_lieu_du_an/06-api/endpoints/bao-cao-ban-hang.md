# API BÁO CÁO BÁN HÀNG NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Báo cáo Tổng quan](#2-endpoints-báo-cáo-tổng-quan)
3. [Endpoints Báo cáo Doanh thu](#3-endpoints-báo-cáo-doanh-thu)
4. [Endpoints Báo cáo Sản phẩm](#4-endpoints-báo-cáo-sản-phẩm)
5. [Endpoints Báo cáo Nhân viên](#5-endpoints-báo-cáo-nhân-viên)
6. [Endpoints Báo cáo Khu vực](#6-endpoints-báo-cáo-khu-vực)
7. [Endpoints Xuất báo cáo](#7-endpoints-xuất-báo-cáo)
8. [Error Codes](#8-error-codes)

## 1. GIỚI THIỆU

API Báo cáo Bán hàng của NextFlow CRM cung cấp các endpoint để tạo và truy xuất các báo cáo chi tiết về hoạt động bán hàng, doanh thu, hiệu suất sản phẩm và nhân viên bán hàng.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
```

### 1.3. Rate Limiting

- **Limit**: 1000 requests/hour
- **Burst**: 100 requests/minute

## 2. ENDPOINTS BÁO CÁO TỔNG QUAN

### 2.1. Báo cáo tổng quan bán hàng

```http
GET /reports/sales/overview
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |
| granularity | string | Độ chi tiết (day, week, month, quarter, year) |
| compareWith | string | So sánh với kỳ trước (previous_period, previous_year) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "summary": {
      "totalRevenue": 15750000,
      "totalOrders": 1247,
      "averageOrderValue": 12630,
      "conversionRate": 3.2,
      "growth": {
        "revenue": 15.3,
        "orders": 8.7,
        "averageOrderValue": 6.1
      }
    },
    "timeline": [
      {
        "date": "2023-10-27",
        "revenue": 850000,
        "orders": 67,
        "averageOrderValue": 12687,
        "conversionRate": 3.4
      }
    ],
    "topProducts": [
      {
        "productId": "product_123456789",
        "productName": "NextFlow CRM Professional",
        "revenue": 2500000,
        "quantity": 125,
        "percentage": 15.9
      }
    ],
    "topSalesReps": [
      {
        "userId": "user_123456789",
        "name": "Nguyễn Văn A",
        "revenue": 1250000,
        "orders": 89,
        "conversionRate": 4.2
      }
    ]
  }
}
```

### 2.2. Báo cáo KPI bán hàng

```http
GET /reports/sales/kpis
```

### 2.3. Báo cáo xu hướng bán hàng

```http
GET /reports/sales/trends
```

### 2.4. Báo cáo so sánh kỳ

```http
GET /reports/sales/comparison
```

## 3. ENDPOINTS BÁO CÁO DOANH THU

### 3.1. Báo cáo doanh thu theo thời gian

```http
GET /reports/sales/revenue
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |
| granularity | string | Độ chi tiết (day, week, month, quarter, year) |
| currency | string | Loại tiền tệ (VND, USD) |
| includeRefunds | boolean | Bao gồm hoàn tiền |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "summary": {
      "totalRevenue": 15750000,
      "grossRevenue": 16200000,
      "refunds": 450000,
      "netRevenue": 15750000,
      "currency": "VND"
    },
    "breakdown": {
      "byPaymentMethod": [
        {
          "method": "bank_transfer",
          "revenue": 9450000,
          "percentage": 60.0
        },
        {
          "method": "credit_card",
          "revenue": 4725000,
          "percentage": 30.0
        }
      ],
      "byChannel": [
        {
          "channel": "website",
          "revenue": 11025000,
          "percentage": 70.0
        },
        {
          "channel": "mobile_app",
          "revenue": 3150000,
          "percentage": 20.0
        }
      ]
    },
    "timeline": [
      {
        "period": "2023-10-27",
        "revenue": 850000,
        "grossRevenue": 875000,
        "refunds": 25000,
        "netRevenue": 850000
      }
    ]
  }
}
```

### 3.2. Báo cáo doanh thu theo kênh

```http
GET /reports/sales/revenue-by-channel
```

### 3.3. Báo cáo doanh thu theo phương thức thanh toán

```http
GET /reports/sales/revenue-by-payment-method
```

### 3.4. Báo cáo dự báo doanh thu

```http
GET /reports/sales/revenue-forecast
```

## 4. ENDPOINTS BÁO CÁO SẢN PHẨM

### 4.1. Báo cáo hiệu suất sản phẩm

```http
GET /reports/sales/product-performance
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |
| categoryId | string | Lọc theo danh mục |
| sortBy | string | Sắp xếp (revenue, quantity, profit) |
| limit | integer | Số lượng sản phẩm (mặc định: 50) |

### 4.2. Báo cáo sản phẩm bán chạy

```http
GET /reports/sales/top-selling-products
```

### 4.3. Báo cáo sản phẩm có lợi nhuận cao

```http
GET /reports/sales/most-profitable-products
```

### 4.4. Báo cáo phân tích ABC sản phẩm

```http
GET /reports/sales/product-abc-analysis
```

## 5. ENDPOINTS BÁO CÁO NHÂN VIÊN

### 5.1. Báo cáo hiệu suất nhân viên bán hàng

```http
GET /reports/sales/sales-rep-performance
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |
| departmentId | string | Lọc theo phòng ban |
| teamId | string | Lọc theo team |
| sortBy | string | Sắp xếp (revenue, orders, conversion_rate) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "userId": "user_123456789",
      "name": "Nguyễn Văn A",
      "email": "a@nextflow-crm.com",
      "department": "Sales",
      "team": "Enterprise Sales",
      "metrics": {
        "revenue": 1250000,
        "orders": 89,
        "averageOrderValue": 14045,
        "conversionRate": 4.2,
        "activitiesCount": 245,
        "callsCount": 156,
        "emailsCount": 89
      },
      "targets": {
        "revenueTarget": 1500000,
        "revenueAchievement": 83.3,
        "ordersTarget": 100,
        "ordersAchievement": 89.0
      },
      "ranking": 2
    }
  ]
}
```

### 5.2. Báo cáo xếp hạng nhân viên

```http
GET /reports/sales/sales-rep-ranking
```

### 5.3. Báo cáo hoạt động bán hàng

```http
GET /reports/sales/sales-activities
```

### 5.4. Báo cáo đạt target

```http
GET /reports/sales/target-achievement
```

## 6. ENDPOINTS BÁO CÁO KHU VỰC

### 6.1. Báo cáo doanh thu theo khu vực

```http
GET /reports/sales/revenue-by-region
```

### 6.2. Báo cáo hiệu suất theo thành phố

```http
GET /reports/sales/performance-by-city
```

### 6.3. Báo cáo phân bố khách hàng

```http
GET /reports/sales/customer-distribution
```

### 6.4. Báo cáo thị trường tiềm năng

```http
GET /reports/sales/market-potential
```

## 7. ENDPOINTS XUẤT BÁO CÁO

### 7.1. Xuất báo cáo Excel

```http
POST /reports/sales/export/excel
Content-Type: application/json
```

#### Request Body

```json
{
  "reportType": "overview",
  "fromDate": "2023-10-01",
  "toDate": "2023-10-31",
  "includeCharts": true,
  "format": "xlsx"
}
```

### 7.2. Xuất báo cáo PDF

```http
POST /reports/sales/export/pdf
Content-Type: application/json
```

### 7.3. Lên lịch báo cáo tự động

```http
POST /reports/sales/schedule
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Báo cáo bán hàng hàng tháng",
  "reportType": "overview",
  "schedule": {
    "frequency": "monthly",
    "dayOfMonth": 1,
    "time": "09:00"
  },
  "recipients": [
    "manager@nextflow-crm.com",
    "sales@nextflow-crm.com"
  ],
  "format": "pdf"
}
```

### 7.4. Lấy danh sách báo cáo đã lên lịch

```http
GET /reports/sales/scheduled
```

## 8. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Invalid date range | Khoảng thời gian không hợp lệ |
| 4002 | Report not found | Không tìm thấy báo cáo |
| 4003 | Insufficient permissions | Không đủ quyền truy cập |
| 4004 | Export failed | Xuất báo cáo thất bại |
| 4005 | Schedule conflict | Xung đột lịch báo cáo |
| 5001 | Data processing error | Lỗi xử lý dữ liệu |
| 5002 | Report generation timeout | Timeout tạo báo cáo |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM API Team
