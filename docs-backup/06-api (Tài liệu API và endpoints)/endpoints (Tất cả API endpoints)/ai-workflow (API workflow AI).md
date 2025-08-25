# API QUẢN LÝ WORKFLOW AI NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Workflow](#2-endpoints-workflow)
3. [Endpoints Execution](#3-endpoints-execution)
4. [Endpoints Template](#4-endpoints-template)
5. [Endpoints Monitoring](#5-endpoints-monitoring)
6. [Error Codes](#6-error-codes)

## 1. GIỚI THIỆU

API Quản lý Workflow AI của NextFlow CRM-AI cung cấp các endpoint để tạo, quản lý và thực thi các workflow AI tự động. API này hỗ trợ tạo các quy trình làm việc phức tạp với nhiều bước, điều kiện và tích hợp với các dịch vụ khác.

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

## 2. ENDPOINTS WORKFLOW

### 2.1. Lấy danh sách workflow

```http
GET /ai/workflows
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số lượng workflow mỗi trang (mặc định: 20, tối đa: 100) |
| sort | string | Sắp xếp (name:asc, createdAt:desc, v.v.) |
| status | string | Lọc theo trạng thái (active, inactive, draft) |
| category | string | Lọc theo danh mục |
| search | string | Tìm kiếm theo tên hoặc mô tả |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "workflow_123456789",
      "name": "Phân tích cảm xúc khách hàng",
      "description": "Workflow tự động phân tích cảm xúc từ feedback khách hàng",
      "category": "customer_analysis",
      "status": "active",
      "version": "1.2.0",
      "trigger": {
        "type": "webhook",
        "event": "customer_feedback_received"
      },
      "steps": 5,
      "executionCount": 1247,
      "successRate": 98.5,
      "averageExecutionTime": 2.3,
      "createdAt": "2023-10-27T09:15:00Z",
      "updatedAt": "2023-10-27T09:15:00Z"
    }
  ]
}
```

### 2.2. Lấy thông tin workflow

```http
GET /ai/workflows/{workflowId}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "id": "workflow_123456789",
    "name": "Phân tích cảm xúc khách hàng",
    "description": "Workflow tự động phân tích cảm xúc từ feedback khách hàng",
    "category": "customer_analysis",
    "status": "active",
    "version": "1.2.0",
    "trigger": {
      "type": "webhook",
      "event": "customer_feedback_received",
      "configuration": {
        "url": "https://api.nextflow-crm.com/webhooks/workflow_123456789",
        "method": "POST",
        "headers": {
          "Content-Type": "application/json"
        }
      }
    },
    "steps": [
      {
        "id": "step_1",
        "name": "Nhận dữ liệu",
        "type": "input",
        "configuration": {
          "schema": {
            "customerId": "string",
            "feedback": "string",
            "rating": "number"
          }
        }
      },
      {
        "id": "step_2",
        "name": "Phân tích cảm xúc",
        "type": "ai_analysis",
        "configuration": {
          "modelId": "model_123456789",
          "prompt": "Phân tích cảm xúc của feedback sau: {feedback}",
          "outputFormat": "json"
        }
      },
      {
        "id": "step_3",
        "name": "Cập nhật khách hàng",
        "type": "api_call",
        "configuration": {
          "endpoint": "/customers/{customerId}",
          "method": "PATCH",
          "body": {
            "sentimentScore": "{sentiment_score}",
            "lastAnalyzedAt": "{current_timestamp}"
          }
        }
      }
    ],
    "statistics": {
      "totalExecutions": 1247,
      "successfulExecutions": 1228,
      "failedExecutions": 19,
      "successRate": 98.5,
      "averageExecutionTime": 2.3,
      "totalCost": 15.67
    },
    "createdAt": "2023-10-27T09:15:00Z",
    "updatedAt": "2023-10-27T09:15:00Z"
  }
}
```

### 2.3. Tạo workflow mới

```http
POST /ai/workflows
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Tự động trả lời email khách hàng",
  "description": "Workflow tự động tạo và gửi email trả lời khách hàng",
  "category": "customer_service",
  "status": "draft",
  "trigger": {
    "type": "email_received",
    "configuration": {
      "emailAddress": "support@nextflow-crm.com",
      "filters": {
        "subject_contains": ["hỗ trợ", "support", "help"]
      }
    }
  },
  "steps": [
    {
      "name": "Phân loại email",
      "type": "ai_classification",
      "configuration": {
        "modelId": "model_123456789",
        "categories": ["technical", "billing", "general"],
        "confidenceThreshold": 0.8
      }
    },
    {
      "name": "Tạo phản hồi",
      "type": "ai_generation",
      "configuration": {
        "modelId": "model_123456789",
        "template": "Tạo email trả lời chuyên nghiệp cho loại: {category}",
        "maxLength": 500
      }
    },
    {
      "name": "Gửi email",
      "type": "email_send",
      "configuration": {
        "to": "{sender_email}",
        "subject": "Re: {original_subject}",
        "body": "{generated_response}"
      }
    }
  ]
}
```

### 2.4. Cập nhật workflow

```http
PUT /ai/workflows/{workflowId}
Content-Type: application/json
```

### 2.5. Xóa workflow

```http
DELETE /ai/workflows/{workflowId}
```

### 2.6. Sao chép workflow

```http
POST /ai/workflows/{workflowId}/clone
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Phân tích cảm xúc khách hàng (Copy)",
  "description": "Bản sao của workflow phân tích cảm xúc"
}
```

## 3. ENDPOINTS EXECUTION

### 3.1. Thực thi workflow

```http
POST /ai/workflows/{workflowId}/execute
Content-Type: application/json
```

#### Request Body

```json
{
  "input": {
    "customerId": "customer_123456789",
    "feedback": "Sản phẩm rất tốt, tôi rất hài lòng với dịch vụ",
    "rating": 5
  },
  "options": {
    "async": true,
    "timeout": 300,
    "retryOnFailure": true
  }
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Workflow đã được thực thi",
  "data": {
    "executionId": "exec_123456789",
    "workflowId": "workflow_123456789",
    "status": "running",
    "startedAt": "2023-10-27T10:30:00Z",
    "estimatedDuration": 5,
    "currentStep": "step_1",
    "progress": 20
  }
}
```

### 3.2. Lấy trạng thái thực thi

```http
GET /ai/executions/{executionId}
```

### 3.3. Lấy danh sách thực thi

```http
GET /ai/workflows/{workflowId}/executions
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số lượng execution mỗi trang (mặc định: 20, tối đa: 100) |
| status | string | Lọc theo trạng thái (running, completed, failed) |
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |

### 3.4. Dừng thực thi

```http
POST /ai/executions/{executionId}/stop
```

### 3.5. Thực thi lại

```http
POST /ai/executions/{executionId}/retry
```

## 4. ENDPOINTS TEMPLATE

### 4.1. Lấy danh sách template

```http
GET /ai/workflow-templates
```

### 4.2. Lấy thông tin template

```http
GET /ai/workflow-templates/{templateId}
```

### 4.3. Tạo workflow từ template

```http
POST /ai/workflow-templates/{templateId}/create-workflow
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Workflow từ template",
  "description": "Workflow được tạo từ template",
  "parameters": {
    "modelId": "model_123456789",
    "emailAddress": "support@nextflow-crm.com"
  }
}
```

### 4.4. Lưu workflow thành template

```http
POST /ai/workflows/{workflowId}/save-as-template
Content-Type: application/json
```

## 5. ENDPOINTS MONITORING

### 5.1. Thống kê workflow

```http
GET /ai/workflows/{workflowId}/analytics
```

### 5.2. Báo cáo hiệu suất

```http
GET /ai/workflows/{workflowId}/performance
```

### 5.3. Logs thực thi

```http
GET /ai/executions/{executionId}/logs
```

### 5.4. Cảnh báo và thông báo

```http
GET /ai/workflows/{workflowId}/alerts
```

### 5.5. Cấu hình monitoring

```http
PUT /ai/workflows/{workflowId}/monitoring
Content-Type: application/json
```

#### Request Body

```json
{
  "alerts": {
    "failureRate": {
      "enabled": true,
      "threshold": 5,
      "period": "1h"
    },
    "executionTime": {
      "enabled": true,
      "threshold": 10,
      "unit": "seconds"
    }
  },
  "notifications": {
    "email": ["admin@nextflow-crm.com"],
    "webhook": "https://hooks.slack.com/services/..."
  }
}
```

## 6. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Workflow not found | Không tìm thấy workflow |
| 4002 | Execution not found | Không tìm thấy execution |
| 4003 | Invalid workflow configuration | Cấu hình workflow không hợp lệ |
| 4004 | Step execution failed | Thực thi bước thất bại |
| 4005 | Timeout exceeded | Vượt quá thời gian timeout |
| 4006 | Resource limit exceeded | Vượt quá giới hạn tài nguyên |
| 5001 | Workflow engine error | Lỗi workflow engine |
| 5002 | External service error | Lỗi dịch vụ bên ngoài |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI API Team
