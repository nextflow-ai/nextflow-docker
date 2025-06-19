# API TÍCH HỢP ZALO NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Zalo Official Account API](#2-zalo-official-account-api)
3. [Chatbot Integration API](#3-chatbot-integration-api)
4. [Webhook Management](#4-webhook-management)
5. [Message Templates](#5-message-templates)
6. [Analytics và Reports](#6-analytics-và-reports)
7. [Error Codes](#7-error-codes)

## 1. GIỚI THIỆU

API tích hợp Zalo của NextFlow CRM cung cấp các endpoint để quản lý tích hợp với Zalo Official Account, chatbot automation và message handling.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
Content-Type: application/json
```

### 1.3. Tính năng chính

- ✅ Quản lý Zalo Official Account
- ✅ Gửi/nhận tin nhắn tự động
- ✅ Chatbot AI integration
- ✅ Webhook management
- ✅ Message templates
- ✅ Analytics và reporting

## 2. ZALO OFFICIAL ACCOUNT API

### 2.1. Lấy danh sách Zalo accounts

```http
GET /zalo/accounts
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| limit | integer | Số lượng/trang (mặc định: 20) |
| status | string | Trạng thái: active, inactive, pending |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "accounts": [
      {
        "id": "zalo_acc_123456789",
        "name": "NextFlow CRM Support",
        "app_id": "123456789",
        "oa_id": "987654321",
        "status": "active",
        "avatar": "https://zalo.me/avatar/123.jpg",
        "followers": 15420,
        "verified": true,
        "webhook_url": "https://api.nextflow-crm.com/v1/webhook/zalo/123456789",
        "created_at": "2023-10-27T09:15:00Z",
        "updated_at": "2023-10-27T09:15:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 1,
      "totalPages": 1
    }
  }
}
```

### 2.2. Lấy thông tin Zalo account

```http
GET /zalo/accounts/{accountId}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "id": "zalo_acc_123456789",
    "name": "NextFlow CRM Support",
    "description": "Tài khoản chính thức của NextFlow CRM",
    "app_id": "123456789",
    "app_secret": "encrypted:abcdefghijklmnop",
    "oa_id": "987654321",
    "access_token": "encrypted:xyz123456789",
    "status": "active",
    "avatar": "https://zalo.me/avatar/123.jpg",
    "cover": "https://zalo.me/cover/123.jpg",
    "followers": 15420,
    "verified": true,
    "category": "business",
    "webhook_url": "https://api.nextflow-crm.com/v1/webhook/zalo/123456789",
    "webhook_events": ["user_send_text", "user_send_image", "user_send_sticker"],
    "chatbot_enabled": true,
    "auto_reply_enabled": true,
    "business_hours": {
      "enabled": true,
      "timezone": "Asia/Ho_Chi_Minh",
      "schedule": {
        "monday": {"start": "08:00", "end": "18:00"},
        "tuesday": {"start": "08:00", "end": "18:00"},
        "wednesday": {"start": "08:00", "end": "18:00"},
        "thursday": {"start": "08:00", "end": "18:00"},
        "friday": {"start": "08:00", "end": "18:00"},
        "saturday": {"start": "08:00", "end": "12:00"},
        "sunday": {"closed": true}
      }
    },
    "created_at": "2023-10-27T09:15:00Z",
    "updated_at": "2023-10-27T09:15:00Z"
  }
}
```

### 2.3. Tạo Zalo account mới

```http
POST /zalo/accounts
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "NextFlow CRM Sales",
  "description": "Tài khoản bán hàng NextFlow CRM",
  "app_id": "123456789",
  "app_secret": "your_app_secret",
  "oa_id": "987654321",
  "access_token": "your_access_token",
  "webhook_events": ["user_send_text", "user_send_image"],
  "chatbot_enabled": true,
  "auto_reply_enabled": true,
  "business_hours": {
    "enabled": true,
    "timezone": "Asia/Ho_Chi_Minh",
    "schedule": {
      "monday": {"start": "08:00", "end": "18:00"},
      "tuesday": {"start": "08:00", "end": "18:00"},
      "wednesday": {"start": "08:00", "end": "18:00"},
      "thursday": {"start": "08:00", "end": "18:00"},
      "friday": {"start": "08:00", "end": "18:00"},
      "saturday": {"start": "08:00", "end": "12:00"},
      "sunday": {"closed": true}
    }
  }
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Tạo thành công",
  "data": {
    "id": "zalo_acc_987654321",
    "webhook_url": "https://api.nextflow-crm.com/v1/webhook/zalo/987654321",
    "status": "pending_verification"
  }
}
```

### 2.4. Cập nhật Zalo account

```http
PUT /zalo/accounts/{accountId}
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "NextFlow CRM Support Updated",
  "description": "Tài khoản hỗ trợ khách hàng NextFlow CRM",
  "chatbot_enabled": true,
  "auto_reply_enabled": false,
  "business_hours": {
    "enabled": true,
    "schedule": {
      "monday": {"start": "09:00", "end": "17:00"}
    }
  }
}
```

### 2.5. Xóa Zalo account

```http
DELETE /zalo/accounts/{accountId}
```

#### Response

```json
{
  "success": true,
  "code": 1003,
  "message": "Xóa thành công"
}
```

## 3. CHATBOT INTEGRATION API

### 3.1. Gửi tin nhắn

```http
POST /zalo/accounts/{accountId}/messages
Content-Type: application/json
```

#### Request Body

```json
{
  "recipient": {
    "user_id": "1234567890123456789"
  },
  "message": {
    "text": "Xin chào! Cảm ơn bạn đã liên hệ với NextFlow CRM. Chúng tôi có thể giúp gì cho bạn?"
  },
  "message_type": "text",
  "quick_replies": [
    {
      "content_type": "text",
      "title": "Tư vấn sản phẩm",
      "payload": "PRODUCT_INQUIRY"
    },
    {
      "content_type": "text",
      "title": "Hỗ trợ kỹ thuật",
      "payload": "TECHNICAL_SUPPORT"
    }
  ]
}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Gửi tin nhắn thành công",
  "data": {
    "message_id": "msg_123456789",
    "status": "sent",
    "sent_at": "2023-10-27T09:15:00Z"
  }
}
```

### 3.2. Gửi tin nhắn template

```http
POST /zalo/accounts/{accountId}/messages/template
Content-Type: application/json
```

#### Request Body

```json
{
  "recipient": {
    "user_id": "1234567890123456789"
  },
  "template": {
    "template_id": "welcome_template",
    "language": "vi",
    "components": [
      {
        "type": "body",
        "parameters": [
          {
            "type": "text",
            "text": "Nguyễn Văn A"
          }
        ]
      }
    ]
  }
}
```

### 3.3. Lấy thông tin người dùng

```http
GET /zalo/accounts/{accountId}/users/{userId}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "user_id": "1234567890123456789",
    "display_name": "Nguyễn Văn A",
    "avatar": "https://zalo.me/avatar/user123.jpg",
    "user_id_by_app": "app_user_123",
    "is_follower": true,
    "tags": ["vip_customer", "tech_support"],
    "last_interaction": "2023-10-27T09:15:00Z",
    "total_messages": 45,
    "customer_id": "cust_123456789"
  }
}
```

## 4. WEBHOOK MANAGEMENT

### 4.1. Đăng ký webhook

```http
POST /zalo/accounts/{accountId}/webhooks
Content-Type: application/json
```

#### Request Body

```json
{
  "webhook_url": "https://api.nextflow-crm.com/v1/webhook/zalo/123456789",
  "events": [
    "user_send_text",
    "user_send_image",
    "user_send_sticker",
    "user_send_file",
    "user_send_location"
  ],
  "verify_token": "your_verify_token"
}
```

### 4.2. Webhook endpoint (nhận tin nhắn)

```http
POST /webhook/zalo/{accountId}
Content-Type: application/json
```

#### Webhook Payload

```json
{
  "app_id": "123456789",
  "user_id_by_app": "app_user_123",
  "timestamp": "1635321300000",
  "event_name": "user_send_text",
  "sender": {
    "id": "1234567890123456789",
    "name": "Nguyễn Văn A"
  },
  "recipient": {
    "id": "987654321"
  },
  "message": {
    "text": "Tôi muốn tìm hiểu về sản phẩm CRM",
    "msg_id": "msg_123456789",
    "msg_type": "text"
  }
}
```

### 4.3. Xác minh webhook

```http
GET /webhook/zalo/{accountId}
```

#### Query Parameters

| Tham số | Mô tả |
|---------|-------|
| hub.mode | subscribe |
| hub.challenge | Challenge string từ Zalo |
| hub.verify_token | Verify token |

## 5. MESSAGE TEMPLATES

### 5.1. Lấy danh sách templates

```http
GET /zalo/accounts/{accountId}/templates
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "templates": [
      {
        "id": "welcome_template",
        "name": "Chào mừng khách hàng mới",
        "category": "greeting",
        "language": "vi",
        "status": "approved",
        "content": {
          "type": "text",
          "text": "Xin chào {{customer_name}}! Chào mừng bạn đến với NextFlow CRM. Chúng tôi có thể hỗ trợ gì cho bạn?"
        },
        "variables": ["customer_name"],
        "created_at": "2023-10-27T09:15:00Z"
      }
    ]
  }
}
```

### 5.2. Tạo template mới

```http
POST /zalo/accounts/{accountId}/templates
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Xác nhận đơn hàng",
  "category": "order_confirmation",
  "language": "vi",
  "content": {
    "type": "text",
    "text": "Đơn hàng #{{order_id}} của bạn đã được xác nhận. Tổng tiền: {{total_amount}}. Dự kiến giao hàng: {{delivery_date}}"
  },
  "variables": ["order_id", "total_amount", "delivery_date"]
}
```

## 6. ANALYTICS VÀ REPORTS

### 6.1. Thống kê tin nhắn

```http
GET /zalo/accounts/{accountId}/analytics/messages
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| start_date | string | Ngày bắt đầu (YYYY-MM-DD) |
| end_date | string | Ngày kết thúc (YYYY-MM-DD) |
| granularity | string | day, week, month |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "summary": {
      "total_messages": 1547,
      "sent_messages": 823,
      "received_messages": 724,
      "unique_users": 342,
      "response_rate": 89.5,
      "avg_response_time": 45
    },
    "daily_stats": [
      {
        "date": "2023-10-27",
        "sent": 125,
        "received": 98,
        "unique_users": 67,
        "response_rate": 92.1
      }
    ]
  }
}
```

### 6.2. Thống kê chatbot

```http
GET /zalo/accounts/{accountId}/analytics/chatbot
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "bot_interactions": 1247,
    "human_handoffs": 89,
    "resolution_rate": 92.8,
    "avg_conversation_length": 4.2,
    "top_intents": [
      {
        "intent": "product_inquiry",
        "count": 456,
        "percentage": 36.6
      },
      {
        "intent": "support_request",
        "count": 234,
        "percentage": 18.8
      }
    ],
    "satisfaction_score": 4.6
  }
}
```

## 7. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 1000 | Success | Thành công |
| 1001 | Created | Tạo thành công |
| 1003 | Deleted | Xóa thành công |
| 4001 | Zalo account not found | Không tìm thấy tài khoản Zalo |
| 4002 | Invalid access token | Access token không hợp lệ |
| 4003 | Webhook verification failed | Xác minh webhook thất bại |
| 4004 | Message send failed | Gửi tin nhắn thất bại |
| 4005 | Template not found | Không tìm thấy template |
| 4006 | User not found | Không tìm thấy người dùng |
| 5001 | Zalo API error | Lỗi từ Zalo API |
| 5002 | Webhook processing error | Lỗi xử lý webhook |
| 5003 | Database error | Lỗi cơ sở dữ liệu |

### Error Response Format

```json
{
  "success": false,
  "code": 4001,
  "message": "Không tìm thấy tài khoản Zalo",
  "errors": [
    {
      "field": "accountId",
      "message": "Tài khoản Zalo với ID này không tồn tại"
    }
  ],
  "timestamp": "2023-10-27T09:15:00Z"
}
```

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 2.0.0
**Tác giả**: NextFlow CRM API Team
