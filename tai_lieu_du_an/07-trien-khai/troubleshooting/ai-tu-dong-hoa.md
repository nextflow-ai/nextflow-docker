# TROUBLESHOOTING - AI VÀ TỰ ĐỘNG HÓA

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn khắc phục sự cố liên quan đến AI và tự động hóa trong hệ thống NextFlow CRM. Các vấn đề AI và tự động hóa có thể bao gồm lỗi kết nối n8n, lỗi kết nối Flowise, lỗi workflow, lỗi chatbot, và các vấn đề AI khác.

## 2. VẤN ĐỀ TÍCH HỢP N8N

### 2.1. Lỗi kết nối n8n

#### Triệu chứng
- Không thể kết nối đến n8n
- Timeout khi gọi API n8n
- Lỗi "Connection refused" hoặc "Connection timeout"

#### Nguyên nhân có thể
1. n8n không chạy
2. Thông tin kết nối không chính xác
3. Tường lửa chặn kết nối
4. Vấn đề mạng
5. Lỗi SSL/TLS

#### Giải pháp

##### 2.1.1. Kiểm tra n8n đang chạy

```bash
# Kiểm tra container n8n
docker ps | grep n8n

# Kiểm tra logs n8n
docker logs NextFlow-n8n
```

Nếu n8n không chạy, khởi động lại:

```bash
# Khởi động lại n8n
cd /opt/NextFlow/n8n
docker-compose restart
```

##### 2.1.2. Kiểm tra thông tin kết nối

Xác minh thông tin kết nối trong file `.env`:

```
N8N_URL=https://n8n.yourdomain.com
N8N_API_KEY=your_n8n_api_key
```

Thử kết nối trực tiếp đến n8n:

```bash
curl -v -H "X-N8N-API-KEY: your_n8n_api_key" https://n8n.yourdomain.com/api/v1/workflows
```

##### 2.1.3. Kiểm tra cấu hình n8n

Kiểm tra cấu hình n8n trong file `docker-compose.yml`:

```yaml
environment:
  - N8N_BASIC_AUTH_ACTIVE=true
  - N8N_BASIC_AUTH_USER=admin
  - N8N_BASIC_AUTH_PASSWORD=your_secure_password
  - N8N_HOST=n8n.yourdomain.com
  - N8N_PORT=5678
  - N8N_PROTOCOL=https
  - N8N_ENCRYPTION_KEY=your_encryption_key
```

### 2.2. Lỗi workflow n8n

#### Triệu chứng
- Workflow không chạy
- Workflow bị lỗi
- Workflow không hoàn thành

#### Nguyên nhân có thể
1. Lỗi cấu hình workflow
2. Lỗi kết nối đến dịch vụ bên ngoài
3. Lỗi xử lý dữ liệu
4. Lỗi xác thực
5. Timeout

#### Giải pháp

##### 2.2.1. Kiểm tra logs workflow

Đăng nhập vào n8n và kiểm tra logs workflow:

1. Truy cập **Executions**
2. Tìm workflow bị lỗi
3. Xem logs chi tiết

##### 2.2.2. Kiểm tra cấu hình workflow

Kiểm tra cấu hình workflow trong n8n:

1. Truy cập **Workflows**
2. Mở workflow cần kiểm tra
3. Kiểm tra từng node

##### 2.2.3. Kiểm tra kết nối đến dịch vụ bên ngoài

```bash
# Kiểm tra kết nối đến dịch vụ bên ngoài
curl -v https://api.example.com/endpoint
```

##### 2.2.4. Chạy workflow thủ công

1. Truy cập **Workflows**
2. Mở workflow cần chạy
3. Nhấp vào **Execute Workflow**

### 2.3. Lỗi webhook n8n

#### Triệu chứng
- Webhook không được kích hoạt
- Webhook không nhận được dữ liệu
- Workflow không chạy khi webhook được gọi

#### Nguyên nhân có thể
1. URL webhook không chính xác
2. Webhook không được kích hoạt
3. Lỗi xác thực webhook
4. Lỗi xử lý dữ liệu
5. Tường lửa chặn webhook

#### Giải pháp

##### 2.3.1. Kiểm tra URL webhook

Xác minh URL webhook trong n8n:

1. Truy cập **Workflows**
2. Mở workflow có webhook
3. Kiểm tra node Webhook
4. Sao chép URL webhook

Thử gọi webhook trực tiếp:

```bash
curl -v -X POST \
  -H "Content-Type: application/json" \
  -d '{"key":"value"}' \
  https://n8n.yourdomain.com/webhook/path
```

##### 2.3.2. Kiểm tra webhook đang hoạt động

1. Truy cập **Workflows**
2. Kiểm tra trạng thái workflow (active/inactive)
3. Kích hoạt workflow nếu cần

