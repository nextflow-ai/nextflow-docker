# API QUẢN LÝ SẢN PHẨM NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Sản phẩm Cơ bản](#2-endpoints-sản-phẩm-cơ-bản)
3. [Endpoints Quản lý Kho](#3-endpoints-quản-lý-kho)
4. [Endpoints Giá cả](#4-endpoints-giá-cả)
5. [Endpoints Hình ảnh](#5-endpoints-hình-ảnh)
6. [Endpoints Tìm kiếm](#6-endpoints-tìm-kiếm)
7. [Error Codes](#7-error-codes)

## 1. GIỚI THIỆU

API Quản lý Sản phẩm của NextFlow CRM cung cấp các endpoint để quản lý thông tin sản phẩm, kho hàng, giá cả và hình ảnh sản phẩm.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
```

## 2. ENDPOINTS SẢN PHẨM CƠ BẢN

### 2.1. Lấy danh sách sản phẩm

```http
GET /products
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số lượng sản phẩm mỗi trang (mặc định: 20, tối đa: 100) |
| sort | string | Sắp xếp (name:asc, price:desc, v.v.) |
| status | string | Lọc theo trạng thái (active, inactive, draft) |
| categoryId | string | Lọc theo danh mục |
| search | string | Tìm kiếm theo tên hoặc mô tả |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "product_123456789",
      "name": "NextFlow CRM Professional",
      "description": "Phần mềm quản lý khách hàng chuyên nghiệp",
      "sku": "NFCRM-PRO-001",
      "status": "active",
      "category": {
        "id": "category_123456789",
        "name": "Phần mềm CRM"
      },
      "price": {
        "regular": 1500000,
        "sale": 1200000,
        "currency": "VND"
      },
      "inventory": {
        "quantity": 100,
        "reserved": 5,
        "available": 95
      },
      "images": [
        {
          "id": "image_123456789",
          "url": "https://cdn.nextflow-crm.com/products/nfcrm-pro-001.jpg",
          "alt": "NextFlow CRM Professional",
          "isPrimary": true
        }
      ],
      "createdAt": "2023-10-27T09:15:00Z",
      "updatedAt": "2023-10-27T09:15:00Z"
    }
  ]
}
```

### 2.2. Lấy thông tin sản phẩm

```http
GET /products/{productId}
```

### 2.3. Tạo sản phẩm mới

```http
POST /products
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "NextFlow CRM Enterprise",
  "description": "Phần mềm quản lý khách hàng doanh nghiệp",
  "sku": "NFCRM-ENT-001",
  "categoryId": "category_123456789",
  "status": "active",
  "price": {
    "regular": 3000000,
    "currency": "VND"
  },
  "inventory": {
    "quantity": 50,
    "trackInventory": true,
    "allowBackorder": false
  },
  "specifications": {
    "users": "Không giới hạn",
    "storage": "1TB",
    "support": "24/7"
  },
  "seo": {
    "metaTitle": "NextFlow CRM Enterprise - Giải pháp CRM doanh nghiệp",
    "metaDescription": "Phần mềm quản lý khách hàng toàn diện cho doanh nghiệp lớn",
    "slug": "nextflow-crm-enterprise"
  }
}
```

### 2.4. Cập nhật sản phẩm

```http
PUT /products/{productId}
Content-Type: application/json
```

### 2.5. Xóa sản phẩm

```http
DELETE /products/{productId}
```

## 3. ENDPOINTS QUẢN LÝ KHO

### 3.1. Lấy thông tin kho hàng

```http
GET /products/{productId}/inventory
```

### 3.2. Cập nhật số lượng tồn kho

```http
PUT /products/{productId}/inventory
Content-Type: application/json
```

#### Request Body

```json
{
  "quantity": 150,
  "reason": "Nhập kho mới",
  "note": "Nhập 50 sản phẩm từ nhà cung cấp"
}
```

### 3.3. Lịch sử xuất nhập kho

```http
GET /products/{productId}/inventory/history
```

### 3.4. Đặt cảnh báo tồn kho

```http
POST /products/{productId}/inventory/alerts
Content-Type: application/json
```

## 4. ENDPOINTS GIÁ CẢ

### 4.1. Lấy thông tin giá

```http
GET /products/{productId}/pricing
```

### 4.2. Cập nhật giá sản phẩm

```http
PUT /products/{productId}/pricing
Content-Type: application/json
```

### 4.3. Lịch sử thay đổi giá

```http
GET /products/{productId}/pricing/history
```

### 4.4. Thiết lập giá theo số lượng

```http
POST /products/{productId}/pricing/tiers
Content-Type: application/json
```

## 5. ENDPOINTS HÌNH ẢNH

### 5.1. Lấy danh sách hình ảnh

```http
GET /products/{productId}/images
```

### 5.2. Upload hình ảnh

```http
POST /products/{productId}/images
Content-Type: multipart/form-data
```

### 5.3. Cập nhật thông tin hình ảnh

```http
PUT /products/{productId}/images/{imageId}
Content-Type: application/json
```

### 5.4. Xóa hình ảnh

```http
DELETE /products/{productId}/images/{imageId}
```

## 6. ENDPOINTS TÌM KIẾM

### 6.1. Tìm kiếm sản phẩm

```http
GET /products/search
```

### 6.2. Tìm kiếm nâng cao

```http
POST /products/advanced-search
Content-Type: application/json
```

### 6.3. Gợi ý sản phẩm

```http
GET /products/suggestions
```

### 6.4. Sản phẩm liên quan

```http
GET /products/{productId}/related
```

## 7. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Product not found | Không tìm thấy sản phẩm |
| 4002 | SKU already exists | SKU đã tồn tại |
| 4003 | Invalid category | Danh mục không hợp lệ |
| 4004 | Insufficient inventory | Không đủ hàng tồn kho |
| 4005 | Invalid price | Giá không hợp lệ |
| 5001 | Image upload failed | Upload hình ảnh thất bại |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM API Team
