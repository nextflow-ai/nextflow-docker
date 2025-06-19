# TÍCH HỢP VỚI OPENAI

## 1. GIỚI THIỆU

OpenAI cung cấp các mô hình ngôn ngữ lớn (LLM) tiên tiến như GPT-3.5 và GPT-4,
có thể được tích hợp vào NextFlow CRM để nâng cao khả năng xử lý ngôn ngữ tự
nhiên, tạo nội dung, và tương tác với khách hàng. Tài liệu này hướng dẫn cách
tích hợp các mô hình OpenAI vào hệ thống NextFlow CRM.

### 1.1. Các mô hình OpenAI phổ biến

| Mô hình                | Mô tả                                      | Use-case phù hợp                        |
| ---------------------- | ------------------------------------------ | --------------------------------------- |
| GPT-3.5-turbo          | Mô hình cân bằng giữa hiệu suất và chi phí | Chatbot, tạo nội dung, phân loại        |
| GPT-4                  | Mô hình mạnh nhất, xử lý nhiệm vụ phức tạp | Tư vấn chuyên sâu, phân tích phức tạp   |
| GPT-4-turbo            | Phiên bản tối ưu hóa của GPT-4             | Ứng dụng thời gian thực, phản hồi nhanh |
| GPT-4-vision           | Hỗ trợ xử lý hình ảnh                      | Phân tích hình ảnh sản phẩm, OCR        |
| text-embedding-ada-002 | Tạo vector embedding                       | Tìm kiếm ngữ nghĩa, RAG                 |

### 1.2. Yêu cầu tiên quyết

- Tài khoản OpenAI với API key
- Đăng ký gói API phù hợp với nhu cầu sử dụng
- Node.js v16 trở lên (cho tích hợp trực tiếp)
- Flowise hoặc n8n (cho tích hợp qua workflow)

## 2. THIẾT LẬP KẾT NỐI VỚI OPENAI

### 2.1. Đăng ký và lấy API Key

