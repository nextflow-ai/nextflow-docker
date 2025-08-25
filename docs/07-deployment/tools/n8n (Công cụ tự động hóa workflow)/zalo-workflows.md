# N8N WORKFLOWS CHO ZALO CHATBOT

## MỤC LỤC

1. [Workflow Cơ bản](#1-workflow-cơ-bản)
2. [Workflow Chăm sóc Khách hàng](#2-workflow-chăm-sóc-khách-hàng)
3. [Workflow Bán hàng](#3-workflow-bán-hàng)
4. [Workflow Hỗ trợ Kỹ thuật](#4-workflow-hỗ-trợ-kỹ-thuật)
5. [Workflow Follow-up](#5-workflow-follow-up)
6. [Configuration và Deployment](#6-configuration-và-deployment)

## 1. WORKFLOW CƠ BẢN

### 1.1. Zalo Message Handler - Workflow chính

```json
{
  "name": "Zalo Customer Service Bot",
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "zalo-webhook",
        "responseMode": "responseNode",
        "options": {}
      },
      "name": "Zalo Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [240, 300]
    },
    {
      "parameters": {
        "functionCode": "// Parse Zalo webhook payload\nconst body = $input.first().json.body;\n\n// Extract message information\nconst messageData = {\n  userId: body.sender.id,\n  userName: body.sender.name || 'Khách hàng',\n  message: body.message.text || '',\n  messageType: body.message.msg_type || 'text',\n  timestamp: body.timestamp,\n  platform: 'zalo',\n  accessToken: body.access_token || $env.ZALO_ACCESS_TOKEN\n};\n\n// Validate message\nif (!messageData.message && messageData.messageType !== 'text') {\n  messageData.message = '[Tin nhắn không phải văn bản]';\n  messageData.needsHumanReview = true;\n}\n\n// Add conversation context\nmessageData.conversationId = `zalo_${messageData.userId}_${Date.now()}`;\n\nreturn [{ json: messageData }];"
      },
      "name": "Parse Message",
      "type": "n8n-nodes-base.function",
      "typeVersion": 1,
      "position": [460, 300]
    },
    {
      "parameters": {
        "method": "GET",
        "url": "={{$env.NEXTFLOW_API_URL}}/v1/customers/search",
        "authentication": "genericCredentialType",
        "genericAuthType": "httpHeaderAuth",
        "headers": {
          "Authorization": "Bearer {{$env.NEXTFLOW_API_TOKEN}}"
        },
        "qs": {
          "zalo_user_id": "={{$json.userId}}"
        }
      },
      "name": "Get Customer Info",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [680, 300]
    },
    {
      "parameters": {
        "functionCode": "// Classify user intent\nconst message = $input.first().json.message.toLowerCase();\nconst customer = $input.first().json.customer;\n\n// Intent classification keywords\nconst intents = {\n  'product_inquiry': ['sản phẩm', 'dịch vụ', 'gói', 'giá', 'tính năng', 'demo'],\n  'support_request': ['hỗ trợ', 'help', 'lỗi', 'không hoạt động', 'sự cố'],\n  'order_status': ['đơn hàng', 'order', 'trạng thái', 'giao hàng', 'thanh toán'],\n  'complaint': ['khiếu nại', 'không hài lòng', 'tệ', 'kém', 'phản ánh'],\n  'greeting': ['xin chào', 'hello', 'hi', 'chào'],\n  'goodbye': ['tạm biệt', 'bye', 'cảm ơn', 'kết thúc']\n};\n\nlet detectedIntent = 'general';\nlet confidence = 0;\n\n// Find best matching intent\nfor (const [intent, keywords] of Object.entries(intents)) {\n  const matches = keywords.filter(keyword => message.includes(keyword)).length;\n  const currentConfidence = matches / keywords.length;\n  \n  if (currentConfidence > confidence) {\n    confidence = currentConfidence;\n    detectedIntent = intent;\n  }\n}\n\n// Prepare context for AI\nconst context = {\n  intent: detectedIntent,\n  confidence: confidence,\n  customer: customer || null,\n  message: $input.first().json.message,\n  userId: $input.first().json.userId,\n  userName: $input.first().json.userName,\n  platform: 'zalo',\n  timestamp: new Date().toISOString()\n};\n\nreturn [{ json: context }];"
      },
      "name": "Intent Classification",
      "type": "n8n-nodes-base.function",
      "typeVersion": 1,
      "position": [900, 300]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "={{$env.FLOWISE_API_URL}}/api/v1/prediction/{{$env.ZALO_CHATFLOW_ID}}",
        "headers": {
          "Authorization": "Bearer {{$env.FLOWISE_API_KEY}}",
          "Content-Type": "application/json"
        },
        "body": {
          "question": "={{$json.message}}",
          "overrideConfig": {
            "systemMessagePrompt": "Bạn là trợ lý chăm sóc khách hàng của NextFlow CRM-AI trên Zalo. Intent được phát hiện: {{$json.intent}}. Thông tin khách hàng: {{$json.customer}}. Hãy trả lời ngắn gọn, thân thiện và chuyên nghiệp."
          }
        }
      },
      "name": "AI Processing",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [1120, 300]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://openapi.zalo.me/v2.0/oa/message",
        "headers": {
          "Content-Type": "application/json",
          "access_token": "={{$('Parse Message').item.json.accessToken}}"
        },
        "body": {
          "recipient": {
            "user_id": "={{$('Parse Message').item.json.userId}}"
          },
          "message": {
            "text": "={{$json.text || $json.answer || 'Xin lỗi, tôi không hiểu câu hỏi của bạn. Vui lòng thử lại hoặc liên hệ nhân viên hỗ trợ.'}}"
          }
        }
      },
      "name": "Send Response",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [1340, 300]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "={{$env.NEXTFLOW_API_URL}}/v1/chat-logs",
        "headers": {
          "Authorization": "Bearer {{$env.NEXTFLOW_API_TOKEN}}",
          "Content-Type": "application/json"
        },
        "body": {
          "platform": "zalo",
          "userId": "={{$('Parse Message').item.json.userId}}",
          "userName": "={{$('Parse Message').item.json.userName}}",
          "userMessage": "={{$('Parse Message').item.json.message}}",
          "botResponse": "={{$('AI Processing').item.json.text || $('AI Processing').item.json.answer}}",
          "intent": "={{$('Intent Classification').item.json.intent}}",
          "confidence": "={{$('Intent Classification').item.json.confidence}}",
          "timestamp": "={{$('Intent Classification').item.json.timestamp}}"
        }
      },
      "name": "Log Interaction",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [1560, 300]
    },
    {
      "parameters": {
        "respondWith": "text",
        "responseBody": "OK"
      },
      "name": "Webhook Response",
      "type": "n8n-nodes-base.respondToWebhook",
      "typeVersion": 1,
      "position": [1780, 300]
    }
  ],
  "connections": {
    "Zalo Webhook": {
      "main": [
        [
          {
            "node": "Parse Message",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Parse Message": {
      "main": [
        [
          {
            "node": "Get Customer Info",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Get Customer Info": {
      "main": [
        [
          {
            "node": "Intent Classification",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Intent Classification": {
      "main": [
        [
          {
            "node": "AI Processing",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "AI Processing": {
      "main": [
        [
          {
            "node": "Send Response",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Send Response": {
      "main": [
        [
          {
            "node": "Log Interaction",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Log Interaction": {
      "main": [
        [
          {
            "node": "Webhook Response",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

### 1.2. Environment Variables

```bash
# Zalo Configuration
ZALO_APP_ID=your_zalo_app_id
ZALO_APP_SECRET=your_zalo_app_secret
ZALO_ACCESS_TOKEN=your_zalo_access_token

# NextFlow CRM-AI API
NEXTFLOW_API_URL=https://api.nextflow-crm.com
NEXTFLOW_API_TOKEN=your_nextflow_api_token

# Flowise Configuration
FLOWISE_API_URL=https://flowise.nextflow-crm.com
FLOWISE_API_KEY=your_flowise_api_key
ZALO_CHATFLOW_ID=your_zalo_chatflow_id
```

## 2. WORKFLOW CHĂM SÓC KHÁCH HÀNG

### 2.1. Customer Support Escalation Workflow

```json
{
  "name": "Zalo Support Escalation",
  "nodes": [
    {
      "parameters": {
        "functionCode": "// Check if escalation is needed\nconst message = $input.first().json.message.toLowerCase();\nconst intent = $input.first().json.intent;\nconst confidence = $input.first().json.confidence;\n\n// Escalation triggers\nconst escalationKeywords = [\n  'khiếu nại', 'không hài lòng', 'muốn hủy',\n  'nói chuyện với người', 'gặp nhân viên',\n  'không giải quyết được', 'phức tạp',\n  'manager', 'quản lý'\n];\n\nconst needsEscalation = \n  escalationKeywords.some(keyword => message.includes(keyword)) ||\n  intent === 'complaint' ||\n  confidence < 0.5 ||\n  message.length > 200;\n\nif (needsEscalation) {\n  return [{ json: { ...($input.first().json), escalate: true } }];\n} else {\n  return [{ json: { ...($input.first().json), escalate: false } }];\n}"
      },
      "name": "Check Escalation",
      "type": "n8n-nodes-base.function",
      "typeVersion": 1,
      "position": [240, 300]
    },
    {
      "parameters": {
        "conditions": {
          "boolean": [
            {
              "value1": "={{$json.escalate}}",
              "value2": true
            }
          ]
        }
      },
      "name": "IF Escalation Needed",
      "type": "n8n-nodes-base.if",
      "typeVersion": 1,
      "position": [460, 300]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "={{$env.NEXTFLOW_API_URL}}/v1/support-tickets",
        "headers": {
          "Authorization": "Bearer {{$env.NEXTFLOW_API_TOKEN}}",
          "Content-Type": "application/json"
        },
        "body": {
          "title": "Yêu cầu hỗ trợ từ Zalo - {{$json.userName}}",
          "description": "{{$json.message}}",
          "priority": "medium",
          "source": "zalo",
          "customer_id": "{{$json.customer.id || null}}",
          "contact_info": {
            "zalo_user_id": "{{$json.userId}}",
            "name": "{{$json.userName}}"
          },
          "tags": ["zalo", "escalation"]
        }
      },
      "name": "Create Support Ticket",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [680, 200]
    },
    {
      "parameters": {
        "method": "POST",
        "url": "https://openapi.zalo.me/v2.0/oa/message",
        "headers": {
          "Content-Type": "application/json",
          "access_token": "={{$json.accessToken}}"
        },
        "body": {
          "recipient": {
            "user_id": "={{$json.userId}}"
          },
          "message": {
            "text": "Cảm ơn bạn đã liên hệ! 🙏\\n\\nChúng tôi đã ghi nhận yêu cầu của bạn và tạo ticket hỗ trợ #{{$('Create Support Ticket').item.json.ticket_number}}.\\n\\nNhân viên chăm sóc khách hàng sẽ liên hệ với bạn trong vòng 2-4 giờ làm việc.\\n\\nNếu cần hỗ trợ gấp, vui lòng gọi hotline: 1900-xxxx\\n\\nTrân trọng! 💙"
          }
        }
      },
      "name": "Send Escalation Message",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 1,
      "position": [900, 200]
    }
  ]
}
```

## 3. WORKFLOW BÁN HÀNG

### 3.1. Sales Lead Qualification

```javascript
// Lead scoring function
function calculateLeadScore(message, customer) {
  let score = 0;

  // Intent-based scoring
  const highIntentKeywords = ["mua", "đăng ký", "trial", "demo", "báo giá"];
  const mediumIntentKeywords = ["quan tâm", "tìm hiểu", "so sánh"];

  if (highIntentKeywords.some((k) => message.includes(k))) score += 30;
  if (mediumIntentKeywords.some((k) => message.includes(k))) score += 15;

  // Company size indicators
  const companySizeKeywords = {
    startup: 10,
    "doanh nghiệp nhỏ": 15,
    "công ty": 20,
    "tập đoàn": 30,
  };

  for (const [keyword, points] of Object.entries(companySizeKeywords)) {
    if (message.includes(keyword)) score += points;
  }

  // Urgency indicators
  if (message.includes("gấp") || message.includes("ngay")) score += 20;

  return Math.min(score, 100);
}
```

### 3.2. Product Recommendation Engine

```javascript
// Product recommendation based on company size and needs
function recommendProduct(message, customer) {
  const needs = {
    nhỏ: "basic",
    vừa: "standard",
    lớn: "premium",
    "tập đoàn": "enterprise",
  };

  const features = {
    email: "Email marketing automation",
    "bán hàng": "Sales pipeline management",
    "khách hàng": "Customer relationship management",
    "báo cáo": "Advanced analytics and reporting",
  };

  // Analyze message for company size and feature needs
  let recommendedPlan = "standard"; // default
  let recommendedFeatures = [];

  for (const [size, plan] of Object.entries(needs)) {
    if (message.includes(size)) {
      recommendedPlan = plan;
      break;
    }
  }

  for (const [keyword, feature] of Object.entries(features)) {
    if (message.includes(keyword)) {
      recommendedFeatures.push(feature);
    }
  }

  return { plan: recommendedPlan, features: recommendedFeatures };
}
```

## 4. WORKFLOW HỖ TRỢ KỸ THUẬT

### 4.1. Technical Issue Classification

```javascript
// Classify technical issues
function classifyTechnicalIssue(message) {
  const issueTypes = {
    login: ["đăng nhập", "login", "password", "mật khẩu"],
    sync: ["đồng bộ", "sync", "dữ liệu không cập nhật"],
    integration: ["tích hợp", "api", "webhook", "kết nối"],
    performance: ["chậm", "lag", "tải", "loading"],
    ui: ["giao diện", "hiển thị", "button", "click"],
  };

  for (const [type, keywords] of Object.entries(issueTypes)) {
    if (keywords.some((keyword) => message.toLowerCase().includes(keyword))) {
      return type;
    }
  }

  return "general";
}

// Generate troubleshooting steps
function generateTroubleshootingSteps(issueType) {
  const solutions = {
    login: [
      "1. Thử reset mật khẩu tại trang đăng nhập",
      "2. Xóa cache và cookies của trình duyệt",
      "3. Thử đăng nhập bằng trình duyệt ẩn danh",
      "4. Kiểm tra caps lock và bàn phím",
    ],
    sync: [
      "1. Kiểm tra kết nối internet",
      "2. Refresh trang và thử lại",
      "3. Kiểm tra quyền truy cập dữ liệu",
      "4. Liên hệ admin để kiểm tra cấu hình",
    ],
    performance: [
      "1. Đóng các tab không cần thiết",
      "2. Kiểm tra tốc độ internet",
      "3. Thử trình duyệt khác",
      "4. Restart thiết bị nếu cần",
    ],
  };

  return solutions[issueType] || ["Vui lòng mô tả chi tiết vấn đề để được hỗ trợ tốt hơn"];
}
```

## 5. WORKFLOW FOLLOW-UP

### 5.1. Automated Follow-up Schedule

```json
{
  "name": "Zalo Follow-up Automation",
  "trigger": {
    "type": "schedule",
    "cron": "0 9 * * *"
  },
  "nodes": [
    {
      "parameters": {
        "method": "GET",
        "url": "={{$env.NEXTFLOW_API_URL}}/v1/chat-logs/pending-followup",
        "headers": {
          "Authorization": "Bearer {{$env.NEXTFLOW_API_TOKEN}}"
        },
        "qs": {
          "platform": "zalo",
          "hours_since": "24"
        }
      },
      "name": "Get Pending Follow-ups",
      "type": "n8n-nodes-base.httpRequest"
    }
  ]
}
```

### 5.2. Follow-up Message Templates

```javascript
const followUpTemplates = {
  product_inquiry: `
Xin chào {customer_name}! 👋

Hôm qua bạn có hỏi về sản phẩm NextFlow CRM-AI. Chúng tôi muốn biết bạn có cần thêm thông tin gì không?

🎯 Ưu đãi đặc biệt: Miễn phí 30 ngày dùng thử
📞 Hotline: 1900-xxxx
💬 Hoặc reply tin nhắn này để được tư vấn

Cảm ơn bạn! 💙
  `,

  support_request: `
Xin chào {customer_name}! 

Chúng tôi muốn kiểm tra xem vấn đề hỗ trợ của bạn đã được giải quyết chưa?

Ticket #{ticket_id}: {issue_summary}

✅ Đã giải quyết
❌ Vẫn cần hỗ trợ

Vui lòng reply để cho chúng tôi biết nhé! 😊
  `,

  general: `
Xin chào {customer_name}! 

Cảm ơn bạn đã quan tâm đến NextFlow CRM-AI! 

Nếu có bất kỳ câu hỏi nào, đừng ngần ngại liên hệ với chúng tôi nhé! 

💬 Chat ngay tại đây
📞 Hotline: 1900-xxxx
🌐 Website: nextflow-crm.com

Chúc bạn một ngày tốt lành! ☀️
  `,
};
```

## 6. CONFIGURATION VÀ DEPLOYMENT

### 6.1. N8n Configuration

```javascript
// n8n.config.js
module.exports = {
  database: {
    type: "postgres",
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
  },

  endpoints: {
    webhook: "webhook",
    webhookWaiting: "webhook-waiting",
    webhookTest: "webhook-test",
  },

  security: {
    basicAuth: {
      active: true,
      user: process.env.N8N_BASIC_AUTH_USER,
      password: process.env.N8N_BASIC_AUTH_PASSWORD,
    },
  },

  executions: {
    saveDataOnError: "all",
    saveDataOnSuccess: "none",
    saveDataManualExecutions: false,
  },
};
```

### 6.2. Docker Deployment

```yaml
# docker-compose.yml
version: "3.8"

services:
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${N8N_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_PASSWORD}
      - WEBHOOK_URL=https://your-domain.com/
      - GENERIC_TIMEZONE=Asia/Ho_Chi_Minh
    volumes:
      - n8n_data:/home/node/.n8n
      - ./workflows:/home/node/.n8n/workflows
    depends_on:
      - postgres
    restart: unless-stopped

  postgres:
    image: postgres:13
    environment:
      - POSTGRES_DB=n8n
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  n8n_data:
  postgres_data:
```

### 6.3. Monitoring và Alerts

```javascript
// monitoring.js
const monitoringConfig = {
  healthCheck: {
    interval: "5m",
    endpoints: ["https://your-domain.com/webhook/zalo-webhook", "https://flowise.nextflow-crm.com/api/health"],
  },

  alerts: {
    webhook_failure: {
      threshold: 3,
      timeWindow: "10m",
      action: "send_slack_notification",
    },

    response_time: {
      threshold: "5s",
      action: "log_warning",
    },

    error_rate: {
      threshold: "5%",
      timeWindow: "1h",
      action: "send_email_alert",
    },
  },
};
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 1.0.0  
**Tác giả**: NextFlow DevOps Team
