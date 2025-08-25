# API BÁO CÁO KHÁCH HÀNG NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Báo cáo Tổng quan](#2-endpoints-báo-cáo-tổng-quan)
3. [Endpoints Phân tích Hành vi](#3-endpoints-phân-tích-hành-vi)
4. [Endpoints Phân khúc Khách hàng](#4-endpoints-phân-khúc-khách-hàng)
5. [Endpoints Giá trị Khách hàng](#5-endpoints-giá-trị-khách-hàng)
6. [Endpoints Churn Analysis](#6-endpoints-churn-analysis)
7. [Endpoints Xuất báo cáo](#7-endpoints-xuất-báo-cáo)
8. [Error Codes](#8-error-codes)

## 1. GIỚI THIỆU

API Báo cáo Khách hàng của NextFlow CRM-AI cung cấp các endpoint để phân tích và báo cáo về khách hàng, bao gồm hành vi mua hàng, giá trị khách hàng, phân khúc và dự đoán churn.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
```

## 2. ENDPOINTS BÁO CÁO TỔNG QUAN

### 2.1. Báo cáo tổng quan khách hàng

```http
GET /reports/customers/overview
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "summary": {
      "totalCustomers": 15420,
      "newCustomers": 247,
      "activeCustomers": 12350,
      "churnedCustomers": 156,
      "averageLifetimeValue": 2450000,
      "customerAcquisitionCost": 125000,
      "retentionRate": 89.2
    },
    "growth": {
      "newCustomers": 15.3,
      "activeCustomers": 8.7,
      "retentionRate": 2.1
    }
  }
}
```

### 2.2. Báo cáo khách hàng mới

```http
GET /reports/customers/new-customers
```

### 2.3. Báo cáo khách hàng hoạt động

```http
GET /reports/customers/active-customers
```

### 2.4. Báo cáo tỷ lệ giữ chân khách hàng

```http
GET /reports/customers/retention-rate
```

## 3. ENDPOINTS PHÂN TÍCH HÀNH VI

### 3.1. Phân tích hành vi mua hàng

```http
GET /reports/customers/purchase-behavior
```

### 3.2. Phân tích tần suất mua hàng

```http
GET /reports/customers/purchase-frequency
```

### 3.3. Phân tích giỏ hàng trung bình

```http
GET /reports/customers/average-basket
```

### 3.4. Phân tích chu kỳ mua hàng

```http
GET /reports/customers/purchase-cycle
```

## 4. ENDPOINTS PHÂN KHÚC KHÁCH HÀNG

### 4.1. Phân tích RFM

```http
GET /reports/customers/rfm-analysis
```

### 4.2. Phân khúc theo giá trị

```http
GET /reports/customers/value-segments
```

### 4.3. Phân khúc theo hành vi

```http
GET /reports/customers/behavior-segments
```

### 4.4. Phân khúc tùy chỉnh

```http
POST /reports/customers/custom-segments
Content-Type: application/json
```

## 5. ENDPOINTS GIÁ TRỊ KHÁCH HÀNG

### 5.1. Customer Lifetime Value (CLV)

```http
GET /reports/customers/lifetime-value
```

### 5.2. Khách hàng có giá trị cao

```http
GET /reports/customers/high-value-customers
```

### 5.3. Dự đoán giá trị khách hàng

```http
GET /reports/customers/predicted-value
```

### 5.4. ROI theo khách hàng

```http
GET /reports/customers/customer-roi
```

## 6. ENDPOINTS CHURN ANALYSIS

### 6.1. Phân tích churn

```http
GET /reports/customers/churn-analysis
```

### 6.2. Dự đoán churn

```http
GET /reports/customers/churn-prediction
```

### 6.3. Khách hàng có nguy cơ churn

```http
GET /reports/customers/at-risk-customers
```

### 6.4. Nguyên nhân churn

```http
GET /reports/customers/churn-reasons
```

## 7. ENDPOINTS XUẤT BÁO CÁO

### 7.1. Xuất báo cáo Excel

```http
POST /reports/customers/export/excel
Content-Type: application/json
```

### 7.2. Xuất báo cáo PDF

```http
POST /reports/customers/export/pdf
Content-Type: application/json
```

### 7.3. Lên lịch báo cáo

```http
POST /reports/customers/schedule
Content-Type: application/json
```

## 8. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Invalid date range | Khoảng thời gian không hợp lệ |
| 4002 | Segment not found | Không tìm thấy phân khúc |
| 4003 | Insufficient data | Không đủ dữ liệu |
| 5001 | Analysis failed | Phân tích thất bại |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
