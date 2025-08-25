# SCHEMA TÍNH NĂNG - TỔNG ĐÀI

## 1. GIỚI THIỆU

Schema Tổng đài quản lý thông tin về các cuộc gọi, chiến dịch telesales, và tương tác qua điện thoại trong hệ thống NextFlow CRM-AI. Tài liệu này mô tả chi tiết cấu trúc dữ liệu của các bảng liên quan đến tổng đài trong hệ thống.

### 1.1. Mục đích

Schema Tổng đài phục vụ các mục đích sau:

- Lưu trữ thông tin về các cuộc gọi đi và đến
- Quản lý chiến dịch telesales
- Theo dõi hiệu suất của agent
- Phân tích nội dung cuộc gọi
- Tích hợp với hệ thống điện thoại
- Hỗ trợ chăm sóc khách hàng qua điện thoại

### 1.2. Các bảng chính

Schema Tổng đài bao gồm các bảng chính sau:

1. `call_centers` - Lưu trữ thông tin về các tổng đài
2. `calls` - Lưu trữ thông tin về các cuộc gọi
3. `call_recordings` - Lưu trữ thông tin về bản ghi âm cuộc gọi
4. `call_agents` - Lưu trữ thông tin về agent tổng đài
5. `call_queues` - Lưu trữ thông tin về hàng đợi cuộc gọi
6. `call_campaigns` - Lưu trữ thông tin về chiến dịch gọi
7. `call_scripts` - Lưu trữ thông tin về kịch bản cuộc gọi
8. `call_dispositions` - Lưu trữ thông tin về kết quả cuộc gọi

## 2. BẢNG CALL_CENTERS

### 2.1. Mô tả

Bảng `call_centers` lưu trữ thông tin về các tổng đài trong hệ thống.

### 2.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính, định danh duy nhất của tổng đài |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations, xác định tổ chức sở hữu |
| name | varchar(100) | false | | Tên tổng đài |
| description | text | true | null | Mô tả tổng đài |
| type | varchar(50) | false | 'virtual_pbx' | Loại tổng đài: virtual_pbx, cloud_call_center, etc. |
| provider | varchar(100) | true | null | Nhà cung cấp dịch vụ tổng đài |
| provider_account_id | varchar(100) | true | null | ID tài khoản với nhà cung cấp |
| status | varchar(20) | false | 'active' | Trạng thái: active, inactive, maintenance |
| settings | jsonb | true | null | Cài đặt tổng đài |
| config | jsonb | true | null | Cấu hình tổng đài |
| credentials | jsonb | true | null | Thông tin xác thực (được mã hóa) |
| business_hours | jsonb | true | null | Giờ làm việc |
| timezone | varchar(50) | false | 'Asia/Ho_Chi_Minh' | Múi giờ |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 2.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| call_centers_pkey | PRIMARY KEY | id | Khóa chính |
| call_centers_organization_name_idx | UNIQUE | organization_id, name | Đảm bảo tên tổng đài là duy nhất trong tổ chức |
| call_centers_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| call_centers_type_idx | INDEX | type | Tăng tốc truy vấn theo loại tổng đài |
| call_centers_provider_idx | INDEX | provider | Tăng tốc truy vấn theo nhà cung cấp |
| call_centers_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |

### 2.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| call_centers_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| call_centers_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| call_centers_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| call_centers_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| call_centers_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |

### 2.5. Ví dụ JSON

