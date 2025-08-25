# SCHEMA HỆ THỐNG CHAT - MONGODB

## Mục lục

1. [TỔNG QUAN](#1-tổng-quan)
2. [CONVERSATIONS COLLECTION](#2-conversations-collection)
3. [MESSAGES COLLECTION](#3-messages-collection)
4. [ATTACHMENTS COLLECTION](#4-attachments-collection)
5. [BOT_INTERACTIONS COLLECTION](#5-bot_interactions-collection)
6. [INDEXING STRATEGY](#6-indexing-strategy)
7. [PERFORMANCE OPTIMIZATION](#7-performance-optimization)
8. [DATA RETENTION](#8-data-retention)

## 1. TỔNG QUAN

### 1.1. Lý do chọn MongoDB cho Chat System

```yaml
Advantages:
  - Document-based: Perfect for message structure
  - High write throughput: Handle millions of messages
  - Flexible schema: Easy to add new message types
  - GridFS: Built-in file storage for attachments
  - Sharding: Horizontal scaling capability
  - Time-series: Optimized for time-based data
```

### 1.2. Collections Overview

```yaml
Collections:
  conversations: Cuộc hội thoại và metadata
  messages: Tin nhắn chat chi tiết
  attachments: File đính kèm (GridFS)
  bot_interactions: Tương tác với AI chatbot
  message_archives: Lưu trữ tin nhắn cũ (>6 tháng)
```

## 2. CONVERSATIONS COLLECTION

### 2.1. Schema Structure

```javascript
{
  "_id": ObjectId("674a1b2c3d4e5f6789abcdef"),
  "tenant_id": "tenant_123",
  "conversation_id": "conv_20241201_001",
  "channel": "facebook|zalo|website|whatsapp|telegram",
  "channel_data": {
    "facebook": {
      "page_id": "fb_page_123",
      "thread_id": "fb_thread_456"
    },
    "zalo": {
      "oa_id": "zalo_oa_789",
      "user_id": "zalo_user_012"
    },
    "website": {
      "session_id": "web_session_345",
      "ip_address": "192.168.1.100",
      "user_agent": "Mozilla/5.0..."
    }
  },
  "participants": [
    {
      "user_id": "customer_456",
      "type": "customer",
      "name": "Nguyễn Văn A",
      "email": "nguyenvana@email.com",
      "phone": "+84901234567",
      "joined_at": ISODate("2024-12-01T09:00:00Z"),
      "left_at": null,
      "is_active": true
    },
    {
      "user_id": "agent_789",
      "type": "agent", 
      "name": "Trần Thị B",
      "email": "agent@company.com",
      "joined_at": ISODate("2024-12-01T09:05:00Z"),
      "left_at": null,
      "is_active": true
    }
  ],
  "status": "active|waiting|closed|archived",
  "priority": "low|medium|high|urgent",
  "tags": ["support", "billing", "technical"],
  "metadata": {
    "customer_id": "cust_123",
    "lead_id": "lead_456", 
    "opportunity_id": "opp_789",
    "assigned_agent": "agent_789",
    "department": "support|sales|technical",
    "language": "vi|en",
    "timezone": "Asia/Ho_Chi_Minh"
  },
  "stats": {
    "message_count": 25,
    "customer_messages": 15,
    "agent_messages": 8,
    "bot_messages": 2,
    "avg_response_time": 300, // seconds
    "first_response_time": 120,
    "resolution_time": 1800
  },
  "ai_analysis": {
    "overall_sentiment": "positive|negative|neutral",
    "customer_satisfaction": 0.85,
    "intent_categories": ["support_request", "billing_inquiry"],
    "escalation_risk": 0.2,
    "resolution_probability": 0.9
  },
  "created_at": ISODate("2024-12-01T09:00:00Z"),
  "updated_at": ISODate("2024-12-01T15:30:00Z"),
  "closed_at": null,
  "archived_at": null
}
```

### 2.2. Validation Rules

```javascript
db.createCollection("conversations", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["tenant_id", "conversation_id", "channel", "participants", "status"],
      properties: {
        tenant_id: { bsonType: "string" },
        conversation_id: { bsonType: "string" },
        channel: { 
          enum: ["facebook", "zalo", "website", "whatsapp", "telegram"] 
        },
        status: { 
          enum: ["active", "waiting", "closed", "archived"] 
        },
        priority: { 
          enum: ["low", "medium", "high", "urgent"] 
        },
        participants: {
          bsonType: "array",
          minItems: 1,
          items: {
            bsonType: "object",
            required: ["user_id", "type", "name"],
            properties: {
              type: { enum: ["customer", "agent", "bot"] }
            }
          }
        }
      }
    }
  }
});
```

## 3. MESSAGES COLLECTION

### 3.1. Schema Structure

```javascript
{
  "_id": ObjectId("674a1b2c3d4e5f6789abcdef"),
  "tenant_id": "tenant_123",
  "conversation_id": "conv_20241201_001",
  "message_id": "msg_20241201_001_001",
  "thread_id": "thread_001", // For message threading
  "reply_to": "msg_20241201_001_000", // Reply to specific message
  "sender": {
    "id": "customer_456",
    "type": "customer|agent|bot|system",
    "name": "Nguyễn Văn A",
    "avatar": "https://cdn.example.com/avatar.jpg"
  },
  "content": {
    "type": "text|image|file|audio|video|location|contact|quick_reply|template",
    "text": "Xin chào, tôi cần hỗ trợ về đơn hàng #12345",
    "html": "<p>Xin chào, tôi cần hỗ trợ về đơn hàng <strong>#12345</strong></p>",
    "attachments": [
      {
        "id": "att_123",
        "type": "image|file|audio|video",
        "filename": "screenshot.png",
        "original_filename": "Ảnh chụp màn hình 2024-12-01.png",
        "size": 1024000,
        "mime_type": "image/png",
        "url": "https://cdn.example.com/files/att_123.png",
        "thumbnail_url": "https://cdn.example.com/thumbs/att_123_thumb.png",
        "metadata": {
          "width": 1920,
          "height": 1080,
          "duration": null // for audio/video
        }
      }
    ],
    "quick_replies": [
      {
        "id": "qr_1",
        "title": "Có",
        "payload": "yes"
      },
      {
        "id": "qr_2", 
        "title": "Không",
        "payload": "no"
      }
    ],
    "template": {
      "type": "generic|button|receipt|airline",
      "elements": [
        {
          "title": "Sản phẩm ABC",
          "subtitle": "Mô tả sản phẩm",
          "image_url": "https://example.com/product.jpg",
          "buttons": [
            {
              "type": "web_url",
              "title": "Xem chi tiết",
              "url": "https://example.com/product/123"
            }
          ]
        }
      ]
    }
  },
  "timestamp": ISODate("2024-12-01T09:15:30.123Z"),
  "status": {
    "sent": true,
    "delivered": true,
    "read": false,
    "failed": false,
    "sent_at": ISODate("2024-12-01T09:15:30.123Z"),
    "delivered_at": ISODate("2024-12-01T09:15:31.456Z"),
    "read_at": null,
    "error_message": null
  },
  "channel_data": {
    "facebook": {
      "message_id": "fb_msg_123456789",
      "page_id": "fb_page_123"
    },
    "zalo": {
      "message_id": "zalo_msg_987654321",
      "oa_id": "zalo_oa_789"
    }
  },
  "ai_processing": {
    "processed": true,
    "processed_at": ISODate("2024-12-01T09:15:32.000Z"),
    "sentiment": {
      "score": 0.7,
      "label": "positive|negative|neutral",
      "confidence": 0.85
    },
    "intent": {
      "name": "support_request",
      "confidence": 0.9,
      "entities": [
        {
          "type": "order_number",
          "value": "12345",
          "start": 45,
          "end": 50
        }
      ]
    },
    "language": {
      "detected": "vi",
      "confidence": 0.95
    },
    "topics": ["order", "support", "inquiry"],
    "keywords": ["đơn hàng", "hỗ trợ", "12345"],
    "embedding_id": "emb_msg_123" // Reference to Qdrant vector
  },
  "metadata": {
    "ip_address": "192.168.1.100",
    "user_agent": "Mozilla/5.0...",
    "device": "mobile|desktop|tablet",
    "location": {
      "country": "VN",
      "city": "Ho Chi Minh City",
      "coordinates": [10.8231, 106.6297]
    },
    "referrer": "https://example.com/contact",
    "utm_source": "facebook",
    "utm_campaign": "support_campaign"
  },
  "flags": {
    "is_edited": false,
    "is_deleted": false,
    "is_spam": false,
    "is_important": false,
    "needs_human": false,
    "auto_generated": false
  },
  "created_at": ISODate("2024-12-01T09:15:30.123Z"),
  "updated_at": ISODate("2024-12-01T09:15:30.123Z"),
  "deleted_at": null
}
```

### 3.2. Message Types Examples

#### 3.2.1. Text Message
```javascript
{
  "content": {
    "type": "text",
    "text": "Xin chào! Tôi có thể giúp gì cho bạn?",
    "html": "<p>Xin chào! Tôi có thể giúp gì cho bạn?</p>"
  }
}
```

#### 3.2.2. Image Message
```javascript
{
  "content": {
    "type": "image",
    "text": "Đây là ảnh sản phẩm",
    "attachments": [
      {
        "id": "att_img_123",
        "type": "image",
        "filename": "product.jpg",
        "size": 2048000,
        "mime_type": "image/jpeg",
        "url": "https://cdn.example.com/images/product.jpg",
        "thumbnail_url": "https://cdn.example.com/thumbs/product_thumb.jpg",
        "metadata": {
          "width": 1920,
          "height": 1080
        }
      }
    ]
  }
}
```

#### 3.2.3. Quick Reply Message
```javascript
{
  "content": {
    "type": "quick_reply",
    "text": "Bạn có hài lòng với dịch vụ không?",
    "quick_replies": [
      { "id": "qr_1", "title": "Rất hài lòng", "payload": "very_satisfied" },
      { "id": "qr_2", "title": "Hài lòng", "payload": "satisfied" },
      { "id": "qr_3", "title": "Không hài lòng", "payload": "not_satisfied" }
    ]
  }
}
```

## 4. ATTACHMENTS COLLECTION

### 4.1. GridFS for File Storage

```javascript
// GridFS files collection
{
  "_id": ObjectId("674a1b2c3d4e5f6789abcdef"),
  "filename": "document.pdf",
  "length": 5242880,
  "chunkSize": 261120,
  "uploadDate": ISODate("2024-12-01T09:20:00Z"),
  "metadata": {
    "tenant_id": "tenant_123",
    "conversation_id": "conv_20241201_001",
    "message_id": "msg_20241201_001_005",
    "original_filename": "Tài liệu hướng dẫn.pdf",
    "mime_type": "application/pdf",
    "uploaded_by": "customer_456",
    "virus_scan": {
      "scanned": true,
      "clean": true,
      "scan_date": ISODate("2024-12-01T09:20:05Z")
    },
    "access_control": {
      "public": false,
      "allowed_users": ["customer_456", "agent_789"]
    }
  }
}
```

## 5. BOT_INTERACTIONS COLLECTION

### 5.1. Schema Structure

```javascript
{
  "_id": ObjectId("674a1b2c3d4e5f6789abcdef"),
  "tenant_id": "tenant_123",
  "conversation_id": "conv_20241201_001",
  "message_id": "msg_20241201_001_003",
  "bot_id": "bot_nextflow_ai",
  "interaction_type": "intent_detection|response_generation|escalation|handoff",
  "input": {
    "user_message": "Tôi muốn hủy đơn hàng",
    "context": {
      "previous_messages": 5,
      "customer_info": {
        "id": "customer_456",
        "tier": "premium",
        "order_history": 15
      }
    }
  },
  "processing": {
    "ai_model": "gpt-4|claude-3|ollama-llama2",
    "processing_time": 1.5, // seconds
    "tokens_used": {
      "input": 150,
      "output": 75,
      "total": 225
    },
    "cost": 0.0045 // USD
  },
  "output": {
    "intent": {
      "name": "cancel_order",
      "confidence": 0.92,
      "entities": [
        {
          "type": "action",
          "value": "cancel",
          "confidence": 0.95
        }
      ]
    },
    "response": {
      "text": "Tôi hiểu bạn muốn hủy đơn hàng. Để hỗ trợ bạn tốt nhất, tôi sẽ chuyển cho nhân viên chăm sóc khách hàng.",
      "actions": [
        {
          "type": "escalate_to_human",
          "department": "customer_service",
          "priority": "medium"
        }
      ]
    },
    "suggestions": [
      "Kiểm tra chính sách hủy đơn",
      "Xem thông tin đơn hàng",
      "Liên hệ hotline"
    ]
  },
  "result": {
    "success": true,
    "escalated": true,
    "escalation_reason": "order_cancellation_requires_human",
    "customer_satisfaction": null // Will be updated later
  },
  "timestamp": ISODate("2024-12-01T09:18:45Z")
}
```

## 6. INDEXING STRATEGY

### 6.1. Conversations Indexes

```javascript
// Primary indexes
db.conversations.createIndex({ "tenant_id": 1, "conversation_id": 1 }, { unique: true });
db.conversations.createIndex({ "tenant_id": 1, "status": 1, "created_at": -1 });
db.conversations.createIndex({ "tenant_id": 1, "channel": 1, "created_at": -1 });

// Participant indexes
db.conversations.createIndex({ "participants.user_id": 1, "participants.type": 1 });
db.conversations.createIndex({ "metadata.assigned_agent": 1, "status": 1 });

// Search indexes
db.conversations.createIndex({ "tags": 1 });
db.conversations.createIndex({ "metadata.customer_id": 1 });
```

### 6.2. Messages Indexes

```javascript
// Primary indexes
db.messages.createIndex({ "tenant_id": 1, "conversation_id": 1, "timestamp": -1 });
db.messages.createIndex({ "tenant_id": 1, "message_id": 1 }, { unique: true });

// Sender indexes
db.messages.createIndex({ "sender.id": 1, "sender.type": 1, "timestamp": -1 });

// Content indexes
db.messages.createIndex({ "content.type": 1 });
db.messages.createIndex({ "content.text": "text" }); // Full-text search

// Status indexes
db.messages.createIndex({ "status.read": 1, "timestamp": -1 });
db.messages.createIndex({ "ai_processing.processed": 1 });

// Compound indexes for common queries
db.messages.createIndex({ 
  "tenant_id": 1, 
  "conversation_id": 1, 
  "sender.type": 1, 
  "timestamp": -1 
});
```

### 6.3. Bot Interactions Indexes

```javascript
db.bot_interactions.createIndex({ "tenant_id": 1, "conversation_id": 1, "timestamp": -1 });
db.bot_interactions.createIndex({ "bot_id": 1, "interaction_type": 1, "timestamp": -1 });
db.bot_interactions.createIndex({ "output.intent.name": 1, "timestamp": -1 });
```

## 7. PERFORMANCE OPTIMIZATION

### 7.1. Sharding Strategy

```javascript
// Shard key: tenant_id for even distribution
sh.shardCollection("nextflow_chat.conversations", { "tenant_id": 1, "_id": 1 });
sh.shardCollection("nextflow_chat.messages", { "tenant_id": 1, "_id": 1 });
sh.shardCollection("nextflow_chat.bot_interactions", { "tenant_id": 1, "_id": 1 });
```

### 7.2. Time-based Collections

```javascript
// Monthly collections for messages (auto-archiving)
// nextflow_chat.messages_2024_12
// nextflow_chat.messages_2024_11
// nextflow_chat.messages_2024_10

// Create time-based collection
db.createCollection("messages_2024_12", {
  timeseries: {
    timeField: "timestamp",
    metaField: "metadata",
    granularity: "minutes"
  }
});
```

## 8. DATA RETENTION

### 8.1. Archiving Strategy

```javascript
// Archive messages older than 6 months
const archiveDate = new Date();
archiveDate.setMonth(archiveDate.getMonth() - 6);

// Move to archive collection
db.messages.aggregate([
  { $match: { "timestamp": { $lt: archiveDate } } },
  { $out: "message_archives" }
]);

// Remove from main collection
db.messages.deleteMany({ "timestamp": { $lt: archiveDate } });
```

### 8.2. Cleanup Jobs

```javascript
// Daily cleanup job
function dailyCleanup() {
  // Remove deleted messages after 30 days
  const deleteDate = new Date();
  deleteDate.setDate(deleteDate.getDate() - 30);
  
  db.messages.deleteMany({
    "flags.is_deleted": true,
    "deleted_at": { $lt: deleteDate }
  });
  
  // Archive old bot interactions
  const archiveDate = new Date();
  archiveDate.setMonth(archiveDate.getMonth() - 3);
  
  db.bot_interactions.deleteMany({
    "timestamp": { $lt: archiveDate }
  });
}
```

---

*Tài liệu được cập nhật lần cuối: Tháng 12/2024*
*Phiên bản: NextFlow CRM-AI v2.0.0*
