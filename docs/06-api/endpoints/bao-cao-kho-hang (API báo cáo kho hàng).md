# API BÁO CÁO KHO HÀNG NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Báo cáo Tồn kho](#2-endpoints-báo-cáo-tồn-kho)
3. [Endpoints Báo cáo Xuất nhập](#3-endpoints-báo-cáo-xuất-nhập)
4. [Endpoints Báo cáo Hiệu suất](#4-endpoints-báo-cáo-hiệu-suất)
5. [Endpoints Dự báo](#5-endpoints-dự-báo)
6. [Endpoints Xuất báo cáo](#6-endpoints-xuất-báo-cáo)
7. [Error Codes](#7-error-codes)

## 1. GIỚI THIỆU

API Báo cáo Kho hàng của NextFlow CRM-AI cung cấp các endpoint để quản lý và báo cáo về tình trạng kho hàng, xuất nhập kho, hiệu suất và dự báo nhu cầu.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
```

## 2. ENDPOINTS BÁO CÁO TỒN KHO

### 2.1. Báo cáo tồn kho tổng quan

```http
GET /reports/inventory/overview
```

### 2.2. Báo cáo tồn kho theo sản phẩm

```http
GET /reports/inventory/by-product
```

### 2.3. Báo cáo hàng sắp hết

```http
GET /reports/inventory/low-stock
```

### 2.4. Báo cáo hàng tồn kho chết

```http
GET /reports/inventory/dead-stock
```

## 3. ENDPOINTS BÁO CÁO XUẤT NHẬP

### 3.1. Báo cáo xuất kho

```http
GET /reports/inventory/outbound
```

### 3.2. Báo cáo nhập kho

```http
GET /reports/inventory/inbound
```

### 3.3. Báo cáo chuyển kho

```http
GET /reports/inventory/transfers
```

### 3.4. Báo cáo điều chỉnh kho

```http
GET /reports/inventory/adjustments
```

## 4. ENDPOINTS BÁO CÁO HIỆU SUẤT

### 4.1. Báo cáo vòng quay kho

```http
GET /reports/inventory/turnover
```

### 4.2. Báo cáo hiệu suất kho

```http
GET /reports/inventory/performance
```

### 4.3. Báo cáo chi phí lưu kho

```http
GET /reports/inventory/storage-costs
```

### 4.4. Báo cáo ABC analysis

```http
GET /reports/inventory/abc-analysis
```

## 5. ENDPOINTS DỰ BÁO

### 5.1. Dự báo nhu cầu

```http
GET /reports/inventory/demand-forecast
```

### 5.2. Dự báo tồn kho

```http
GET /reports/inventory/stock-forecast
```

### 5.3. Khuyến nghị đặt hàng

```http
GET /reports/inventory/reorder-recommendations
```

## 6. ENDPOINTS XUẤT BÁO CÁO

### 6.1. Xuất báo cáo Excel

```http
POST /reports/inventory/export/excel
```

### 6.2. Xuất báo cáo PDF

```http
POST /reports/inventory/export/pdf
```

## 7. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Warehouse not found | Không tìm thấy kho |
| 4002 | Product not found | Không tìm thấy sản phẩm |
| 5001 | Calculation failed | Tính toán thất bại |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
