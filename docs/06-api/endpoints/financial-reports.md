# API BÁO CÁO TÀI CHÍNH NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Báo cáo Doanh thu](#2-endpoints-báo-cáo-doanh-thu)
3. [Endpoints Báo cáo Chi phí](#3-endpoints-báo-cáo-chi-phí)
4. [Endpoints Báo cáo Lợi nhuận](#4-endpoints-báo-cáo-lợi-nhuận)
5. [Endpoints Báo cáo Công nợ](#5-endpoints-báo-cáo-công-nợ)
6. [Endpoints Xuất báo cáo](#6-endpoints-xuất-báo-cáo)
7. [Error Codes](#7-error-codes)

## 1. GIỚI THIỆU

API Báo cáo Tài chính của NextFlow CRM-AI cung cấp các endpoint để tạo và truy xuất các báo cáo tài chính chi tiết bao gồm doanh thu, chi phí, lợi nhuận và công nợ.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
```

## 2. ENDPOINTS BÁO CÁO DOANH THU

### 2.1. Báo cáo doanh thu tổng quan

```http
GET /reports/financial/revenue/overview
```

### 2.2. Báo cáo doanh thu theo kỳ

```http
GET /reports/financial/revenue/by-period
```

### 2.3. Báo cáo doanh thu theo sản phẩm

```http
GET /reports/financial/revenue/by-product
```

### 2.4. Báo cáo doanh thu theo khách hàng

```http
GET /reports/financial/revenue/by-customer
```

## 3. ENDPOINTS BÁO CÁO CHI PHÍ

### 3.1. Báo cáo chi phí tổng quan

```http
GET /reports/financial/expenses/overview
```

### 2.2. Báo cáo chi phí theo danh mục

```http
GET /reports/financial/expenses/by-category
```

### 3.3. Báo cáo chi phí vận hành

```http
GET /reports/financial/expenses/operational
```

### 3.4. Báo cáo chi phí marketing

```http
GET /reports/financial/expenses/marketing
```

## 4. ENDPOINTS BÁO CÁO LỢI NHUẬN

### 4.1. Báo cáo lợi nhuận tổng quan

```http
GET /reports/financial/profit/overview
```

### 4.2. Báo cáo lợi nhuận gộp

```http
GET /reports/financial/profit/gross
```

### 4.3. Báo cáo lợi nhuận ròng

```http
GET /reports/financial/profit/net
```

### 4.4. Báo cáo margin

```http
GET /reports/financial/profit/margins
```

## 5. ENDPOINTS BÁO CÁO CÔNG NỢ

### 5.1. Báo cáo công nợ phải thu

```http
GET /reports/financial/receivables
```

### 5.2. Báo cáo công nợ phải trả

```http
GET /reports/financial/payables
```

### 5.3. Báo cáo tuổi nợ

```http
GET /reports/financial/aging
```

### 5.4. Báo cáo cash flow

```http
GET /reports/financial/cash-flow
```

## 6. ENDPOINTS XUẤT BÁO CÁO

### 6.1. Xuất báo cáo Excel

```http
POST /reports/financial/export/excel
```

### 6.2. Xuất báo cáo PDF

```http
POST /reports/financial/export/pdf
```

## 7. ERROR CODES

| Code | Message            | Mô tả                   |
| ---- | ------------------ | ----------------------- |
| 4001 | Invalid period     | Kỳ báo cáo không hợp lệ |
| 4002 | Data not available | Dữ liệu không có sẵn    |
| 5001 | Calculation error  | Lỗi tính toán           |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
