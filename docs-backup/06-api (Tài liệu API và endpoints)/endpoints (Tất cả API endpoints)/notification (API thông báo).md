# API HỆ THỐNG THÔNG BÁO NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Thông báo Cơ bản](#2-endpoints-thông-báo-cơ-bản)
3. [Endpoints Template](#3-endpoints-template)
4. [Endpoints Subscription](#4-endpoints-subscription)
5. [Endpoints Delivery](#5-endpoints-delivery)
6. [Endpoints Analytics](#6-endpoints-analytics)
7. [Error Codes](#7-error-codes)

## 1. GIỚI THIỆU

API Hệ thống Thông báo của NextFlow CRM-AI cung cấp các endpoint để quản lý và gửi thông báo đa kênh, bao gồm in-app, email, SMS và push notifications.

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

## 2. ENDPOINTS THÔNG BÁO CƠ BẢN

### 2.1. Gửi thông báo

```http
POST /notifications/send
Content-Type: application/json
```

#### Request Body

```json
{
  "type": "order_created",
  "title": "Đơn hàng mới",
  "message": "Bạn có đơn hàng mới #12345 từ khách hàng Nguyễn Văn A",
  "recipients": [
    {
      "userId": "user_123456789",
      "channels": ["in_app", "email", "push"]
    }
  ],
  "data": {
    "orderId": "order_123456789",
    "customerId": "customer_123456789",
    "amount": 1500000
  },
  "priority": "high",
  "scheduledAt": "2023-10-27T10:30:00Z"
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Thông báo đã được gửi",
  "data": {
    "notificationId": "notif_123456789",
    "status": "sent",
    "recipients": [
      {
        "userId": "user_123456789",
        "deliveryStatus": {
          "in_app": "delivered",
          "email": "sent",
          "push": "delivered"
        }
      }
    ],
    "sentAt": "2023-10-27T10:30:00Z"
  }
}
```

### 2.2. Lấy danh sách thông báo

```http
GET /notifications
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số lượng thông báo mỗi trang (mặc định: 20, tối đa: 100) |
| type | string | Lọc theo loại thông báo |
| status | string | Lọc theo trạng thái (unread, read, archived) |
| priority | string | Lọc theo mức độ ưu tiên (low, medium, high, urgent) |
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "notif_123456789",
      "type": "order_created",
      "title": "Đơn hàng mới",
      "message": "Bạn có đơn hàng mới #12345 từ khách hàng Nguyễn Văn A",
      "priority": "high",
      "status": "unread",
      "data": {
        "orderId": "order_123456789",
        "customerId": "customer_123456789"
      },
      "createdAt": "2023-10-27T10:30:00Z",
      "readAt": null
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "perPage": 20,
      "totalPages": 1,
      "totalItems": 1
    }
  }
}
```

### 2.3. Đánh dấu đã đọc

```http
PUT /notifications/{notificationId}/read
```

### 2.4. Đánh dấu tất cả đã đọc

```http
PUT /notifications/mark-all-read
```

### 2.5. Xóa thông báo

```http
DELETE /notifications/{notificationId}
```

## 3. ENDPOINTS TEMPLATE

### 3.1. Lấy danh sách template

```http
GET /notification-templates
```

### 3.2. Tạo template mới

```http
POST /notification-templates
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Order Created Template",
  "type": "order_created",
  "channels": {
    "in_app": {
      "title": "Đơn hàng mới #{{orderNumber}}",
      "message": "Bạn có đơn hàng mới từ {{customerName}} với giá trị {{amount}}"
    },
    "email": {
      "subject": "Đơn hàng mới #{{orderNumber}}",
      "htmlContent": "<h1>Đơn hàng mới</h1><p>Chi tiết đơn hàng...</p>",
      "textContent": "Đơn hàng mới từ {{customerName}}"
    },
    "sms": {
      "message": "Đơn hàng mới #{{orderNumber}} từ {{customerName}}"
    }
  },
  "variables": [
    {
      "name": "orderNumber",
      "type": "string",
      "required": true
    },
    {
      "name": "customerName",
      "type": "string",
      "required": true
    },
    {
      "name": "amount",
      "type": "number",
      "required": true
    }
  ]
}
```

### 3.3. Cập nhật template

```http
PUT /notification-templates/{templateId}
Content-Type: application/json
```

### 3.4. Xóa template

```http
DELETE /notification-templates/{templateId}
```

## 4. ENDPOINTS SUBSCRIPTION

### 4.1. Lấy cài đặt thông báo của user

```http
GET /users/{userId}/notification-preferences
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "userId": "user_123456789",
    "channels": {
      "in_app": {
        "enabled": true,
        "types": ["order_created", "lead_assigned", "task_due"]
      },
      "email": {
        "enabled": true,
        "frequency": "immediate",
        "types": ["order_created", "weekly_report"]
      },
      "sms": {
        "enabled": false,
        "types": []
      },
      "push": {
        "enabled": true,
        "types": ["urgent_notifications"]
      }
    },
    "doNotDisturb": {
      "enabled": true,
      "startTime": "22:00",
      "endTime": "08:00",
      "timezone": "Asia/Ho_Chi_Minh"
    }
  }
}
```

### 4.2. Cập nhật cài đặt thông báo

```http
PUT /users/{userId}/notification-preferences
Content-Type: application/json
```

### 4.3. Subscribe/Unsubscribe

```http
POST /notifications/subscribe
Content-Type: application/json
```

#### Request Body

```json
{
  "userId": "user_123456789",
  "notificationType": "marketing_emails",
  "channel": "email",
  "action": "subscribe"
}
```

## 5. ENDPOINTS DELIVERY

### 5.1. Lấy trạng thái delivery

```http
GET /notifications/{notificationId}/delivery-status
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "notificationId": "notif_123456789",
    "deliveryStatus": {
      "in_app": {
        "status": "delivered",
        "deliveredAt": "2023-10-27T10:30:01Z"
      },
      "email": {
        "status": "delivered",
        "deliveredAt": "2023-10-27T10:30:05Z",
        "openedAt": "2023-10-27T10:35:00Z",
        "clickedAt": null
      },
      "sms": {
        "status": "failed",
        "failureReason": "Invalid phone number",
        "failedAt": "2023-10-27T10:30:02Z"
      }
    }
  }
}
```

### 5.2. Retry failed delivery

```http
POST /notifications/{notificationId}/retry
Content-Type: application/json
```

### 5.3. Webhook delivery status

```http
POST /notifications/webhook/delivery-status
Content-Type: application/json
```

## 6. ENDPOINTS ANALYTICS

### 6.1. Thống kê thông báo

```http
GET /notifications/analytics
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |
| groupBy | string | Nhóm theo (day, week, month) |
| channel | string | Lọc theo kênh |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "summary": {
      "totalSent": 15420,
      "totalDelivered": 14890,
      "totalOpened": 8934,
      "totalClicked": 2156,
      "deliveryRate": 96.6,
      "openRate": 60.0,
      "clickRate": 24.1
    },
    "byChannel": {
      "in_app": {
        "sent": 8500,
        "delivered": 8500,
        "deliveryRate": 100.0
      },
      "email": {
        "sent": 5200,
        "delivered": 4890,
        "opened": 2934,
        "clicked": 1156,
        "deliveryRate": 94.0,
        "openRate": 60.0,
        "clickRate": 39.4
      },
      "sms": {
        "sent": 1720,
        "delivered": 1500,
        "deliveryRate": 87.2
      }
    },
    "timeline": [
      {
        "date": "2023-10-27",
        "sent": 1250,
        "delivered": 1200,
        "opened": 720,
        "clicked": 180
      }
    ]
  }
}
```

### 6.2. User engagement analytics

```http
GET /notifications/analytics/engagement
```

### 6.3. Template performance

```http
GET /notification-templates/{templateId}/analytics
```

## 7. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Notification not found | Không tìm thấy thông báo |
| 4002 | Template not found | Không tìm thấy template |
| 4003 | Invalid recipient | Người nhận không hợp lệ |
| 4004 | Channel not supported | Kênh không được hỗ trợ |
| 4005 | Template validation failed | Template không hợp lệ |
| 4006 | Rate limit exceeded | Vượt quá giới hạn gửi |
| 5001 | Delivery failed | Gửi thông báo thất bại |
| 5002 | Template processing failed | Xử lý template thất bại |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
