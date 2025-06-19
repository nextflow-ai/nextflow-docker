# HƯỚNG DẪN SETUP NHIỀU CỬA HÀNG - NextFlow CRM

## MỤC LỤC

1. [Chuẩn bị](#1-chuẩn-bị)
2. [Setup Shopee](#2-setup-shopee)
3. [Setup Lazada](#3-setup-lazada)
4. [Setup TikTok Shop](#4-setup-tiktok-shop)
5. [Setup Facebook](#5-setup-facebook)
6. [Setup Zalo](#6-setup-zalo)
7. [Cấu hình AI Chatbot](#7-cấu-hình-ai-chatbot)
8. [Testing và Go-live](#8-testing-và-go-live)

## 1. CHUẨN BỊ

### 1.1. Checklist trước khi bắt đầu

**Thông tin cần có**:
```
☐ Danh sách tất cả shop/kênh hiện tại
☐ Thông tin đăng nhập các tài khoản
☐ Quyền admin/developer trên các platform
☐ Danh sách sản phẩm và giá
☐ Chính sách bán hàng, đổi trả
☐ Team phụ trách (2-3 người)
```

**Ví dụ inventory**:
```
📋 SHOP INVENTORY - CÔNG TY ABC
┌─────────────────────────────────────────┐
│ SHOPEE:                                 │
│ ├── Shop A: Thời trang nam              │
│ ├── Shop B: Thời trang nữ               │
│ └── Shop C: Phụ kiện                    │
│                                         │
│ LAZADA:                                 │
│ ├── Shop 1: Điện tử                     │
│ └── Shop 2: Gia dụng                    │
│                                         │
│ KHÁC:                                   │
│ ├── TikTok Shop: Mix products           │
│ ├── Facebook: Fanpage chính             │
│ ├── Website: abc-fashion.com            │
│ └── Zalo: Business account              │
└─────────────────────────────────────────┘
```

### 1.2. Lập kế hoạch triển khai

**Phase 1** (Tuần 1-2): Core platforms
- Shopee (shop chính)
- Lazada (shop chính)

**Phase 2** (Tuần 3): Social platforms  
- Facebook Fanpage
- Zalo Business

**Phase 3** (Tuần 4): Remaining channels
- TikTok Shop
- Website chat
- Shopee/Lazada shops phụ

## 2. SETUP SHOPEE

### 2.1. Tạo Shopee App

**Bước 1**: Truy cập Shopee Open Platform
```
🌐 URL: https://open.shopee.com/
1. Đăng nhập bằng tài khoản Shopee seller
2. Vào "My Apps" → "Create New App"
3. Điền thông tin:
   - App Name: "NextFlow CRM Integration"
   - App Type: "Public App"
   - Callback URL: https://your-domain.com/callback/shopee
```

**Bước 2**: Lấy credentials
```
📋 SHOPEE CREDENTIALS
┌─────────────────────────────────────────┐
│ Partner ID: 123456                      │
│ Partner Key: abc123def456...            │
│ Shop ID: 789012                         │
│ Callback URL: https://...               │
└─────────────────────────────────────────┘
```

### 2.2. Cấu hình trong NextFlow CRM

**Bước 1**: Vào Settings → Integrations → Shopee
```
⚙️ SHOPEE INTEGRATION SETUP
┌─────────────────────────────────────────┐
│ Shop Name: [Shopee Shop A]              │
│ Partner ID: [123456]                    │
│ Partner Key: [abc123def456...]          │
│ Shop ID: [789012]                       │
│                                         │
│ Permissions:                            │
│ ☑️ Read messages                        │
│ ☑️ Send messages                        │
│ ☑️ Read orders                          │
│ ☑️ Read products                        │
│                                         │
│ [Test Connection] [Save]                │
└─────────────────────────────────────────┘
```

**Bước 2**: Authorize app
```
🔐 AUTHORIZATION FLOW
1. Click "Authorize" button
2. Redirect to Shopee login
3. Grant permissions
4. Redirect back to NextFlow CRM
5. ✅ Connection established
```

### 2.3. Setup Webhook

**Tự động setup**:
```javascript
// NextFlow CRM tự động đăng ký webhook
POST https://partner.shopeemobile.com/api/v2/push/subscribe
{
  "partner_id": 123456,
  "shop_id": 789012,
  "push_type": "chat_message",
  "callback_url": "https://your-crm.com/webhook/shopee/789012"
}
```

**Verify webhook**:
```
✅ WEBHOOK VERIFICATION
┌─────────────────────────────────────────┐
│ Status: Active                          │
│ Endpoint: /webhook/shopee/789012        │
│ Events: chat_message, order_update      │
│ Last ping: 2024-01-15 14:30:00         │
│ Success rate: 100%                     │
└─────────────────────────────────────────┘
```

## 3. SETUP LAZADA

### 3.1. Tạo Lazada App

**Bước 1**: Truy cập Lazada Open Platform
```
🌐 URL: https://open.lazada.com/
1. Login với Lazada seller account
2. Console → Create Application
3. Fill information:
   - App Name: "NextFlow CRM"
   - App Type: "Web Application"
   - Redirect URI: https://your-domain.com/callback/lazada
```

**Bước 2**: Get API credentials
```
📋 LAZADA CREDENTIALS
┌─────────────────────────────────────────┐
│ App Key: lzd_app_123456                 │
│ App Secret: secret_abc123def...         │
│ Seller ID: 987654                      │
│ Access Token: (generated after auth)    │
└─────────────────────────────────────────┘
```

### 3.2. Cấu hình trong NextFlow CRM

**Integration setup**:
```
⚙️ LAZADA INTEGRATION SETUP
┌─────────────────────────────────────────┐
│ Shop Name: [Lazada Electronics]         │
│ App Key: [lzd_app_123456]               │
│ App Secret: [secret_abc123def...]       │
│ Seller ID: [987654]                     │
│                                         │
│ Scopes:                                 │
│ ☑️ Read messages                        │
│ ☑️ Send messages                        │
│ ☑️ Read orders                          │
│ ☑️ Manage products                      │
│                                         │
│ [Authorize] [Test] [Save]               │
└─────────────────────────────────────────┘
```

## 4. SETUP TIKTOK SHOP

### 4.1. TikTok Shop API

**Bước 1**: Đăng ký TikTok for Business
```
🌐 URL: https://ads.tiktok.com/marketing_api/
1. Create developer account
2. Apply for Shop API access
3. Wait for approval (3-5 days)
```

**Bước 2**: Cấu hình app
```
📋 TIKTOK SHOP CREDENTIALS
┌─────────────────────────────────────────┐
│ App Key: ttshop_123456                  │
│ App Secret: tts_secret_abc123...        │
│ Shop ID: 555666                         │
│ Webhook URL: https://...                │
└─────────────────────────────────────────┘
```

### 4.2. Integration setup

**Trong NextFlow CRM**:
```
⚙️ TIKTOK SHOP SETUP
┌─────────────────────────────────────────┐
│ Shop Name: [TikTok Mix Products]         │
│ App Key: [ttshop_123456]                │
│ App Secret: [tts_secret_abc123...]      │
│ Shop ID: [555666]                       │
│                                         │
│ Features:                               │
│ ☑️ Message sync                         │
│ ☑️ Order management                     │
│ ☑️ Product sync                         │
│ ☐ Live stream chat (coming soon)       │
│                                         │
│ [Connect] [Test] [Save]                 │
└─────────────────────────────────────────┘
```

## 5. SETUP FACEBOOK

### 5.1. Facebook App

**Bước 1**: Tạo Facebook App
```
🌐 URL: https://developers.facebook.com/
1. Create App → Business
2. Add Messenger product
3. Add Pages product
4. Get Page Access Token
```

**Bước 2**: Setup Webhook
```
📋 FACEBOOK WEBHOOK
┌─────────────────────────────────────────┐
│ Callback URL: https://your-crm.com/     │
│               webhook/facebook          │
│ Verify Token: your_verify_token         │
│ Subscription Fields:                    │
│ ☑️ messages                             │
│ ☑️ messaging_postbacks                  │
│ ☑️ messaging_optins                     │
└─────────────────────────────────────────┘
```

### 5.2. Cấu hình trong NextFlow CRM

```
⚙️ FACEBOOK INTEGRATION
┌─────────────────────────────────────────┐
│ Page Name: [ABC Fashion Fanpage]        │
│ Page ID: [123456789012345]              │
│ Access Token: [EAABwz...very_long...]   │
│ App Secret: [abc123def456...]           │
│                                         │
│ Permissions:                            │
│ ☑️ pages_messaging                      │
│ ☑️ pages_read_engagement                │
│ ☑️ pages_manage_metadata                │
│                                         │
│ [Connect Page] [Test] [Save]            │
└─────────────────────────────────────────┘
```

## 6. SETUP ZALO

### 6.1. Zalo Business API

**Bước 1**: Đăng ký Zalo for Business
```
🌐 URL: https://developers.zalo.me/
1. Tạo ứng dụng Zalo
2. Chọn loại: Official Account API
3. Điền thông tin doanh nghiệp
4. Chờ duyệt (1-2 ngày)
```

**Bước 2**: Lấy credentials
```
📋 ZALO CREDENTIALS
┌─────────────────────────────────────────┐
│ App ID: 123456789                       │
│ App Secret: zalo_secret_abc123...       │
│ OA ID: 987654321                        │
│ Access Token: (refresh every 90 days)   │
└─────────────────────────────────────────┘
```

### 6.2. Cấu hình trong NextFlow CRM

```
⚙️ ZALO INTEGRATION
┌─────────────────────────────────────────┐
│ OA Name: [ABC Fashion Official]         │
│ App ID: [123456789]                     │
│ App Secret: [zalo_secret_abc123...]     │
│ OA ID: [987654321]                      │
│                                         │
│ Features:                               │
│ ☑️ Receive messages                     │
│ ☑️ Send messages                        │
│ ☑️ Send notifications                   │
│ ☑️ User management                      │
│                                         │
│ [Authorize] [Test] [Save]               │
└─────────────────────────────────────────┘
```

## 7. CẤU HÌNH AI CHATBOT

### 7.1. Tạo Bot Profile cho từng kênh

**Shopee Shop A** (Thời trang nam):
```
🤖 BOT CONFIGURATION - SHOPEE A
┌─────────────────────────────────────────┐
│ Bot Name: "Trợ lý Shop A"               │
│ Personality: Thân thiện, trẻ trung      │
│ Language: Tiếng Việt                    │
│                                         │
│ Knowledge Base:                         │
│ - Products: Áo, quần, phụ kiện nam      │
│ - Sizes: S, M, L, XL, XXL               │
│ - Policies: Freeship >300k, đổi 7 ngày │
│ - Promotions: Sale cuối tuần 20%        │
│                                         │
│ Auto Responses:                         │
│ - Greeting: "Chào anh! Shop giúp gì?"   │
│ - Size: "Sản phẩm có size từ S-XXL"     │
│ - Ship: "Freeship cho đơn từ 300k"      │
│ - Return: "Đổi trả trong 7 ngày"        │
└─────────────────────────────────────────┘
```

**Lazada Shop** (Điện tử):
```
🤖 BOT CONFIGURATION - LAZADA
┌─────────────────────────────────────────┐
│ Bot Name: "Chuyên viên kỹ thuật"        │
│ Personality: Chuyên nghiệp, kỹ thuật    │
│ Language: Tiếng Việt                    │
│                                         │
│ Knowledge Base:                         │
│ - Products: Laptop, điện thoại, phụ kiện│
│ - Specs: Chi tiết kỹ thuật              │
│ - Warranty: 12-24 tháng                 │
│ - Support: Hỗ trợ kỹ thuật              │
│                                         │
│ Auto Responses:                         │
│ - Greeting: "Xin chào! Cần tư vấn gì?"  │
│ - Specs: "Sản phẩm có thông số..."      │
│ - Warranty: "Bảo hành 12 tháng"         │
│ - Support: "Hỗ trợ kỹ thuật 24/7"       │
└─────────────────────────────────────────┘
```

### 7.2. Training Data

**Upload training data**:
```
📚 TRAINING DATA UPLOAD
┌─────────────────────────────────────────┐
│ 1. FAQ file: shopee_a_faq.csv           │
│    - 500 câu hỏi thường gặp             │
│    - Answers đã được review             │
│                                         │
│ 2. Product catalog: products.json       │
│    - 1000 sản phẩm với mô tả            │
│    - Giá, size, màu sắc                 │
│                                         │
│ 3. Conversation history: chat_logs.txt  │
│    - 10,000 cuộc trò chuyện thực        │
│    - Đã được anonymize                  │
│                                         │
│ [Upload] [Process] [Train Model]        │
└─────────────────────────────────────────┘
```

### 7.3. Testing Bot

**Test conversation**:
```
💬 BOT TESTING - SHOPEE A
┌─────────────────────────────────────────┐
│ User: "Áo này có size XL không?"        │
│ Bot: "Chào anh! Áo polo này có đủ size  │
│      từ S đến XXL ạ. Size XL hiện còn   │
│      15 cái. Anh có muốn đặt không?"    │
│                                         │
│ ✅ Response time: 0.8s                  │
│ ✅ Accuracy: 95%                        │
│ ✅ Tone: Appropriate                    │
│ ✅ Context: Correct                     │
│                                         │
│ [Approve] [Adjust] [Retrain]            │
└─────────────────────────────────────────┘
```

## 8. TESTING VÀ GO-LIVE

### 8.1. Pre-launch Testing

**Test checklist**:
```
✅ TESTING CHECKLIST
┌─────────────────────────────────────────┐
│ CONNECTIVITY:                           │
│ ☑️ All platforms connected              │
│ ☑️ Webhooks receiving messages          │
│ ☑️ Can send messages back               │
│                                         │
│ FUNCTIONALITY:                          │
│ ☑️ Message routing works                │
│ ☑️ Customer unification works           │
│ ☑️ AI responses appropriate             │
│ ☑️ Escalation rules working             │
│                                         │
│ PERFORMANCE:                            │
│ ☑️ Response time < 2 seconds            │
│ ☑️ No message loss                      │
│ ☑️ Handles concurrent messages          │
│ ☑️ Error handling works                 │
└─────────────────────────────────────────┘
```

### 8.2. Soft Launch

**Phase 1**: Single channel (1 tuần)
```
🚀 SOFT LAUNCH - SHOPEE A ONLY
┌─────────────────────────────────────────┐
│ Duration: 1 week                        │
│ Scope: Shopee Shop A only               │
│ Team: 1 agent + supervisor              │
│                                         │
│ Monitoring:                             │
│ - Response time                         │
│ - AI accuracy                           │
│ - Customer feedback                     │
│ - Error rates                           │
│                                         │
│ Success criteria:                       │
│ - 95% uptime                            │
│ - <2min response time                   │
│ - >4.0 customer rating                  │
│ - <5% error rate                        │
└─────────────────────────────────────────┘
```

**Phase 2**: Multi-channel (2 tuần)
```
🚀 FULL LAUNCH - ALL CHANNELS
┌─────────────────────────────────────────┐
│ Duration: 2 weeks                       │
│ Scope: All 8 channels                   │
│ Team: 2 agents + supervisor             │
│                                         │
│ Gradual rollout:                        │
│ Day 1-3: Shopee + Lazada                │
│ Day 4-7: + Facebook + Zalo              │
│ Day 8-14: + TikTok + Website            │
│                                         │
│ Daily monitoring:                       │
│ - Volume handling                       │
│ - Agent workload                        │
│ - System performance                    │
│ - Customer satisfaction                 │
└─────────────────────────────────────────┘
```

### 8.3. Go-live Checklist

**Final checklist**:
```
🎯 GO-LIVE CHECKLIST
┌─────────────────────────────────────────┐
│ TECHNICAL:                              │
│ ☑️ All integrations tested              │
│ ☑️ Backup systems ready                 │
│ ☑️ Monitoring alerts setup              │
│ ☑️ Support team on standby              │
│                                         │
│ BUSINESS:                               │
│ ☑️ Team trained on new system           │
│ ☑️ Escalation procedures defined        │
│ ☑️ Customer communication sent          │
│ ☑️ Success metrics defined              │
│                                         │
│ CONTINGENCY:                            │
│ ☑️ Rollback plan ready                  │
│ ☑️ Manual backup process               │
│ ☑️ Emergency contacts list              │
│ ☑️ 24/7 support coverage               │
└─────────────────────────────────────────┘
```

### 8.4. Post-launch Monitoring

**Week 1 metrics**:
```
📊 WEEK 1 PERFORMANCE
┌─────────────────────────────────────────┐
│ Messages handled: 2,450                 │
│ AI resolution rate: 82%                 │
│ Avg response time: 1.2 min              │
│ Customer satisfaction: 4.3/5            │
│ System uptime: 99.8%                    │
│                                         │
│ Issues found:                           │
│ - TikTok webhook delay (fixed)          │
│ - Zalo token refresh needed             │
│ - AI training for electronics needed    │
│                                         │
│ Actions taken:                          │
│ ✅ TikTok webhook optimized             │
│ ✅ Auto token refresh implemented       │
│ ✅ Electronics training data added      │
└─────────────────────────────────────────┘
```

---

**Tài liệu liên quan**:
- [Troubleshooting](./troubleshooting.md)
- [Cross-Channel Analytics](./cross-channel-analytics.md)
- [Unified Customer Management](./unified-customer-management.md)

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 1.0.0  
**Tác giả**: NextFlow CRM Team