##### 2.3.3. Kiểm tra logs webhook

```bash
# Kiểm tra logs n8n
docker logs NextFlow-n8n | grep webhook
```

## 3. VẤN ĐỀ TÍCH HỢP FLOWISE

### 3.1. Lỗi kết nối Flowise

#### Triệu chứng
- Không thể kết nối đến Flowise
- Timeout khi gọi API Flowise
- Lỗi "Connection refused" hoặc "Connection timeout"

#### Nguyên nhân có thể
1. Flowise không chạy
2. Thông tin kết nối không chính xác
3. Tường lửa chặn kết nối
4. Vấn đề mạng
5. Lỗi SSL/TLS

#### Giải pháp

##### 3.1.1. Kiểm tra Flowise đang chạy

```bash
# Kiểm tra container Flowise
docker ps | grep flowise

# Kiểm tra logs Flowise
docker logs NextFlow-flowise
```

Nếu Flowise không chạy, khởi động lại:

```bash
# Khởi động lại Flowise
cd /opt/NextFlow/flowise
docker-compose restart
```

##### 3.1.2. Kiểm tra thông tin kết nối

Xác minh thông tin kết nối trong file `.env`:

```
FLOWISE_URL=https://flowise.yourdomain.com
FLOWISE_API_KEY=your_flowise_api_key
```

Thử kết nối trực tiếp đến Flowise:

```bash
curl -v -H "Authorization: Bearer your_flowise_api_key" https://flowise.yourdomain.com/api/v1/chatflows
```

##### 3.1.3. Kiểm tra cấu hình Flowise

Kiểm tra cấu hình Flowise trong file `docker-compose.yml`:

```yaml
environment:
  - PORT=3000
  - FLOWISE_USERNAME=admin
  - FLOWISE_PASSWORD=your_secure_password
  - APIKEY_PATH=/app/apikeys
  - SECRETKEY_PATH=/app/secrets
  - DATABASE_PATH=/app/database
  - FLOWISE_SECRETKEY_OVERWRITE=your_secret_key
```

### 3.2. Lỗi chatflow Flowise

#### Triệu chứng
- Chatflow không hoạt động
- Chatbot không phản hồi
- Chatbot phản hồi không chính xác

#### Nguyên nhân có thể
1. Lỗi cấu hình chatflow
2. Lỗi kết nối đến LLM
3. Lỗi cơ sở kiến thức
4. Lỗi xử lý dữ liệu
5. Giới hạn API LLM bị vượt quá

#### Giải pháp

##### 3.2.1. Kiểm tra cấu hình chatflow

Đăng nhập vào Flowise và kiểm tra cấu hình chatflow:

1. Truy cập **Chatflows**
2. Mở chatflow cần kiểm tra
3. Kiểm tra từng node

##### 3.2.2. Kiểm tra kết nối đến LLM

Kiểm tra cấu hình LLM trong Flowise:

1. Truy cập **Credentials**
2. Kiểm tra thông tin xác thực LLM (OpenAI, Google, v.v.)

Thử kết nối trực tiếp đến LLM:

```bash
# Kiểm tra kết nối đến OpenAI
curl -v -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_openai_api_key" \
  -d '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"Hello"}]}' \
  https://api.openai.com/v1/chat/completions
```

##### 3.2.3. Kiểm tra cơ sở kiến thức

Kiểm tra cơ sở kiến thức trong Flowise:

1. Truy cập **Knowledge**
2. Kiểm tra tài liệu đã tải lên
3. Kiểm tra vector store

##### 3.2.4. Kiểm tra logs Flowise

```bash
# Kiểm tra logs Flowise
docker logs NextFlow-flowise
```

### 3.3. Lỗi API Flowise

#### Triệu chứng
- Lỗi khi gọi API Flowise
- Timeout khi gọi API Flowise
- Lỗi xác thực API Flowise

#### Nguyên nhân có thể
1. API key không chính xác
2. Định dạng yêu cầu không đúng
3. Lỗi xử lý dữ liệu
4. Giới hạn API bị vượt quá
5. Lỗi trong chatflow

#### Giải pháp

##### 3.3.1. Kiểm tra API key

Xác minh API key trong file `.env`:

```
FLOWISE_API_KEY=your_flowise_api_key
```

##### 3.3.2. Kiểm tra định dạng yêu cầu

```bash
# Kiểm tra định dạng yêu cầu
curl -v -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_flowise_api_key" \
  -d '{"question":"Hello","chatId":"123","overrideConfig":{}}' \
  https://flowise.yourdomain.com/api/v1/prediction/chatflow_id
```

##### 3.3.3. Kiểm tra logs API

