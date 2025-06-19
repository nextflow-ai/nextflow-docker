# AI CHATBOT ĐA KÊNH

## 1. GIỚI THIỆU

AI Chatbot đa kênh là một trong những tính năng chủ đạo của NextFlow CRM, cho phép doanh nghiệp tự động hóa giao tiếp với khách hàng trên nhiều nền tảng khác nhau. Chatbot này được thiết kế đặc biệt để quản lý và tương tác với khách hàng từ nhiều tài khoản marketplace (như Shopee, TikTok Shop, Lazada, v.v.), giúp tự động hóa việc trả lời câu hỏi, tư vấn sản phẩm và thậm chí chốt đơn hàng.

### 1.1. Đặc điểm chính

- **Đa kênh**: Tương tác với khách hàng trên nhiều nền tảng từ một hệ thống quản lý trung tâm
- **Tự động hóa**: Tự động trả lời câu hỏi, tư vấn sản phẩm và hỗ trợ chốt đơn
- **Cá nhân hóa**: Điều chỉnh phản hồi dựa trên thông tin khách hàng và lịch sử tương tác
- **Đa ngôn ngữ**: Hỗ trợ tiếng Việt và tiếng Anh
- **Khả năng mở rộng**: Dễ dàng thêm kênh mới và tùy chỉnh theo nhu cầu

### 1.2. Lợi ích

- **Tiết kiệm thời gian**: Giảm thời gian phản hồi khách hàng từ nhiều kênh
- **Tăng tỷ lệ chuyển đổi**: Phản hồi nhanh chóng và chính xác giúp tăng tỷ lệ chốt đơn
- **Nhất quán trong trải nghiệm**: Đảm bảo phản hồi nhất quán trên tất cả các kênh
- **Hoạt động 24/7**: Phục vụ khách hàng mọi lúc, không bỏ lỡ cơ hội bán hàng
- **Phân tích dữ liệu**: Thu thập và phân tích dữ liệu từ tất cả các kênh tại một nơi

## 2. KIẾN TRÚC CHATBOT ĐA KÊNH

### 2.1. Tổng quan kiến trúc

```
[Marketplace Channels]
    |
    v
[Channel Adapters] <---> [Message Queue]
    |                        |
    v                        v
[Message Router] <---> [AI Processing Engine]
    |                        |
    v                        v
[Response Generator] <---> [Knowledge Base]
    |
    v
[Analytics & Monitoring]
```

### 2.2. Các thành phần chính

#### 2.2.1. Channel Adapters

Kết nối với các API của các nền tảng marketplace:
- Shopee Adapter
- TikTok Shop Adapter
- Lazada Adapter
- WordPress Adapter
- Facebook Messenger Adapter
- Zalo Adapter

#### 2.2.2. Message Queue

Sử dụng RabbitMQ để xử lý tin nhắn từ nhiều kênh:
- Đảm bảo không mất tin nhắn
- Xử lý tin nhắn theo thứ tự ưu tiên
- Cân bằng tải khi có nhiều tin nhắn đồng thời

#### 2.2.3. Message Router

Phân tích và định tuyến tin nhắn:
- Xác định loại tin nhắn (câu hỏi, đặt hàng, khiếu nại)
- Xác định ngôn ngữ
- Định tuyến đến quy trình xử lý phù hợp

#### 2.2.4. AI Processing Engine

Xử lý tin nhắn bằng AI:
- Sử dụng Flowise để điều phối các mô hình AI
- Phân tích ý định và cảm xúc của khách hàng
- Trích xuất thông tin quan trọng
- Tạo phản hồi phù hợp

#### 2.2.5. Knowledge Base

Cơ sở kiến thức cho chatbot:
- Thông tin sản phẩm
- Câu hỏi thường gặp
- Chính sách bán hàng
- Lịch sử tương tác với khách hàng

#### 2.2.6. Response Generator

Tạo phản hồi cho khách hàng:
- Tùy chỉnh phản hồi theo kênh
- Cá nhân hóa phản hồi
- Thêm hình ảnh, liên kết và nút hành động
- Đảm bảo nhất quán với phong cách giao tiếp của thương hiệu

