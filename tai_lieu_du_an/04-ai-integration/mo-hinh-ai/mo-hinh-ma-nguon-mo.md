# TÍCH HỢP VỚI MÔ HÌNH AI MÃ NGUỒN MỞ

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Triển khai mô hình mã nguồn mở](#2-triển-khai-mô-hình-mã-nguồn-mở)
3. [Tích hợp với NextFlow CRM](#3-tích-hợp-với-nextflow-crm)
4. [Use-cases và ví dụ](#4-use-cases-và-ví-dụ)
5. [Fine-tuning mô hình](#5-fine-tuning-mô-hình)
6. [Quản lý hiệu suất và tài nguyên](#6-quản-lý-hiệu-suất-và-tài-nguyên)
7. [Tài liệu tham khảo](#7-tài-liệu-tham-khảo)

## 1. GIỚI THIỆU

Các mô hình ngôn ngữ lớn (LLM) mã nguồn mở như Llama, Mistral, và Falcon cung cấp giải pháp AI linh hoạt, có thể tùy chỉnh và kiểm soát chi phí cho NextFlow CRM. Tài liệu này hướng dẫn cách tích hợp các mô hình mã nguồn mở vào hệ thống NextFlow CRM một cách hiệu quả và bảo mật.

### 1.1. Các mô hình mã nguồn mở phổ biến

| Mô hình | Mô tả | Use-case phù hợp |
|---------|-------|------------------|
| Llama 3 | Mô hình mới nhất từ Meta, hỗ trợ nhiều ngôn ngữ | Chatbot, tạo nội dung, phân loại |
| Mistral | Mô hình hiệu quả với kích thước nhỏ | Ứng dụng nhẹ, triển khai edge |
| Falcon | Mô hình từ Technology Innovation Institute | Xử lý ngôn ngữ tự nhiên đa dạng |
| Phi-2 | Mô hình nhỏ, hiệu suất cao | Ứng dụng yêu cầu tốc độ cao |
| BLOOM | Mô hình đa ngôn ngữ | Ứng dụng đa ngôn ngữ |

### 1.2. Lợi ích của mô hình mã nguồn mở

- **Kiểm soát chi phí**: Không phụ thuộc vào API bên ngoài
- **Bảo mật dữ liệu**: Dữ liệu không rời khỏi hệ thống
- **Tùy chỉnh**: Có thể fine-tune theo nhu cầu cụ thể
- **Không phụ thuộc**: Không bị ràng buộc bởi nhà cung cấp
- **Cộng đồng hỗ trợ**: Cộng đồng mã nguồn mở lớn

### 1.3. Yêu cầu tiên quyết

- Máy chủ với GPU (khuyến nghị NVIDIA với CUDA)
- Docker và Docker Compose
- Python 3.8+ và các thư viện ML
- Ít nhất 16GB RAM (khuyến nghị 32GB+)
- Ổ cứng SSD với ít nhất 100GB trống

## 2. TRIỂN KHAI MÔ HÌNH MÃ NGUỒN MỞ

### 2.1. Sử dụng Ollama

[Ollama](https://ollama.ai/) là công cụ đơn giản để triển khai và chạy các mô hình mã nguồn mở.

#### 2.1.1. Cài đặt Ollama

```bash
# Linux
curl -fsSL https://ollama.ai/install.sh | sh

# macOS
brew install ollama

# Windows
# Tải xuống từ https://ollama.ai/download
```

#### 2.1.2. Chạy mô hình với Ollama

```bash
# Tải và chạy Llama 3
ollama run llama3

# Tải và chạy Mistral
ollama run mistral

# Liệt kê các mô hình đã cài đặt
ollama list
```

#### 2.1.3. Sử dụng Ollama API

```javascript
// Ví dụ: Gọi Ollama API
async function callOllamaAPI(prompt, model = 'llama3') {
  try {
    const response = await axios.post('http://localhost:11434/api/generate', {
      model: model,
      prompt: prompt,
      stream: false
    });

    return response.data.response;
  } catch (error) {
    console.error('Error calling Ollama API:', error);
    throw error;
  }
}
```

### 2.2. Sử dụng LM Studio

[LM Studio](https://lmstudio.ai/) là ứng dụng desktop để chạy và quản lý các mô hình mã nguồn mở.

#### 2.2.1. Cài đặt LM Studio

1. Tải xuống từ [lmstudio.ai](https://lmstudio.ai/)
2. Cài đặt ứng dụng
3. Khởi động LM Studio

#### 2.2.2. Tải và chạy mô hình

1. Trong LM Studio, chọn "Browse Models"
2. Tìm và tải xuống mô hình (Llama 3, Mistral, v.v.)
3. Chọn mô hình và nhấp "Run Local Server"
4. Server sẽ chạy trên http://localhost:1234

#### 2.2.3. Sử dụng LM Studio API

```javascript
// Ví dụ: Gọi LM Studio API
async function callLMStudioAPI(prompt) {
  try {
    const response = await axios.post('http://localhost:1234/v1/chat/completions', {
      messages: [
        { role: "user", content: prompt }
      ],
      model: "local-model",
      temperature: 0.7,
      max_tokens: 500
    });

    return response.data.choices[0].message.content;
  } catch (error) {
    console.error('Error calling LM Studio API:', error);
    throw error;
  }
}
```

### 2.3. Sử dụng Docker và Text Generation Inference (TGI)

[Text Generation Inference](https://github.com/huggingface/text-generation-inference) là server triển khai mô hình từ Hugging Face.

#### 2.3.1. Triển khai với Docker

```bash
docker run --gpus all -p 8080:80 \
  -v $HOME/.cache/huggingface:/data \
  ghcr.io/huggingface/text-generation-inference:latest \
  --model-id meta-llama/Llama-3-8b-chat-hf
```

#### 2.3.2. Sử dụng TGI API

```javascript
// Ví dụ: Gọi TGI API
async function callTGIAPI(prompt) {
  try {
    const response = await axios.post('http://localhost:8080/generate', {
      inputs: prompt,
      parameters: {
        max_new_tokens: 500,
        temperature: 0.7,
        top_p: 0.95,
        do_sample: true
      }
    });

    return response.data.generated_text;
  } catch (error) {
    console.error('Error calling TGI API:', error);
    throw error;
  }
}
```

## 3. TÍCH HỢP VỚI NextFlow CRM

### 3.1. Tích hợp trực tiếp qua API

#### 3.1.1. Tạo service cho mô hình mã nguồn mở

```javascript
// src/services/open-source-llm.service.ts
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';

@Injectable()
export class OpenSourceLLMService {
  constructor(private configService: ConfigService) {}

  async generateText(prompt: string, options = {}) {
    try {
      const llmServer = this.configService.get<string>('LLM_SERVER_URL') || 'http://localhost:11434';
      const model = options.model || this.configService.get<string>('LLM_DEFAULT_MODEL') || 'llama3';

      // Sử dụng Ollama API
      if (llmServer.includes('11434')) {
        const response = await axios.post(`${llmServer}/api/generate`, {
          model: model,
          prompt: prompt,
          stream: false,
          ...options
        });

        return response.data.response;
      }
      // Sử dụng LM Studio API
      else if (llmServer.includes('1234')) {
        const response = await axios.post(`${llmServer}/v1/chat/completions`, {
          messages: [
            { role: "user", content: prompt }
          ],
          model: model,
          temperature: options.temperature || 0.7,
          max_tokens: options.max_tokens || 500
        });

        return response.data.choices[0].message.content;
      }
      // Sử dụng TGI API
      else {
        const response = await axios.post(`${llmServer}/generate`, {
          inputs: prompt,
          parameters: {
            max_new_tokens: options.max_tokens || 500,
            temperature: options.temperature || 0.7,
            top_p: options.top_p || 0.95,
            do_sample: options.do_sample !== undefined ? options.do_sample : true
          }
        });

        return response.data.generated_text;
      }
    } catch (error) {
      console.error('Error generating text:', error);
      throw error;
    }
  }

  async generateChatResponse(messages: any[], options = {}) {
    try {
      const llmServer = this.configService.get<string>('LLM_SERVER_URL') || 'http://localhost:11434';
      const model = options.model || this.configService.get<string>('LLM_DEFAULT_MODEL') || 'llama3';

      // Format messages for different APIs
      if (llmServer.includes('11434')) {
        // Ollama format
        const formattedPrompt = messages.map(msg =>
          `${msg.role === 'user' ? 'Human' : 'Assistant'}: ${msg.content}`
        ).join('\n') + '\nAssistant:';

        return this.generateText(formattedPrompt, { model, ...options });
      } else {
        // OpenAI-compatible format for LM Studio and others
        const response = await axios.post(`${llmServer}/v1/chat/completions`, {
          messages: messages.map(msg => ({
            role: msg.role,
            content: msg.content
          })),
          model: model,
          temperature: options.temperature || 0.7,
          max_tokens: options.max_tokens || 500
        });

        return response.data.choices[0].message.content;
      }
    } catch (error) {
      console.error('Error generating chat response:', error);
      throw error;
    }
  }
}
```

#### 3.1.2. Sử dụng service trong Controller

```javascript
// src/controllers/ai.controller.ts
import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { OpenSourceLLMService } from '../services/open-source-llm.service';
import { AuthGuard } from '../guards/auth.guard';

@Controller('ai')
@UseGuards(AuthGuard)
export class AIController {
  constructor(private llmService: OpenSourceLLMService) {}

  @Post('generate')
  async generateText(@Body() body: any) {
    try {
      const { prompt, options } = body;
      const response = await this.llmService.generateText(prompt, options);

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
        message: 'Lỗi khi tạo văn bản',
        error: {
          type: 'AI_ERROR',
          details: error.message
        }
      };
    }
  }

  @Post('chat')
  async generateChatResponse(@Body() body: any) {
    try {
      const { messages, options } = body;
      const response = await this.llmService.generateChatResponse(messages, options);

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
        message: 'Lỗi khi tạo phản hồi chat',
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

#### 3.2.1. Cấu hình Ollama trong Flowise

1. Đăng nhập vào Flowise
2. Truy cập **Credentials**
3. Tạo credential mới cho Ollama
4. Nhập URL (http://localhost:11434)
5. Lưu credential

#### 3.2.2. Tạo Chatflow với Ollama

1. Tạo chatflow mới
2. Thêm node "Chat Input"
3. Thêm node "Ollama" và kết nối với credential đã tạo
4. Cấu hình model (llama3, mistral, v.v.)
5. Thêm node "Chat Output" và kết nối
6. Lưu và xuất chatflow dưới dạng API

### 3.3. Tích hợp qua n8n

#### 3.3.1. Cấu hình Ollama trong n8n

1. Đăng nhập vào n8n
2. Truy cập **Credentials**
3. Tạo credential mới cho Ollama
4. Nhập URL (http://localhost:11434)
5. Lưu credential

#### 3.3.2. Tạo Workflow với Ollama

1. Tạo workflow mới
2. Thêm node "Webhook" để nhận request
3. Thêm node "Ollama" và kết nối với credential đã tạo
4. Cấu hình operation (Generate hoặc Chat)
5. Thêm node "Respond to Webhook" để trả về kết quả
6. Lưu và kích hoạt workflow

## 4. USE-CASES VÀ VÍ DỤ

### 4.1. Chatbot thông minh

```javascript
// Ví dụ: Chatbot với mô hình mã nguồn mở
async function handleCustomerMessage(message, sessionId) {
  try {
    // Lấy lịch sử chat
    const chatHistory = await getChatHistory(sessionId);

    // Tạo messages
    const messages = [
      { role: "system", content: "Bạn là trợ lý AI của NextFlow CRM, giúp đỡ khách hàng với thông tin sản phẩm và dịch vụ." },
      ...chatHistory.map(msg => ({
        role: msg.isUser ? "user" : "assistant",
        content: msg.content
      })),
      { role: "user", content: message }
    ];

    // Gọi mô hình
    const response = await llmService.generateChatResponse(messages);

    // Lưu tin nhắn vào lịch sử
    await saveChatMessage(sessionId, message, response);

    return response;
  } catch (error) {
    console.error('Error handling customer message:', error);
    return "Xin lỗi, tôi đang gặp sự cố kỹ thuật. Vui lòng thử lại sau.";
  }
}
```

### 4.2. Tạo nội dung marketing

```javascript
// Ví dụ: Tạo nội dung marketing với mô hình mã nguồn mở
async function generateMarketingContent(product, contentType, tone) {
  try {
    const prompt = `Tạo nội dung ${contentType} cho sản phẩm sau với tone ${tone}:
      Tên: ${product.name}
      Mô tả: ${product.description}
      Giá: ${product.price}
      Tính năng: ${product.features.join(', ')}
      Đối tượng: ${product.targetAudience}`;

    const response = await llmService.generateText(prompt, {
      temperature: 0.8,
      max_tokens: 1000
    });

    return response;
  } catch (error) {
    console.error('Error generating marketing content:', error);
    throw error;
  }
}
```

### 4.3. Phân loại phản hồi khách hàng

```javascript
// Ví dụ: Phân loại phản hồi khách hàng
async function classifyFeedback(feedback) {
  try {
    const prompt = `Phân loại phản hồi khách hàng sau vào một trong các danh mục: Khiếu nại, Góp ý, Khen ngợi, Câu hỏi, hoặc Khác.

      Phản hồi: "${feedback}"

      Danh mục:`;

    const response = await llmService.generateText(prompt, {
      temperature: 0.3,
      max_tokens: 50
    });

    return response.trim();
  } catch (error) {
    console.error('Error classifying feedback:', error);
    throw error;
  }
}
```

## 5. FINE-TUNING MÔ HÌNH

### 5.1. Chuẩn bị dữ liệu

```javascript
// Ví dụ: Chuẩn bị dữ liệu huấn luyện
async function prepareTrainingData() {
  try {
    // Lấy dữ liệu từ database
    const conversations = await db.collection('chat_history').find({
      quality_score: { $gte: 4 }  // Chỉ lấy các cuộc hội thoại chất lượng cao
    }).toArray();

    // Chuyển đổi sang định dạng huấn luyện
    const trainingData = conversations.map(conv => {
      return {
        messages: conv.messages.map(msg => ({
          role: msg.isUser ? "user" : "assistant",
          content: msg.content
        }))
      };
    });

    // Lưu vào file
    fs.writeFileSync('training_data.json', JSON.stringify(trainingData, null, 2));

    return trainingData;
  } catch (error) {
    console.error('Error preparing training data:', error);
    throw error;
  }
}
```

### 5.2. Fine-tuning với Ollama

```bash
# Tạo Modelfile
cat > Modelfile << EOF
FROM llama3
SYSTEM "Bạn là trợ lý AI của NextFlow CRM, giúp đỡ khách hàng với thông tin sản phẩm và dịch vụ."

# Thêm dữ liệu huấn luyện
TEMPLATE """{{ if .System }}{{ .System }}{{ end }}
{{ if .Prompt }}{{ .Prompt }}{{ end }}
"""
EOF

# Tạo mô hình tùy chỉnh
ollama create NextFlow-assistant -f Modelfile

# Fine-tune mô hình
ollama pull llama3
cat training_data.json | ollama tune -f Modelfile -o NextFlow-assistant:latest
```

### 5.3. Sử dụng mô hình đã fine-tune

```javascript
// Ví dụ: Sử dụng mô hình đã fine-tune
async function useFineTunedModel(prompt) {
  try {
    const response = await axios.post('http://localhost:11434/api/generate', {
      model: 'NextFlow-assistant',
      prompt: prompt,
      stream: false
    });

    return response.data.response;
  } catch (error) {
    console.error('Error using fine-tuned model:', error);
    throw error;
  }
}
```

## 6. QUẢN LÝ HIỆU SUẤT VÀ TÀI NGUYÊN

### 6.1. Giám sát tài nguyên

```javascript
// Ví dụ: Giám sát tài nguyên
async function monitorResources() {
  try {
    const { stdout } = await exec('nvidia-smi --query-gpu=utilization.gpu,utilization.memory,memory.used,memory.total --format=csv,noheader');

    const [gpuUtil, memUtil, memUsed, memTotal] = stdout.trim().split(', ');

    await db.collection('resource_metrics').insertOne({
      timestamp: new Date(),
      gpu_utilization: parseInt(gpuUtil),
      memory_utilization: parseInt(memUtil),
      memory_used: parseInt(memUsed.replace(' MiB', '')),
      memory_total: parseInt(memTotal.replace(' MiB', ''))
    });

    // Kiểm tra ngưỡng cảnh báo
    if (parseInt(gpuUtil) > 90 || parseInt(memUtil) > 90) {
      await sendAlert('GPU resource utilization high', {
        gpu_utilization: parseInt(gpuUtil),
        memory_utilization: parseInt(memUtil)
      });
    }
  } catch (error) {
    console.error('Error monitoring resources:', error);
  }
}

// Lên lịch giám sát
setInterval(monitorResources, 60000); // Mỗi phút
```

### 6.2. Caching kết quả

```javascript
// Ví dụ: Caching kết quả
const cache = new Map();

async function generateTextWithCache(prompt, options = {}) {
  // Tạo cache key
  const cacheKey = `${prompt}_${JSON.stringify(options)}`;

  // Kiểm tra cache
  if (cache.has(cacheKey)) {
    console.log('Cache hit');
    return cache.get(cacheKey);
  }

  // Gọi mô hình
  const response = await llmService.generateText(prompt, options);

  // Lưu vào cache
  cache.set(cacheKey, response);

  // Giới hạn kích thước cache
  if (cache.size > 1000) {
    const oldestKey = cache.keys().next().value;
    cache.delete(oldestKey);
  }

  return response;
}
```

## 7. KẾT LUẬN

Tích hợp mô hình AI mã nguồn mở vào NextFlow CRM mang lại nhiều lợi ích:

### 7.1. Lợi ích chính
- **Kiểm soát chi phí**: Không phụ thuộc vào API bên ngoài, giảm chi phí vận hành
- **Bảo mật dữ liệu**: Dữ liệu không rời khỏi hệ thống, đảm bảo an toàn thông tin
- **Tùy chỉnh cao**: Có thể fine-tune theo nhu cầu cụ thể của NextFlow CRM
- **Độc lập**: Không bị ràng buộc bởi nhà cung cấp bên ngoài

### 7.2. Khuyến nghị triển khai
- Bắt đầu với Ollama cho môi trường development
- Sử dụng LM Studio cho testing và prototype
- Triển khai TGI cho production với yêu cầu cao
- Thực hiện fine-tuning cho các use-case cụ thể

### 7.3. Tài liệu liên quan
- [Tổng quan Tích hợp AI](../tong-quan-ai.md)
- [AI Chatbot Đa kênh](../chatbot/ai-chatbot-da-kenh.md)
- [Tự động hóa Quy trình](../tu-dong-hoa/tu-dong-hoa-quy-trinh.md)

## 8. TÀI LIỆU THAM KHẢO

### 8.1. Công cụ triển khai
- [Ollama Documentation](https://github.com/ollama/ollama)
- [LM Studio Documentation](https://lmstudio.ai/docs)
- [Hugging Face Text Generation Inference](https://github.com/huggingface/text-generation-inference)

### 8.2. Mô hình AI
- [Llama 3 Documentation](https://ai.meta.com/llama/)
- [Mistral AI Documentation](https://docs.mistral.ai/)
- [Falcon Documentation](https://huggingface.co/tiiuae/falcon-7b)
- [Phi-2 Documentation](https://huggingface.co/microsoft/phi-2)

### 8.3. Tích hợp NextFlow CRM
- [Flowise Documentation](https://docs.flowiseai.com/)
- [n8n Documentation](https://docs.n8n.io/)
- [NextFlow CRM API Documentation](../../api-reference.md)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 1.0.0
**Tác giả**: NextFlow Development Team
