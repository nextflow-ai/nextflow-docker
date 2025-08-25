# API QUẢN LÝ THANH TOÁN - NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Authentication](#2-authentication)
3. [Base URL](#3-base-url)
4. [Endpoints chính](#4-endpoints-chính)
5. [Models và Schema](#5-models-và-schema)
6. [Ví dụ sử dụng](#6-ví-dụ-sử-dụng)
7. [Error Handling](#7-error-handling)

## 1. GIỚI THIỆU

API Quản lý Thanh toán cung cấp các endpoints để xử lý thanh toán trong hệ thống NextFlow CRM-AI, tích hợp với các payment gateways phổ biến tại Việt Nam.

### 1.1. Tính năng chính

- ✅ **Payment Processing**: Xử lý thanh toán online và offline
- ✅ **Multiple Gateways**: Tích hợp VNPay, MoMo, ZaloPay, PayPal
- ✅ **Payment Methods**: Thẻ tín dụng, ví điện tử, chuyển khoản, COD
- ✅ **Refunds**: Hoàn tiền tự động và thủ công
- ✅ **Installments**: Thanh toán trả góp
- ✅ **Recurring**: Thanh toán định kỳ
- ✅ **Security**: PCI DSS compliance, tokenization
- ✅ **Webhooks**: Thông báo real-time

### 1.2. Payment Gateways được hỗ trợ

- **VNPay**: Cổng thanh toán phổ biến nhất VN
- **MoMo**: Ví điện tử hàng đầu
- **ZaloPay**: Ví điện tử của Zalo
- **PayPal**: Thanh toán quốc tế
- **Stripe**: Thanh toán thẻ quốc tế
- **Bank Transfer**: Chuyển khoản ngân hàng
- **Cash on Delivery**: Thanh toán khi nhận hàng

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

### 4.1. Quản lý Thanh toán

#### GET /payments
Lấy danh sách thanh toán với phân trang và filter

**Query Parameters:**
- `page` (integer): Số trang (default: 1)
- `limit` (integer): Số items per page (default: 20, max: 100)
- `status` (string): Filter theo trạng thái
- `gateway` (string): Filter theo payment gateway
- `customer_id` (string): Filter theo khách hàng
- `order_id` (string): Filter theo đơn hàng
- `date_from` (string): Từ ngày (YYYY-MM-DD)
- `date_to` (string): Đến ngày (YYYY-MM-DD)
- `amount_from` (number): Từ số tiền
- `amount_to` (number): Đến số tiền

**Response:**
```json
{
  "success": true,
  "data": {
    "payments": [
      {
        "id": "pay_123456789",
        "payment_number": "PAY-2024-001234",
        "order_id": "ord_987654321",
        "customer_id": "cust_456789123",
        "gateway": "vnpay",
        "method": "credit_card",
        "status": "completed",
        "amount": 2990000,
        "currency": "VND",
        "gateway_transaction_id": "VNP_TXN_123456",
        "gateway_response": {
          "response_code": "00",
          "response_message": "Giao dịch thành công",
          "bank_code": "NCB",
          "card_type": "ATM"
        },
        "payment_details": {
          "card_last4": "1234",
          "card_brand": "VISA",
          "bank_name": "Ngân hàng NCB"
        },
        "fees": {
          "gateway_fee": 29900,
          "processing_fee": 0,
          "total_fee": 29900
        },
        "metadata": {
          "ip_address": "192.168.1.1",
          "user_agent": "Mozilla/5.0...",
          "return_url": "https://shop.com/payment/success"
        },
        "created_at": "2024-01-15T10:00:00Z",
        "completed_at": "2024-01-15T10:02:30Z",
        "updated_at": "2024-01-15T10:02:30Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 100,
      "items_per_page": 20
    },
    "summary": {
      "total_amount": 500000000,
      "total_fees": 5000000,
      "success_rate": 95.5,
      "average_amount": 2500000
    }
  }
}
```

#### POST /payments
Tạo payment mới

**Request Body:**
```json
{
  "order_id": "ord_987654321",
  "amount": 2990000,
  "currency": "VND",
  "gateway": "vnpay",
  "method": "credit_card",
  "return_url": "https://shop.com/payment/success",
  "cancel_url": "https://shop.com/payment/cancel",
  "webhook_url": "https://shop.com/webhooks/payment",
  "description": "Thanh toán đơn hàng ORD-2024-001234",
  "customer_info": {
    "name": "Nguyễn Văn A",
    "email": "nguyenvana@email.com",
    "phone": "0901234567"
  },
  "metadata": {
    "campaign": "new_year_sale",
    "source": "mobile_app"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "payment_id": "pay_123456789",
    "payment_url": "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?vnp_Amount=...",
    "qr_code": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
    "expires_at": "2024-01-15T10:15:00Z"
  }
}
```

#### GET /payments/{id}
Lấy thông tin chi tiết payment

#### PUT /payments/{id}/capture
Capture payment (cho pre-authorized payments)

#### POST /payments/{id}/refund
Hoàn tiền payment

**Request Body:**
```json
{
  "amount": 1000000,
  "reason": "Khách hàng yêu cầu hoàn tiền",
  "notify_customer": true
}
```

### 4.2. Payment Methods

#### GET /payment-methods
Lấy danh sách payment methods có sẵn

**Response:**
```json
{
  "success": true,
  "data": {
    "methods": [
      {
        "id": "vnpay_credit_card",
        "name": "Thẻ tín dụng/ghi nợ",
        "gateway": "vnpay",
        "type": "credit_card",
        "icon": "https://cdn.nextflow.com/icons/credit-card.png",
        "fees": {
          "percentage": 1.0,
          "fixed": 0
        },
        "limits": {
          "min_amount": 10000,
          "max_amount": 500000000
        },
        "supported_currencies": ["VND"],
        "is_active": true
      },
      {
        "id": "momo_wallet",
        "name": "Ví MoMo",
        "gateway": "momo",
        "type": "e_wallet",
        "icon": "https://cdn.nextflow.com/icons/momo.png",
        "fees": {
          "percentage": 0.5,
          "fixed": 0
        },
        "limits": {
          "min_amount": 10000,
          "max_amount": 50000000
        },
        "supported_currencies": ["VND"],
        "is_active": true
      }
    ]
  }
}
```

### 4.3. Webhooks

#### POST /payments/webhooks/{gateway}
Nhận webhook từ payment gateway

#### GET /payments/{id}/webhooks
Lấy lịch sử webhooks của payment

### 4.4. Recurring Payments

#### POST /payments/subscriptions
Tạo subscription cho thanh toán định kỳ

#### GET /payments/subscriptions
Lấy danh sách subscriptions

#### PUT /payments/subscriptions/{id}
Cập nhật subscription

#### DELETE /payments/subscriptions/{id}
Hủy subscription

## 5. MODELS VÀ SCHEMA

### 5.1. Payment Model

```typescript
interface Payment {
  id: string;
  payment_number: string;
  order_id: string;
  customer_id: string;
  gateway: PaymentGateway;
  method: PaymentMethod;
  status: PaymentStatus;
  amount: number;
  currency: string;
  gateway_transaction_id?: string;
  gateway_response?: any;
  payment_details?: PaymentDetails;
  fees: PaymentFees;
  metadata?: Record<string, any>;
  created_at: string;
  completed_at?: string;
  updated_at: string;
}
```

### 5.2. Payment Status Enum

```typescript
enum PaymentStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
  PARTIALLY_REFUNDED = 'partially_refunded'
}
```

### 5.3. Payment Gateway Enum

```typescript
enum PaymentGateway {
  VNPAY = 'vnpay',
  MOMO = 'momo',
  ZALOPAY = 'zalopay',
  PAYPAL = 'paypal',
  STRIPE = 'stripe',
  BANK_TRANSFER = 'bank_transfer',
  CASH_ON_DELIVERY = 'cod'
}
```

## 6. VÍ DỤ SỬ DỤNG

### 6.1. Tạo payment VNPay

```javascript
const payment = await fetch('/api/v1/payments', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json',
    'X-Organization-ID': orgId
  },
  body: JSON.stringify({
    order_id: 'ord_123',
    amount: 2990000,
    currency: 'VND',
    gateway: 'vnpay',
    method: 'credit_card',
    return_url: 'https://shop.com/payment/success',
    cancel_url: 'https://shop.com/payment/cancel',
    description: 'Thanh toán đơn hàng',
    customer_info: {
      name: 'Nguyễn Văn A',
      email: 'nguyenvana@email.com',
      phone: '0901234567'
    }
  })
});

// Redirect user to payment_url
window.location.href = payment.data.payment_url;
```

### 6.2. Xử lý webhook VNPay

```javascript
// Webhook endpoint
app.post('/webhooks/vnpay', (req, res) => {
  const vnpayData = req.body;
  
  // Verify signature
  const isValid = verifyVNPaySignature(vnpayData);
  
  if (isValid && vnpayData.vnp_ResponseCode === '00') {
    // Payment successful
    updatePaymentStatus(vnpayData.vnp_TxnRef, 'completed');
    updateOrderStatus(vnpayData.vnp_OrderInfo, 'paid');
  } else {
    // Payment failed
    updatePaymentStatus(vnpayData.vnp_TxnRef, 'failed');
  }
  
  res.status(200).send('OK');
});
```

### 6.3. Hoàn tiền

```javascript
const refund = await fetch(`/api/v1/payments/${paymentId}/refund`, {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    amount: 1000000,
    reason: 'Khách hàng yêu cầu hoàn tiền',
    notify_customer: true
  })
});
```

## 7. ERROR HANDLING

### 7.1. Error Codes

- `400` - Bad Request: Dữ liệu không hợp lệ
- `401` - Unauthorized: Không có quyền truy cập
- `402` - Payment Required: Thanh toán thất bại
- `403` - Forbidden: Không đủ quyền hạn
- `404` - Not Found: Payment không tồn tại
- `409` - Conflict: Trạng thái payment không hợp lệ
- `422` - Validation Error: Lỗi validation
- `500` - Internal Server Error: Lỗi server
- `502` - Bad Gateway: Lỗi từ payment gateway

### 7.2. Error Response Format

```json
{
  "success": false,
  "error": {
    "code": "PAYMENT_FAILED",
    "message": "Thanh toán thất bại",
    "details": {
      "gateway_code": "05",
      "gateway_message": "Thẻ không đủ số dư",
      "payment_id": "pay_123456789"
    }
  }
}
```

### 7.3. Gateway Specific Errors

```json
{
  "success": false,
  "error": {
    "code": "GATEWAY_ERROR",
    "message": "Lỗi từ cổng thanh toán",
    "details": {
      "gateway": "vnpay",
      "gateway_code": "24",
      "gateway_message": "Giao dịch bị hủy",
      "retry_allowed": false
    }
  }
}
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản API**: v1.0.0  
**Tác giả**: NextFlow CRM-AI API Team
