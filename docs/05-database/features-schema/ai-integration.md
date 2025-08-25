# SCHEMA TÍNH NĂNG - TÍCH HỢP AI

## 1. GIỚI THIỆU

Schema Tích hợp AI quản lý thông tin về các tích hợp AI, workflow tự động, chatbot và các cấu hình liên quan trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến tích hợp AI trong hệ thống.

### 1.1. Mục đích

Schema Tích hợp AI phục vụ các mục đích sau:

- Lưu trữ thông tin cấu hình tích hợp AI
- Quản lý workflow tự động với n8n
- Quản lý chatbot với Flowise
- Lưu trữ lịch sử tương tác AI
- Quản lý mô hình AI và vector database
- Theo dõi hiệu suất và sử dụng AI

### 1.2. Các bảng chính

Schema Tích hợp AI bao gồm các bảng chính sau:

1. `ai_integrations` - Lưu trữ thông tin cấu hình tích hợp AI
2. `ai_providers` - Lưu trữ thông tin nhà cung cấp dịch vụ AI
3. `n8n_workflows` - Lưu trữ thông tin workflow n8n
4. `flowise_chatflows` - Lưu trữ thông tin chatflow Flowise
5. `ai_chat_sessions` - Lưu trữ thông tin phiên chat AI
6. `ai_chat_messages` - Lưu trữ thông tin tin nhắn chat AI
7. `ai_usage_logs` - Lưu trữ thông tin sử dụng AI
8. `ai_vector_stores` - Lưu trữ thông tin vector database

## 2. BẢNG AI_INTEGRATIONS

### 2.1. Mô tả

Bảng `ai_integrations` lưu trữ thông tin cấu hình tích hợp AI cho từng tổ chức trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của tích hợp AI |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên tích hợp |
| description | text | true | null | Mô tả tích hợp |
| type | enum | false | | Loại tích hợp: n8n, flowise, openai, gemini, etc. |
| status | enum | false | 'active' | Trạng thái: active, inactive, error |
| config | jsonb | false | | Cấu hình tích hợp |
| credentials | jsonb | true | null | Thông tin xác thực (được mã hóa) |
| base_url | varchar(255) | true | null | URL cơ sở của dịch vụ |
| webhook_url | varchar(255) | true | null | URL webhook |
| rate_limit | integer | true | null | Giới hạn số lượng request |
| usage_quota | integer | true | null | Hạn mức sử dụng |
| usage_count | integer | false | 0 | Số lần đã sử dụng |
| last_used_at | timestamp | true | null | Thời gian sử dụng gần nhất |
| error_message | text | true | null | Thông báo lỗi gần nhất |
| metadata | jsonb | true | null | Dữ liệu bổ sung |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| ai_integrations_pkey | PRIMARY KEY | id | Khóa chính |
| ai_integrations_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên tích hợp là duy nhất trong tổ chức |
| ai_integrations_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| ai_integrations_type_idx | INDEX | type | Tăng tốc truy vấn theo loại tích hợp |
| ai_integrations_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| ai_integrations_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| ai_integrations_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| ai_integrations_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| ai_integrations_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| ai_integrations_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "a1i2i3n4-t5e6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "OpenAI Integration",
  "description": "Tích hợp OpenAI API cho chatbot và tạo nội dung",
  "type": "openai",
  "status": "active",
  "config": {
    "model": "gpt-4",
    "temperature": 0.7,
    "max_tokens": 2000,
    "top_p": 1,
    "frequency_penalty": 0,
    "presence_penalty": 0
  },
  "credentials": {
    "api_key": "encrypted:abcdefghijklmnopqrstuvwxyz"
  },
  "base_url": "https://api.openai.com/v1",
  "webhook_url": null,
  "rate_limit": 3000,
  "usage_quota": 100000,
  "usage_count": 1250,
  "last_used_at": "2023-06-20T15:30:00Z",
  "error_message": null,
  "metadata": {
    "supported_features": ["chat", "completion", "embedding", "image_generation"]
  },
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-06-20T15:30:00Z",
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG AI_PROVIDERS

### 3.1. Mô tả