1. Truy cập [OpenAI Platform](https://platform.openai.com/)
2. Đăng ký tài khoản hoặc đăng nhập
3. Truy cập mục API Keys
4. Tạo API Key mới
5. Lưu API Key an toàn (API Key chỉ hiển thị một lần)

### 2.2. Cấu hình API Key trong NextFlow CRM

#### 2.2.1. Cấu hình qua giao diện quản trị

1. Đăng nhập vào NextFlow CRM với tài khoản admin
2. Truy cập **Cài đặt > Tích hợp > AI Providers**
3. Chọn "OpenAI" và nhập API Key
4. Cấu hình các thông số bổ sung (nếu cần)
5. Lưu cấu hình

#### 2.2.2. Cấu hình qua biến môi trường

Thêm các biến môi trường sau vào file `.env`:

```
OPENAI_API_KEY=your_api_key_here
OPENAI_ORG_ID=your_org_id_here  # Tùy chọn
OPENAI_API_VERSION=2023-05-15   # Tùy chọn
OPENAI_DEFAULT_MODEL=gpt-3.5-turbo
```

### 2.3. Kiểm tra kết nối

```javascript
// Ví dụ: Kiểm tra kết nối với OpenAI
const { OpenAI } = require('openai');

async function testOpenAIConnection() {
  try {
    const openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });

    const response = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system', content: 'Bạn là trợ lý AI của NextFlow CRM.' },
        { role: 'user', content: 'Xin chào!' },
      ],
      max_tokens: 50,
    });

    console.log('Kết nối thành công!');
    console.log('Phản hồi:', response.choices[0].message.content);
    return true;
  } catch (error) {
    console.error('Lỗi kết nối OpenAI:', error);
    return false;
  }
}

testOpenAIConnection();
```

## 3. TÍCH HỢP OPENAI VỚI NextFlow CRM

### 3.1. Tích hợp trực tiếp qua API

#### 3.1.1. Cài đặt thư viện OpenAI

```bash
npm install openai
```

#### 3.1.2. Tạo service cho OpenAI

```javascript
// src/services/openai.service.ts
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { OpenAI } from 'openai';

@Injectable()
export class OpenAIService {
  private openai: OpenAI;

  constructor(private configService: ConfigService) {
    this.openai = new OpenAI({
      apiKey: this.configService.get<string>('OPENAI_API_KEY'),
    });
  }

  async generateChatCompletion(messages: any[], options = {}) {
    try {
      const defaultOptions = {
        model: this.configService.get<string>('OPENAI_DEFAULT_MODEL') || 'gpt-3.5-turbo',
        temperature: 0.7,
        max_tokens: 500,
      };

      const response = await this.openai.chat.completions.create({
        ...defaultOptions,
        ...options,
        messages,
      });

      return response.choices[0].message.content;
    } catch (error) {
      console.error('Error generating chat completion:', error);
      throw error;
    }
  }

  async generateEmbedding(text: string) {
    try {
      const response = await this.openai.embeddings.create({
        model: 'text-embedding-ada-002',
        input: text,
      });

      return response.data[0].embedding;
    } catch (error) {
      console.error('Error generating embedding:', error);
      throw error;
    }
  }
}
```

#### 3.1.3. Sử dụng OpenAI Service trong Controller

```javascript
// src/controllers/ai.controller.ts
import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { OpenAIService } from '../services/openai.service';
import { AuthGuard } from '../guards/auth.guard';

@Controller('ai')
@UseGuards(AuthGuard)
export class AIController {
  constructor(private openaiService: OpenAIService) {}

  @Post('chat')
  async generateChatResponse(@Body() body: any) {
    try {
      const { messages, options } = body;
      const response = await this.openaiService.generateChatCompletion(messages, options);

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

  @Post('embedding')
  async generateEmbedding(@Body() body: any) {
    try {
      const { text } = body;
      const embedding = await this.openaiService.generateEmbedding(text);

      return {
        success: true,
        code: 1000,
        message: 'Thành công',
        data: { embedding }
      };
    } catch (error) {
      return {
        success: false,
        code: 5000,
        message: 'Lỗi khi tạo embedding',
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

#### 3.2.1. Cấu hình OpenAI trong Flowise

1. Đăng nhập vào Flowise
2. Truy cập **Credentials**
3. Tạo credential mới cho OpenAI
4. Nhập API Key và các thông số khác (nếu cần)
5. Lưu credential

#### 3.2.2. Tạo Chatflow với OpenAI

1. Tạo chatflow mới
2. Thêm node "Chat Input"
3. Thêm node "OpenAI" và kết nối với credential đã tạo
4. Cấu hình model (GPT-3.5-turbo hoặc GPT-4)
5. Thêm node "Chat Output" và kết nối
6. Lưu và xuất chatflow dưới dạng API

#### 3.2.3. Gọi Flowise API từ NextFlow CRM

```javascript
// Ví dụ: Gọi Flowise API
async function callFlowiseOpenAI(message, chatflowId, apiKey) {
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

#### 3.3.1. Cấu hình OpenAI trong n8n

1. Đăng nhập vào n8n
2. Truy cập **Credentials**
3. Tạo credential mới cho OpenAI
4. Nhập API Key
5. Lưu credential

#### 3.3.2. Tạo Workflow với OpenAI

1. Tạo workflow mới
2. Thêm node "Webhook" để nhận request
3. Thêm node "OpenAI" và kết nối với credential đã tạo
4. Cấu hình operation (Chat Completion hoặc Embedding)
5. Thêm node "Respond to Webhook" để trả về kết quả
6. Lưu và kích hoạt workflow

#### 3.3.3. Gọi n8n Webhook từ NextFlow CRM

```javascript
// Ví dụ: Gọi n8n Webhook
async function callN8nOpenAI(message, webhookUrl) {
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
// Ví dụ: Chatbot với OpenAI
async function handleCustomerMessage(message, sessionId) {
  try {
    // Lấy lịch sử chat
    const chatHistory = await getChatHistory(sessionId);

    // Tạo messages cho OpenAI
    const messages = [
      {
        role: 'system',
        content:
          'Bạn là trợ lý AI của NextFlow CRM, giúp đỡ khách hàng với thông tin sản phẩm và dịch vụ.',
      },
      ...chatHistory.map(msg => ({
        role: msg.isUser ? 'user' : 'assistant',
        content: msg.content,
      })),
      { role: 'user', content: message },
    ];

    // Gọi OpenAI
    const response = await openaiService.generateChatCompletion(messages);

    // Lưu tin nhắn vào lịch sử
    await saveChatMessage(sessionId, message, response);

    return response;
  } catch (error) {
    console.error('Error handling customer message:', error);
    return 'Xin lỗi, tôi đang gặp sự cố kỹ thuật. Vui lòng thử lại sau.';
  }
}
```

### 4.2. Phân tích cảm xúc khách hàng

```javascript
// Ví dụ: Phân tích cảm xúc với OpenAI
async function analyzeSentiment(text) {
  try {
    const messages = [
      {
        role: 'system',
        content:
          'Bạn là một hệ thống phân tích cảm xúc. Hãy phân tích cảm xúc trong văn bản và trả về kết quả dưới dạng JSON với các trường: sentiment (positive, neutral, negative), score (0-1), explanation.',
      },
      {
        role: 'user',
        content: `Phân tích cảm xúc trong văn bản sau: "${text}"`,
      },
    ];

    const response = await openaiService.generateChatCompletion(messages, {
      response_format: { type: 'json_object' },
    });

    return JSON.parse(response);
  } catch (error) {
    console.error('Error analyzing sentiment:', error);
    throw error;
  }
}
```

### 4.3. Tạo nội dung marketing

```javascript
// Ví dụ: Tạo nội dung marketing với OpenAI
async function generateMarketingContent(product, contentType, tone) {
  try {
    const messages = [
      {
        role: 'system',
        content: `Bạn là một chuyên gia marketing. Hãy tạo nội dung ${contentType} cho sản phẩm với tone ${tone}.`,
      },
      {
        role: 'user',
        content: `Tạo nội dung ${contentType} cho sản phẩm sau:
        Tên: ${product.name}
        Mô tả: ${product.description}
        Giá: ${product.price}
        Tính năng: ${product.features.join(', ')}
        Đối tượng: ${product.targetAudience}`,
      },
    ];

    const response = await openaiService.generateChatCompletion(messages, {
      temperature: 0.8,
      max_tokens: 1000,
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
// Ví dụ: Theo dõi sử dụng OpenAI
async function trackOpenAIUsage(userId, model, tokensUsed, requestType) {
  try {
    await db.collection('ai_usage').insertOne({
      userId,
      provider: 'openai',
      model,
      tokensUsed,
      requestType,
      cost: calculateCost(model, tokensUsed),
      timestamp: new Date(),
    });
  } catch (error) {
    console.error('Error tracking OpenAI usage:', error);
  }
}

function calculateCost(model, tokens) {
  const pricing = {
    'gpt-3.5-turbo': 0.0015 / 1000, // $0.0015 per 1K tokens
    'gpt-4': 0.03 / 1000, // $0.03 per 1K tokens
    'text-embedding-ada-002': 0.0001 / 1000, // $0.0001 per 1K tokens
  };

  return tokens * (pricing[model] || 0);
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
    // Thử với GPT-4 trước
    const response = await openaiService.generateChatCompletion(messages, {
      model: 'gpt-4',
      ...options,
    });

    return response;
  } catch (error) {
    console.warn('Fallback to GPT-3.5-turbo due to error:', error.message);

    try {
      // Fallback sang GPT-3.5-turbo
      const fallbackResponse = await openaiService.generateChatCompletion(
        messages,
        {
          model: 'gpt-3.5-turbo',
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
  OpenAI
- **Sử dụng API của OpenAI**: Không lưu dữ liệu người dùng
- **Thông báo cho người dùng**: Thông báo rõ ràng về việc sử dụng AI

```javascript
// Ví dụ: Lọc thông tin nhạy cảm
function sanitizeInput(text) {
  // Lọc thông tin cá nhân
  const sanitized = text
    .replace(/\b\d{9,16}\b/g, '[CARD_NUMBER]') // Số thẻ
    .replace(/\b\d{10,11}\b/g, '[PHONE_NUMBER]') // Số điện thoại
    .replace(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/g, '[EMAIL]') // Email
    .replace(/\b\d{9,12}\b/g, '[ID_NUMBER]'); // CMND/CCCD

  return sanitized;
}
```

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
async function callOpenAIWithLogging(messages, options = {}) {
  const startTime = Date.now();
  const requestId = generateRequestId();

  try {
    // Log request
    logger.info({
      message: 'OpenAI request',
      requestId,
      model: options.model || 'gpt-3.5-turbo',
      messageCount: messages.length,
      timestamp: new Date(),
    });

    // Gọi API
    const response = await openaiService.generateChatCompletion(
      messages,
      options
    );

    // Log success
    const duration = Date.now() - startTime;
    logger.info({
      message: 'OpenAI response success',
      requestId,
      duration,
      tokensUsed: response.usage?.total_tokens,
      timestamp: new Date(),
    });

    return response;
  } catch (error) {
    // Log error
    const duration = Date.now() - startTime;
    logger.error({
      message: 'OpenAI response error',
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

- [OpenAI API Documentation](https://platform.openai.com/docs/api-reference)
- [OpenAI Cookbook](https://github.com/openai/openai-cookbook)
- [OpenAI Node.js Library](https://github.com/openai/openai-node)
- [Flowise Documentation](https://docs.flowiseai.com/)
- [n8n Documentation](https://docs.n8n.io/)
