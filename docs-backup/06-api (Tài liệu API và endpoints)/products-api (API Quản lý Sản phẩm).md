# API QUẢN LÝ SẢN PHẨM - NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Authentication](#2-authentication)
3. [Base URL](#3-base-url)
4. [Endpoints chính](#4-endpoints-chính)
5. [Models và Schema](#5-models-và-schema)
6. [Ví dụ sử dụng](#6-ví-dụ-sử-dụng)
7. [Error Handling](#7-error-handling)

## 1. GIỚI THIỆU

API Quản lý Sản phẩm cung cấp các endpoints để quản lý sản phẩm trong hệ thống NextFlow CRM-AI, bao gồm tạo, đọc, cập nhật, xóa sản phẩm và quản lý danh mục, biến thể, thuộc tính.

### 1.1. Tính năng chính

- ✅ **CRUD Operations**: Tạo, đọc, cập nhật, xóa sản phẩm
- ✅ **Category Management**: Quản lý danh mục sản phẩm
- ✅ **Product Variants**: Quản lý biến thể sản phẩm (size, color, etc.)
- ✅ **Attributes**: Quản lý thuộc tính sản phẩm
- ✅ **Inventory**: Quản lý tồn kho
- ✅ **Pricing**: Quản lý giá và khuyến mãi
- ✅ **Media**: Quản lý hình ảnh và video sản phẩm
- ✅ **SEO**: Tối ưu hóa SEO cho sản phẩm

## 2. AUTHENTICATION

Tất cả API calls cần có header Authorization:

```http
Authorization: Bearer {access_token}
Content-Type: application/json
X-Organization-ID: {organization_id}
```

## 3. BASE URL

```
Production: https://api.nextflow.com/v1
Staging: https://staging-api.nextflow.com/v1
Development: https://dev-api.nextflow.com/v1
```

## 4. ENDPOINTS CHÍNH

### 4.1. Quản lý Sản phẩm

#### GET /products
Lấy danh sách sản phẩm với phân trang và filter

**Query Parameters:**
- `page` (integer): Số trang (default: 1)
- `limit` (integer): Số items per page (default: 20, max: 100)
- `category_id` (string): Filter theo danh mục
- `status` (string): Filter theo trạng thái (active, inactive, draft)
- `search` (string): Tìm kiếm theo tên, SKU, mô tả
- `sort` (string): Sắp xếp (name, created_at, price, stock)
- `order` (string): Thứ tự (asc, desc)

**Response:**
```json
{
  "success": true,
  "data": {
    "products": [
      {
        "id": "prod_123456789",
        "name": "iPhone 15 Pro Max",
        "slug": "iphone-15-pro-max",
        "sku": "IP15PM-256-TIT",
        "description": "iPhone 15 Pro Max với chip A17 Pro",
        "short_description": "Flagship iPhone mới nhất",
        "category_id": "cat_electronics",
        "status": "active",
        "price": 29990000,
        "compare_price": 32990000,
        "cost_price": 25000000,
        "currency": "VND",
        "stock_quantity": 50,
        "track_inventory": true,
        "weight": 221,
        "dimensions": {
          "length": 159.9,
          "width": 76.7,
          "height": 8.25
        },
        "images": [
          {
            "id": "img_001",
            "url": "https://cdn.nextflow.com/products/iphone15pro.jpg",
            "alt": "iPhone 15 Pro Max",
            "position": 1
          }
        ],
        "variants": [
          {
            "id": "var_001",
            "sku": "IP15PM-256-TIT",
            "price": 29990000,
            "stock": 50,
            "attributes": {
              "color": "Titan Tự nhiên",
              "storage": "256GB"
            }
          }
        ],
        "seo": {
          "title": "iPhone 15 Pro Max - Điện thoại flagship Apple",
          "description": "Mua iPhone 15 Pro Max chính hãng với giá tốt nhất",
          "keywords": ["iphone", "apple", "smartphone"]
        },
        "created_at": "2024-01-15T10:00:00Z",
        "updated_at": "2024-01-15T10:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 100,
      "items_per_page": 20
    }
  }
}
```

#### POST /products
Tạo sản phẩm mới

**Request Body:**
```json
{
  "name": "iPhone 15 Pro Max",
  "slug": "iphone-15-pro-max",
  "sku": "IP15PM-256-TIT",
  "description": "iPhone 15 Pro Max với chip A17 Pro",
  "short_description": "Flagship iPhone mới nhất",
  "category_id": "cat_electronics",
  "status": "active",
  "price": 29990000,
  "compare_price": 32990000,
  "cost_price": 25000000,
  "currency": "VND",
  "stock_quantity": 50,
  "track_inventory": true,
  "weight": 221,
  "dimensions": {
    "length": 159.9,
    "width": 76.7,
    "height": 8.25
  },
  "images": [
    {
      "url": "https://cdn.nextflow.com/products/iphone15pro.jpg",
      "alt": "iPhone 15 Pro Max",
      "position": 1
    }
  ],
  "seo": {
    "title": "iPhone 15 Pro Max - Điện thoại flagship Apple",
    "description": "Mua iPhone 15 Pro Max chính hãng với giá tốt nhất",
    "keywords": ["iphone", "apple", "smartphone"]
  }
}
```

#### GET /products/{id}
Lấy thông tin chi tiết sản phẩm

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "prod_123456789",
    "name": "iPhone 15 Pro Max",
    // ... full product details
    "variants": [...],
    "categories": [...],
    "attributes": [...],
    "related_products": [...],
    "reviews_summary": {
      "average_rating": 4.8,
      "total_reviews": 156,
      "rating_distribution": {
        "5": 120,
        "4": 25,
        "3": 8,
        "2": 2,
        "1": 1
      }
    }
  }
}
```

#### PUT /products/{id}
Cập nhật sản phẩm

#### DELETE /products/{id}
Xóa sản phẩm (soft delete)

### 4.2. Quản lý Danh mục

#### GET /products/categories
Lấy danh sách danh mục sản phẩm

#### POST /products/categories
Tạo danh mục mới

#### PUT /products/categories/{id}
Cập nhật danh mục

#### DELETE /products/categories/{id}
Xóa danh mục

### 4.3. Quản lý Biến thể

#### GET /products/{id}/variants
Lấy danh sách biến thể của sản phẩm

#### POST /products/{id}/variants
Tạo biến thể mới

#### PUT /products/{id}/variants/{variant_id}
Cập nhật biến thể

#### DELETE /products/{id}/variants/{variant_id}
Xóa biến thể

### 4.4. Quản lý Tồn kho

#### GET /products/{id}/inventory
Lấy thông tin tồn kho

#### PUT /products/{id}/inventory
Cập nhật tồn kho

#### POST /products/{id}/inventory/adjust
Điều chỉnh tồn kho (nhập/xuất)

## 5. MODELS VÀ SCHEMA

### 5.1. Product Model

```typescript
interface Product {
  id: string;
  name: string;
  slug: string;
  sku: string;
  description?: string;
  short_description?: string;
  category_id: string;
  status: 'active' | 'inactive' | 'draft';
  price: number;
  compare_price?: number;
  cost_price?: number;
  currency: string;
  stock_quantity: number;
  track_inventory: boolean;
  weight?: number;
  dimensions?: {
    length: number;
    width: number;
    height: number;
  };
  images: ProductImage[];
  variants?: ProductVariant[];
  seo?: SEOData;
  created_at: string;
  updated_at: string;
}
```

### 5.2. Product Category Model

```typescript
interface ProductCategory {
  id: string;
  name: string;
  slug: string;
  description?: string;
  parent_id?: string;
  image?: string;
  sort_order: number;
  is_active: boolean;
  seo?: SEOData;
  created_at: string;
  updated_at: string;
}
```

### 5.3. Product Variant Model

```typescript
interface ProductVariant {
  id: string;
  product_id: string;
  sku: string;
  price: number;
  compare_price?: number;
  cost_price?: number;
  stock_quantity: number;
  attributes: Record<string, string>;
  image?: string;
  weight?: number;
  created_at: string;
  updated_at: string;
}
```

## 6. VÍ DỤ SỬ DỤNG

### 6.1. Tạo sản phẩm với biến thể

```javascript
// Tạo sản phẩm chính
const product = await fetch('/api/v1/products', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json',
    'X-Organization-ID': orgId
  },
  body: JSON.stringify({
    name: 'Áo thun nam',
    sku: 'AT-NAM-001',
    category_id: 'cat_fashion',
    price: 299000,
    stock_quantity: 100
  })
});

// Tạo biến thể
const variant = await fetch(`/api/v1/products/${product.id}/variants`, {
  method: 'POST',
  body: JSON.stringify({
    sku: 'AT-NAM-001-M-RED',
    attributes: {
      size: 'M',
      color: 'Đỏ'
    },
    stock_quantity: 25
  })
});
```

### 6.2. Tìm kiếm sản phẩm

```javascript
const products = await fetch('/api/v1/products?' + new URLSearchParams({
  search: 'iPhone',
  category_id: 'cat_electronics',
  status: 'active',
  sort: 'price',
  order: 'asc',
  page: 1,
  limit: 20
}));
```

## 7. ERROR HANDLING

### 7.1. Error Codes

- `400` - Bad Request: Dữ liệu không hợp lệ
- `401` - Unauthorized: Không có quyền truy cập
- `403` - Forbidden: Không đủ quyền hạn
- `404` - Not Found: Sản phẩm không tồn tại
- `409` - Conflict: SKU đã tồn tại
- `422` - Validation Error: Lỗi validation
- `500` - Internal Server Error: Lỗi server

### 7.2. Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "PRODUCT_NOT_FOUND",
    "message": "Sản phẩm không tồn tại",
    "details": {
      "product_id": "prod_123456789"
    }
  }
}
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản API**: v1.0.0  
**Tác giả**: NextFlow CRM-AI API Team
