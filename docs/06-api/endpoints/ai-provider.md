# API QUẢN LÝ NHÀ CUNG CẤP AI NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Nhà cung cấp](#2-endpoints-nhà-cung-cấp)
3. [Endpoints Xác thực](#3-endpoints-xác-thực)
4. [Endpoints Cấu hình](#4-endpoints-cấu-hình)
5. [Endpoints Thống kê](#5-endpoints-thống-kê)
6. [Error Codes](#6-error-codes)

## 1. GIỚI THIỆU

API Quản lý Nhà cung cấp AI của NextFlow CRM-AI cung cấp các endpoint để quản lý các nhà cung cấp dịch vụ AI như OpenAI, Google AI, Anthropic, Azure OpenAI, và các provider tự host khác.

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

## 2. ENDPOINTS NHÀ CUNG CẤP

### 2.1. Lấy danh sách nhà cung cấp

```http
GET /ai/providers
```

#### Query Parameters

| Tham số | Kiểu    | Mô tả                                                   |
| ------- | ------- | ------------------------------------------------------- |
| page    | integer | Số trang (mặc định: 1)                                  |
| perPage | integer | Số lượng provider mỗi trang (mặc định: 20, tối đa: 100) |
| sort    | string  | Sắp xếp (name:asc, createdAt:desc, v.v.)                |
| status  | string  | Lọc theo trạng thái (active, inactive)                  |
| type    | string  | Lọc theo loại (external, self_hosted)                   |
| search  | string  | Tìm kiếm theo tên                                       |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "provider_123456789",
      "name": "OpenAI",
      "description": "Nhà cung cấp mô hình AI OpenAI",
      "type": "external",
      "status": "active",
      "apiEndpoint": "https://api.openai.com/v1",
      "supportedModels": ["gpt-4", "gpt-3.5-turbo", "text-embedding-ada-002"],
      "capabilities": {
        "chat": true,
        "completion": true,
        "embedding": true,
        "vision": true,
        "functions": true
      },
      "pricing": {
        "currency": "USD",
        "billingModel": "pay_per_token"
      },
      "createdAt": "2023-10-27T09:15:00Z",
      "updatedAt": "2023-10-27T09:15:00Z"
    }
  ]
}
```

### 2.2. Lấy thông tin nhà cung cấp

```http
GET /ai/providers/{providerId}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "id": "provider_123456789",
    "name": "OpenAI",
    "description": "Nhà cung cấp mô hình AI OpenAI",
    "type": "external",
    "status": "active",
    "apiEndpoint": "https://api.openai.com/v1",
    "documentation": "https://platform.openai.com/docs",
    "supportedModels": [
      {
        "id": "gpt-4",
        "name": "GPT-4",
        "type": "chat",
        "maxTokens": 8192
      },
      {
        "id": "gpt-3.5-turbo",
        "name": "GPT-3.5 Turbo",
        "type": "chat",
        "maxTokens": 4096
      }
    ],
    "capabilities": {
      "chat": true,
      "completion": true,
      "embedding": true,
      "vision": true,
      "functions": true,
      "streaming": true,
      "fineTuning": true
    },
    "authentication": {
      "type": "api_key",
      "required": true,
      "fields": [
        {
          "name": "api_key",
          "type": "string",
          "required": true,
          "description": "OpenAI API Key"
        }
      ]
    },
    "pricing": {
      "currency": "USD",
      "billingModel": "pay_per_token",
      "freeQuota": {
        "tokens": 0,
        "requests": 0
      }
    },
    "rateLimits": {
      "requestsPerMinute": 3500,
      "tokensPerMinute": 90000
    },
    "statistics": {
      "totalRequests": 25847,
      "totalTokens": 4729384,
      "averageResponseTime": 1.1,
      "successRate": 99.9
    },
    "createdAt": "2023-10-27T09:15:00Z",
    "updatedAt": "2023-10-27T09:15:00Z"
  }
}
```

### 2.3. Thêm nhà cung cấp mới

```http
POST /ai/providers
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Google AI",
  "description": "Nhà cung cấp mô hình AI Google",
  "type": "external",
  "status": "active",
  "apiEndpoint": "https://generativelanguage.googleapis.com/v1",
  "documentation": "https://ai.google.dev/docs",
  "authentication": {
    "type": "api_key",
    "required": true,
    "fields": [
      {
        "name": "api_key",
        "type": "string",
        "required": true,
        "description": "Google AI API Key"
      }
    ]
  },
  "capabilities": {
    "chat": true,
    "completion": true,
    "embedding": true,
    "vision": false,
    "functions": false
  },
  "pricing": {
    "currency": "USD",
    "billingModel": "pay_per_token"
  }
}
```

### 2.4. Cập nhật nhà cung cấp

```http
PUT /ai/providers/{providerId}
Content-Type: application/json
```

### 2.5. Xóa nhà cung cấp

```http
DELETE /ai/providers/{providerId}
```

## 3. ENDPOINTS XÁC THỰC

### 3.1. Lấy thông tin xác thực

```http
GET /ai/providers/{providerId}/authentication
```

### 3.2. Cập nhật thông tin xác thực

```http
PUT /ai/providers/{providerId}/authentication
Content-Type: application/json
```

#### Request Body

```json
{
  "credentials": {
    "api_key": "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "organization_id": "org-xxxxxxxxxxxxxxxxxxxxxxxx"
  },
  "testConnection": true
}
```

### 3.3. Kiểm tra xác thực

```http
POST /ai/providers/{providerId}/test-authentication
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Xác thực thành công",
  "data": {
    "status": "authenticated",
    "validUntil": "2024-12-31T23:59:59Z",
    "quotaRemaining": {
      "requests": 4500,
      "tokens": 75000
    },
    "lastChecked": "2023-10-27T10:30:00Z"
  }
}
```

### 3.4. Làm mới token

```http
POST /ai/providers/{providerId}/refresh-token
```

## 4. ENDPOINTS CẤU HÌNH

### 4.1. Lấy cấu hình provider

```http
GET /ai/providers/{providerId}/configuration
```

### 4.2. Cập nhật cấu hình provider

```http
PUT /ai/providers/{providerId}/configuration
Content-Type: application/json
```

#### Request Body

```json
{
  "rateLimits": {
    "requestsPerMinute": 60,
    "tokensPerMinute": 90000,
    "enableRateLimiting": true
  },
  "timeout": {
    "connection": 30,
    "read": 60
  },
  "retry": {
    "maxRetries": 3,
    "backoffMultiplier": 2,
    "initialDelay": 1000
  },
  "fallback": {
    "enabled": true,
    "fallbackProviders": ["provider_234567890"]
  }
}
```

### 4.3. Lấy danh sách mô hình hỗ trợ

```http
GET /ai/providers/{providerId}/supported-models
```

### 4.4. Đồng bộ mô hình từ provider

```http
POST /ai/providers/{providerId}/sync-models
```

## 5. ENDPOINTS THỐNG KÊ

### 5.1. Thống kê sử dụng provider

```http
GET /ai/providers/{providerId}/analytics
```

#### Query Parameters

| Tham số     | Kiểu   | Mô tả                                |
| ----------- | ------ | ------------------------------------ |
| fromDate    | string | Từ ngày (YYYY-MM-DD)                 |
| toDate      | string | Đến ngày (YYYY-MM-DD)                |
| granularity | string | Độ chi tiết (hour, day, week, month) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "summary": {
      "totalRequests": 15420,
      "totalTokens": 2847392,
      "totalCost": 85.42,
      "averageResponseTime": 1.2,
      "successRate": 99.8
    },
    "timeline": [
      {
        "date": "2023-10-27",
        "requests": 1250,
        "tokens": 234567,
        "cost": 7.04,
        "averageResponseTime": 1.1,
        "successRate": 99.9
      }
    ],
    "modelBreakdown": [
      {
        "modelId": "gpt-4",
        "requests": 8500,
        "tokens": 1654321,
        "cost": 49.63,
        "percentage": 55.1
      }
    ]
  }
}
```

### 5.2. Báo cáo chi phí

```http
GET /ai/providers/{providerId}/cost-report
```

### 5.3. Thống kê hiệu suất

```http
GET /ai/providers/{providerId}/performance
```

### 5.4. Báo cáo quota

```http
GET /ai/providers/{providerId}/quota-report
```

## 6. ERROR CODES

| Code | Message                | Mô tả                           |
| ---- | ---------------------- | ------------------------------- |
| 4001 | Provider not found     | Không tìm thấy nhà cung cấp     |
| 4002 | Invalid credentials    | Thông tin xác thực không hợp lệ |
| 4003 | Authentication failed  | Xác thực thất bại               |
| 4004 | Provider not available | Nhà cung cấp không khả dụng     |
| 4005 | Quota exceeded         | Vượt quá quota                  |
| 4006 | Rate limit exceeded    | Vượt quá giới hạn tốc độ        |
| 5001 | Connection failed      | Kết nối thất bại                |
| 5002 | API error              | Lỗi API                         |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