Bảng `ai_providers` lưu trữ thông tin về các nhà cung cấp dịch vụ AI được hỗ trợ trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| code | varchar(50) | false | | Mã nhà cung cấp |
| name | varchar(100) | false | | Tên nhà cung cấp |
| description | text | true | null | Mô tả nhà cung cấp |
| website | varchar(255) | true | null | Website của nhà cung cấp |
| logo_url | varchar(255) | true | null | URL logo của nhà cung cấp |
| api_base_url | varchar(255) | true | null | URL cơ sở API mặc định |
| documentation_url | varchar(255) | true | null | URL tài liệu API |
| features | jsonb | true | null | Tính năng được hỗ trợ |
| models | jsonb | true | null | Danh sách mô hình được hỗ trợ |
| pricing | jsonb | true | null | Thông tin giá |
| auth_type | varchar(50) | false | 'api_key' | Loại xác thực: api_key, oauth, etc. |
| is_active | boolean | false | true | Trạng thái kích hoạt |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| ai_providers_pkey | PRIMARY KEY | id | Khóa chính |
| ai_providers_code_idx | UNIQUE | code | Đảm bảo mã nhà cung cấp là duy nhất |
| ai_providers_name_idx | INDEX | name | Tăng tốc truy vấn theo tên |
| ai_providers_is_active_idx | INDEX | is_active | Tăng tốc truy vấn theo trạng thái kích hoạt |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| ai_providers_auth_type_check | CHECK | Đảm bảo auth_type chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "p1r2o3v4-i5d6-7890-abcd-ef1234567890",
  "code": "openai",
  "name": "OpenAI",
  "description": "OpenAI cung cấp các API cho mô hình ngôn ngữ lớn như GPT-4, GPT-3.5 và các mô hình khác.",
  "website": "https://openai.com",
  "logo_url": "https://assets.NextFlow.com/ai_providers/openai.png",
  "api_base_url": "https://api.openai.com/v1",
  "documentation_url": "https://platform.openai.com/docs/api-reference",
  "features": [
    "chat_completion",
    "text_completion",
    "embeddings",
    "image_generation",
    "audio_transcription",
    "fine_tuning"
  ],
  "models": [
    {
      "id": "gpt-4",
      "name": "GPT-4",
      "type": "chat",
      "context_length": 8192,
      "is_default": true
    },
    {
      "id": "gpt-3.5-turbo",
      "name": "GPT-3.5 Turbo",
      "type": "chat",
      "context_length": 4096,
      "is_default": false
    }
  ],
  "pricing": {
    "gpt-4": {
      "input": 0.03,
      "output": 0.06,
      "unit": "1K tokens",
      "currency": "USD"
    },
    "gpt-3.5-turbo": {
      "input": 0.0015,
      "output": 0.002,
      "unit": "1K tokens",
      "currency": "USD"
    }
  },
  "auth_type": "api_key",
  "is_active": true,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-06-01T00:00:00Z"
}
```

## 4. BẢNG N8N_WORKFLOWS

### 4.1. Mô tả

Bảng `n8n_workflows` lưu trữ thông tin về các workflow n8n được cấu hình trong hệ thống.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| integration_id | uuid | false | | Khóa ngoại tới bảng ai_integrations |
| name | varchar(100) | false | | Tên workflow |
| description | text | true | null | Mô tả workflow |
| n8n_workflow_id | varchar(100) | true | null | ID workflow trong n8n |
| workflow_data | jsonb | true | null | Dữ liệu workflow |
| status | enum | false | 'active' | Trạng thái: active, inactive, error |
| category | varchar(50) | true | null | Danh mục workflow |
| tags | jsonb | true | null | Thẻ workflow |
| trigger_type | varchar(50) | false | 'manual' | Loại trigger: manual, webhook, schedule, event |
| trigger_config | jsonb | true | null | Cấu hình trigger |
| execution_mode | varchar(50) | false | 'regular' | Chế độ thực thi: regular, queue |
| timeout | integer | true | null | Thời gian timeout (giây) |
| retries | integer | false | 0 | Số lần thử lại |
| last_executed_at | timestamp | true | null | Thời gian thực thi gần nhất |
| last_execution_status | varchar(50) | true | null | Trạng thái thực thi gần nhất |
| execution_count | integer | false | 0 | Số lần đã thực thi |
| error_message | text | true | null | Thông báo lỗi gần nhất |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |
