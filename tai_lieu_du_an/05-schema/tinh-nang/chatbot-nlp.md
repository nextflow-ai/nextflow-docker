# SCHEMA TÍNH NĂNG - CHATBOT VÀ NLP

## 1. GIỚI THIỆU

Schema Chatbot và NLP quản lý thông tin về các chatbot, xử lý ngôn ngữ tự nhiên, hội thoại và các hoạt động liên quan đến trí tuệ nhân tạo trong giao tiếp với khách hàng trong hệ thống NextFlow CRM. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến chatbot và NLP trong hệ thống.

### 1.1. Mục đích

Schema Chatbot và NLP phục vụ các mục đích sau:

- Lưu trữ thông tin về các chatbot và cấu hình
- Quản lý hội thoại và tin nhắn giữa chatbot và người dùng
- Lưu trữ ý định (intent) và thực thể (entity) cho NLP
- Quản lý kịch bản hội thoại và luồng hội thoại
- Theo dõi hiệu suất chatbot và phân tích hội thoại
- Tích hợp với các kênh giao tiếp khác nhau

### 1.2. Các bảng chính

Schema Chatbot và NLP bao gồm các bảng chính sau:

1. `chatbots` - Lưu trữ thông tin về các chatbot
2. `chatbot_channels` - Lưu trữ thông tin về các kênh giao tiếp
3. `chatbot_conversations` - Lưu trữ thông tin về các hội thoại
4. `chatbot_messages` - Lưu trữ thông tin về các tin nhắn
5. `chatbot_intents` - Lưu trữ thông tin về các ý định
6. `chatbot_entities` - Lưu trữ thông tin về các thực thể
7. `chatbot_flows` - Lưu trữ thông tin về các luồng hội thoại

## 2. BẢNG CHATBOTS

### 2.1. Mô tả

Bảng `chatbots` lưu trữ thông tin về các chatbot trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của chatbot |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên chatbot |
| description | text | true | null | Mô tả chatbot |
| avatar_url | varchar(255) | true | null | URL avatar của chatbot |
| type | varchar(50) | false | 'rule_based' | Loại chatbot: rule_based, ai_powered, hybrid |
| status | varchar(20) | false | 'inactive' | Trạng thái: active, inactive, maintenance |
| language | varchar(20) | false | 'vi' | Ngôn ngữ chính: vi, en, etc. |
| nlp_provider | varchar(50) | true | null | Nhà cung cấp NLP: dialogflow, rasa, wit, custom, etc. |
| nlp_config | jsonb | true | null | Cấu hình NLP |
| default_responses | jsonb | true | null | Câu trả lời mặc định |
| welcome_message | text | true | null | Tin nhắn chào mừng |
| fallback_message | text | true | null | Tin nhắn khi không hiểu |
| working_hours | jsonb | true | null | Giờ làm việc |
| timezone | varchar(50) | false | 'Asia/Ho_Chi_Minh' | Múi giờ |
| settings | jsonb | true | null | Cài đặt chatbot |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| chatbots_pkey | PRIMARY KEY | id | Khóa chính |
| chatbots_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên chatbot là duy nhất trong tổ chức |
| chatbots_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| chatbots_type_idx | INDEX | type | Tăng tốc truy vấn theo loại chatbot |
| chatbots_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| chatbots_language_idx | INDEX | language | Tăng tốc truy vấn theo ngôn ngữ |
| chatbots_nlp_provider_idx | INDEX | nlp_provider | Tăng tốc truy vấn theo nhà cung cấp NLP |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| chatbots_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| chatbots_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| chatbots_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| chatbots_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| chatbots_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| chatbots_language_check | CHECK | Đảm bảo language chỉ nhận các giá trị cho phép |
| chatbots_nlp_provider_check | CHECK | Đảm bảo nlp_provider chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "c1h2a3t4-b5o6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "NextFlow Hỗ trợ Khách hàng",
  "description": "Chatbot hỗ trợ khách hàng tự động của NextFlow CRM",
  "avatar_url": "https://assets.NextFlow.com/chatbots/support-bot.png",
  "type": "ai_powered",
  "status": "active",
  "language": "vi",
  "nlp_provider": "dialogflow",
  "nlp_config": {
    "project_id": "NextFlow-support-bot",
    "language_code": "vi",
    "environment": "production",
    "session_ttl": 1800,
    "confidence_threshold": 0.7
  },
  "default_responses": [
    "Xin lỗi, tôi không hiểu ý bạn. Bạn có thể diễn đạt lại được không?",
    "Tôi chưa được đào tạo để trả lời câu hỏi này. Bạn có thể hỏi câu khác không?",
    "Tôi không chắc mình hiểu đúng ý bạn. Bạn có thể nói rõ hơn được không?"
  ],
  "welcome_message": "Xin chào! Tôi là trợ lý ảo của NextFlow CRM. Tôi có thể giúp gì cho bạn hôm nay?",
  "fallback_message": "Xin lỗi, tôi không thể hiểu yêu cầu của bạn. Vui lòng thử lại hoặc liên hệ với nhân viên hỗ trợ của chúng tôi.",
  "working_hours": {
    "monday": {"start": "08:00", "end": "17:30"},
    "tuesday": {"start": "08:00", "end": "17:30"},
    "wednesday": {"start": "08:00", "end": "17:30"},
    "thursday": {"start": "08:00", "end": "17:30"},
    "friday": {"start": "08:00", "end": "17:30"},
    "saturday": {"start": "08:00", "end": "12:00"},
    "sunday": null
  },
  "timezone": "Asia/Ho_Chi_Minh",
  "settings": {
    "handover_to_human": true,
    "handover_threshold": 3,
    "collect_feedback": true,
    "save_conversations": true,
    "conversation_ttl_days": 90,
    "max_message_length": 1000,
    "enable_typing_indicator": true,
    "typing_delay_ms": 500
  },
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-06-15T10:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG CHATBOT_CHANNELS

### 3.1. Mô tả

Bảng `chatbot_channels` lưu trữ thông tin về các kênh giao tiếp của chatbot.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| chatbot_id | uuid | false | | Khóa ngoại tới bảng chatbots |
| name | varchar(100) | false | | Tên kênh |
| type | varchar(50) | false | | Loại kênh: website, facebook, zalo, telegram, etc. |
| status | varchar(20) | false | 'inactive' | Trạng thái: active, inactive |
| config | jsonb | false | | Cấu hình kênh |
| settings | jsonb | true | null | Cài đặt kênh |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| chatbot_channels_pkey | PRIMARY KEY | id | Khóa chính |
| chatbot_channels_chatbot_type_idx | UNIQUE | chatbot_id, type | Đảm bảo mỗi chatbot chỉ có một kênh cho mỗi loại |
| chatbot_channels_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| chatbot_channels_chatbot_id_idx | INDEX | chatbot_id | Tăng tốc truy vấn theo chatbot |
| chatbot_channels_type_idx | INDEX | type | Tăng tốc truy vấn theo loại kênh |
| chatbot_channels_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| chatbot_channels_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| chatbot_channels_chatbot_id_fkey | FOREIGN KEY | Tham chiếu đến bảng chatbots(id) |
| chatbot_channels_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| chatbot_channels_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| chatbot_channels_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| chatbot_channels_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |

### 3.5. Ví dụ JSON

