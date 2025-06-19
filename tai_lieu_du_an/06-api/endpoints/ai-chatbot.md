# API QUẢN LÝ CHATBOT AI NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Chatbot Cơ bản](#2-endpoints-chatbot-cơ-bản)
3. [Endpoints Chatbot Nâng cao](#3-endpoints-chatbot-nâng-cao)
4. [Endpoints Hội thoại](#4-endpoints-hội-thoại)
5. [Endpoints Tin nhắn](#5-endpoints-tin-nhắn)
6. [Endpoints Tích hợp](#6-endpoints-tích-hợp)
7. [Endpoints Thống kê](#7-endpoints-thống-kê)
8. [Error Codes](#8-error-codes)

## 1. GIỚI THIỆU

API Quản lý Chatbot AI của NextFlow CRM cung cấp các endpoint để tạo, quản lý và tương tác với chatbot AI. API này hỗ trợ tích hợp với nhiều mô hình AI khác nhau và cung cấp khả năng quản lý hội thoại, tin nhắn và thống kê chi tiết.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
```

hoặc

```http
X-API-Key: {your_api_key}
```

### 1.3. Rate Limiting

- **Limit**: 1000 requests/hour
- **Burst**: 100 requests/minute

## 2. ENDPOINTS CHATBOT CỞ BẢN

### 2.1. Tạo chatbot mới

```http
POST /ai/chatbots
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Chatbot Hỗ trợ Bán hàng",
  "description": "Chatbot hỗ trợ tư vấn và bán hàng",
  "modelId": "model_123456789",
  "configuration": {
    "temperature": 0.7,
    "maxTokens": 4096,
    "topP": 0.95
  },
  "prompt": {
    "systemPrompt": "Bạn là trợ lý bán hàng AI chuyên nghiệp của NextFlow CRM.",
    "exampleConversations": [
      {
        "user": "Tôi đang tìm một sản phẩm CRM phù hợp cho doanh nghiệp nhỏ",
        "assistant": "NextFlow CRM có gói Basic rất phù hợp với doanh nghiệp nhỏ."
      }
    ]
  },
  "knowledgeBaseId": "kb_123456789",
  "status": "active"
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Tạo mới thành công",
  "data": {
    "id": "chatbot_345678901",
    "name": "Chatbot Hỗ trợ Bán hàng",
    "description": "Chatbot hỗ trợ tư vấn và bán hàng",
    "status": "active",
    "model": {
      "id": "model_123456789",
      "name": "GPT-4",
      "provider": {
        "id": "provider_123456789",
        "name": "OpenAI"
      }
    },
    "configuration": {
      "temperature": 0.7,
      "maxTokens": 4096,
      "topP": 0.95
    },
    "createdAt": "2023-10-27T09:15:00Z",
    "updatedAt": "2023-10-27T09:15:00Z"
  },
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0"
  }
}
```

### 2.2. Lấy danh sách chatbot

```http
GET /ai/chatbots
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số lượng chatbot mỗi trang (mặc định: 20, tối đa: 100) |
| sort | string | Sắp xếp (name:asc, createdAt:desc, v.v.) |
| status | string | Lọc theo trạng thái (active, inactive, draft) |
| search | string | Tìm kiếm theo tên hoặc mô tả |

### 2.3. Lấy thông tin chatbot

```http
GET /ai/chatbots/{chatbotId}
```

### 2.4. Cập nhật chatbot

```http
PUT /ai/chatbots/{chatbotId}
Content-Type: application/json
```

### 2.5. Xóa chatbot

```http
DELETE /ai/chatbots/{chatbotId}
```

## 3. ENDPOINTS CHATBOT NÂNG CAO

### 3.1. Huấn luyện chatbot

```http
POST /ai/chatbots/{chatbotId}/train
Content-Type: application/json
```

### 3.2. Kiểm tra trạng thái huấn luyện

```http
GET /ai/chatbots/{chatbotId}/training-status
```

### 3.3. Xuất cấu hình chatbot

```http
GET /ai/chatbots/{chatbotId}/export
```

### 3.4. Nhập cấu hình chatbot

```http
POST /ai/chatbots/{chatbotId}/import
Content-Type: application/json
```

## 4. ENDPOINTS HỘI THOẠI

### 4.1. Lấy danh sách hội thoại

```http
GET /ai/chatbots/{chatbotId}/conversations
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số lượng hội thoại mỗi trang (mặc định: 20, tối đa: 100) |
| sort | string | Sắp xếp (createdAt:desc, updatedAt:asc, v.v.) |
| status | string | Lọc theo trạng thái (active, closed) |
| fromDate | string | Lọc từ ngày (format: YYYY-MM-DD) |
| toDate | string | Lọc đến ngày (format: YYYY-MM-DD) |
| search | string | Tìm kiếm theo nội dung hoặc thông tin người dùng |

### 4.2. Tạo hội thoại mới

```http
POST /ai/chatbots/{chatbotId}/conversations
Content-Type: application/json
```

#### Request Body

```json
{
  "user": {
    "name": "Lê Văn C",
    "email": "c@example.com",
    "phone": "0907654321"
  },
  "source": "website",
  "initialMessage": "Xin chào, tôi muốn tìm hiểu về NextFlow CRM"
}
```

### 4.3. Lấy thông tin hội thoại

```http
GET /ai/conversations/{conversationId}
```

### 4.4. Cập nhật hội thoại

```http
PUT /ai/conversations/{conversationId}
Content-Type: application/json
```

### 4.5. Đóng hội thoại

```http
POST /ai/conversations/{conversationId}/close
```

## 5. ENDPOINTS TIN NHẮN

### 5.1. Lấy danh sách tin nhắn

```http
GET /ai/conversations/{conversationId}/messages
```

### 5.2. Gửi tin nhắn mới

```http
POST /ai/conversations/{conversationId}/messages
Content-Type: application/json
```

#### Request Body

```json
{
  "role": "user",
  "content": "Tôi muốn biết thêm về tính năng tích hợp AI trong gói Enterprise"
}
```

### 5.3. Cập nhật tin nhắn

```http
PUT /ai/messages/{messageId}
Content-Type: application/json
```

### 5.4. Xóa tin nhắn

```http
DELETE /ai/messages/{messageId}
```

## 6. ENDPOINTS TÍCH HỢP

### 6.1. Webhook Configuration

```http
POST /ai/chatbots/{chatbotId}/webhooks
Content-Type: application/json
```

### 6.2. Test Webhook

```http
POST /ai/chatbots/{chatbotId}/webhooks/test
```

### 6.3. Widget Configuration

```http
GET /ai/chatbots/{chatbotId}/widget-config
```

### 6.4. Embed Code

```http
GET /ai/chatbots/{chatbotId}/embed-code
```

## 7. ENDPOINTS THỐNG KÊ

### 7.1. Thống kê tổng quan

```http
GET /ai/chatbots/{chatbotId}/analytics
```

### 7.2. Thống kê hội thoại

```http
GET /ai/chatbots/{chatbotId}/analytics/conversations
```

### 7.3. Thống kê hiệu suất

```http
GET /ai/chatbots/{chatbotId}/analytics/performance
```

### 7.4. Báo cáo chi tiết

```http
GET /ai/chatbots/{chatbotId}/reports
```

## 8. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Chatbot not found | Không tìm thấy chatbot |
| 4002 | Invalid configuration | Cấu hình không hợp lệ |
| 4003 | Model not available | Mô hình AI không khả dụng |
| 4004 | Knowledge base not found | Không tìm thấy knowledge base |
| 4005 | Conversation not found | Không tìm thấy hội thoại |
| 4006 | Message not found | Không tìm thấy tin nhắn |
| 5001 | Training failed | Huấn luyện thất bại |
| 5002 | API quota exceeded | Vượt quá giới hạn API |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM API Team
