# API USER NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Cơ bản](#2-endpoints-cơ-bản)
3. [Endpoints Nâng cao](#3-endpoints-nâng-cao)
4. [Endpoints Bảo mật](#4-endpoints-bảo-mật)
5. [Endpoints Thống kê](#5-endpoints-thống-kê)
6. [Error Codes](#6-error-codes)

## 1. GIỚI THIỆU

API user của NextFlow CRM-AI cung cấp các endpoint để quản lý user.

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

## 2. ENDPOINTS CƠ BẢN

### 2.1. Lấy danh sách

```http
GET /user
```

### 2.2. Lấy thông tin chi tiết

```http
GET /user/{id}
```

### 2.3. Tạo mới

```http
POST /user
Content-Type: application/json
```

### 2.4. Cập nhật

```http
PUT /user/{id}
Content-Type: application/json
```

### 2.5. Xóa

```http
DELETE /user/{id}
```

## 3. ENDPOINTS NÂNG CAO

### 3.1. Tìm kiếm

```http
GET /user/search
```

### 3.2. Bulk operations

```http
POST /user/bulk
Content-Type: application/json
```

### 3.3. Import/Export

```http
POST /user/import
Content-Type: multipart/form-data
```

## 4. ENDPOINTS BẢO MẬT

### 4.1. Xác thực

```http
POST /user/authenticate
```

### 4.2. Phân quyền

```http
GET /user/permissions
```

## 5. ENDPOINTS THỐNG KÊ

### 5.1. Thống kê tổng quan

```http
GET /user/analytics
```

### 5.2. Báo cáo

```http
GET /user/reports
```

## 6. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Not found | Không tìm thấy |
| 4002 | Invalid data | Dữ liệu không hợp lệ |
| 4003 | Unauthorized | Không có quyền |
| 5001 | Server error | Lỗi server |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
