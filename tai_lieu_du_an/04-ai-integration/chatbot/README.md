# CHATBOT INTEGRATION - NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Cấu trúc tài liệu](#2-cấu-trúc-tài-liệu)
3. [Hướng dẫn sử dụng](#3-hướng-dẫn-sử-dụng)
4. [Tích hợp đa kênh](#4-tích-hợp-đa-kênh)
5. [Zalo Chatbot](#5-zalo-chatbot)
6. [Tài liệu liên quan](#6-tài-liệu-liên-quan)

## 1. GIỚI THIỆU

Thư mục này chứa tài liệu về tích hợp chatbot AI cho NextFlow CRM, bao gồm:

- ✅ Chatbot đa kênh (Facebook, Zalo, Telegram, Website)
- ✅ Tích hợp AI với n8n và Flowise
- ✅ Tự động hóa chăm sóc khách hàng
- ✅ Hướng dẫn triển khai chi tiết
- ✅ Prompt templates và workflows

### 1.1. Tính năng chính

🤖 **AI-Powered Chatbot**
- Xử lý ngôn ngữ tự nhiên tiếng Việt
- Multi-model AI support (OpenAI, Anthropic, Google AI)
- Context-aware conversations
- Intent classification và entity extraction

📱 **Multi-Channel Support**
- Zalo Official Account
- Facebook Messenger
- Telegram Bot
- Website Live Chat
- WhatsApp Business (coming soon)

🔄 **Automation Workflows**
- n8n workflow automation
- Flowise chatflow management
- Customer service escalation
- Lead qualification và nurturing

📊 **Analytics & Monitoring**
- Conversation analytics
- Performance metrics
- Customer satisfaction tracking
- Real-time monitoring

## 2. CẤU TRÚC TÀI LIỆU

```
📁 04-ai-integration/chatbot/
├── 📄 README.md                    # Tài liệu tổng quan (file này)
├── 📄 ai-chatbot-da-kenh.md        # Chatbot đa kênh marketplace
├── 📄 zalo-chatbot-setup.md        # Setup Zalo chatbot chi tiết
└── 📄 zalo-deployment-guide.md     # Hướng dẫn triển khai Zalo
```

### 2.1. Mô tả từng file

| File | Mô tả | Độ ưu tiên |
|------|-------|------------|
| `ai-chatbot-da-kenh.md` | Tổng quan chatbot đa kênh, kiến trúc và tích hợp | ⭐⭐⭐⭐⭐ |
| `zalo-chatbot-setup.md` | Hướng dẫn setup chi tiết Zalo chatbot với n8n/Flowise | ⭐⭐⭐⭐⭐ |
| `zalo-deployment-guide.md` | Hướng dẫn triển khai production Zalo chatbot | ⭐⭐⭐⭐ |

## 3. HƯỚNG DẪN SỬ DỤNG

### 3.1. Cho người mới bắt đầu

1. **Đọc tổng quan**: Bắt đầu với `ai-chatbot-da-kenh.md`
2. **Chọn platform**: Quyết định platform chatbot (Zalo, Facebook, etc.)
3. **Setup cơ bản**: Theo hướng dẫn trong `zalo-chatbot-setup.md`
4. **Triển khai**: Sử dụng `zalo-deployment-guide.md` cho production

### 3.2. Cho developers

```bash
# 1. Clone repository
git clone https://github.com/nextflow-crm/nextflow-crm.git

# 2. Setup environment
cp .env.example .env
nano .env  # Cấu hình API keys

# 3. Install dependencies
npm install

# 4. Start development
npm run dev:chatbot
```

### 3.3. Cho system administrators

```bash
# 1. Production deployment
docker-compose -f docker-compose.production.yml up -d

# 2. Monitor services
docker-compose logs -f

# 3. Health checks
curl https://api.nextflow-crm.com/health
```

## 4. TÍCH HỢP ĐA KÊNH

### 4.1. Supported Platforms

| Platform | Status | Tài liệu | API Support |
|----------|--------|----------|-------------|
| **Zalo OA** | ✅ Hoàn thành | `zalo-chatbot-setup.md` | Full API |
| **Facebook** | ✅ Hoàn thành | `ai-chatbot-da-kenh.md` | Messenger API |
| **Telegram** | ✅ Hoàn thành | `ai-chatbot-da-kenh.md` | Bot API |
| **Website** | ✅ Hoàn thành | `ai-chatbot-da-kenh.md` | WebSocket |
| **WhatsApp** | 🚧 Đang phát triển | Coming soon | Business API |

### 4.2. Architecture Overview

```
┌─────────────────┐    ┌──────────────┐    ┌─────────────┐
│   Zalo OA       │    │   Facebook   │    │  Telegram   │
│   Webhook       │    │   Webhook    │    │   Webhook   │
└─────────┬───────┘    └──────┬───────┘    └─────┬───────┘
          │                   │                  │
          └───────────────────┼──────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │   NextFlow CRM    │
                    │   Webhook Router  │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │   n8n Workflow   │
                    │   Processing      │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │   Flowise AI      │
                    │   Chatflow        │
                    └─────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │   Response        │
                    │   Delivery        │
                    └───────────────────┘
```

## 5. ZALO CHATBOT

### 5.1. Quick Start

```bash
# 1. Cấu hình Zalo credentials
export ZALO_APP_ID="your_app_id"
export ZALO_ACCESS_TOKEN="your_access_token"

# 2. Setup webhook
curl -X POST "https://openapi.zalo.me/v2.0/oa/webhook" \
  -H "access_token: $ZALO_ACCESS_TOKEN" \
  -d '{"webhook": "https://your-domain.com/webhook/zalo"}'

# 3. Test chatbot
curl -X POST "https://your-domain.com/api/zalo/test" \
  -d '{"message": "Hello test"}'
```

### 5.2. Features

🎯 **Customer Service Automation**
- Tự động trả lời FAQ
- Escalation to human agents
- Ticket creation và tracking
- Follow-up automation

💼 **Sales Support**
- Product recommendations
- Lead qualification
- Quote generation
- Order status tracking

📈 **Analytics**
- Conversation metrics
- Customer satisfaction
- Response time tracking
- Intent analysis

### 5.3. Prompt Templates

```javascript
// Customer Service Prompt
const customerServicePrompt = `
Bạn là trợ lý chăm sóc khách hàng của NextFlow CRM trên Zalo.

NGUYÊN TẮC:
- Lịch sự, thân thiện, chuyên nghiệp
- Trả lời ngắn gọn (< 500 ký tự)
- Sử dụng emoji phù hợp
- Hỏi thêm để hiểu rõ nhu cầu

KHẢ NĂNG:
✅ Tư vấn sản phẩm
✅ Hỗ trợ kỹ thuật
✅ Kiểm tra đơn hàng
✅ Thu thập feedback

Câu hỏi: {user_message}
`;

// Sales Prompt
const salesPrompt = `
Bạn là tư vấn bán hàng NextFlow CRM trên Zalo.

SẢN PHẨM:
- Basic: 500k/tháng (3 users)
- Standard: 1.5M/tháng (10 users)  
- Premium: 5M/tháng (30 users)
- Enterprise: Tùy chỉnh

Hãy tư vấn phù hợp với nhu cầu khách hàng.
`;
```

## 6. TÀI LIỆU LIÊN QUAN

### 6.1. Tài liệu kỹ thuật

- 📁 `../tong-quan-ai.md` - Tổng quan AI integration
- 📁 `../mo-hinh-ai/` - Các mô hình AI được hỗ trợ
- 📁 `../../06-api/endpoints/zalo-api.md` - API documentation
- 📁 `../../07-trien-khai/cong-cu/n8n/` - N8n workflows

### 6.2. Schema và Database

- 📁 `../../05-schema/tinh-nang/chatbot-nlp.md` - Chatbot schema
- 📁 `../../05-schema/tinh-nang/ai-integration.md` - AI integration schema

### 6.3. Deployment và Operations

- 📁 `../../07-trien-khai/` - Deployment guides
- 📁 `../../07-trien-khai/bao-mat/` - Security configuration
- 📁 `../../07-trien-khai/monitoring/` - Monitoring setup

### 6.4. Business Documentation

- 📁 `../../10-mo-hinh-kinh-doanh/` - Business model
- 📁 `../../01-tong-quan/` - Project overview

## 7. SUPPORT VÀ ĐÓNG GÓP

### 7.1. Báo lỗi

Nếu gặp vấn đề, vui lòng:

1. Kiểm tra logs: `docker-compose logs chatbot`
2. Xem troubleshooting trong tài liệu
3. Tạo issue trên GitHub với thông tin chi tiết

### 7.2. Đóng góp

```bash
# 1. Fork repository
# 2. Tạo feature branch
git checkout -b feature/zalo-enhancement

# 3. Commit changes
git commit -m "Add: Zalo quick reply support"

# 4. Push và tạo PR
git push origin feature/zalo-enhancement
```

### 7.3. Liên hệ

- 📧 Email: dev@nextflow-crm.com
- 💬 Slack: #chatbot-development
- 📞 Hotline: 1900-xxxx

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow AI Team

> 💡 **Tip**: Để triển khai nhanh Zalo chatbot, hãy bắt đầu với `zalo-chatbot-setup.md` và làm theo từng bước một cách tuần tự.
