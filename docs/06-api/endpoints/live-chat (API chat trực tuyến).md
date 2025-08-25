# API LIVE CHAT NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Chat Sessions](#2-endpoints-chat-sessions)
3. [Endpoints Messages](#3-endpoints-messages)
4. [Endpoints Agents](#4-endpoints-agents)
5. [Endpoints Widget](#5-endpoints-widget)
6. [Endpoints Analytics](#6-endpoints-analytics)
7. [WebSocket Events](#7-websocket-events)
8. [Error Codes](#8-error-codes)

## 1. GIỚI THIỆU

API Live Chat của NextFlow CRM-AI cung cấp các endpoint để quản lý chat sessions, messages, agents và real-time communication.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. WebSocket URL

```
wss://ws.nextflow-crm.com/v1/chat
```

### 1.3. Xác thực

```http
Authorization: Bearer {your_token}
```

## 2. ENDPOINTS CHAT SESSIONS

### 2.1. Tạo chat session mới

```http
POST /chat/sessions
Content-Type: application/json
```

#### Request Body

```json
{
  "visitorId": "visitor_123456789",
  "channel": "website",
  "source": {
    "url": "https://nextflow-crm.com/pricing",
    "title": "Bảng giá NextFlow CRM-AI",
    "referrer": "https://google.com"
  },
  "visitor": {
    "name": "Nguyễn Văn A",
    "email": "customer@example.com",
    "phone": "+84901234567",
    "customFields": {
      "company": "ABC Corp",
      "interest": "Enterprise plan"
    }
  },
  "initialMessage": "Xin chào, tôi muốn tìm hiểu về gói Enterprise",
  "department": "sales",
  "priority": "medium"
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Chat session đã được tạo",
  "data": {
    "sessionId": "session_123456789",
    "status": "waiting",
    "queuePosition": 2,
    "estimatedWaitTime": 120,
    "assignedAgent": null,
    "createdAt": "2023-10-27T10:30:00Z",
    "websocketUrl": "wss://ws.nextflow-crm.com/v1/chat/session_123456789"
  }
}
```

### 2.2. Lấy thông tin chat session

```http
GET /chat/sessions/{sessionId}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "id": "session_123456789",
    "status": "active",
    "channel": "website",
    "visitor": {
      "id": "visitor_123456789",
      "name": "Nguyễn Văn A",
      "email": "customer@example.com",
      "isOnline": true,
      "lastSeen": "2023-10-27T10:35:00Z"
    },
    "assignedAgent": {
      "id": "agent_123456789",
      "name": "Trần Thị B",
      "avatar": "https://cdn.nextflow-crm.com/avatars/agent_123456789.jpg",
      "isOnline": true
    },
    "department": "sales",
    "priority": "medium",
    "tags": ["enterprise", "pricing"],
    "customFields": {
      "leadScore": 85,
      "source": "google_ads"
    },
    "startedAt": "2023-10-27T10:30:00Z",
    "lastActivity": "2023-10-27T10:35:00Z",
    "messageCount": 8,
    "satisfaction": null
  }
}
```

### 2.3. Assign agent to session

```http
POST /chat/sessions/{sessionId}/assign
Content-Type: application/json
```

#### Request Body

```json
{
  "agentId": "agent_123456789",
  "transferReason": "Skill-based routing"
}
```

### 2.4. Transfer chat session

```http
POST /chat/sessions/{sessionId}/transfer
Content-Type: application/json
```

#### Request Body

```json
{
  "targetAgentId": "agent_234567890",
  "targetDepartment": "technical_support",
  "reason": "Technical issue requires specialist",
  "notes": "Customer has integration questions"
}
```

### 2.5. End chat session

```http
POST /chat/sessions/{sessionId}/end
Content-Type: application/json
```

#### Request Body

```json
{
  "reason": "resolved",
  "notes": "Customer's questions answered",
  "followUpRequired": false,
  "satisfaction": {
    "rating": 5,
    "feedback": "Excellent support!"
  }
}
```

## 3. ENDPOINTS MESSAGES

### 3.1. Gửi message

```http
POST /chat/sessions/{sessionId}/messages
Content-Type: application/json
```

#### Request Body

```json
{
  "type": "text",
  "content": "Cảm ơn bạn đã liên hệ! Tôi có thể giúp gì cho bạn?",
  "senderId": "agent_123456789",
  "senderType": "agent",
  "metadata": {
    "isInternal": false,
    "priority": "normal"
  },
  "attachments": [
    {
      "type": "file",
      "url": "https://cdn.nextflow-crm.com/files/pricing.pdf",
      "name": "Bảng giá NextFlow CRM-AI.pdf",
      "size": 245760
    }
  ]
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Message đã được gửi",
  "data": {
    "id": "msg_123456789",
    "sessionId": "session_123456789",
    "type": "text",
    "content": "Cảm ơn bạn đã liên hệ! Tôi có thể giúp gì cho bạn?",
    "senderId": "agent_123456789",
    "senderType": "agent",
    "status": "sent",
    "sentAt": "2023-10-27T10:35:00Z",
    "deliveredAt": "2023-10-27T10:35:01Z",
    "readAt": null
  }
}
```

### 3.2. Lấy message history

```http
GET /chat/sessions/{sessionId}/messages
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số lượng message mỗi trang (mặc định: 50, tối đa: 100) |
| before | string | Lấy message trước timestamp |
| after | string | Lấy message sau timestamp |
| type | string | Lọc theo loại message (text, file, image, system) |

### 3.3. Upload file

```http
POST /chat/sessions/{sessionId}/upload
Content-Type: multipart/form-data
```

### 3.4. Đánh dấu message đã đọc

```http
PUT /chat/sessions/{sessionId}/messages/{messageId}/read
```

### 3.5. Typing indicator

```http
POST /chat/sessions/{sessionId}/typing
Content-Type: application/json
```

#### Request Body

```json
{
  "isTyping": true,
  "senderId": "agent_123456789"
}
```

## 4. ENDPOINTS AGENTS

### 4.1. Lấy danh sách agents online

```http
GET /chat/agents/online
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "agent_123456789",
      "name": "Trần Thị B",
      "email": "agent1@nextflow-crm.com",
      "avatar": "https://cdn.nextflow-crm.com/avatars/agent_123456789.jpg",
      "status": "available",
      "department": "sales",
      "skills": ["sales", "enterprise", "pricing"],
      "currentChats": 2,
      "maxChats": 5,
      "lastActivity": "2023-10-27T10:35:00Z"
    }
  ]
}
```

### 4.2. Cập nhật agent status

```http
PUT /chat/agents/{agentId}/status
Content-Type: application/json
```

#### Request Body

```json
{
  "status": "busy",
  "statusMessage": "In a meeting",
  "availableUntil": "2023-10-27T11:30:00Z"
}
```

### 4.3. Lấy agent workload

```http
GET /chat/agents/{agentId}/workload
```

### 4.4. Agent performance

```http
GET /chat/agents/{agentId}/performance
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |
| period | string | Kỳ báo cáo (day, week, month) |

## 5. ENDPOINTS WIDGET

### 5.1. Lấy widget configuration

```http
GET /chat/widget/config
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| domain | string | Domain của website |
| page | string | URL của trang |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "widgetId": "widget_123456789",
    "enabled": true,
    "appearance": {
      "position": "bottom-right",
      "primaryColor": "#007bff",
      "textColor": "#ffffff",
      "borderRadius": 8,
      "showAgentPhotos": true
    },
    "behavior": {
      "autoOpen": false,
      "proactiveMessage": {
        "enabled": true,
        "delay": 30,
        "message": "Cần hỗ trợ gì không?"
      },
      "offlineMessage": "Chúng tôi hiện offline. Vui lòng để lại tin nhắn!"
    },
    "departments": [
      {
        "id": "sales",
        "name": "Bán hàng",
        "available": true
      },
      {
        "id": "support",
        "name": "Hỗ trợ kỹ thuật",
        "available": true
      }
    ],
    "businessHours": {
      "timezone": "Asia/Ho_Chi_Minh",
      "schedule": {
        "monday": {"start": "08:00", "end": "17:00"},
        "tuesday": {"start": "08:00", "end": "17:00"},
        "wednesday": {"start": "08:00", "end": "17:00"},
        "thursday": {"start": "08:00", "end": "17:00"},
        "friday": {"start": "08:00", "end": "17:00"},
        "saturday": {"closed": true},
        "sunday": {"closed": true}
      }
    }
  }
}
```

### 5.2. Cập nhật widget settings

```http
PUT /chat/widget/config
Content-Type: application/json
```

### 5.3. Widget analytics

```http
GET /chat/widget/analytics
```

## 6. ENDPOINTS ANALYTICS

### 6.1. Chat overview analytics

```http
GET /chat/analytics/overview
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |
| department | string | Lọc theo phòng ban |
| channel | string | Lọc theo kênh |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "summary": {
      "totalChats": 1547,
      "completedChats": 1423,
      "abandonedChats": 124,
      "averageWaitTime": 45,
      "averageResponseTime": 12,
      "averageResolutionTime": 480,
      "satisfactionScore": 4.6,
      "firstContactResolution": 78.5
    },
    "trends": [
      {
        "date": "2023-10-27",
        "chats": 125,
        "avgWaitTime": 42,
        "avgResponseTime": 10,
        "satisfaction": 4.7
      }
    ],
    "byChannel": {
      "website": 856,
      "facebook": 423,
      "zalo": 268
    },
    "byDepartment": {
      "sales": 623,
      "support": 524,
      "billing": 400
    }
  }
}
```

### 6.2. Agent performance analytics

```http
GET /chat/analytics/agents
```

### 6.3. Customer satisfaction analytics

```http
GET /chat/analytics/satisfaction
```

## 7. WEBSOCKET EVENTS

### 7.1. Connection

```javascript
const ws = new WebSocket('wss://ws.nextflow-crm.com/v1/chat/session_123456789?token=your_token');
```

### 7.2. Event Types

**Incoming Events:**
- `message.new` - Tin nhắn mới
- `message.read` - Tin nhắn đã đọc
- `typing.start` - Bắt đầu typing
- `typing.stop` - Dừng typing
- `agent.assigned` - Agent được assign
- `session.ended` - Session kết thúc

**Outgoing Events:**
- `message.send` - Gửi tin nhắn
- `typing.start` - Bắt đầu typing
- `typing.stop` - Dừng typing
- `message.read` - Đánh dấu đã đọc

### 7.3. Event Examples

```javascript
// Gửi tin nhắn
ws.send(JSON.stringify({
  type: 'message.send',
  data: {
    content: 'Hello!',
    type: 'text'
  }
}));

// Nhận tin nhắn
ws.onmessage = function(event) {
  const message = JSON.parse(event.data);
  if (message.type === 'message.new') {
    console.log('New message:', message.data);
  }
};
```

## 8. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Session not found | Không tìm thấy chat session |
| 4002 | Agent not found | Không tìm thấy agent |
| 4003 | Message not found | Không tìm thấy message |
| 4004 | Agent unavailable | Agent không có sẵn |
| 4005 | Session already ended | Session đã kết thúc |
| 4006 | File too large | File quá lớn |
| 4007 | Unsupported file type | Loại file không được hỗ trợ |
| 5001 | Message delivery failed | Gửi message thất bại |
| 5002 | WebSocket connection failed | Kết nối WebSocket thất bại |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
