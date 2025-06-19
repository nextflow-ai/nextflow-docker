# TÍCH HỢP VỚI ANTHROPIC

## 1. GIỚI THIỆU

Anthropic cung cấp các mô hình ngôn ngữ lớn (LLM) Claude, được thiết kế với
trọng tâm về an toàn và hữu ích. Các mô hình Claude có thể được tích hợp vào
NextFlow CRM để nâng cao khả năng xử lý ngôn ngữ tự nhiên, tạo nội dung, và
tương tác với khách hàng. Tài liệu này hướng dẫn cách tích hợp các mô hình
Anthropic vào hệ thống NextFlow CRM.

### 1.1. Các mô hình Anthropic phổ biến

| Mô hình         | Mô tả                                      | Use-case phù hợp                              |
| --------------- | ------------------------------------------ | --------------------------------------------- |
| Claude 3 Opus   | Mô hình mạnh nhất, xử lý nhiệm vụ phức tạp | Tư vấn chuyên sâu, phân tích phức tạp         |
| Claude 3 Sonnet | Mô hình cân bằng giữa hiệu suất và chi phí | Chatbot, tạo nội dung, phân loại              |
| Claude 3 Haiku  | Phiên bản nhẹ, tối ưu hóa tốc độ           | Ứng dụng thời gian thực, phản hồi nhanh       |
| Claude 2        | Phiên bản trước đó, chi phí thấp hơn       | Các ứng dụng không yêu cầu tính năng mới nhất |

### 1.2. Yêu cầu tiên quyết

- Tài khoản Anthropic với API key
- Đăng ký gói API phù hợp với nhu cầu sử dụng
- Node.js v16 trở lên (cho tích hợp trực tiếp)
- Flowise hoặc n8n (cho tích hợp qua workflow)

## 2. THIẾT LẬP KẾT NỐI VỚI ANTHROPIC

### 2.1. Đăng ký và lấy API Key

