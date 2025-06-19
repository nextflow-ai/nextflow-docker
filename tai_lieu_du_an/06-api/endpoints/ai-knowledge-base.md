# API QUẢN LÝ KNOWLEDGE BASE AI NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Knowledge Base](#2-endpoints-knowledge-base)
3. [Endpoints Nguồn dữ liệu](#3-endpoints-nguồn-dữ-liệu)
4. [Endpoints Tài liệu](#4-endpoints-tài-liệu)
5. [Endpoints Truy vấn](#5-endpoints-truy-vấn)
6. [Endpoints Thống kê](#6-endpoints-thống-kê)
7. [Error Codes](#7-error-codes)

## 1. GIỚI THIỆU

API Quản lý Knowledge Base AI của NextFlow CRM cung cấp các endpoint để tạo, quản lý và truy vấn cơ sở kiến thức AI. API này hỗ trợ nhiều loại nguồn dữ liệu như tài liệu, website, database và API, đồng thời cung cấp khả năng tìm kiếm semantic và truy vấn thông minh.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
```

### 1.3. Rate Limiting

- **Limit**: 1000 requests/hour
- **Burst**: 100 requests/minute

## 2. ENDPOINTS KNOWLEDGE BASE

### 2.1. Tạo knowledge base mới

```http
POST /ai/knowledge-bases
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Kiến thức Sản phẩm NextFlow CRM",
  "description": "Cơ sở kiến thức về sản phẩm và dịch vụ NextFlow CRM",
  "type": "product",
  "status": "active",
  "configuration": {
    "embeddingModelId": "model_123456789",
    "chunkSize": 1000,
    "chunkOverlap": 200,
    "similarityThreshold": 0.8,
    "maxResults": 5
  }
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Tạo mới thành công",
  "data": {
    "id": "kb_345678901",
    "name": "Kiến thức Sản phẩm NextFlow CRM",
    "description": "Cơ sở kiến thức về sản phẩm và dịch vụ NextFlow CRM",
    "type": "product",
    "status": "active",
    "configuration": {
      "embeddingModelId": "model_123456789",
      "chunkSize": 1000,
      "chunkOverlap": 200,
      "similarityThreshold": 0.8,
      "maxResults": 5
    },
    "statistics": {
      "totalSources": 0,
      "totalDocuments": 0,
      "totalChunks": 0,
      "totalTokens": 0
    },
    "createdAt": "2023-10-27T09:15:00Z",
    "updatedAt": "2023-10-27T09:15:00Z"
  }
}
```

### 2.2. Lấy danh sách knowledge base

```http
GET /ai/knowledge-bases
```

### 2.3. Lấy thông tin knowledge base

```http
GET /ai/knowledge-bases/{knowledgeBaseId}
```

### 2.4. Cập nhật knowledge base

```http
PUT /ai/knowledge-bases/{knowledgeBaseId}
Content-Type: application/json
```

### 2.5. Xóa knowledge base

```http
DELETE /ai/knowledge-bases/{knowledgeBaseId}
```

## 3. ENDPOINTS NGUỒN DỮ LIỆU

### 3.1. Lấy danh sách nguồn dữ liệu

```http
GET /ai/knowledge-bases/{knowledgeBaseId}/sources
```

### 3.2. Thêm nguồn dữ liệu mới

```http
POST /ai/knowledge-bases/{knowledgeBaseId}/sources
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "API Documentation",
  "description": "Tài liệu API của NextFlow CRM",
  "type": "website",
  "status": "active",
  "configuration": {
    "urls": [
      "https://api.nextflow-crm.com/docs",
      "https://api.nextflow-crm.com/guides"
    ],
    "crawlDepth": 2,
    "includePatterns": [
      "https://api.nextflow-crm.com/docs/.*",
      "https://api.nextflow-crm.com/guides/.*"
    ],
    "excludePatterns": [
      "https://api.nextflow-crm.com/docs/deprecated/.*"
    ],
    "sitemap": "https://api.nextflow-crm.com/sitemap.xml",
    "userAgent": "NextFlow CRM Knowledge Base Crawler",
    "renderJavaScript": true
  }
}
```

### 3.3. Lấy thông tin nguồn dữ liệu

```http
GET /ai/knowledge-bases/{knowledgeBaseId}/sources/{sourceId}
```

### 3.4. Cập nhật nguồn dữ liệu

```http
PUT /ai/knowledge-bases/{knowledgeBaseId}/sources/{sourceId}
Content-Type: application/json
```

### 3.5. Xóa nguồn dữ liệu

```http
DELETE /ai/knowledge-bases/{knowledgeBaseId}/sources/{sourceId}
```

### 3.6. Đồng bộ nguồn dữ liệu

```http
POST /ai/knowledge-bases/{knowledgeBaseId}/sources/{sourceId}/sync
```

## 4. ENDPOINTS TÀI LIỆU

### 4.1. Lấy danh sách tài liệu

```http
GET /ai/knowledge-bases/{knowledgeBaseId}/documents
```

### 4.2. Upload tài liệu

```http
POST /ai/knowledge-bases/{knowledgeBaseId}/documents
Content-Type: multipart/form-data
```

### 4.3. Lấy thông tin tài liệu

```http
GET /ai/documents/{documentId}
```

### 4.4. Cập nhật tài liệu

```http
PUT /ai/documents/{documentId}
Content-Type: application/json
```

### 4.5. Xóa tài liệu

```http
DELETE /ai/documents/{documentId}
```

### 4.6. Xử lý tài liệu

```http
POST /ai/documents/{documentId}/process
```

## 5. ENDPOINTS TRUY VẤN

### 5.1. Tìm kiếm semantic

```http
POST /ai/knowledge-bases/{knowledgeBaseId}/search
Content-Type: application/json
```

#### Request Body

```json
{
  "query": "Tính năng quản lý khách hàng của NextFlow CRM",
  "maxResults": 5,
  "similarityThreshold": 0.7,
  "filters": {
    "sourceIds": ["source_123456789"],
    "documentTypes": ["pdf", "docx"],
    "dateRange": {
      "from": "2023-01-01",
      "to": "2023-12-31"
    }
  }
}
```

### 5.2. Truy vấn với context

```http
POST /ai/knowledge-bases/{knowledgeBaseId}/query
Content-Type: application/json
```

### 5.3. Gợi ý câu hỏi

```http
GET /ai/knowledge-bases/{knowledgeBaseId}/suggestions
```

### 5.4. Tìm kiếm tương tự

```http
POST /ai/knowledge-bases/{knowledgeBaseId}/similar
Content-Type: application/json
```

## 6. ENDPOINTS THỐNG KÊ

### 6.1. Thống kê tổng quan

```http
GET /ai/knowledge-bases/{knowledgeBaseId}/analytics
```

### 6.2. Thống kê truy vấn

```http
GET /ai/knowledge-bases/{knowledgeBaseId}/analytics/queries
```

### 6.3. Thống kê hiệu suất

```http
GET /ai/knowledge-bases/{knowledgeBaseId}/analytics/performance
```

### 6.4. Báo cáo sử dụng

```http
GET /ai/knowledge-bases/{knowledgeBaseId}/usage-reports
```

## 7. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Knowledge base not found | Không tìm thấy knowledge base |
| 4002 | Source not found | Không tìm thấy nguồn dữ liệu |
| 4003 | Document not found | Không tìm thấy tài liệu |
| 4004 | Invalid file format | Định dạng file không hợp lệ |
| 4005 | File too large | File quá lớn |
| 4006 | Processing failed | Xử lý thất bại |
| 5001 | Embedding failed | Tạo embedding thất bại |
| 5002 | Search timeout | Tìm kiếm timeout |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM API Team
