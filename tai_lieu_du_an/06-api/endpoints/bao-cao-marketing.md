# API BÁO CÁO MARKETING NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Báo cáo Chiến dịch](#2-endpoints-báo-cáo-chiến-dịch)
3. [Endpoints Báo cáo Kênh](#3-endpoints-báo-cáo-kênh)
4. [Endpoints Báo cáo ROI](#4-endpoints-báo-cáo-roi)
5. [Endpoints Báo cáo Lead](#5-endpoints-báo-cáo-lead)
6. [Endpoints Xuất báo cáo](#6-endpoints-xuất-báo-cáo)
7. [Error Codes](#7-error-codes)

## 1. GIỚI THIỆU

API Báo cáo Marketing của NextFlow CRM cung cấp các endpoint để phân tích hiệu quả các chiến dịch marketing, ROI, conversion và lead generation.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
```

## 2. ENDPOINTS BÁO CÁO CHIẾN DỊCH

### 2.1. Báo cáo tổng quan chiến dịch

```http
GET /reports/marketing/campaigns/overview
```

### 2.2. Báo cáo hiệu suất chiến dịch

```http
GET /reports/marketing/campaigns/performance
```

### 2.3. Báo cáo conversion rate

```http
GET /reports/marketing/campaigns/conversion
```

### 2.4. Báo cáo chi phí chiến dịch

```http
GET /reports/marketing/campaigns/costs
```

## 3. ENDPOINTS BÁO CÁO KÊNH

### 3.1. Báo cáo hiệu suất theo kênh

```http
GET /reports/marketing/channels/performance
```

### 3.2. Báo cáo attribution

```http
GET /reports/marketing/channels/attribution
```

### 3.3. Báo cáo customer journey

```http
GET /reports/marketing/channels/customer-journey
```

## 4. ENDPOINTS BÁO CÁO ROI

### 4.1. Báo cáo ROI marketing

```http
GET /reports/marketing/roi
```

### 4.2. Báo cáo ROAS

```http
GET /reports/marketing/roas
```

### 4.3. Báo cáo LTV/CAC

```http
GET /reports/marketing/ltv-cac
```

## 5. ENDPOINTS BÁO CÁO LEAD

### 5.1. Báo cáo lead generation

```http
GET /reports/marketing/leads/generation
```

### 5.2. Báo cáo lead quality

```http
GET /reports/marketing/leads/quality
```

### 5.3. Báo cáo lead conversion

```http
GET /reports/marketing/leads/conversion
```

## 6. ENDPOINTS XUẤT BÁO CÁO

### 6.1. Xuất báo cáo Excel

```http
POST /reports/marketing/export/excel
```

### 6.2. Xuất báo cáo PDF

```http
POST /reports/marketing/export/pdf
```

## 7. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Campaign not found | Không tìm thấy chiến dịch |
| 4002 | Channel not found | Không tìm thấy kênh |
| 5001 | Analytics failed | Phân tích thất bại |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM API Team
