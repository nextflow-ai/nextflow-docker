# API $(echo $file | tr '-' ' ' | tr '[:lower:]' '[:upper:]') NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Cơ bản](#2-endpoints-cơ-bản)
3. [Endpoints Nâng cao](#3-endpoints-nâng-cao)
4. [Endpoints Tìm kiếm](#4-endpoints-tìm-kiếm)
5. [Endpoints Thống kê](#5-endpoints-thống-kê)
6. [Error Codes](#6-error-codes)

## 1. GIỚI THIỆU

API $(echo $file | tr '-' ' ') của NextFlow CRM-AI cung cấp các endpoint để quản lý $(echo $file | tr '-' ' ').

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
```

## 2. ENDPOINTS CƠ BẢN

### 2.1. Lấy danh sách

```http
GET /$(echo $file | tr '-' '/')
```

### 2.2. Lấy thông tin chi tiết

```http
GET /$(echo $file | tr '-' '/')/{id}
```

### 2.3. Tạo mới

```http
POST /$(echo $file | tr '-' '/')
Content-Type: application/json
```

### 2.4. Cập nhật

```http
PUT /$(echo $file | tr '-' '/')/{id}
Content-Type: application/json
```

### 2.5. Xóa

```http
DELETE /$(echo $file | tr '-' '/')/{id}
```

## 3. ENDPOINTS NÂNG CAO

### 3.1. Bulk operations

```http
POST /$(echo $file | tr '-' '/')/bulk
Content-Type: application/json
```

### 3.2. Import/Export

```http
POST /$(echo $file | tr '-' '/')/import
Content-Type: multipart/form-data
```

```http
GET /$(echo $file | tr '-' '/')/export
```

## 4. ENDPOINTS TÌM KIẾM

### 4.1. Tìm kiếm cơ bản

```http
GET /$(echo $file | tr '-' '/')/search
```

### 4.2. Tìm kiếm nâng cao

```http
POST /$(echo $file | tr '-' '/')/advanced-search
Content-Type: application/json
```

## 5. ENDPOINTS THỐNG KÊ

### 5.1. Thống kê tổng quan

```http
GET /$(echo $file | tr '-' '/')/analytics
```

### 5.2. Báo cáo

```http
GET /$(echo $file | tr '-' '/')/reports
```

## 6. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Not found | Không tìm thấy |
| 4002 | Invalid data | Dữ liệu không hợp lệ |
| 5001 | Server error | Lỗi server |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
