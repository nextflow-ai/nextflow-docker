# API HỆ THỐNG TỔNG ĐÀI NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Cuộc gọi](#2-endpoints-cuộc-gọi)
3. [Endpoints Ghi âm](#3-endpoints-ghi-âm)
4. [Endpoints IVR](#4-endpoints-ivr)
5. [Endpoints Hàng đợi](#5-endpoints-hàng-đợi)
6. [Endpoints Báo cáo](#6-endpoints-báo-cáo)
7. [WebRTC Integration](#7-webrtc-integration)
8. [Mã lỗi](#8-mã-lỗi)

## 1. GIỚI THIỆU

API Hệ thống Tổng đài NextFlow CRM-AI cung cấp các endpoint để quản lý cuộc gọi, ghi âm, IVR và tích hợp VoIP.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1/call-center
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
X-Device-ID: {device_id}
```

## 2. ENDPOINTS CUỘC GỌI

### 2.1. Thực hiện cuộc gọi

```http
POST /calls/make
Content-Type: application/json
```

#### Request Body

```json
{
  "phoneNumber": "+84901234567",
  "customerId": "customer_123456789",
  "callType": "outbound",
  "priority": "normal",
  "notes": "Gọi tư vấn gói Enterprise"
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Cuộc gọi đã được khởi tạo",
  "data": {
    "callId": "call_123456789",
    "status": "connecting",
    "phoneNumber": "+84901234567",
    "customer": {
      "id": "customer_123456789",
      "name": "Nguyễn Văn A",
      "company": "Công ty ABC"
    },
    "startedAt": "2024-10-27T10:30:00Z",
    "webrtcUrl": "wss://webrtc.nextflow-crm.com/call_123456789"
  }
}
```

### 2.2. Lấy thông tin cuộc gọi

```http
GET /calls/{callId}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "id": "call_123456789",
    "phoneNumber": "+84901234567",
    "direction": "outbound",
    "status": "completed",
    "duration": 345,
    "customer": {
      "id": "customer_123456789",
      "name": "Nguyễn Văn A",
      "company": "Công ty ABC"
    },
    "agent": {
      "id": "agent_123456789",
      "name": "Trần Thị B",
      "extension": "101"
    },
    "startedAt": "2024-10-27T10:30:00Z",
    "answeredAt": "2024-10-27T10:30:05Z",
    "endedAt": "2024-10-27T10:35:45Z",
    "recordingUrl": "https://cdn.nextflow-crm.com/recordings/call_123456789.mp3",
    "notes": "Khách hàng quan tâm gói Enterprise, hẹn demo vào thứ 3",
    "outcome": "interested",
    "followUpRequired": true
  }
}
```

### 2.3. Kết thúc cuộc gọi

```http
POST /calls/{callId}/hangup
Content-Type: application/json
```

#### Request Body

```json
{
  "reason": "completed",
  "notes": "Tư vấn thành công, khách hàng quan tâm",
  "outcome": "interested",
  "followUpDate": "2024-10-30T14:00:00Z"
}
```

### 2.4. Chuyển cuộc gọi

```http
POST /calls/{callId}/transfer
Content-Type: application/json
```

#### Request Body

```json
{
  "transferType": "warm",
  "targetAgentId": "agent_234567890",
  "targetExtension": "102",
  "notes": "Chuyển cho chuyên viên kỹ thuật"
}
```

## 3. ENDPOINTS GHI ÂM

### 3.1. Lấy danh sách ghi âm

```http
GET /recordings
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số lượng ghi âm mỗi trang (mặc định: 20) |
| agentId | string | Lọc theo nhân viên |
| customerId | string | Lọc theo khách hàng |
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |
| duration | string | Lọc theo thời lượng (short, medium, long) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "recording_123456789",
      "callId": "call_123456789",
      "fileName": "cuoc_goi_001_20241027_103015.mp3",
      "duration": 345,
      "fileSize": 2048576,
      "quality": "HD",
      "transcription": "Xin chào, tôi là Trần Thị B từ NextFlow CRM-AI...",
      "sentiment": "positive",
      "keywords": ["enterprise", "demo", "pricing"],
      "downloadUrl": "https://cdn.nextflow-crm.com/recordings/call_123456789.mp3",
      "createdAt": "2024-10-27T10:30:00Z"
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "perPage": 20,
      "totalPages": 5,
      "totalItems": 95
    }
  }
}
```

### 3.2. Phân tích ghi âm

```http
POST /recordings/{recordingId}/analyze
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Phân tích hoàn tất",
  "data": {
    "transcription": "Xin chào, tôi là Trần Thị B từ NextFlow CRM-AI. Hôm nay tôi gọi để tư vấn về gói Enterprise...",
    "sentiment": {
      "overall": "positive",
      "confidence": 0.85,
      "emotions": {
        "happy": 0.6,
        "neutral": 0.3,
        "frustrated": 0.1
      }
    },
    "keywords": [
      {"word": "enterprise", "count": 5, "relevance": 0.9},
      {"word": "pricing", "count": 3, "relevance": 0.8},
      {"word": "demo", "count": 2, "relevance": 0.7}
    ],
    "talkTime": {
      "agent": 180,
      "customer": 165,
      "agentPercentage": 52.2
    },
    "qualityScore": 8.5,
    "suggestions": [
      "Nên hỏi thêm về ngân sách của khách hàng",
      "Đề xuất lịch demo cụ thể"
    ]
  }
}
```

## 4. ENDPOINTS IVR

### 4.1. Cấu hình IVR

```http
POST /ivr/flows
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "IVR Chính",
  "description": "Menu chính cho khách hàng gọi vào",
  "isActive": true,
  "steps": [
    {
      "type": "greeting",
      "message": "Xin chào! Cảm ơn bạn đã gọi đến NextFlow CRM-AI",
      "audioFile": "greeting.mp3"
    },
    {
      "type": "menu",
      "message": "Bấm 1 cho tư vấn bán hàng, bấm 2 cho hỗ trợ kỹ thuật",
      "options": [
        {
          "key": "1",
          "action": "transfer_to_queue",
          "target": "sales_queue"
        },
        {
          "key": "2", 
          "action": "transfer_to_queue",
          "target": "support_queue"
        },
        {
          "key": "0",
          "action": "transfer_to_agent",
          "target": "operator"
        }
      ]
    }
  ]
}
```

### 4.2. Lấy thống kê IVR

```http
GET /ivr/analytics
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| flowId | string | ID của IVR flow |
| fromDate | string | Từ ngày |
| toDate | string | Đến ngày |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "totalCalls": 1250,
    "completedFlows": 1100,
    "abandonedCalls": 150,
    "averageFlowTime": 45,
    "optionUsage": {
      "1": 650,
      "2": 350,
      "0": 100,
      "timeout": 150
    },
    "peakHours": [
      {"hour": 9, "calls": 120},
      {"hour": 14, "calls": 95},
      {"hour": 16, "calls": 110}
    ]
  }
}
```

## 5. ENDPOINTS HÀNG ĐỢI

### 5.1. Lấy trạng thái hàng đợi

```http
GET /queues/status
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "queueId": "sales_queue",
      "name": "Tư vấn bán hàng",
      "waitingCalls": 3,
      "availableAgents": 2,
      "busyAgents": 3,
      "averageWaitTime": 83,
      "longestWaitTime": 156,
      "callsToday": 45,
      "abandonedToday": 3
    },
    {
      "queueId": "support_queue", 
      "name": "Hỗ trợ kỹ thuật",
      "waitingCalls": 1,
      "availableAgents": 1,
      "busyAgents": 2,
      "averageWaitTime": 45,
      "longestWaitTime": 45,
      "callsToday": 28,
      "abandonedToday": 1
    }
  ]
}
```

### 5.2. Thêm cuộc gọi vào hàng đợi

```http
POST /queues/{queueId}/calls
Content-Type: application/json
```

#### Request Body

```json
{
  "callId": "call_123456789",
  "priority": "high",
  "customerTier": "vip",
  "estimatedDuration": 300
}
```

## 6. ENDPOINTS BÁO CÁO

### 6.1. Báo cáo nhân viên

```http
GET /reports/agents/{agentId}
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| fromDate | string | Từ ngày |
| toDate | string | Đến ngày |
| period | string | Kỳ báo cáo (day, week, month) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "agentId": "agent_123456789",
    "agentName": "Nguyễn Văn A",
    "period": {
      "from": "2024-10-21",
      "to": "2024-10-27"
    },
    "callStats": {
      "totalCalls": 77,
      "inboundCalls": 32,
      "outboundCalls": 45,
      "totalTalkTime": 30240,
      "averageCallDuration": 393,
      "longestCall": 1245,
      "shortestCall": 15
    },
    "performance": {
      "answerRate": 96.8,
      "firstCallResolution": 78.5,
      "customerSatisfaction": 4.6,
      "salesConversion": 17.8
    },
    "outcomes": {
      "interested": 14,
      "notInterested": 8,
      "callback": 12,
      "voicemail": 3,
      "busy": 5
    },
    "ranking": {
      "position": 2,
      "totalAgents": 15,
      "topMetric": "conversion_rate"
    }
  }
}
```

### 6.2. Báo cáo tổng quan

```http
GET /reports/overview
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "today": {
      "totalCalls": 245,
      "answeredCalls": 230,
      "missedCalls": 15,
      "averageWaitTime": 67,
      "totalTalkTime": 54000,
      "peakHour": 14
    },
    "thisWeek": {
      "totalCalls": 1680,
      "growthRate": 12.5,
      "averageDaily": 240,
      "bestDay": "2024-10-25",
      "worstDay": "2024-10-23"
    },
    "agents": {
      "online": 8,
      "busy": 5,
      "available": 3,
      "offline": 2
    },
    "queues": {
      "totalWaiting": 4,
      "longestWait": 156,
      "averageWait": 78
    }
  }
}
```

## 7. WEBRTC INTEGRATION

### 7.1. Khởi tạo WebRTC session

```http
POST /webrtc/session
Content-Type: application/json
```

#### Request Body

```json
{
  "agentId": "agent_123456789",
  "deviceType": "browser",
  "capabilities": ["audio", "video"]
}
```

### 7.2. WebSocket Events

```javascript
// Kết nối WebSocket
const ws = new WebSocket('wss://webrtc.nextflow-crm.com/agent_123456789');

// Sự kiện cuộc gọi đến
ws.onmessage = function(event) {
  const data = JSON.parse(event.data);
  if (data.type === 'incoming_call') {
    console.log('Cuộc gọi đến từ:', data.phoneNumber);
    // Hiển thị popup nhận cuộc gọi
  }
};
```

## 8. MÃ LỖI

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Call not found | Không tìm thấy cuộc gọi |
| 4002 | Agent not available | Nhân viên không có sẵn |
| 4003 | Invalid phone number | Số điện thoại không hợp lệ |
| 4004 | Queue is full | Hàng đợi đã đầy |
| 4005 | Recording not found | Không tìm thấy ghi âm |
| 4006 | Transfer failed | Chuyển cuộc gọi thất bại |
| 5001 | VoIP connection failed | Kết nối VoIP thất bại |
| 5002 | Recording failed | Ghi âm thất bại |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