```bash
# Kiểm tra logs Flowise
docker logs NextFlow-flowise | grep api
```

## 4. VẤN ĐỀ TÍCH HỢP LLM

### 4.1. Lỗi kết nối LLM

#### Triệu chứng
- Không thể kết nối đến LLM
- Timeout khi gọi API LLM
- Lỗi "Connection refused" hoặc "Connection timeout"

#### Nguyên nhân có thể
1. API LLM không khả dụng
2. API key không chính xác
3. Giới hạn API bị vượt quá
4. Vấn đề mạng
5. Lỗi SSL/TLS

#### Giải pháp

##### 4.1.1. Kiểm tra API LLM có khả dụng

```bash
# Kiểm tra kết nối đến OpenAI
curl -v https://api.openai.com/v1/models \
  -H "Authorization: Bearer your_openai_api_key"

# Kiểm tra kết nối đến Google AI
curl -v https://generativelanguage.googleapis.com/v1beta/models \
  -H "Authorization: Bearer your_google_api_key"
```

##### 4.1.2. Kiểm tra API key

Xác minh API key trong file `.env`:

```
OPENAI_API_KEY=your_openai_api_key
GOOGLE_API_KEY=your_google_api_key
ANTHROPIC_API_KEY=your_anthropic_api_key
```

##### 4.1.3. Kiểm tra giới hạn API

Kiểm tra giới hạn API trong trang quản lý của nhà cung cấp LLM:
- OpenAI: https://platform.openai.com/usage
- Google AI: https://console.cloud.google.com/apis/dashboard
- Anthropic: https://console.anthropic.com/usage

### 4.2. Lỗi xử lý LLM

#### Triệu chứng
- LLM phản hồi không chính xác
- LLM không hiểu yêu cầu
- LLM tạo ra nội dung không phù hợp

#### Nguyên nhân có thể
1. Prompt không hiệu quả
2. Thiếu ngữ cảnh
3. Tham số không phù hợp
4. Mô hình không phù hợp
5. Giới hạn token

#### Giải pháp

##### 4.2.1. Cải thiện prompt

```typescript
// Thay vì
const prompt = "Tóm tắt văn bản sau: " + text;

// Sử dụng
const prompt = `
Tóm tắt văn bản sau đây thành các điểm chính, giữ lại thông tin quan trọng và bỏ qua chi tiết không cần thiết.
Văn bản cần tóm tắt:
${text}

Tóm tắt:
`;
```

##### 4.2.2. Cung cấp ngữ cảnh

```typescript
// Thêm ngữ cảnh vào prompt
const prompt = `
Bạn là một trợ lý AI chuyên về ${domain}.
Nhiệm vụ của bạn là ${task}.
Hãy trả lời câu hỏi sau dựa trên kiến thức chuyên môn của bạn.

Câu hỏi: ${question}

Trả lời:
`;
```

##### 4.2.3. Điều chỉnh tham số

```typescript
// Điều chỉnh tham số LLM
const response = await openai.chat.completions.create({
  model: "gpt-4",
  messages: [
    { role: "system", content: systemPrompt },
    { role: "user", content: userPrompt }
  ],
  temperature: 0.3, // Giảm temperature để tăng tính nhất quán
  max_tokens: 500, // Giới hạn độ dài phản hồi
  top_p: 0.9, // Điều chỉnh top_p
  frequency_penalty: 0.5, // Giảm lặp lại
  presence_penalty: 0.5, // Khuyến khích đa dạng
});
```

##### 4.2.4. Chọn mô hình phù hợp

```typescript
// Chọn mô hình phù hợp với nhiệm vụ
// Cho nhiệm vụ đơn giản
const model = "gpt-3.5-turbo";

// Cho nhiệm vụ phức tạp
const model = "gpt-4";

// Cho nhiệm vụ đa ngôn ngữ
const model = "gpt-4-turbo";
```

### 4.3. Lỗi chi phí LLM

#### Triệu chứng
- Chi phí LLM cao bất thường
- Vượt quá ngân sách
- Sử dụng token quá nhiều

#### Nguyên nhân có thể
1. Sử dụng mô hình đắt tiền không cần thiết
2. Prompt quá dài
3. Lỗi trong mã nguồn gây gọi API liên tục
4. Không giới hạn độ dài phản hồi
5. Không sử dụng cache

#### Giải pháp

##### 4.3.1. Sử dụng mô hình phù hợp

```typescript
// Thay vì luôn sử dụng GPT-4
const model = "gpt-4";

// Sử dụng mô hình phù hợp với nhiệm vụ
function selectModel(task) {
  switch (task) {
    case 'simple_qa':
      return "gpt-3.5-turbo";
    case 'complex_reasoning':
      return "gpt-4";
    case 'code_generation':
      return "gpt-4";
    default:
      return "gpt-3.5-turbo";
  }
}
```

