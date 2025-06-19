# TỔNG QUAN VỀ API NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Xác thực](#2-xác-thực)
3. [Định dạng dữ liệu](#3-định-dạng-dữ-liệu)
4. [Endpoints chính](#4-endpoints-chính)
5. [Rate limiting](#5-rate-limiting)
6. [Webhooks](#6-webhooks)
7. [SDKs và tools](#7-sdks-và-tools)
8. [Kết luận](#8-kết-luận)
9. [Tài liệu tham khảo](#9-tài-liệu-tham-khảo)

## 1. GIỚI THIỆU

NextFlow CRM cung cấp API RESTful toàn diện cho phép tích hợp với các hệ thống bên ngoài, xây dựng ứng dụng tùy chỉnh và tự động hóa quy trình kinh doanh. Tài liệu này mô tả cách thức xác thực, cấu trúc yêu cầu và phản hồi, cũng như các endpoint có sẵn trong NextFlow CRM API.

### 1.1. Đặc điểm chính

- **RESTful Design**: Tuân thủ nguyên tắc REST architecture
- **JSON Format**: Sử dụng JSON cho request và response
- **Multi-tenant**: Hỗ trợ nhiều tổ chức trên cùng API
- **Versioning**: API versioning để đảm bảo backward compatibility
- **Security**: Bảo mật cao với multiple authentication methods
- **Rate Limiting**: Kiểm soát tần suất request để đảm bảo hiệu suất
- **Webhooks**: Real-time notifications cho events

### 1.2. Base URLs

| Môi trường | URL | Mô tả |
|------------|-----|-------|
| **Production** | `https://api.nextflow.com` | Môi trường sản xuất |
| **Staging** | `https://staging-api.nextflow.com` | Môi trường test |
| **Development** | `https://dev-api.nextflow.com` | Môi trường phát triển |

### 1.3. API Versioning

NextFlow CRM sử dụng URL-based versioning:
- **Current Version**: v1
- **Endpoint Pattern**: `/api/v1/{resource}`
- **Deprecation Policy**: Thông báo trước 90 ngày cho breaking changes

## 2. XÁC THỰC

### 2.1. Tạo API Key
- Truy cập Cài đặt > API > Tạo API Key mới
- Đặt tên và chọn quyền cho API Key
- Lưu API Key an toàn (chỉ hiển thị một lần)

### 2.2. Xác thực Bearer Token
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "your-email@example.com",
  "password": "your-password"
}
```

Phản hồi:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600
}
```

### 2.3. Sử dụng token trong request
```http
GET /api/v1/customers
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 3. ĐỊNH DẠNG DỮ LIỆU

### 3.1. Request
- Content-Type: application/json
- Dữ liệu gửi dưới dạng JSON
- Hỗ trợ query parameters cho lọc, sắp xếp và phân trang

### 3.2. Response
- Dữ liệu trả về dạng JSON
- Mã HTTP chuẩn (200, 201, 400, 401, 403, 404, 500)
- Cấu trúc lỗi nhất quán

### 3.3. Phân trang
```http
GET /api/v1/customers?page=1&limit=20
```

Phản hồi:
```json
{
  "data": [...],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20,
    "pages": 5
  }
}
```

## 4. ENDPOINTS CHÍNH

NextFlow CRM API được tổ chức theo các module chức năng chính:

### 4.1. Hệ thống (System)
- **Users**: `/api/v1/users` - Quản lý người dùng
- **Organizations**: `/api/v1/organizations` - Quản lý tổ chức
- **Roles**: `/api/v1/roles` - Quản lý vai trò
- **Permissions**: `/api/v1/permissions` - Quản lý quyền hạn

### 4.2. Khách hàng (Customers)
- **Customers**: `/api/v1/customers` - Quản lý khách hàng
- **Contacts**: `/api/v1/contacts` - Quản lý liên hệ
- **Segments**: `/api/v1/segments` - Phân khúc khách hàng

### 4.3. Sản phẩm (Products)
- **Products**: `/api/v1/products` - Quản lý sản phẩm
- **Categories**: `/api/v1/categories` - Danh mục sản phẩm
- **Inventory**: `/api/v1/inventory` - Quản lý tồn kho

### 4.4. Đơn hàng (Orders)
- **Orders**: `/api/v1/orders` - Quản lý đơn hàng
- **Order Items**: `/api/v1/order-items` - Chi tiết đơn hàng
- **Payments**: `/api/v1/payments` - Thanh toán

### 4.5. Bán hàng (Sales)
- **Leads**: `/api/v1/leads` - Quản lý leads
- **Opportunities**: `/api/v1/opportunities` - Cơ hội bán hàng
- **Quotes**: `/api/v1/quotes` - Báo giá
- **Deals**: `/api/v1/deals` - Giao dịch

### 4.6. Marketing
- **Campaigns**: `/api/v1/campaigns` - Chiến dịch marketing
- **Emails**: `/api/v1/emails` - Email marketing
- **Landing Pages**: `/api/v1/landing-pages` - Landing pages
- **Analytics**: `/api/v1/analytics` - Phân tích marketing

### 4.7. Hỗ trợ (Support)
- **Tickets**: `/api/v1/tickets` - Quản lý tickets
- **Knowledge Base**: `/api/v1/knowledge-base` - Cơ sở kiến thức
- **Chat**: `/api/v1/chat` - Chat hỗ trợ

### 4.8. Tích hợp (Integration)
- **Webhooks**: `/api/v1/webhooks` - Quản lý webhooks
- **Marketplace**: `/api/v1/marketplace` - Tích hợp marketplace
- **Third Party**: `/api/v1/third-party` - Tích hợp bên thứ ba

## 5. RATE LIMITING

NextFlow CRM áp dụng rate limiting để đảm bảo hiệu suất và công bằng cho tất cả users:

### 5.1. Giới hạn theo plan

| Plan | Requests/phút | Requests/giờ | Requests/ngày |
|------|---------------|--------------|---------------|
| **Basic** | 60 | 1,000 | 10,000 |
| **Professional** | 120 | 2,000 | 20,000 |
| **Enterprise** | 300 | 5,000 | 50,000 |
| **Custom** | Tùy chỉnh | Tùy chỉnh | Tùy chỉnh |

### 5.2. Headers phản hồi

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1635789600
X-RateLimit-Window: 60
```

### 5.3. Xử lý khi vượt giới hạn

Khi vượt quá rate limit, API trả về HTTP 429:

```json
{
  "success": false,
  "code": 4008,
  "message": "Quá nhiều yêu cầu",
  "error": {
    "type": "RATE_LIMIT_EXCEEDED",
    "message": "Bạn đã vượt quá giới hạn số lượng request cho phép",
    "details": {
      "retry_after": 60,
      "limit": 60,
      "window": "1 minute"
    }
  }
}
```

## 6. WEBHOOKS

Webhooks cho phép NextFlow CRM gửi thông báo real-time đến ứng dụng của bạn khi có events xảy ra.

### 6.1. Supported Events

- **customer.created**: Khách hàng mới được tạo
- **customer.updated**: Thông tin khách hàng được cập nhật
- **order.created**: Đơn hàng mới được tạo
- **order.updated**: Trạng thái đơn hàng thay đổi
- **payment.completed**: Thanh toán hoàn tất
- **lead.created**: Lead mới được tạo
- **ticket.created**: Ticket hỗ trợ mới

### 6.2. Webhook payload

```json
{
  "event": "customer.created",
  "data": {
    "id": "cust_123456",
    "name": "Nguyễn Văn A",
    "email": "nguyenvana@example.com",
    "created_at": "2023-11-15T08:30:45Z"
  },
  "timestamp": "2023-11-15T08:30:45Z",
  "webhook_id": "wh_789012"
}
```

### 6.3. Security

Webhooks được ký bằng HMAC-SHA256:

```http
X-NextFlow-Signature: sha256=5d41402abc4b2a76b9719d911017c592
X-NextFlow-Timestamp: 1635789600
```

## 7. SDKs VÀ TOOLS

### 7.1. Official SDKs

- **JavaScript/Node.js**: `npm install @nextflow/api-client`
- **Python**: `pip install nextflow-api`
- **PHP**: `composer require nextflow/api-client`
- **C#/.NET**: `Install-Package NextFlow.ApiClient`

### 7.2. Developer Tools

- **API Explorer**: Giao diện web để test APIs
- **Postman Collection**: Import collection vào Postman
- **OpenAPI Spec**: Swagger/OpenAPI 3.0 specification
- **Webhooks Tester**: Tool để test webhooks locally

### 7.3. Code Examples

#### JavaScript
```javascript
import { NextFlowAPI } from '@nextflow/api-client';

const api = new NextFlowAPI({
  apiKey: 'your-api-key',
  baseURL: 'https://api.nextflow.com'
});

// Lấy danh sách khách hàng
const customers = await api.customers.list({
  page: 1,
  limit: 20,
  status: 'active'
});
```

#### Python
```python
from nextflow_api import NextFlowAPI

api = NextFlowAPI(
    api_key='your-api-key',
    base_url='https://api.nextflow.com'
)

# Tạo khách hàng mới
customer = api.customers.create({
    'name': 'Nguyễn Văn A',
    'email': 'nguyenvana@example.com',
    'phone': '+84901234567'
})
```

## 8. KẾT LUẬN

NextFlow CRM API cung cấp một giải pháp toàn diện cho việc tích hợp và tự động hóa quy trình kinh doanh. Với thiết kế RESTful, bảo mật cao và documentation chi tiết, API giúp developers dễ dàng xây dựng các ứng dụng tích hợp mạnh mẽ.

### 8.1. Lợi ích chính

- **Tích hợp dễ dàng**: RESTful design với JSON format
- **Bảo mật cao**: Multiple authentication methods
- **Hiệu suất tốt**: Rate limiting và caching
- **Real-time**: Webhooks cho instant notifications
- **Developer-friendly**: SDKs, tools và documentation chi tiết

### 8.2. Bước tiếp theo

1. **Đọc tài liệu chi tiết**: Khám phá các endpoint cụ thể
2. **Thiết lập xác thực**: Tạo API key hoặc OAuth app
3. **Test với API Explorer**: Thử nghiệm APIs trực tiếp
4. **Implement webhooks**: Nhận real-time notifications
5. **Sử dụng SDKs**: Tăng tốc development với official SDKs

### 8.3. Tài liệu liên quan

- [Cấu trúc Phản hồi API](./cau-truc-phan-hoi.md)
- [Xác thực và Bảo mật](./xac-thuc-va-bao-mat.md)
- [API Endpoints chi tiết](./he-thong/users.md)
- [Webhooks Documentation](./tich-hop/webhooks.md)

## 9. TÀI LIỆU THAM KHẢO

### 9.1. API Documentation
- [API Reference](https://docs.nextflow.com/api)
- [OpenAPI Specification](https://api.nextflow.com/openapi.json)
- [Postman Collection](https://www.postman.com/nextflow/workspace/nextflow-api)

### 9.2. Developer Resources
- [Developer Portal](https://developers.nextflow.com)
- [Code Examples](https://github.com/nextflow/api-examples)
- [Community Forum](https://community.nextflow.com)
- [Status Page](https://status.nextflow.com)

### 9.3. Standards và Best Practices
- [REST API Design](https://restfulapi.net/)
- [HTTP Status Codes](https://httpstatuses.com/)
- [JSON API Specification](https://jsonapi.org/)
- [OAuth 2.0 RFC](https://tools.ietf.org/html/rfc6749)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản API**: v1.0.0
**Tác giả**: NextFlow Development Team