1. Truy cập [Anthropic Console](https://console.anthropic.com/)
2. Đăng ký tài khoản hoặc đăng nhập
3. Truy cập mục API Keys
4. Tạo API Key mới
5. Lưu API Key an toàn (API Key chỉ hiển thị một lần)

### 2.2. Cấu hình API Key trong NextFlow CRM

#### 2.2.1. Cấu hình qua giao diện quản trị

1. Đăng nhập vào NextFlow CRM với tài khoản admin
2. Truy cập **Cài đặt > Tích hợp > AI Providers**
3. Chọn "Anthropic" và nhập API Key
4. Cấu hình các thông số bổ sung (nếu cần)
5. Lưu cấu hình

#### 2.2.2. Cấu hình qua biến môi trường

Thêm các biến môi trường sau vào file `.env`:

```
ANTHROPIC_API_KEY=your_api_key_here
ANTHROPIC_DEFAULT_MODEL=claude-3-sonnet-20240229
ANTHROPIC_MAX_TOKENS=1000
```

### 2.3. Kiểm tra kết nối

```javascript
// Ví dụ: Kiểm tra kết nối với Anthropic
const Anthropic = require('@anthropic-ai/sdk');

async function testAnthropicConnection() {
  try {
    const anthropic = new Anthropic({
      apiKey: process.env.ANTHROPIC_API_KEY,
    });

    const message = await anthropic.messages.create({
      model: 'claude-3-sonnet-20240229',
      max_tokens: 100,
      messages: [{ role: 'user', content: 'Xin chào! Bạn là ai?' }],
    });

    console.log('Kết nối thành công!');
    console.log('Phản hồi:', message.content[0].text);
    return true;
  } catch (error) {
    console.error('Lỗi kết nối Anthropic:', error);
    return false;
  }
}

testAnthropicConnection();
```

## 3. TÍCH HỢP ANTHROPIC VỚI NextFlow CRM

### 3.1. Tích hợp trực tiếp qua API

#### 3.1.1. Cài đặt thư viện Anthropic

```bash
npm install @anthropic-ai/sdk
```

#### 3.1.2. Tạo service cho Anthropic

```javascript
// src/services/anthropic.service.ts
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Anthropic from '@anthropic-ai/sdk';

@Injectable()
export class AnthropicService {
  private anthropic: Anthropic;

  constructor(private configService: ConfigService) {
    this.anthropic = new Anthropic({
      apiKey: this.configService.get<string>('ANTHROPIC_API_KEY'),
    });
  }

  async generateMessage(messages: any[], options = {}) {
    try {
      const defaultOptions = {
        model: this.configService.get<string>('ANTHROPIC_DEFAULT_MODEL') || 'claude-3-sonnet-20240229',
        max_tokens: this.configService.get<number>('ANTHROPIC_MAX_TOKENS') || 1000,
        temperature: 0.7,
      };

      const formattedMessages = messages.map(msg => ({
        role: msg.role === 'assistant' ? 'assistant' : 'user',
        content: msg.content
      }));

      const response = await this.anthropic.messages.create({
        model: options.model || defaultOptions.model,
        max_tokens: options.max_tokens || defaultOptions.max_tokens,
        temperature: options.temperature || defaultOptions.temperature,
        messages: formattedMessages,
      });

      return response.content[0].text;
    } catch (error) {
      console.error('Error generating message:', error);
      throw error;
    }
  }
}
```

#### 3.1.3. Sử dụng Anthropic Service trong Controller

```javascript
// src/controllers/ai.controller.ts
import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { AnthropicService } from '../services/anthropic.service';
import { AuthGuard } from '../guards/auth.guard';

@Controller('ai')
@UseGuards(AuthGuard)
export class AIController {
  constructor(private anthropicService: AnthropicService) {}

  @Post('chat')
  async generateChatResponse(@Body() body: any) {
    try {
      const { messages, options } = body;
      const response = await this.anthropicService.generateMessage(messages, options);

      return {
        success: true,
        code: 1000,
        message: 'Thành công',
        data: { response }
      };
    } catch (error) {
      return {
        success: false,
        code: 5000,
        message: 'Lỗi khi tạo phản hồi',
        error: {
          type: 'AI_ERROR',
          details: error.message
        }
      };
    }
  }
}
```

### 3.2. Tích hợp qua Flowise

#### 3.2.1. Cấu hình Anthropic trong Flowise

1. Đăng nhập vào Flowise
2. Truy cập **Credentials**
3. Tạo credential mới cho Anthropic
4. Nhập API Key và các thông số khác (nếu cần)
5. Lưu credential

#### 3.2.2. Tạo Chatflow với Anthropic

1. Tạo chatflow mới
2. Thêm node "Chat Input"
3. Thêm node "Anthropic" và kết nối với credential đã tạo
4. Cấu hình model (Claude 3 Sonnet hoặc model khác)
5. Thêm node "Chat Output" và kết nối
6. Lưu và xuất chatflow dưới dạng API

#### 3.2.3. Gọi Flowise API từ NextFlow CRM

```javascript
// Ví dụ: Gọi Flowise API
async function callFlowiseAnthropic(message, chatflowId, apiKey) {
  try {
    const response = await axios.post(
      `${FLOWISE_URL}/api/v1/prediction/${chatflowId}`,
      {
        question: message,
        history: [],
      },
      {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
        },
      }
    );

    return response.data;
  } catch (error) {
    console.error('Error calling Flowise API:', error);
    throw error;
  }
}
```

### 3.3. Tích hợp qua n8n

#### 3.3.1. Cấu hình Anthropic trong n8n

1. Đăng nhập vào n8n
2. Truy cập **Credentials**
3. Tạo credential mới cho Anthropic
4. Nhập API Key
5. Lưu credential

#### 3.3.2. Tạo Workflow với Anthropic

1. Tạo workflow mới
2. Thêm node "Webhook" để nhận request
3. Thêm node "Anthropic" và kết nối với credential đã tạo
4. Cấu hình operation (Messages)
5. Thêm node "Respond to Webhook" để trả về kết quả
6. Lưu và kích hoạt workflow

#### 3.3.3. Gọi n8n Webhook từ NextFlow CRM

```javascript
// Ví dụ: Gọi n8n Webhook
async function callN8nAnthropic(message, webhookUrl) {
  try {
    const response = await axios.post(
      webhookUrl,
      {
        message: message,
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    return response.data;
  } catch (error) {
    console.error('Error calling n8n webhook:', error);
    throw error;
  }
}
```

## 4. USE-CASES VÀ VÍ DỤ

### 4.1. Chatbot thông minh

```javascript
// Ví dụ: Chatbot với Anthropic
async function handleCustomerMessage(message, sessionId) {
  try {
    // Lấy lịch sử chat
    const chatHistory = await getChatHistory(sessionId);

    // Tạo messages cho Anthropic
    const messages = [
      {
        role: 'user',
        content:
          'Bạn là trợ lý AI của NextFlow CRM, giúp đỡ khách hàng với thông tin sản phẩm và dịch vụ. Hãy trả lời ngắn gọn, hữu ích và thân thiện.',
      },
      ...chatHistory.map(msg => ({
        role: msg.isUser ? 'user' : 'assistant',
        content: msg.content,
      })),
      { role: 'user', content: message },
    ];

    // Gọi Anthropic
    const response = await anthropicService.generateMessage(messages);

    // Lưu tin nhắn vào lịch sử
    await saveChatMessage(sessionId, message, response);

    return response;
  } catch (error) {
    console.error('Error handling customer message:', error);
    return 'Xin lỗi, tôi đang gặp sự cố kỹ thuật. Vui lòng thử lại sau.';
  }
}
```

### 4.2. Phân tích phản hồi khách hàng

```javascript
// Ví dụ: Phân tích phản hồi khách hàng với Anthropic
async function analyzeFeedback(feedback) {
  try {
    const prompt = `Phân tích phản hồi khách hàng sau và trả về kết quả dưới dạng JSON với các trường:
    - sentiment: cảm xúc (positive, neutral, negative)
    - score: điểm số từ 0-10
    - key_points: các điểm chính được đề cập
    - suggestions: đề xuất cải thiện dựa trên phản hồi
    
    Phản hồi khách hàng: "${feedback}"`;

    const messages = [{ role: 'user', content: prompt }];

    const response = await anthropicService.generateMessage(messages, {
      temperature: 0.2,
      max_tokens: 1500,
    });

    // Cố gắng parse JSON từ phản hồi
    try {
      return JSON.parse(response);
    } catch (parseError) {
      // Nếu không phải JSON, trả về text
      return { rawText: response };
    }
  } catch (error) {
    console.error('Error analyzing feedback:', error);
    throw error;
  }
}
```

### 4.3. Tạo nội dung marketing

```javascript
// Ví dụ: Tạo nội dung marketing với Anthropic
async function generateMarketingContent(product, contentType, tone) {
  try {
    const prompt = `Tạo nội dung ${contentType} cho sản phẩm sau với tone ${tone}:
      Tên: ${product.name}
      Mô tả: ${product.description}
      Giá: ${product.price}
      Tính năng: ${product.features.join(', ')}
      Đối tượng: ${product.targetAudience}`;

    const messages = [{ role: 'user', content: prompt }];

    const response = await anthropicService.generateMessage(messages, {
      temperature: 0.8,
      max_tokens: 2000,
    });

    return response;
  } catch (error) {
    console.error('Error generating marketing content:', error);
    throw error;
  }
}
```

## 5. QUẢN LÝ CHI PHÍ VÀ TỐI ƯU HÓA

### 5.1. Theo dõi sử dụng

```javascript
// Ví dụ: Theo dõi sử dụng Anthropic
async function trackAnthropicUsage(
  userId,
  model,
  inputTokens,
  outputTokens,
  requestType
) {
  try {
    await db.collection('ai_usage').insertOne({
      userId,
      provider: 'anthropic',
      model,
      inputTokens,
      outputTokens,
      totalTokens: inputTokens + outputTokens,
      requestType,
      cost: calculateCost(model, inputTokens, outputTokens),
      timestamp: new Date(),
    });
  } catch (error) {
    console.error('Error tracking Anthropic usage:', error);
  }
}

function calculateCost(model, inputTokens, outputTokens) {
  const pricing = {
    'claude-3-opus-20240229': {
      input: 15 / 1000000, // $15 per 1M input tokens
      output: 75 / 1000000, // $75 per 1M output tokens
    },
    'claude-3-sonnet-20240229': {
      input: 3 / 1000000, // $3 per 1M input tokens
      output: 15 / 1000000, // $15 per 1M output tokens
    },
    'claude-3-haiku-20240307': {
      input: 0.25 / 1000000, // $0.25 per 1M input tokens
      output: 1.25 / 1000000, // $1.25 per 1M output tokens
    },
  };

  const modelPricing = pricing[model] || pricing['claude-3-sonnet-20240229'];
  return inputTokens * modelPricing.input + outputTokens * modelPricing.output;
}
```

### 5.2. Tối ưu hóa prompt

- **Sử dụng hướng dẫn rõ ràng**: Cung cấp hướng dẫn cụ thể và rõ ràng
- **Giới hạn độ dài**: Giữ prompt ngắn gọn khi có thể
- **Sử dụng few-shot learning**: Cung cấp ví dụ để mô hình học cách phản hồi
- **Caching**: Cache các phản hồi thường xuyên sử dụng

### 5.3. Chiến lược fallback

```javascript
// Ví dụ: Chiến lược fallback
async function generateResponseWithFallback(messages, options = {}) {
  try {
    // Thử với Claude 3 Opus trước
    const response = await anthropicService.generateMessage(messages, {
      model: 'claude-3-opus-20240229',
      ...options,
    });

    return response;
  } catch (error) {
    console.warn('Fallback to Claude 3 Sonnet due to error:', error.message);

    try {
      // Fallback sang Claude 3 Sonnet
      const fallbackResponse = await anthropicService.generateMessage(
        messages,
        {
          model: 'claude-3-sonnet-20240229',
          ...options,
        }
      );

      return fallbackResponse;
    } catch (fallbackError) {
      console.error('Both models failed:', fallbackError);
      throw new Error('Không thể tạo phản hồi. Vui lòng thử lại sau.');
    }
  }
}
```

## 6. BẢO MẬT VÀ TUÂN THỦ

### 6.1. Xử lý dữ liệu nhạy cảm

- **Lọc thông tin nhạy cảm**: Loại bỏ thông tin nhạy cảm trước khi gửi đến
  Anthropic
- **Sử dụng API của Anthropic**: Tuân thủ chính sách bảo mật của Anthropic
- **Thông báo cho người dùng**: Thông báo rõ ràng về việc sử dụng AI

### 6.2. Tuân thủ GDPR

- **Xin phép người dùng**: Lấy sự đồng ý trước khi sử dụng dữ liệu
- **Quyền truy cập và xóa**: Cho phép người dùng truy cập và xóa dữ liệu
- **Lưu trữ có thời hạn**: Xóa dữ liệu sau một khoảng thời gian

## 7. KHẮC PHỤC SỰ CỐ

### 7.1. Lỗi thường gặp và giải pháp

| Lỗi                      | Nguyên nhân                 | Giải pháp                                              |
| ------------------------ | --------------------------- | ------------------------------------------------------ |
| API key invalid          | API key không hợp lệ        | Kiểm tra và cập nhật API key                           |
| Rate limit exceeded      | Vượt quá giới hạn request   | Thêm delay giữa các request, tăng quota                |
| Context length exceeded  | Prompt quá dài              | Rút gọn prompt, sử dụng mô hình hỗ trợ context dài hơn |
| Content policy violation | Vi phạm chính sách nội dung | Kiểm tra và điều chỉnh prompt                          |
| Timeout                  | Request quá lâu             | Tăng timeout, chia nhỏ request                         |

### 7.2. Logging và Monitoring

```javascript
// Ví dụ: Logging và Monitoring
async function callAnthropicWithLogging(messages, options = {}) {
  const startTime = Date.now();
  const requestId = generateRequestId();

  try {
    // Log request
    logger.info({
      message: 'Anthropic request',
      requestId,
      model: options.model || 'claude-3-sonnet-20240229',
      messageCount: messages.length,
      timestamp: new Date(),
    });

    // Gọi API
    const response = await anthropicService.generateMessage(messages, options);

    // Log success
    const duration = Date.now() - startTime;
    logger.info({
      message: 'Anthropic response success',
      requestId,
      duration,
      responseLength: response.length,
      timestamp: new Date(),
    });

    return response;
  } catch (error) {
    // Log error
    const duration = Date.now() - startTime;
    logger.error({
      message: 'Anthropic response error',
      requestId,
      duration,
      error: error.message,
      timestamp: new Date(),
    });

    throw error;
  }
}
```

## 8. TÀI LIỆU THAM KHẢO

- [Anthropic API Documentation](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)
- [Anthropic Node.js SDK](https://github.com/anthropics/anthropic-sdk-typescript)
- [Claude Models Overview](https://docs.anthropic.com/claude/docs/models-overview)
- [Flowise Documentation](https://docs.flowiseai.com/)
- [n8n Documentation](https://docs.n8n.io/)