```json
{
  "id": "c1h2a3n4-n5e6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "chatbot_id": "c1h2a3t4-b5o6-7890-abcd-ef1234567890",
  "name": "Website Chat",
  "type": "website",
  "status": "active",
  "config": {
    "widget_id": "NextFlow-chat-widget",
    "position": "bottom-right",
    "theme_color": "#1976d2",
    "secondary_color": "#ffffff",
    "welcome_message": "Xin chào! Tôi có thể giúp gì cho bạn?",
    "domain_whitelist": ["NextFlow.com", "NextFlow.vn"]
  },
  "settings": {
    "auto_open": false,
    "auto_open_delay": 5000,
    "collect_visitor_info": true,
    "required_fields": ["name", "email"],
    "file_upload": {
      "enabled": true,
      "max_size_mb": 5,
      "allowed_types": ["image/jpeg", "image/png", "application/pdf"]
    },
    "custom_css": ".chat-widget { font-family: 'Roboto', sans-serif; }"
  },
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 4. BẢNG CHATBOT_INTENTS

### 4.1. Mô tả

Bảng `chatbot_intents` lưu trữ thông tin về các ý định (intents) của chatbot.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| chatbot_id | uuid | false | | Khóa ngoại tới bảng chatbots |
| name | varchar(100) | false | | Tên ý định |
| description | text | true | null | Mô tả ý định |
| training_phrases | jsonb | false | | Các cụm từ huấn luyện |
| responses | jsonb | false | | Các câu trả lời |
| parameters | jsonb | true | null | Các tham số |
| contexts_in | jsonb | true | null | Ngữ cảnh đầu vào |
| contexts_out | jsonb | true | null | Ngữ cảnh đầu ra |
| priority | integer | false | 0 | Độ ưu tiên |
| is_fallback | boolean | false | false | Đánh dấu là ý định dự phòng |
| is_default_welcome | boolean | false | false | Đánh dấu là ý định chào mừng mặc định |
| is_default_goodbye | boolean | false | false | Đánh dấu là ý định tạm biệt mặc định |
| webhook_enabled | boolean | false | false | Kích hoạt webhook |
| webhook_url | varchar(255) | true | null | URL webhook |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| chatbot_intents_pkey | PRIMARY KEY | id | Khóa chính |
| chatbot_intents_chatbot_name_idx | UNIQUE | chatbot_id, name | Đảm bảo tên ý định là duy nhất cho mỗi chatbot |
| chatbot_intents_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| chatbot_intents_chatbot_id_idx | INDEX | chatbot_id | Tăng tốc truy vấn theo chatbot |
| chatbot_intents_is_fallback_idx | INDEX | is_fallback | Tăng tốc truy vấn theo ý định dự phòng |
| chatbot_intents_is_default_welcome_idx | INDEX | is_default_welcome | Tăng tốc truy vấn theo ý định chào mừng mặc định |
| chatbot_intents_is_default_goodbye_idx | INDEX | is_default_goodbye | Tăng tốc truy vấn theo ý định tạm biệt mặc định |
| chatbot_intents_priority_idx | INDEX | priority | Tăng tốc truy vấn theo độ ưu tiên |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| chatbot_intents_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| chatbot_intents_chatbot_id_fkey | FOREIGN KEY | Tham chiếu đến bảng chatbots(id) |
| chatbot_intents_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| chatbot_intents_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| chatbot_intents_priority_check | CHECK | Đảm bảo priority >= 0 |

### 4.5. Ví dụ JSON

```json
{
  "id": "i1n2t3e4-n5t6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "chatbot_id": "c1h2a3t4-b5o6-7890-abcd-ef1234567890",
  "name": "pricing_inquiry",
  "description": "Xử lý câu hỏi về giá cả và gói dịch vụ",
  "training_phrases": [
    "Giá của NextFlow CRM là bao nhiêu?",
    "Các gói dịch vụ của NextFlow có những gì?",
    "Chi phí sử dụng NextFlow CRM",
    "NextFlow có mấy gói dịch vụ?",
    "Gói cơ bản giá bao nhiêu?",
    "Gói premium có những tính năng gì?",
    "Tôi muốn biết giá các gói dịch vụ",
    "Cho tôi biết về bảng giá của NextFlow"
  ],
  "responses": [
    "NextFlow CRM có 3 gói dịch vụ chính:\n\n1. Gói Cơ bản: 500.000đ/tháng\n2. Gói Nâng cao: 1.500.000đ/tháng\n3. Gói Premium: 5.000.000đ/tháng\n\nMỗi gói có các tính năng khác nhau. Bạn muốn tìm hiểu chi tiết về gói nào?",
    "Chúng tôi cung cấp 3 gói dịch vụ với mức giá từ 500.000đ đến 5.000.000đ mỗi tháng. Bạn có thể xem chi tiết tại https://NextFlow.com/pricing. Bạn quan tâm đến gói nào?"
  ],
  "parameters": [
    {
      "name": "package",
      "entity_type": "package",
      "required": false,
      "prompts": ["Bạn muốn biết thông tin về gói nào?"]
    }
  ],
  "contexts_in": ["welcome", "service_inquiry"],
  "contexts_out": ["pricing_provided", "awaiting_package_selection"],
  "priority": 5,
  "is_fallback": false,
  "is_default_welcome": false,
  "is_default_goodbye": false,
  "webhook_enabled": true,
  "webhook_url": "https://api.NextFlow.com/webhooks/chatbot/pricing",
  "created_at": "2023-01-15T09:00:00Z",
  "updated_at": "2023-06-01T10:30:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