##### 4.3.2. Tối ưu hóa prompt

```typescript
// Thay vì gửi toàn bộ văn bản
const prompt = `Tóm tắt văn bản sau: ${longText}`;

// Tối ưu hóa prompt
function optimizePrompt(text) {
  // Cắt bớt văn bản nếu quá dài
  if (text.length > 10000) {
    text = text.substring(0, 10000) + "...";
  }
  
  // Loại bỏ thông tin không cần thiết
  text = text.replace(/\n\n+/g, '\n\n');
  
  return `Tóm tắt văn bản sau: ${text}`;
}
```

##### 4.3.3. Sử dụng cache

```typescript
// Sử dụng cache cho các yêu cầu LLM
async function getCachedLLMResponse(prompt, model) {
  const cacheKey = `llm:${model}:${crypto.createHash('md5').update(prompt).digest('hex')}`;
  
  // Kiểm tra cache
  const cachedResponse = await redisClient.get(cacheKey);
  if (cachedResponse) {
    return JSON.parse(cachedResponse);
  }
  
  // Gọi API LLM
  const response = await callLLM(prompt, model);
  
  // Lưu vào cache
  await redisClient.set(cacheKey, JSON.stringify(response), 'EX', 3600); // Hết hạn sau 1 giờ
  
  return response;
}
```

##### 4.3.4. Giám sát sử dụng

```typescript
// Giám sát sử dụng LLM
async function trackLLMUsage(model, promptTokens, completionTokens, organizationId) {
  await prisma.llmUsage.create({
    data: {
      model,
      promptTokens,
      completionTokens,
      totalTokens: promptTokens + completionTokens,
      cost: calculateCost(model, promptTokens, completionTokens),
      organizationId,
      timestamp: new Date(),
    },
  });
}

// Tính toán chi phí
function calculateCost(model, promptTokens, completionTokens) {
  const rates = {
    'gpt-3.5-turbo': { prompt: 0.0015, completion: 0.002 },
    'gpt-4': { prompt: 0.03, completion: 0.06 },
    'gpt-4-turbo': { prompt: 0.01, completion: 0.03 },
  };
  
  const rate = rates[model] || rates['gpt-3.5-turbo'];
  
  return (promptTokens / 1000 * rate.prompt) + (completionTokens / 1000 * rate.completion);
}
```

## 5. CÔNG CỤ KHẮC PHỤC SỰ CỐ AI VÀ TỰ ĐỘNG HÓA

### 5.1. AI Monitor

AI Monitor là công cụ trong NextFlow CRM giúp giám sát và quản lý AI:

1. Truy cập **Cài đặt > Hệ thống > AI Monitor**
2. Xem trạng thái kết nối AI
3. Kiểm tra sử dụng AI
4. Xem logs AI

### 5.2. Workflow Debugger

Workflow Debugger giúp gỡ lỗi workflow n8n:

1. Truy cập **Cài đặt > Hệ thống > Workflow Debugger**
2. Chọn workflow cần gỡ lỗi
3. Xem logs workflow
4. Chạy workflow với dữ liệu mẫu

### 5.3. Chatbot Tester

Chatbot Tester giúp kiểm tra chatbot Flowise:

1. Truy cập **Cài đặt > Hệ thống > Chatbot Tester**
2. Chọn chatbot cần kiểm tra
3. Gửi tin nhắn thử nghiệm
4. Xem logs chatbot

### 5.4. Công cụ dòng lệnh

#### 5.4.1. Kiểm tra kết nối n8n

```bash
# Kiểm tra kết nối n8n
curl -v -H "X-N8N-API-KEY: your_n8n_api_key" https://n8n.yourdomain.com/api/v1/workflows
```

#### 5.4.2. Kiểm tra kết nối Flowise

```bash
# Kiểm tra kết nối Flowise
curl -v -H "Authorization: Bearer your_flowise_api_key" https://flowise.yourdomain.com/api/v1/chatflows
```

#### 5.4.3. Kiểm tra kết nối LLM

```bash
# Kiểm tra kết nối OpenAI
curl -v -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_openai_api_key" \
  -d '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"Hello"}]}' \
  https://api.openai.com/v1/chat/completions
```

## 6. TÀI LIỆU THAM KHẢO

1. [Tài liệu n8n](https://docs.n8n.io/)
2. [Tài liệu Flowise](https://docs.flowiseai.com/)
3. [Tài liệu OpenAI](https://platform.openai.com/docs/api-reference)
4. [Tài liệu Google AI](https://ai.google.dev/docs)
5. [Tài liệu Anthropic](https://docs.anthropic.com/claude/reference)
