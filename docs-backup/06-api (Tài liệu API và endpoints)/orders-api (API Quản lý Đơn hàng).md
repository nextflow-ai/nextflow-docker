# API QUẢN LÝ ĐỚN HÀNG - NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Authentication](#2-authentication)
3. [Base URL](#3-base-url)
4. [Endpoints chính](#4-endpoints-chính)
5. [Models và Schema](#5-models-và-schema)
6. [Ví dụ sử dụng](#6-ví-dụ-sử-dụng)
7. [Error Handling](#7-error-handling)

## 1. GIỚI THIỆU

API Quản lý Đơn hàng cung cấp các endpoints để quản lý toàn bộ lifecycle của đơn hàng trong hệ thống NextFlow CRM-AI, từ tạo đơn hàng đến hoàn thành và hậu mãi.

### 1.1. Tính năng chính

- ✅ **Order Management**: Tạo, đọc, cập nhật, hủy đơn hàng
- ✅ **Order Status**: Quản lý trạng thái đơn hàng
- ✅ **Order Items**: Quản lý sản phẩm trong đơn hàng
- ✅ **Shipping**: Quản lý vận chuyển
- ✅ **Payment Integration**: Tích hợp thanh toán
- ✅ **Order History**: Lịch sử thay đổi đơn hàng
- ✅ **Fulfillment**: Xử lý và giao hàng
- ✅ **Returns & Refunds**: Trả hàng và hoàn tiền

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

### 4.1. Quản lý Đơn hàng

#### GET /orders
Lấy danh sách đơn hàng với phân trang và filter

**Query Parameters:**
- `page` (integer): Số trang (default: 1)
- `limit` (integer): Số items per page (default: 20, max: 100)
- `status` (string): Filter theo trạng thái
- `customer_id` (string): Filter theo khách hàng
- `date_from` (string): Từ ngày (YYYY-MM-DD)
- `date_to` (string): Đến ngày (YYYY-MM-DD)
- `search` (string): Tìm kiếm theo order number, customer
- `sort` (string): Sắp xếp (created_at, total_amount, status)
- `order` (string): Thứ tự (asc, desc)

**Response:**
```json
{
  "success": true,
  "data": {
    "orders": [
      {
        "id": "ord_123456789",
        "order_number": "ORD-2024-001234",
        "customer_id": "cust_987654321",
        "customer": {
          "id": "cust_987654321",
          "name": "Nguyễn Văn A",
          "email": "nguyenvana@email.com",
          "phone": "0901234567"
        },
        "status": "processing",
        "payment_status": "paid",
        "fulfillment_status": "pending",
        "currency": "VND",
        "subtotal": 2990000,
        "tax_amount": 299000,
        "shipping_amount": 50000,
        "discount_amount": 100000,
        "total_amount": 3239000,
        "items": [
          {
            "id": "item_001",
            "product_id": "prod_123",
            "variant_id": "var_456",
            "sku": "IP15PM-256-TIT",
            "name": "iPhone 15 Pro Max",
            "variant_title": "256GB - Titan Tự nhiên",
            "quantity": 1,
            "price": 29990000,
            "total": 29990000
          }
        ],
        "shipping_address": {
          "name": "Nguyễn Văn A",
          "phone": "0901234567",
          "address": "123 Đường ABC",
          "ward": "Phường XYZ",
          "district": "Quận 1",
          "city": "TP.HCM",
          "country": "Vietnam",
          "postal_code": "70000"
        },
        "billing_address": {
          "name": "Nguyễn Văn A",
          "phone": "0901234567",
          "address": "123 Đường ABC",
          "ward": "Phường XYZ",
          "district": "Quận 1",
          "city": "TP.HCM",
          "country": "Vietnam",
          "postal_code": "70000"
        },
        "shipping_method": {
          "id": "ship_001",
          "name": "Giao hàng nhanh",
          "carrier": "Giao Hàng Nhanh",
          "estimated_delivery": "2024-01-18"
        },
        "payment_method": {
          "id": "pay_001",
          "type": "credit_card",
          "name": "Thẻ tín dụng",
          "last4": "1234"
        },
        "notes": "Giao hàng giờ hành chính",
        "tags": ["vip", "priority"],
        "created_at": "2024-01-15T10:00:00Z",
        "updated_at": "2024-01-15T10:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 10,
      "total_items": 200,
      "items_per_page": 20
    },
    "summary": {
      "total_orders": 200,
      "total_amount": 500000000,
      "average_order_value": 2500000
    }
  }
}
```

#### POST /orders
Tạo đơn hàng mới

**Request Body:**
```json
{
  "customer_id": "cust_987654321",
  "items": [
    {
      "product_id": "prod_123",
      "variant_id": "var_456",
      "quantity": 1,
      "price": 29990000
    }
  ],
  "shipping_address": {
    "name": "Nguyễn Văn A",
    "phone": "0901234567",
    "address": "123 Đường ABC",
    "ward": "Phường XYZ",
    "district": "Quận 1",
    "city": "TP.HCM",
    "country": "Vietnam",
    "postal_code": "70000"
  },
  "billing_address": {
    "name": "Nguyễn Văn A",
    "phone": "0901234567",
    "address": "123 Đường ABC",
    "ward": "Phường XYZ",
    "district": "Quận 1",
    "city": "TP.HCM",
    "country": "Vietnam",
    "postal_code": "70000"
  },
  "shipping_method_id": "ship_001",
  "payment_method_id": "pay_001",
  "discount_code": "WELCOME10",
  "notes": "Giao hàng giờ hành chính",
  "tags": ["vip"]
}
```

#### GET /orders/{id}
Lấy thông tin chi tiết đơn hàng

#### PUT /orders/{id}
Cập nhật đơn hàng

#### DELETE /orders/{id}
Hủy đơn hàng

### 4.2. Quản lý Trạng thái

#### PUT /orders/{id}/status
Cập nhật trạng thái đơn hàng

**Request Body:**
```json
{
  "status": "shipped",
  "notes": "Đơn hàng đã được giao cho đơn vị vận chuyển",
  "tracking_number": "GHN123456789",
  "notify_customer": true
}
```

#### GET /orders/{id}/history
Lấy lịch sử thay đổi đơn hàng

### 4.3. Quản lý Thanh toán

#### POST /orders/{id}/payments
Tạo payment cho đơn hàng

#### GET /orders/{id}/payments
Lấy danh sách payments của đơn hàng

#### POST /orders/{id}/refund
Hoàn tiền đơn hàng

### 4.4. Quản lý Vận chuyển

#### POST /orders/{id}/fulfillments
Tạo fulfillment (xử lý giao hàng)

#### GET /orders/{id}/fulfillments
Lấy danh sách fulfillments

#### PUT /orders/{id}/fulfillments/{fulfillment_id}
Cập nhật fulfillment

### 4.5. Quản lý Trả hàng

#### POST /orders/{id}/returns
Tạo yêu cầu trả hàng

#### GET /orders/{id}/returns
Lấy danh sách returns

#### PUT /orders/{id}/returns/{return_id}
Cập nhật return

## 5. MODELS VÀ SCHEMA

### 5.1. Order Model

```typescript
interface Order {
  id: string;
  order_number: string;
  customer_id: string;
  customer?: Customer;
  status: OrderStatus;
  payment_status: PaymentStatus;
  fulfillment_status: FulfillmentStatus;
  currency: string;
  subtotal: number;
  tax_amount: number;
  shipping_amount: number;
  discount_amount: number;
  total_amount: number;
  items: OrderItem[];
  shipping_address: Address;
  billing_address: Address;
  shipping_method?: ShippingMethod;
  payment_method?: PaymentMethod;
  notes?: string;
  tags: string[];
  created_at: string;
  updated_at: string;
}
```

### 5.2. Order Status Enum

```typescript
enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PROCESSING = 'processing',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded'
}
```

### 5.3. Order Item Model

```typescript
interface OrderItem {
  id: string;
  order_id: string;
  product_id: string;
  variant_id?: string;
  sku: string;
  name: string;
  variant_title?: string;
  quantity: number;
  price: number;
  total: number;
  tax_amount?: number;
  discount_amount?: number;
}
```

## 6. VÍ DỤ SỬ DỤNG

### 6.1. Tạo đơn hàng từ giỏ hàng

```javascript
const order = await fetch('/api/v1/orders', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json',
    'X-Organization-ID': orgId
  },
  body: JSON.stringify({
    customer_id: 'cust_123',
    items: [
      {
        product_id: 'prod_456',
        variant_id: 'var_789',
        quantity: 2,
        price: 500000
      }
    ],
    shipping_address: {
      name: 'Nguyễn Văn A',
      phone: '0901234567',
      address: '123 Đường ABC, Phường XYZ',
      district: 'Quận 1',
      city: 'TP.HCM',
      country: 'Vietnam'
    },
    shipping_method_id: 'ship_fast',
    payment_method_id: 'pay_cod'
  })
});
```

### 6.2. Cập nhật trạng thái đơn hàng

```javascript
const statusUpdate = await fetch(`/api/v1/orders/${orderId}/status`, {
  method: 'PUT',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    status: 'shipped',
    tracking_number: 'GHN123456789',
    notes: 'Đơn hàng đã được giao cho đơn vị vận chuyển',
    notify_customer: true
  })
});
```

### 6.3. Tìm kiếm đơn hàng

```javascript
const orders = await fetch('/api/v1/orders?' + new URLSearchParams({
  status: 'processing',
  date_from: '2024-01-01',
  date_to: '2024-01-31',
  customer_id: 'cust_123',
  sort: 'created_at',
  order: 'desc',
  page: 1,
  limit: 20
}));
```

## 7. ERROR HANDLING

### 7.1. Error Codes

- `400` - Bad Request: Dữ liệu không hợp lệ
- `401` - Unauthorized: Không có quyền truy cập
- `403` - Forbidden: Không đủ quyền hạn
- `404` - Not Found: Đơn hàng không tồn tại
- `409` - Conflict: Trạng thái đơn hàng không hợp lệ
- `422` - Validation Error: Lỗi validation
- `500` - Internal Server Error: Lỗi server

### 7.2. Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "ORDER_NOT_FOUND",
    "message": "Đơn hàng không tồn tại",
    "details": {
      "order_id": "ord_123456789"
    }
  }
}
```

### 7.3. Validation Errors

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Dữ liệu không hợp lệ",
    "details": {
      "fields": {
        "customer_id": "Khách hàng là bắt buộc",
        "items": "Đơn hàng phải có ít nhất 1 sản phẩm",
        "shipping_address.phone": "Số điện thoại không hợp lệ"
      }
    }
  }
}
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản API**: v1.0.0  
**Tác giả**: NextFlow CRM-AI API Team
