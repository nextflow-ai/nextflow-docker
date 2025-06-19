# SETUP ZALO CHATBOT VỚI N8N VÀ FLOWISE

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Cấu hình Zalo Official Account](#2-cấu-hình-zalo-official-account)
3. [Setup N8n Workflow](#3-setup-n8n-workflow)
4. [Cấu hình Flowise Chatflow](#4-cấu-hình-flowise-chatflow)
5. [Prompt Templates](#5-prompt-templates)
6. [Customer Service Automation](#6-customer-service-automation)
7. [Testing và Monitoring](#7-testing-và-monitoring)
8. [Troubleshooting](#8-troubleshooting)

## 1. GIỚI THIỆU

Tài liệu này hướng dẫn chi tiết cách setup chatbot Zalo chăm sóc khách hàng tự động sử dụng n8n và Flowise trong hệ thống NextFlow CRM. Chatbot sẽ có khả năng:

- Tự động trả lời câu hỏi thường gặp
- Hỗ trợ thông tin sản phẩm và dịch vụ
- Xử lý yêu cầu hỗ trợ và chuyển tiếp cho nhân viên
- Theo dõi đơn hàng và trạng thái giao hàng
- Thu thập feedback và đánh giá từ khách hàng

### 1.1. Kiến trúc tổng thể

```
[Zalo User] → [Zalo OA API] → [NextFlow Webhook] → [n8n Workflow] → [Flowise AI] → [Response] → [Zalo User]
                                      ↓
                              [NextFlow CRM Database]
```

### 1.2. Yêu cầu hệ thống

- Zalo Official Account đã được phê duyệt
- NextFlow CRM đã cài đặt n8n và Flowise
- API credentials cho Zalo OA
- SSL certificate cho webhook endpoints

## 2. CẤU HÌNH ZALO OFFICIAL ACCOUNT

### 2.1. Tạo Zalo Official Account

1. Truy cập [Zalo Official Account](https://oa.zalo.me/)
2. Đăng ký tài khoản doanh nghiệp
3. Hoàn thành quy trình xác minh
4. Lấy thông tin cần thiết:
   - App ID
   - App Secret
   - Access Token

### 2.2. Cấu hình Webhook

```javascript
// Cấu hình webhook trong NextFlow CRM
const zaloWebhookConfig = {
  webhookUrl: 'https://your-domain.com/api/webhook/zalo/chat',
  events: [
    'user_send_text',
    'user_send_image', 
    'user_send_sticker',
    'user_send_file',
    'user_send_location'
  ],
  verifyToken: 'your_verify_token'
};
```

### 2.3. Đăng ký Webhook với Zalo

```bash
curl -X POST "https://openapi.zalo.me/v2.0/oa/webhook" \
  -H "Content-Type: application/json" \
  -H "access_token: YOUR_ACCESS_TOKEN" \
  -d '{
    "webhook": "https://your-domain.com/api/webhook/zalo/chat",
    "types": ["user_send_text", "user_send_image", "user_send_sticker"]
  }'
```

## 3. SETUP N8N WORKFLOW

### 3.1. Tạo Workflow Cơ bản

1. Đăng nhập vào n8n interface
2. Tạo workflow mới: "Zalo Customer Service Bot"
3. Thêm các node theo thứ tự:

#### Node 1: Webhook Trigger
```json
{
  "httpMethod": "POST",
  "path": "zalo-webhook",
  "authentication": "none",
  "responseMode": "responseNode"
}
```

#### Node 2: Function - Parse Zalo Message
```javascript
// Parse incoming Zalo webhook data
const body = $input.first().json.body;

// Extract message data
const messageData = {
  userId: body.sender.id,
  userName: body.sender.name || 'Khách hàng',
  message: body.message.text || '',
  messageType: body.message.msg_type || 'text',
  timestamp: body.timestamp,
  platform: 'zalo'
};

// Check if this is a valid message
if (!messageData.message && messageData.messageType !== 'text') {
  messageData.message = '[Tin nhắn không phải văn bản]';
}

return [{ json: messageData }];
```

#### Node 3: HTTP Request - Get Customer Info
```json
{
  "method": "GET",
  "url": "https://api.nextflow-crm.com/v1/customers/search",
  "headers": {
    "Authorization": "Bearer {{$env.NEXTFLOW_API_TOKEN}}",
    "Content-Type": "application/json"
  },
  "qs": {
    "zalo_user_id": "={{$json.userId}}"
  }
}
```

### 3.2. Workflow Logic Flow

```
[Webhook] → [Parse Message] → [Get Customer] → [Intent Classification] → [AI Processing] → [Send Response]
                                     ↓
                              [Create/Update Customer]
```

## 4. CẤU HÌNH FLOWISE CHATFLOW

### 4.1. Tạo Chatflow cho Zalo

1. Truy cập Flowise interface
2. Tạo chatflow mới: "Zalo Customer Support"
3. Cấu hình các node:

#### Chat Input Node
```json
{
  "inputKey": "question",
  "description": "Tin nhắn từ khách hàng Zalo"
}
```

#### Prompt Template Node
```
Bạn là trợ lý chăm sóc khách hàng chuyên nghiệp của {company_name} trên Zalo.

THÔNG TIN KHÁCH HÀNG:
- Tên: {customer_name}
- ID: {customer_id}
- Lịch sử mua hàng: {purchase_history}
- Trạng thái: {customer_status}

NGUYÊN TẮC TRẢ LỜI:
1. Luôn lịch sự, thân thiện và chuyên nghiệp
2. Trả lời ngắn gọn, phù hợp với chat Zalo (tối đa 500 ký tự)
3. Sử dụng emoji phù hợp để tạo sự thân thiện
4. Nếu không biết thông tin, hãy hướng dẫn khách hàng liên hệ nhân viên
5. Luôn kết thúc bằng câu hỏi để duy trì cuộc trò chuyện

CÂU HỎI CỦA KHÁCH HÀNG: {question}

Hãy trả lời một cách hữu ích và chuyên nghiệp:
```

#### LLM Node (OpenAI/Anthropic)
```json
{
  "model": "gpt-4",
  "temperature": 0.7,
  "maxTokens": 500,
  "topP": 0.9
}
```

### 4.2. Vector Store cho Knowledge Base

```javascript
// Tạo knowledge base cho sản phẩm/dịch vụ
const knowledgeBase = [
  {
    "category": "sản phẩm",
    "content": "NextFlow CRM có 4 gói dịch vụ: Basic (500k/tháng), Standard (1.5M/tháng), Premium (5M/tháng), Enterprise (tùy chỉnh)"
  },
  {
    "category": "hỗ trợ",
    "content": "Thời gian hỗ trợ: 8h-18h thứ 2-6, 8h-12h thứ 7. Hotline: 1900-xxxx"
  },
  {
    "category": "thanh toán",
    "content": "Hỗ trợ thanh toán qua VNPay, MoMo, chuyển khoản ngân hàng"
  }
];
```

## 5. PROMPT TEMPLATES

### 5.1. System Prompt Chính

```
Bạn là AI Assistant chăm sóc khách hàng của NextFlow CRM trên Zalo.

THÔNG TIN CÔNG TY:
- Tên: NextFlow CRM
- Sản phẩm: Hệ thống CRM tích hợp AI
- Website: https://nextflow.vn
- Hotline: 1900-xxxx

TÍNH CÁCH:
- Thân thiện, nhiệt tình
- Chuyên nghiệp nhưng gần gũi
- Sử dụng emoji phù hợp
- Ngôn ngữ đơn giản, dễ hiểu

KHẢ NĂNG:
✅ Tư vấn sản phẩm và gói dịch vụ
✅ Hỗ trợ kỹ thuật cơ bản
✅ Kiểm tra thông tin đơn hàng
✅ Hướng dẫn sử dụng
✅ Thu thập feedback

❌ Không thể xử lý thanh toán
❌ Không thể thay đổi hợp đồng
❌ Không thể truy cập thông tin nhạy cảm

CÁCH TRẢ LỜI:
1. Chào hỏi thân thiện
2. Hiểu rõ nhu cầu khách hàng
3. Đưa ra giải pháp cụ thể
4. Hỏi thêm để hỗ trợ tốt hơn
5. Kết thúc bằng lời cảm ơn

Hãy trả lời tin nhắn sau đây:
```

### 5.2. Intent-based Prompts

#### Tư vấn sản phẩm
```
Khách hàng đang hỏi về sản phẩm/dịch vụ. Hãy:

1. Giới thiệu ngắn gọn về NextFlow CRM
2. Đề xuất gói phù hợp dựa trên nhu cầu
3. Nêu lợi ích chính
4. Hỏi thêm để tư vấn chính xác

Thông tin gói dịch vụ:
- Basic: 500k/tháng - 3 users, 1000 khách hàng
- Standard: 1.5M/tháng - 10 users, 5000 khách hàng  
- Premium: 5M/tháng - 30 users, 20000 khách hàng
- Enterprise: Tùy chỉnh - Không giới hạn

Câu hỏi: {question}
```

#### Hỗ trợ kỹ thuật
```
Khách hàng gặp vấn đề kỹ thuật. Hãy:

1. Thể hiện sự đồng cảm
2. Hỏi thêm chi tiết về vấn đề
3. Đưa ra hướng dẫn từng bước
4. Nếu phức tạp, hướng dẫn liên hệ support

Các vấn đề thường gặp:
- Đăng nhập: Reset password, clear cache
- Đồng bộ dữ liệu: Kiểm tra kết nối internet
- Tích hợp API: Kiểm tra credentials

Vấn đề: {question}
```

#### Kiểm tra đơn hàng
```
Khách hàng muốn kiểm tra thông tin đơn hàng. Hãy:

1. Yêu cầu mã đơn hàng hoặc email đăng ký
2. Tra cứu thông tin (nếu có quyền)
3. Cung cấp thông tin trạng thái
4. Hướng dẫn các bước tiếp theo

Lưu ý: Chỉ cung cấp thông tin cơ bản, không tiết lộ thông tin nhạy cảm.

Yêu cầu: {question}
```

## 6. CUSTOMER SERVICE AUTOMATION

### 6.1. Workflow Escalation

```javascript
// Logic chuyển tiếp cho nhân viên
function shouldEscalateToHuman(message, context) {
  const escalationKeywords = [
    'khiếu nại', 'không hài lòng', 'muốn hủy', 
    'nói chuyện với người', 'gặp nhân viên',
    'không giải quyết được', 'phức tạp'
  ];
  
  const hasEscalationKeyword = escalationKeywords.some(keyword => 
    message.toLowerCase().includes(keyword)
  );
  
  const isComplexQuery = message.length > 200;
  const isRepeatQuery = context.messageCount > 5;
  
  return hasEscalationKeyword || isComplexQuery || isRepeatQuery;
}
```

### 6.2. Ticket Creation Workflow

```
[Escalation Trigger] → [Create Support Ticket] → [Notify Agent] → [Send Confirmation to Customer]
```

### 6.3. Follow-up Automation

```javascript
// Tự động follow-up sau 24h
const followUpWorkflow = {
  trigger: 'schedule',
  interval: '24h',
  condition: 'ticket_status = "pending"',
  action: 'send_followup_message'
};

const followUpMessage = `
Xin chào {customer_name}! 👋

Chúng tôi muốn kiểm tra xem vấn đề của bạn đã được giải quyết chưa?

Ticket #{ticket_id} - {ticket_subject}

Nếu cần hỗ trợ thêm, vui lòng reply tin nhắn này nhé! 😊

Trân trọng,
NextFlow CRM Support Team
`;
```

## 7. TESTING VÀ MONITORING

### 7.1. Test Cases

#### Test Case 1: Tư vấn sản phẩm
```
Input: "Tôi muốn tìm hiểu về CRM cho công ty 20 nhân viên"
Expected: Giới thiệu gói Standard/Premium, hỏi thêm về nhu cầu cụ thể
```

#### Test Case 2: Hỗ trợ kỹ thuật
```
Input: "Tôi không đăng nhập được vào hệ thống"
Expected: Hướng dẫn reset password, kiểm tra browser
```

#### Test Case 3: Escalation
```
Input: "Tôi muốn khiếu nại về dịch vụ"
Expected: Tạo ticket, thông báo sẽ có nhân viên liên hệ
```

### 7.2. Monitoring Metrics

```javascript
const monitoringMetrics = {
  responseTime: 'avg_response_time < 3s',
  accuracy: 'intent_accuracy > 85%',
  satisfaction: 'customer_rating > 4.0',
  escalationRate: 'escalation_rate < 15%',
  resolutionRate: 'first_contact_resolution > 70%'
};
```

## 8. TROUBLESHOOTING

### 8.1. Vấn đề thường gặp

#### Webhook không nhận được tin nhắn
```bash
# Kiểm tra webhook status
curl -X GET "https://openapi.zalo.me/v2.0/oa/webhook" \
  -H "access_token: YOUR_ACCESS_TOKEN"

# Test webhook endpoint
curl -X POST "https://your-domain.com/api/webhook/zalo/chat" \
  -H "Content-Type: application/json" \
  -d '{"test": "message"}'
```

#### AI không trả lời chính xác
1. Kiểm tra prompt template
2. Cập nhật knowledge base
3. Điều chỉnh temperature parameter
4. Thêm training examples

#### Tin nhắn bị delay
1. Kiểm tra n8n queue status
2. Monitor Flowise response time
3. Optimize database queries
4. Scale infrastructure nếu cần

### 8.2. Logs và Debugging

```javascript
// Enable debug logging
const debugConfig = {
  logLevel: 'debug',
  logWebhooks: true,
  logAIResponses: true,
  logErrors: true,
  logPerformance: true
};
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 1.0.0  
**Tác giả**: NextFlow AI Team