```json
{
  "id": "c1a2l3l4-c5e6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "name": "Tổng đài Chăm sóc Khách hàng",
  "description": "Tổng đài chăm sóc khách hàng và hỗ trợ bán hàng",
  "type": "virtual_pbx",
  "provider": "VoIP24h",
  "provider_account_id": "ACC123456",
  "status": "active",
  "settings": {
    "max_concurrent_calls": 50,
    "call_recording": true,
    "call_monitoring": true,
    "voicemail_enabled": true,
    "auto_attendant": true,
    "call_analytics": true
  },
  "config": {
    "sip_server": "sip.voip24h.vn",
    "sip_port": 5060,
    "outbound_proxy": "proxy.voip24h.vn",
    "nat_traversal": "stun",
    "codecs": ["G.711", "G.729", "OPUS"]
  },
  "credentials": {
    "api_key": "encrypted:abcdefghijklmnopqrstuvwxyz",
    "api_secret": "encrypted:123456789abcdefghijklmnopqrstuvwxyz"
  },
  "business_hours": {
    "monday": {"start": "08:00", "end": "17:30"},
    "tuesday": {"start": "08:00", "end": "17:30"},
    "wednesday": {"start": "08:00", "end": "17:30"},
    "thursday": {"start": "08:00", "end": "17:30"},
    "friday": {"start": "08:00", "end": "17:30"},
    "saturday": {"start": "08:00", "end": "12:00"},
    "sunday": null
  },
  "timezone": "Asia/Ho_Chi_Minh",
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2023-01-01T00:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## 3. BẢNG CALLS

### 3.1. Mô tả

Bảng `calls` lưu trữ thông tin về các cuộc gọi trong hệ thống.

### 3.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| call_center_id | uuid | false | | Khóa ngoại tới bảng call_centers |
| call_id | varchar(100) | false | | ID cuộc gọi từ nhà cung cấp |
| direction | varchar(20) | false | | Hướng cuộc gọi: inbound, outbound |
| type | varchar(50) | false | 'voice' | Loại cuộc gọi: voice, video, etc. |
| from_number | varchar(20) | false | | Số điện thoại gọi đi |
| to_number | varchar(20) | false | | Số điện thoại gọi đến |
| from_name | varchar(100) | true | null | Tên người gọi |
| to_name | varchar(100) | true | null | Tên người nhận |
| status | varchar(20) | false | | Trạng thái: ringing, in_progress, completed, missed, failed, etc. |
| start_time | timestamp | true | null | Thời gian bắt đầu cuộc gọi |
| answer_time | timestamp | true | null | Thời gian trả lời cuộc gọi |
| end_time | timestamp | true | null | Thời gian kết thúc cuộc gọi |
| duration | integer | true | null | Thời lượng cuộc gọi (giây) |
| talk_time | integer | true | null | Thời gian nói chuyện (giây) |
| wait_time | integer | true | null | Thời gian chờ (giây) |
| agent_id | uuid | true | null | Khóa ngoại tới bảng call_agents |
| queue_id | uuid | true | null | Khóa ngoại tới bảng call_queues |
| campaign_id | uuid | true | null | Khóa ngoại tới bảng call_campaigns |
| customer_id | uuid | true | null | Khóa ngoại tới bảng customers |
| contact_id | uuid | true | null | Khóa ngoại tới bảng contacts |
| disposition_id | uuid | true | null | Khóa ngoại tới bảng call_dispositions |
| disposition_notes | text | true | null | Ghi chú kết quả cuộc gọi |
| recording_id | uuid | true | null | Khóa ngoại tới bảng call_recordings |
| recording_url | varchar(255) | true | null | URL bản ghi âm |
| call_data | jsonb | true | null | Dữ liệu cuộc gọi bổ sung |
| tags | jsonb | true | null | Thẻ cuộc gọi |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |

### 3.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| calls_pkey | PRIMARY KEY | id | Khóa chính |
| calls_organization_call_id_idx | UNIQUE | organization_id, call_id | Đảm bảo ID cuộc gọi là duy nhất trong tổ chức |
| calls_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| calls_call_center_id_idx | INDEX | call_center_id | Tăng tốc truy vấn theo tổng đài |
| calls_direction_idx | INDEX | direction | Tăng tốc truy vấn theo hướng cuộc gọi |
| calls_type_idx | INDEX | type | Tăng tốc truy vấn theo loại cuộc gọi |
| calls_from_number_idx | INDEX | from_number | Tăng tốc truy vấn theo số gọi đi |
| calls_to_number_idx | INDEX | to_number | Tăng tốc truy vấn theo số gọi đến |
| calls_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |
| calls_start_time_idx | INDEX | start_time | Tăng tốc truy vấn theo thời gian bắt đầu |
| calls_agent_id_idx | INDEX | agent_id | Tăng tốc truy vấn theo agent |
| calls_queue_id_idx | INDEX | queue_id | Tăng tốc truy vấn theo hàng đợi |
| calls_campaign_id_idx | INDEX | campaign_id | Tăng tốc truy vấn theo chiến dịch |
| calls_customer_id_idx | INDEX | customer_id | Tăng tốc truy vấn theo khách hàng |
| calls_contact_id_idx | INDEX | contact_id | Tăng tốc truy vấn theo liên hệ |
| calls_disposition_id_idx | INDEX | disposition_id | Tăng tốc truy vấn theo kết quả |

### 3.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| calls_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| calls_call_center_id_fkey | FOREIGN KEY | Tham chiếu đến bảng call_centers(id) |
| calls_agent_id_fkey | FOREIGN KEY | Tham chiếu đến bảng call_agents(id) |
| calls_queue_id_fkey | FOREIGN KEY | Tham chiếu đến bảng call_queues(id) |
| calls_campaign_id_fkey | FOREIGN KEY | Tham chiếu đến bảng call_campaigns(id) |
| calls_customer_id_fkey | FOREIGN KEY | Tham chiếu đến bảng customers(id) |
| calls_contact_id_fkey | FOREIGN KEY | Tham chiếu đến bảng contacts(id) |
| calls_disposition_id_fkey | FOREIGN KEY | Tham chiếu đến bảng call_dispositions(id) |
| calls_recording_id_fkey | FOREIGN KEY | Tham chiếu đến bảng call_recordings(id) |
| calls_direction_check | CHECK | Đảm bảo direction chỉ nhận các giá trị cho phép |
| calls_type_check | CHECK | Đảm bảo type chỉ nhận các giá trị cho phép |
| calls_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| calls_duration_check | CHECK | Đảm bảo duration >= 0 khi không null |
| calls_talk_time_check | CHECK | Đảm bảo talk_time >= 0 khi không null |
| calls_wait_time_check | CHECK | Đảm bảo wait_time >= 0 khi không null |

### 3.5. Ví dụ JSON

```json
{
  "id": "c1a2l3l4-i5d6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "call_center_id": "c1a2l3l4-c5e6-7890-abcd-ef1234567890",
  "call_id": "CALL-2023-0001",
  "direction": "outbound",
  "type": "voice",
  "from_number": "+84901234567",
  "to_number": "+84987654321",
  "from_name": "Nguyễn Văn A (Agent)",
  "to_name": "Trần Văn B (Khách hàng)",
  "status": "completed",
  "start_time": "2023-07-15T10:00:00Z",
  "answer_time": "2023-07-15T10:00:05Z",
  "end_time": "2023-07-15T10:05:30Z",
  "duration": 330,
  "talk_time": 325,
  "wait_time": 5,
  "agent_id": "a1g2e3n4-t5i6-7890-abcd-ef1234567890",
  "queue_id": "q1u2e3u4-e5i6-7890-abcd-ef1234567890",
  "campaign_id": "c1a2m3p4-a5i6-7890-abcd-ef1234567890",
  "customer_id": "c1u2s3t4-o5m6-7890-abcd-ef1234567890",
  "contact_id": "c1o2n3t4-a5c6-7890-abcd-ef1234567890",
  "disposition_id": "d1i2s3p4-o5s6-7890-abcd-ef1234567890",
  "disposition_notes": "Khách hàng quan tâm đến sản phẩm, hẹn gọi lại vào tuần sau để tư vấn chi tiết",
  "recording_id": "r1e2c3o4-r5d6-7890-abcd-ef1234567890",
  "recording_url": "https://storage.NextFlow.com/call-recordings/2023/07/15/CALL-2023-0001.mp3",
  "call_data": {
    "ivr_path": "sales > product_info",
    "transfer_count": 0,
    "call_quality": 4.5,
    "network_quality": "good",
    "device_info": "SIP Phone (Yealink T53W)"
  },
  "tags": ["sales", "product_inquiry", "follow_up"],
  "created_at": "2023-07-15T10:00:00Z",
  "updated_at": "2023-07-15T10:05:35Z"
}
```

## 4. BẢNG CALL_AGENTS

### 4.1. Mô tả

Bảng `call_agents` lưu trữ thông tin về các agent tổng đài trong hệ thống.

### 4.2. Cấu trúc

| Tên cột | Kiểu dữ liệu | Nullable | Mặc định | Mô tả |
|---------|--------------|----------|----------|-------|
| id | uuid | false | gen_random_uuid() | Khóa chính |
| organization_id | uuid | false | | Khóa ngoại tới bảng organizations |
| call_center_id | uuid | false | | Khóa ngoại tới bảng call_centers |
| user_id | uuid | false | | Khóa ngoại tới bảng users |
| agent_code | varchar(50) | false | | Mã agent |
| extension | varchar(20) | true | null | Số máy nhánh |
| status | varchar(20) | false | 'offline' | Trạng thái: online, offline, busy, break, etc. |
| skills | jsonb | true | null | Kỹ năng của agent |
| max_concurrent_calls | integer | false | 1 | Số cuộc gọi đồng thời tối đa |
| current_calls | integer | false | 0 | Số cuộc gọi hiện tại |
| settings | jsonb | true | null | Cài đặt agent |
| last_status_change | timestamp | true | null | Thời gian thay đổi trạng thái gần nhất |
| created_at | timestamp | false | now() | Thời gian tạo bản ghi |
| updated_at | timestamp | false | now() | Thời gian cập nhật bản ghi |
| deleted_at | timestamp | true | null | Thời gian xóa bản ghi (soft delete) |
| created_by | uuid | true | null | ID người tạo |
| updated_by | uuid | true | null | ID người cập nhật |

### 4.3. Chỉ mục

| Tên chỉ mục | Loại | Cột | Mô tả |
|-------------|------|-----|-------|
| call_agents_pkey | PRIMARY KEY | id | Khóa chính |
| call_agents_organization_agent_code_idx | UNIQUE | organization_id, agent_code | Đảm bảo mã agent là duy nhất trong tổ chức |
| call_agents_call_center_user_idx | UNIQUE | call_center_id, user_id | Đảm bảo mỗi user chỉ là một agent trong một tổng đài |
| call_agents_organization_id_idx | INDEX | organization_id | Tăng tốc truy vấn theo tổ chức |
| call_agents_call_center_id_idx | INDEX | call_center_id | Tăng tốc truy vấn theo tổng đài |
| call_agents_user_id_idx | INDEX | user_id | Tăng tốc truy vấn theo người dùng |
| call_agents_status_idx | INDEX | status | Tăng tốc truy vấn theo trạng thái |

### 4.4. Ràng buộc

| Tên ràng buộc | Loại | Mô tả |
|---------------|------|-------|
| call_agents_organization_id_fkey | FOREIGN KEY | Tham chiếu đến bảng organizations(id) |
| call_agents_call_center_id_fkey | FOREIGN KEY | Tham chiếu đến bảng call_centers(id) |
| call_agents_user_id_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| call_agents_created_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| call_agents_updated_by_fkey | FOREIGN KEY | Tham chiếu đến bảng users(id) |
| call_agents_status_check | CHECK | Đảm bảo status chỉ nhận các giá trị cho phép |
| call_agents_max_concurrent_calls_check | CHECK | Đảm bảo max_concurrent_calls > 0 |
| call_agents_current_calls_check | CHECK | Đảm bảo current_calls >= 0 |

### 4.5. Ví dụ JSON

```json
{
  "id": "a1g2e3n4-t5i6-7890-abcd-ef1234567890",
  "organization_id": "o1p2q3r4-s5t6-7890-uvwx-yz1234567890",
  "call_center_id": "c1a2l3l4-c5e6-7890-abcd-ef1234567890",
  "user_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "agent_code": "AGT-001",
  "extension": "101",
  "status": "online",
  "skills": [
    {"name": "sales", "level": 5},
    {"name": "technical_support", "level": 3},
    {"name": "customer_service", "level": 4},
    {"name": "english", "level": 4}
  ],
  "max_concurrent_calls": 2,
  "current_calls": 1,
  "settings": {
    "auto_answer": true,
    "wrap_up_time": 30,
    "call_recording": true,
    "outbound_caller_id": "+84901234567",
    "notifications": {
      "desktop": true,
      "sound": true,
      "email": false
    }
  },
  "last_status_change": "2023-07-15T08:00:00Z",
  "created_at": "2023-01-15T00:00:00Z",
  "updated_at": "2023-07-15T08:00:00Z",
  "deleted_at": null,
  "created_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "updated_by": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```