#### 2.2.7. Analytics & Monitoring

Theo dõi và phân tích hiệu suất:
- Thống kê tương tác
- Tỷ lệ chuyển đổi
- Thời gian phản hồi
- Mức độ hài lòng của khách hàng

## 3. TRIỂN KHAI CHATBOT ĐA KÊNH

### 3.1. Cấu hình Flowise cho Chatbot

#### 3.1.1. Thiết lập chatflow cơ bản

1. Tạo chatflow mới trong Flowise
2. Thêm node Chat Input
3. Thêm node Prompt Template với nội dung:

```
Bạn là trợ lý AI của cửa hàng {store_name}. Hãy trả lời câu hỏi của khách hàng một cách lịch sự, chuyên nghiệp và hữu ích.

Thông tin về cửa hàng:
- Tên cửa hàng: {store_name}
- Danh mục sản phẩm: {product_categories}
- Chính sách giao hàng: {shipping_policy}
- Chính sách đổi trả: {return_policy}

Câu hỏi của khách hàng: {question}
```

4. Thêm node LLM (OpenAI hoặc mô hình khác)
5. Thêm node Output Parser
6. Kết nối các node lại với nhau

#### 3.1.2. Tích hợp với cơ sở dữ liệu sản phẩm

1. Thêm node Document Loader để tải thông tin sản phẩm
2. Thêm node Vector Store để lưu trữ và truy vấn thông tin
3. Thêm node Conversational Retrieval QA
4. Kết nối với chatflow chính

### 3.2. Tích hợp với các nền tảng marketplace

#### 3.2.1. Tích hợp Zalo

```typescript
// zalo.adapter.ts
import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { ChatbotService } from '../chatbot/chatbot.service';

@Injectable()
export class ZaloAdapter {
  constructor(
    private readonly httpService: HttpService,
    private readonly configService: ConfigService,
    private readonly chatbotService: ChatbotService,
  ) {}

  async initialize(appId: string, secretKey: string, accessToken: string) {
    // Đăng ký webhook với Zalo Official Account API
    const webhookUrl = `${this.configService.get('app.url')}/api/webhook/zalo/chat`;

    const response = await this.httpService.post('https://openapi.zalo.me/v2.0/oa/webhook', {
      webhook: webhookUrl,
      types: ['user_send_text', 'user_send_image', 'user_send_sticker']
    }, {
      headers: {
        'Content-Type': 'application/json',
        'access_token': accessToken,
      },
    }).toPromise();

    return response.data;
  }

  async sendMessage(userId: string, message: string, accessToken: string) {
    try {
      const response = await this.httpService.post('https://openapi.zalo.me/v2.0/oa/message', {
        recipient: {
          user_id: userId
        },
        message: {
          text: message
        }
      }, {
        headers: {
          'Content-Type': 'application/json',
          'access_token': accessToken,
        },
      }).toPromise();

      return response.data;
    } catch (error) {
      console.error('Error sending Zalo message:', error);
      throw error;
    }
  }

  async handleWebhook(payload: any, organizationId: string) {
    const { sender, message, timestamp } = payload;

    // Xử lý tin nhắn từ Zalo
    const response = await this.chatbotService.processMessage(
      message.text,
      sender.id,
      'zalo',
      organizationId,
      {
        platform: 'zalo',
        userId: sender.id,
        timestamp: timestamp
      }
    );

    // Gửi phản hồi về Zalo
    await this.sendMessage(sender.id, response.text, payload.accessToken);

    return response;
  }
}
```

#### 3.2.2. Tích hợp Shopee

