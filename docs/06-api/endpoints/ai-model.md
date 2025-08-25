# API QUẢN LÝ MÔ HÌNH AI NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Mô hình AI](#2-endpoints-mô-hình-ai)
3. [Endpoints Cấu hình](#3-endpoints-cấu-hình)
4. [Endpoints Kiểm tra](#4-endpoints-kiểm-tra)
5. [Endpoints Thống kê](#5-endpoints-thống-kê)
6. [Error Codes](#6-error-codes)

## 1. GIỚI THIỆU

API Quản lý Mô hình AI của NextFlow CRM-AI cung cấp các endpoint để quản lý và tương tác với các mô hình AI từ nhiều nhà cung cấp khác nhau như OpenAI, Google AI, Anthropic, và các mô hình tự host.

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

## 2. ENDPOINTS MÔ HÌNH AI

### 2.1. Lấy danh sách mô hình

```http
GET /ai/models
```

#### Query Parameters

| Tham số  | Kiểu    | Mô tả                                                  |
| -------- | ------- | ------------------------------------------------------ |
| page     | integer | Số trang (mặc định: 1)                                 |
| perPage  | integer | Số lượng mô hình mỗi trang (mặc định: 20, tối đa: 100) |
| sort     | string  | Sắp xếp (name:asc, createdAt:desc, v.v.)               |
| status   | string  | Lọc theo trạng thái (active, inactive)                 |
| provider | string  | Lọc theo nhà cung cấp                                  |
| type     | string  | Lọc theo loại (chat, embedding, completion)            |
| search   | string  | Tìm kiếm theo tên hoặc mô tả                           |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "model_123456789",
      "name": "GPT-4",
      "description": "Mô hình ngôn ngữ lớn GPT-4 của OpenAI",
      "type": "chat",
      "status": "active",
      "provider": {
        "id": "provider_123456789",
        "name": "OpenAI",
        "type": "external"
      },
      "capabilities": {
        "maxTokens": 8192,
        "supportsFunctions": true,
        "supportsVision": true,
        "supportsStreaming": true
      },
      "pricing": {
        "inputTokens": 0.03,
        "outputTokens": 0.06,
        "currency": "USD",
        "unit": "1K tokens"
      },
      "createdAt": "2023-10-27T09:15:00Z",
      "updatedAt": "2023-10-27T09:15:00Z"
    }
  ]
}
```

### 2.2. Lấy thông tin mô hình

```http
GET /ai/models/{modelId}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "id": "model_123456789",
    "name": "GPT-4",
    "description": "Mô hình ngôn ngữ lớn GPT-4 của OpenAI",
    "type": "chat",
    "status": "active",
    "provider": {
      "id": "provider_123456789",
      "name": "OpenAI",
      "type": "external",
      "apiEndpoint": "https://api.openai.com/v1",
      "documentation": "https://platform.openai.com/docs"
    },
    "capabilities": {
      "maxTokens": 8192,
      "contextWindow": 8192,
      "supportsFunctions": true,
      "supportsVision": true,
      "supportsStreaming": true,
      "supportedLanguages": ["en", "vi", "zh", "ja", "ko"],
      "supportedFormats": ["text", "json", "markdown"]
    },
    "pricing": {
      "inputTokens": 0.03,
      "outputTokens": 0.06,
      "currency": "USD",
      "unit": "1K tokens",
      "minimumCharge": 0.001
    },
    "configuration": {
      "defaultTemperature": 0.7,
      "defaultMaxTokens": 4096,
      "defaultTopP": 0.95,
      "availableParameters": ["temperature", "max_tokens", "top_p", "frequency_penalty", "presence_penalty", "stop"]
    },
    "statistics": {
      "totalRequests": 15420,
      "totalTokens": 2847392,
      "averageResponseTime": 1.2,
      "successRate": 99.8
    },
    "createdAt": "2023-10-27T09:15:00Z",
    "updatedAt": "2023-10-27T09:15:00Z"
  }
}
```

### 2.3. Thêm mô hình mới

```http
POST /ai/models
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Claude-3 Sonnet",
  "description": "Mô hình Claude-3 Sonnet của Anthropic",
  "type": "chat",
  "providerId": "provider_234567890",
  "status": "active",
  "configuration": {
    "modelName": "claude-3-sonnet-20240229",
    "apiEndpoint": "https://api.anthropic.com/v1/messages",
    "defaultTemperature": 0.7,
    "defaultMaxTokens": 4096,
    "defaultTopP": 0.95
  },
  "capabilities": {
    "maxTokens": 200000,
    "contextWindow": 200000,
    "supportsFunctions": false,
    "supportsVision": true,
    "supportsStreaming": true
  },
  "pricing": {
    "inputTokens": 0.015,
    "outputTokens": 0.075,
    "currency": "USD",
    "unit": "1K tokens"
  }
}
```

### 2.4. Cập nhật mô hình

```http
PUT /ai/models/{modelId}
Content-Type: application/json
```

### 2.5. Xóa mô hình

```http
DELETE /ai/models/{modelId}
```

## 3. ENDPOINTS CẤU HÌNH

### 3.1. Lấy cấu hình mô hình

```http
GET /ai/models/{modelId}/configuration
```

### 3.2. Cập nhật cấu hình mô hình

```http
PUT /ai/models/{modelId}/configuration
Content-Type: application/json
```

#### Request Body

```json
{
  "defaultTemperature": 0.8,
  "defaultMaxTokens": 2048,
  "defaultTopP": 0.9,
  "rateLimits": {
    "requestsPerMinute": 60,
    "tokensPerMinute": 90000
  },
  "fallbackModels": ["model_987654321", "model_456789012"]
}
```

### 3.3. Kiểm tra khả năng mô hình

```http
GET /ai/models/{modelId}/capabilities
```

### 3.4. Lấy thông số giá cả

```http
GET /ai/models/{modelId}/pricing
```

## 4. ENDPOINTS KIỂM TRA

### 4.1. Kiểm tra kết nối mô hình

```http
POST /ai/models/{modelId}/test-connection
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Kết nối thành công",
  "data": {
    "status": "connected",
    "responseTime": 0.8,
    "apiVersion": "v1",
    "lastChecked": "2023-10-27T10:30:00Z"
  }
}
```

### 4.2. Kiểm tra hiệu suất mô hình

```http
POST /ai/models/{modelId}/benchmark
Content-Type: application/json
```

#### Request Body

```json
{
  "testCases": [
    {
      "prompt": "Giải thích về NextFlow CRM-AI",
      "expectedKeywords": ["CRM", "quản lý", "khách hàng"]
    }
  ],
  "metrics": ["response_time", "token_count", "quality_score"]
}
```

### 4.3. Thử nghiệm mô hình

```http
POST /ai/models/{modelId}/test
Content-Type: application/json
```

#### Request Body

```json
{
  "prompt": "Xin chào, bạn có thể giới thiệu về NextFlow CRM-AI không?",
  "parameters": {
    "temperature": 0.7,
    "maxTokens": 500,
    "topP": 0.95
  }
}
```

## 5. ENDPOINTS THỐNG KÊ

### 5.1. Thống kê sử dụng mô hình

```http
GET /ai/models/{modelId}/analytics
```

#### Query Parameters

| Tham số     | Kiểu   | Mô tả                                |
| ----------- | ------ | ------------------------------------ |
| fromDate    | string | Từ ngày (YYYY-MM-DD)                 |
| toDate      | string | Đến ngày (YYYY-MM-DD)                |
| granularity | string | Độ chi tiết (hour, day, week, month) |

### 5.2. Báo cáo chi phí

```http
GET /ai/models/{modelId}/cost-report
```

### 5.3. Thống kê hiệu suất

```http
GET /ai/models/{modelId}/performance
```

### 5.4. So sánh mô hình

```http
POST /ai/models/compare
Content-Type: application/json
```

#### Request Body

```json
{
  "modelIds": ["model_123456789", "model_234567890"],
  "metrics": ["response_time", "cost", "quality"],
  "timeRange": {
    "from": "2023-10-01",
    "to": "2023-10-31"
  }
}
```

## 6. ERROR CODES

| Code | Message               | Mô tả                       |
| ---- | --------------------- | --------------------------- |
| 4001 | Model not found       | Không tìm thấy mô hình      |
| 4002 | Provider not found    | Không tìm thấy nhà cung cấp |
| 4003 | Invalid configuration | Cấu hình không hợp lệ       |
| 4004 | Model not available   | Mô hình không khả dụng      |
| 4005 | Rate limit exceeded   | Vượt quá giới hạn tốc độ    |
| 4006 | Insufficient credits  | Không đủ credits            |
| 5001 | Connection failed     | Kết nối thất bại            |
| 5002 | API error             | Lỗi API                     |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
