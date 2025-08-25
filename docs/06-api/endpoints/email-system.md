# API HỆ THỐNG EMAIL NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Email Campaigns](#2-endpoints-email-campaigns)
3. [Endpoints Email Templates](#3-endpoints-email-templates)
4. [Endpoints Email Lists](#4-endpoints-email-lists)
5. [Endpoints Email Automation](#5-endpoints-email-automation)
6. [Endpoints Email Analytics](#6-endpoints-email-analytics)
7. [Error Codes](#7-error-codes)

## 1. GIỚI THIỆU

API Hệ thống Email của NextFlow CRM-AI cung cấp các endpoint để quản lý email marketing, templates, automation và analytics.

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

## 2. ENDPOINTS EMAIL CAMPAIGNS

### 2.1. Tạo campaign mới

```http
POST /email/campaigns
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Newsletter Tháng 10",
  "subject": "Tin tức và ưu đãi mới nhất từ NextFlow CRM-AI",
  "templateId": "template_123456789",
  "listIds": ["list_123456789", "list_234567890"],
  "segmentIds": ["segment_123456789"],
  "scheduledAt": "2023-10-27T10:00:00Z",
  "timezone": "Asia/Ho_Chi_Minh",
  "settings": {
    "trackOpens": true,
    "trackClicks": true,
    "enableUnsubscribe": true,
    "replyToEmail": "support@nextflow-crm.com"
  },
  "abTest": {
    "enabled": true,
    "testType": "subject_line",
    "variants": [
      {
        "name": "Variant A",
        "subject": "Tin tức và ưu đãi mới nhất từ NextFlow CRM-AI",
        "percentage": 50
      },
      {
        "name": "Variant B",
        "subject": "🎉 Ưu đãi đặc biệt chỉ dành cho bạn!",
        "percentage": 50
      }
    ],
    "testDuration": 2,
    "winnerCriteria": "open_rate"
  }
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Campaign đã được tạo",
  "data": {
    "id": "campaign_123456789",
    "name": "Newsletter Tháng 10",
    "status": "scheduled",
    "recipientCount": 15420,
    "scheduledAt": "2023-10-27T10:00:00Z",
    "createdAt": "2023-10-26T15:30:00Z"
  }
}
```

### 2.2. Lấy danh sách campaigns

```http
GET /email/campaigns
```

#### Query Parameters

| Tham số  | Kiểu    | Mô tả                                                         |
| -------- | ------- | ------------------------------------------------------------- |
| page     | integer | Số trang (mặc định: 1)                                        |
| perPage  | integer | Số lượng campaign mỗi trang (mặc định: 20, tối đa: 100)       |
| status   | string  | Lọc theo trạng thái (draft, scheduled, sending, sent, paused) |
| type     | string  | Loại campaign (newsletter, promotional, transactional)        |
| fromDate | string  | Từ ngày (YYYY-MM-DD)                                          |
| toDate   | string  | Đến ngày (YYYY-MM-DD)                                         |

### 2.3. Gửi campaign

```http
POST /email/campaigns/{campaignId}/send
```

### 2.4. Tạm dừng campaign

```http
POST /email/campaigns/{campaignId}/pause
```

### 2.5. Hủy campaign

```http
POST /email/campaigns/{campaignId}/cancel
```

## 3. ENDPOINTS EMAIL TEMPLATES

### 3.1. Tạo template mới

```http
POST /email/templates
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Newsletter Template",
  "description": "Template cho newsletter hàng tháng",
  "category": "newsletter",
  "subject": "{{company_name}} - Tin tức tháng {{month}}",
  "htmlContent": "<!DOCTYPE html><html>...</html>",
  "textContent": "Phiên bản text của email...",
  "preheader": "Xem trước nội dung email",
  "variables": [
    {
      "name": "company_name",
      "type": "string",
      "defaultValue": "NextFlow CRM-AI",
      "required": true
    },
    {
      "name": "month",
      "type": "string",
      "required": true
    },
    {
      "name": "customer_name",
      "type": "string",
      "defaultValue": "Khách hàng",
      "required": false
    }
  ],
  "settings": {
    "responsive": true,
    "darkMode": true,
    "ampSupport": false
  }
}
```

### 3.2. Lấy danh sách templates

```http
GET /email/templates
```

### 3.3. Preview template

```http
POST /email/templates/{templateId}/preview
Content-Type: application/json
```

#### Request Body

```json
{
  "variables": {
    "company_name": "NextFlow CRM-AI",
    "month": "Tháng 10",
    "customer_name": "Nguyễn Văn A"
  },
  "testData": {
    "customerId": "customer_123456789"
  }
}
```

### 3.4. Test gửi template

```http
POST /email/templates/{templateId}/test-send
Content-Type: application/json
```

#### Request Body

```json
{
  "recipients": ["test@nextflow-crm.com"],
  "variables": {
    "company_name": "NextFlow CRM-AI",
    "month": "Tháng 10"
  }
}
```

## 4. ENDPOINTS EMAIL LISTS

### 4.1. Tạo email list mới

```http
POST /email/lists
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Newsletter Subscribers",
  "description": "Danh sách người đăng ký newsletter",
  "type": "static",
  "tags": ["newsletter", "marketing"],
  "settings": {
    "doubleOptIn": true,
    "sendWelcomeEmail": true,
    "welcomeTemplateId": "template_welcome_123"
  }
}
```

### 4.2. Thêm subscribers vào list

```http
POST /email/lists/{listId}/subscribers
Content-Type: application/json
```

#### Request Body

```json
{
  "subscribers": [
    {
      "email": "customer1@example.com",
      "firstName": "Nguyễn",
      "lastName": "Văn A",
      "customFields": {
        "company": "ABC Corp",
        "position": "Manager"
      },
      "tags": ["vip", "enterprise"]
    },
    {
      "email": "customer2@example.com",
      "firstName": "Trần",
      "lastName": "Thị B"
    }
  ],
  "updateExisting": true,
  "sendConfirmation": true
}
```

### 4.3. Import subscribers từ file

```http
POST /email/lists/{listId}/import
Content-Type: multipart/form-data
```

### 4.4. Lấy danh sách subscribers

```http
GET /email/lists/{listId}/subscribers
```

### 4.5. Unsubscribe

```http
POST /email/lists/{listId}/unsubscribe
Content-Type: application/json
```

#### Request Body

```json
{
  "email": "customer@example.com",
  "reason": "user_request",
  "sendConfirmation": true
}
```

## 5. ENDPOINTS EMAIL AUTOMATION

### 5.1. Tạo automation workflow

```http
POST /email/automations
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Welcome Series",
  "description": "Chuỗi email chào mừng khách hàng mới",
  "trigger": {
    "type": "list_subscription",
    "listId": "list_123456789"
  },
  "steps": [
    {
      "type": "email",
      "delay": 0,
      "templateId": "template_welcome_1",
      "subject": "Chào mừng bạn đến với NextFlow CRM-AI!"
    },
    {
      "type": "wait",
      "delay": 86400,
      "unit": "seconds"
    },
    {
      "type": "email",
      "delay": 0,
      "templateId": "template_welcome_2",
      "subject": "Hướng dẫn sử dụng NextFlow CRM-AI"
    },
    {
      "type": "condition",
      "condition": {
        "field": "email_opened",
        "operator": "equals",
        "value": true
      },
      "trueSteps": [
        {
          "type": "email",
          "delay": 172800,
          "templateId": "template_welcome_3",
          "subject": "Tips và tricks cho NextFlow CRM-AI"
        }
      ],
      "falseSteps": [
        {
          "type": "email",
          "delay": 259200,
          "templateId": "template_re_engagement",
          "subject": "Bạn có cần hỗ trợ không?"
        }
      ]
    }
  ],
  "settings": {
    "timezone": "Asia/Ho_Chi_Minh",
    "respectUnsubscribe": true,
    "respectDoNotDisturb": true
  }
}
```

### 5.2. Kích hoạt automation

```http
POST /email/automations/{automationId}/activate
```

### 5.3. Tạm dừng automation

```http
POST /email/automations/{automationId}/pause
```

### 5.4. Lấy automation performance

```http
GET /email/automations/{automationId}/performance
```

## 6. ENDPOINTS EMAIL ANALYTICS

### 6.1. Campaign analytics

```http
GET /email/campaigns/{campaignId}/analytics
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "campaignId": "campaign_123456789",
    "summary": {
      "sent": 15420,
      "delivered": 14890,
      "bounced": 530,
      "opened": 8934,
      "clicked": 2156,
      "unsubscribed": 45,
      "complained": 12
    },
    "rates": {
      "deliveryRate": 96.6,
      "openRate": 60.0,
      "clickRate": 24.1,
      "unsubscribeRate": 0.3,
      "complaintRate": 0.08
    },
    "revenue": {
      "totalRevenue": 125000000,
      "revenuePerEmail": 8108,
      "revenuePerRecipient": 8108,
      "roi": 2500
    },
    "timeline": [
      {
        "hour": "2023-10-27T10:00:00Z",
        "sent": 1542,
        "delivered": 1489,
        "opened": 893,
        "clicked": 215
      }
    ],
    "topLinks": [
      {
        "url": "https://nextflow-crm.com/products",
        "clicks": 856,
        "uniqueClicks": 623,
        "clickRate": 28.9
      }
    ],
    "devices": {
      "desktop": 45.2,
      "mobile": 48.3,
      "tablet": 6.5
    },
    "emailClients": {
      "gmail": 52.3,
      "outlook": 23.1,
      "apple_mail": 15.6,
      "other": 9.0
    }
  }
}
```

### 6.2. List analytics

```http
GET /email/lists/{listId}/analytics
```

### 6.3. Subscriber analytics

```http
GET /email/subscribers/{subscriberId}/analytics
```

### 6.4. Overall email performance

```http
GET /email/analytics/overview
```

#### Query Parameters

| Tham số  | Kiểu   | Mô tả                        |
| -------- | ------ | ---------------------------- |
| fromDate | string | Từ ngày (YYYY-MM-DD)         |
| toDate   | string | Đến ngày (YYYY-MM-DD)        |
| groupBy  | string | Nhóm theo (day, week, month) |

## 7. ERROR CODES

| Code | Message                    | Mô tả                      |
| ---- | -------------------------- | -------------------------- |
| 4001 | Campaign not found         | Không tìm thấy campaign    |
| 4002 | Template not found         | Không tìm thấy template    |
| 4003 | List not found             | Không tìm thấy email list  |
| 4004 | Invalid email address      | Địa chỉ email không hợp lệ |
| 4005 | Subscriber already exists  | Subscriber đã tồn tại      |
| 4006 | Campaign already sent      | Campaign đã được gửi       |
| 4007 | Template validation failed | Template không hợp lệ      |
| 4008 | Sending quota exceeded     | Vượt quá quota gửi email   |
| 5001 | Email delivery failed      | Gửi email thất bại         |
| 5002 | Template processing failed | Xử lý template thất bại    |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