```typescript
// shopee.adapter.ts
import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { ChatbotService } from '../chatbot/chatbot.service';

@Injectable()
export class ShopeeAdapter {
  constructor(
    private httpService: HttpService,
    private configService: ConfigService,
    private chatbotService: ChatbotService,
  ) {}

  async initialize(shopId: string, partnerId: string, partnerKey: string) {
    // Đăng ký webhook với Shopee Open Platform
    const timestamp = Math.floor(Date.now() / 1000);
    const baseUrl = this.configService.get('shopee.openApiUrl');
    const path = '/api/v2/push/subscribe';
    const signature = this.generateSignature(partnerId, partnerKey, path, timestamp);

    const response = await this.httpService.post(`${baseUrl}${path}`, {
      partner_id: parseInt(partnerId),
      shop_id: parseInt(shopId),
      timestamp,
      push_type: 'chat_message',
      callback_url: `${this.configService.get('app.url')}/api/webhook/shopee/chat/${shopId}`,
    }, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': signature,
      },
    }).toPromise();

    return response.data;
  }

  async handleChatMessage(shopId: string, message: any) {
    const { conversation_id, message_id, message_type, message_content, from_id, to_id, created_timestamp } = message;

    // Lấy thông tin tổ chức từ shopId
    const organization = await this.getOrganizationByShopId(shopId);

    // Xử lý tin nhắn với chatbot
    const response = await this.chatbotService.processMessage(
      message_content.text,
      'shopee',
      shopId,
      from_id,
      organization.id,
    );

    // Gửi phản hồi lại cho khách hàng
    await this.sendMessage(shopId, conversation_id, response.text);

    return true;
  }

  async sendMessage(shopId: string, conversationId: string, text: string) {
    // Gửi tin nhắn qua Shopee Open Platform
    // Implement logic here
  }

  private generateSignature(partnerId: string, partnerKey: string, path: string, timestamp: number): string {
    // Implement signature generation logic
    return '';
  }

  private async getOrganizationByShopId(shopId: string) {
    // Implement logic to get organization by shop ID
    return { id: '1' };
  }
}
```

#### 3.2.2. Tích hợp TikTok Shop

```typescript
// tiktok-shop.adapter.ts
import { Injectable } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { ChatbotService } from '../chatbot/chatbot.service';

@Injectable()
export class TikTokShopAdapter {
  constructor(
    private httpService: HttpService,
    private configService: ConfigService,
    private chatbotService: ChatbotService,
  ) {}

  // Implement similar methods as ShopeeAdapter
}
```

### 3.3. Xử lý tin nhắn đa kênh

```typescript
// chatbot.service.ts
import { Injectable } from '@nestjs/common';
import { FlowiseService } from '../ai/flowise.service';
import { N8nService } from '../ai/n8n.service';
import { OrganizationsService } from '../organizations/organizations.service';

@Injectable()
export class ChatbotService {
  constructor(
    private flowiseService: FlowiseService,
    private n8nService: N8nService,
    private organizationsService: OrganizationsService,
  ) {}

  async processMessage(
    message: string,
    platform: string,
    accountId: string,
    customerId: string,
    organizationId: string,
  ) {
    // 1. Lấy thông tin tổ chức
    const organization = await this.organizationsService.findOne(organizationId);

    // 2. Lấy chatflow ID phù hợp
    const chatflowId = this.getChatflowId(organization, platform);

    // 3. Chuẩn bị context cho chatbot
    const context = await this.prepareContext(organization, platform, accountId, customerId);

    // 4. Gọi Flowise để xử lý tin nhắn
    const response = await this.flowiseService.getChatflowResponse(
      chatflowId,
      message,
      context,
      organizationId,
    );

    // 5. Ghi nhật ký tương tác
    await this.logInteraction(organizationId, platform, accountId, customerId, message, response.text);

    // 6. Kiểm tra nếu cần kích hoạt workflow
    if (this.shouldTriggerWorkflow(response)) {
      await this.n8nService.triggerWorkflow(
        organization.settings.chatbotSettings.followUpWorkflowId,
        {
          message,
          response: response.data,
          customer: customerId,
          account: accountId,
          platform,
        },
        organizationId,
      );
    }

    return response;
  }

  private getChatflowId(organization: any, platform: string): string {
    // Lấy chatflow ID phù hợp với nền tảng
    const platformSettings = organization.settings.chatbotSettings.platforms[platform];
    return platformSettings?.chatflowId || organization.settings.chatbotSettings.defaultChatflowId;
  }

  private async prepareContext(organization: any, platform: string, accountId: string, customerId: string) {
    // Chuẩn bị context cho chatbot
    // Implement logic here
    return {
      store_name: organization.name,
      product_categories: organization.productCategories.join(', '),
      shipping_policy: organization.settings.shippingPolicy,
      return_policy: organization.settings.returnPolicy,
      // Thêm thông tin khác
    };
  }

  private async logInteraction(organizationId: string, platform: string, accountId: string, customerId: string, message: string, response: string) {
    // Ghi nhật ký tương tác
    // Implement logic here
  }

  private shouldTriggerWorkflow(response: any): boolean {
    // Kiểm tra nếu cần kích hoạt workflow
    return response.intent === 'purchase' || response.sentiment > 0.8;
  }
}
```

## 4. TÍNH NĂNG NÂNG CAO

### 4.1. Phân tích ý định mua hàng

Chatbot có khả năng phát hiện khi khách hàng có ý định mua hàng và chủ động hỗ trợ quá trình này:

1. **Phát hiện ý định**: Sử dụng NLP để phát hiện khi khách hàng muốn mua hàng
2. **Hỗ trợ thông tin**: Cung cấp thông tin chi tiết về sản phẩm, giá cả, khuyến mãi
3. **Hướng dẫn mua hàng**: Hướng dẫn khách hàng các bước để hoàn tất đơn hàng
4. **Tạo đơn hàng**: Tự động tạo đơn hàng trong hệ thống
5. **Theo dõi chuyển đổi**: Đo lường tỷ lệ chuyển đổi từ chat sang đơn hàng

### 4.2. Cá nhân hóa trải nghiệm

Chatbot cá nhân hóa trải nghiệm dựa trên thông tin và lịch sử của khách hàng:

1. **Nhận diện khách hàng**: Nhận diện khách hàng qua ID hoặc thông tin liên hệ
2. **Lịch sử tương tác**: Sử dụng lịch sử tương tác để cá nhân hóa phản hồi
3. **Sở thích sản phẩm**: Gợi ý sản phẩm dựa trên sở thích và lịch sử mua hàng
4. **Điều chỉnh giọng điệu**: Điều chỉnh giọng điệu phù hợp với từng khách hàng
5. **Nhắc nhở cá nhân**: Gửi nhắc nhở về sản phẩm đã xem, giỏ hàng bỏ dở

### 4.3. Chuyển giao cho nhân viên

Khi chatbot không thể xử lý tình huống phức tạp, hệ thống sẽ chuyển giao cho nhân viên:

1. **Phát hiện tình huống phức tạp**: Nhận diện khi nào cần sự can thiệp của con người
2. **Thông báo nhân viên**: Gửi thông báo cho nhân viên phù hợp
3. **Chuyển giao context**: Cung cấp toàn bộ lịch sử trò chuyện và thông tin khách hàng
4. **Hỗ trợ nhân viên**: Gợi ý phản hồi cho nhân viên dựa trên AI
5. **Học hỏi từ can thiệp**: Cải thiện chatbot dựa trên cách nhân viên xử lý tình huống

## 5. QUẢN LÝ VÀ GIÁM SÁT

### 5.1. Dashboard quản lý

Dashboard cung cấp tổng quan về hoạt động của chatbot đa kênh:

1. **Tổng quan tương tác**: Số lượng tin nhắn, tỷ lệ phản hồi, thời gian phản hồi
2. **Phân tích theo kênh**: Hiệu suất trên từng kênh (Shopee, TikTok Shop, v.v.)
3. **Phân tích theo tài khoản**: Hiệu suất trên từng tài khoản marketplace
4. **Phân tích nội dung**: Chủ đề phổ biến, câu hỏi thường gặp
5. **Phân tích chuyển đổi**: Tỷ lệ chuyển đổi từ chat sang đơn hàng

### 5.2. Cải thiện liên tục

Hệ thống liên tục cải thiện dựa trên dữ liệu và phản hồi:

1. **Thu thập phản hồi**: Đánh giá của khách hàng về trải nghiệm chatbot
2. **Phân tích lỗi**: Xác định và phân tích các tình huống chatbot không xử lý tốt
3. **Cập nhật kiến thức**: Cập nhật cơ sở kiến thức dựa trên câu hỏi mới
4. **Tinh chỉnh mô hình**: Điều chỉnh mô hình AI dựa trên dữ liệu thực tế
5. **A/B testing**: Thử nghiệm các phiên bản khác nhau của chatbot

## 6. TÍCH HỢP VỚI CRM

### 6.1. Đồng bộ dữ liệu khách hàng

Chatbot đa kênh tích hợp chặt chẽ với hệ thống CRM:

1. **Hồ sơ khách hàng 360**: Tích hợp dữ liệu chat vào hồ sơ khách hàng
2. **Lịch sử tương tác**: Lưu trữ toàn bộ lịch sử tương tác qua chat
3. **Cập nhật thông tin**: Cập nhật thông tin khách hàng từ tương tác chat
4. **Ghi chú và tag**: Thêm ghi chú và tag cho khách hàng dựa trên tương tác
5. **Đồng bộ đa kênh**: Đồng bộ thông tin khách hàng giữa các kênh

### 6.2. Tích hợp với quy trình bán hàng

Chatbot hỗ trợ quy trình bán hàng:

1. **Tạo lead**: Tự động tạo lead từ tương tác chat
2. **Đánh giá lead**: Đánh giá và phân loại lead dựa trên tương tác
3. **Chuyển đổi cơ hội**: Chuyển đổi lead thành cơ hội bán hàng
4. **Theo dõi cơ hội**: Cập nhật trạng thái cơ hội dựa trên tương tác
5. **Báo cáo hiệu quả**: Đo lường hiệu quả của chatbot trong quy trình bán hàng

## 7. TRIỂN KHAI THỰC TẾ

### 7.1. Quy trình triển khai

1. **Phân tích nhu cầu**: Xác định nhu cầu cụ thể của doanh nghiệp
2. **Thiết kế chatbot**: Thiết kế luồng trò chuyện và cơ sở kiến thức
3. **Tích hợp kênh**: Kết nối với các nền tảng marketplace
4. **Đào tạo mô hình**: Đào tạo mô hình AI với dữ liệu của doanh nghiệp
5. **Kiểm thử**: Kiểm thử chatbot trên tất cả các kênh
6. **Triển khai**: Triển khai chatbot cho người dùng thực
7. **Giám sát và cải thiện**: Theo dõi hiệu suất và liên tục cải thiện

### 7.2. Các trường hợp sử dụng

#### 7.2.1. Thương mại điện tử

- Tự động trả lời câu hỏi về sản phẩm
- Hỗ trợ đặt hàng và thanh toán
- Theo dõi đơn hàng
- Xử lý đổi trả
- Gợi ý sản phẩm liên quan

#### 7.2.2. Dịch vụ

- Đặt lịch hẹn
- Tư vấn dịch vụ
- Báo giá
- Hỗ trợ kỹ thuật
- Phản hồi đánh giá

#### 7.2.3. Giáo dục

- Tư vấn khóa học
- Trả lời câu hỏi về nội dung học tập
- Nhắc nhở lịch học
- Hỗ trợ đăng ký và thanh toán
- Phản hồi thắc mắc của học viên

## 8. KẾT LUẬN

AI Chatbot đa kênh là một giải pháp mạnh mẽ giúp doanh nghiệp tự động hóa giao tiếp với khách hàng trên nhiều nền tảng marketplace. Với khả năng tích hợp sâu với hệ thống CRM, chatbot không chỉ giúp tiết kiệm thời gian và chi phí mà còn nâng cao trải nghiệm khách hàng và tăng tỷ lệ chuyển đổi.

Để triển khai thành công, doanh nghiệp cần có chiến lược rõ ràng, thiết kế chatbot phù hợp với nhu cầu cụ thể, và liên tục cải thiện dựa trên dữ liệu và phản hồi. Với sự hỗ trợ của NextFlow CRM, việc triển khai và quản lý chatbot đa kênh trở nên đơn giản và hiệu quả hơn.
