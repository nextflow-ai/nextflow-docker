# API DOCUMENTATION NextFlow CRM

## TỔNG QUAN

Thư mục này chứa tài liệu chi tiết về API của NextFlow CRM. API NextFlow CRM là RESTful API cho phép tích hợp với các hệ thống bên ngoài, xây dựng ứng dụng tùy chỉnh và tự động hóa quy trình kinh doanh.

NextFlow CRM API được thiết kế theo chuẩn REST với định dạng JSON, hỗ trợ đầy đủ các phương thức HTTP và tuân thủ các best practices về bảo mật và hiệu suất.

## CẤU TRÚC THƯ MỤC

```
06-api/
├── README.md                           # Tổng quan về API NextFlow CRM
├── tong-quan-api.md                    # Tài liệu tổng quan API (68 dòng)
├── cau-truc-phan-hoi.md               # Cấu trúc phản hồi API (242 dòng)
├── xac-thuc-va-bao-mat.md             # Xác thực và bảo mật (277 dòng)
└── endpoints/                          # ⭐ API Endpoints (33 tệp) ✅ HOÀN THÀNH
    ├── README.md                       # Tổng quan endpoints
    ├── ai-chatbot.md                   # API Quản lý Chatbot AI
    ├── ai-knowledge-base.md            # API Quản lý Knowledge Base AI
    ├── ai-model.md                     # API Quản lý Mô hình AI
    ├── ai-provider.md                  # API Quản lý Nhà cung cấp AI
    ├── ai-workflow.md                  # API Quản lý Workflow AI
    ├── bao-cao-ban-hang.md             # API Báo cáo Bán hàng
    ├── bao-cao-khach-hang.md           # API Báo cáo Khách hàng
    ├── bao-cao-kho-hang.md             # API Báo cáo Kho hàng
    ├── bao-cao-marketing.md            # API Báo cáo Marketing
    ├── bao-cao-tai-chinh.md            # API Báo cáo Tài chính
    ├── bien-the-san-pham.md            # API Quản lý Biến thể Sản phẩm
    ├── danh-muc-san-pham.md            # API Quản lý Danh mục Sản phẩm
    ├── don-hang.md                     # API Quản lý Đơn hàng
    ├── form.md                         # API Quản lý Form
    ├── hoan-tien.md                    # API Quản lý Hoàn tiền
    ├── khach-hang.md                   # API Quản lý Khách hàng
    ├── kho-hang.md                     # API Quản lý Kho hàng
    ├── khuyen-mai.md                   # API Quản lý Khuyến mãi
    ├── landing-page.md                 # API Quản lý Landing Page
    ├── lazada-api.md                   # API Tích hợp Lazada
    ├── lien-he.md                      # API Quản lý Liên hệ
    ├── ma-giam-gia.md                  # API Quản lý Mã giảm giá
    ├── marketing.md                    # API Quản lý Marketing
    ├── phan-khuc-khach-hang.md         # API Quản lý Phân khúc Khách hàng
    ├── san-pham.md                     # API Quản lý Sản phẩm
    ├── shopee-api.md                   # API Tích hợp Shopee
    ├── thanh-toan.md                   # API Quản lý Thanh toán
    ├── thuoc-tinh-san-pham.md          # API Quản lý Thuộc tính Sản phẩm
    ├── tiktok-shop-api.md              # API Tích hợp TikTok Shop
    ├── tuong-tac-khach-hang.md         # API Quản lý Tương tác Khách hàng
    ├── van-chuyen.md                   # API Quản lý Vận chuyển
    ├── wordpress-api.md                # API Tích hợp WordPress
    └── zalo-api.md                     # API Tích hợp Zalo
```

## THÔNG TIN API CHÍNH

### Base URL
```
Production: https://api.nextflow.com
Staging: https://staging-api.nextflow.com
Development: https://dev-api.nextflow.com
```

### Phiên bản API
- **Hiện tại**: v1
- **Endpoint**: `/api/v1/`
- **Versioning**: URL-based versioning

### Định dạng dữ liệu
- **Request**: JSON (application/json)
- **Response**: JSON với cấu trúc chuẩn
- **Encoding**: UTF-8
- **Date format**: ISO 8601 (YYYY-MM-DDTHH:mm:ssZ)

### Phương thức xác thực
1. **Bearer Token**: JWT tokens cho user authentication
2. **API Key**: X-API-Key header cho server-to-server
3. **OAuth 2.0**: Cho ứng dụng bên thứ ba

## HƯỚNG DẪN NHANH

### 1. Bắt đầu với API
1. **Đọc tổng quan**: [Tổng quan API](./tong-quan-api.md)
2. **Hiểu cấu trúc phản hồi**: [Cấu trúc Phản hồi](./cau-truc-phan-hoi.md)
3. **Thiết lập xác thực**: [Xác thực và Bảo mật](./xac-thuc-va-bao-mat.md)

### 2. Xác thực đầu tiên
```bash
# Đăng nhập để lấy token
curl -X POST https://api.nextflow.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your-email@example.com",
    "password": "your-password"
  }'

# Sử dụng token để gọi API
curl -X GET https://api.nextflow.com/api/v1/customers \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 3. Khám phá API theo nhóm chức năng
- **🤖 AI & Automation**: [endpoints/ai-*.md](./endpoints/) - Chatbot, Knowledge Base, Models, Workflows
- **📊 Báo cáo & Thống kê**: [endpoints/bao-cao-*.md](./endpoints/) - Sales, Customer, Inventory, Marketing, Financial
- **🛍️ Sản phẩm & Kho hàng**: [endpoints/san-pham.md](./endpoints/san-pham.md), [endpoints/kho-hang.md](./endpoints/kho-hang.md) - Products, Categories, Inventory
- **👥 Khách hàng & Đối tác**: [endpoints/khach-hang.md](./endpoints/khach-hang.md), [endpoints/don-hang.md](./endpoints/don-hang.md) - Customers, Orders, Segments
- **🛒 E-commerce & Marketplace**: [endpoints/*-api.md](./endpoints/) - Lazada, Shopee, TikTok Shop, WordPress, Zalo
- **💰 Thanh toán & Tài chính**: [endpoints/thanh-toan.md](./endpoints/thanh-toan.md), [endpoints/hoan-tien.md](./endpoints/hoan-tien.md) - Payments, Refunds, Coupons
- **📧 Marketing & Communication**: [endpoints/marketing.md](./endpoints/marketing.md), [endpoints/landing-page.md](./endpoints/landing-page.md) - Campaigns, Forms, Contacts
- **🚚 Vận hành**: [endpoints/van-chuyen.md](./endpoints/van-chuyen.md) - Shipping, Logistics

## TÍNH NĂNG API CHÍNH

### RESTful Design
- **Resource-based URLs**: `/api/v1/customers/{id}`
- **HTTP Methods**: GET, POST, PUT, PATCH, DELETE
- **Status Codes**: Chuẩn HTTP status codes
- **Idempotent**: PUT và DELETE operations

### Phân trang và Lọc
```bash
# Phân trang
GET /api/v1/customers?page=1&limit=20

# Lọc và sắp xếp
GET /api/v1/customers?status=active&sort=created_at:desc

# Tìm kiếm
GET /api/v1/customers?search=john@example.com
```

### Webhooks
- **Real-time notifications**: Nhận thông báo khi dữ liệu thay đổi
- **Event types**: customer.created, order.updated, etc.
- **Retry mechanism**: Tự động retry khi webhook fails
- **Security**: HMAC signature verification

### Rate Limiting
- **Basic**: 60 requests/minute
- **Professional**: 120 requests/minute
- **Enterprise**: 300 requests/minute
- **Headers**: X-RateLimit-* headers trong response

## YÊU CẦU KỸ THUẬT

### Client Requirements
- **HTTPS**: Bắt buộc cho tất cả requests
- **JSON Support**: Parse và generate JSON
- **HTTP/1.1**: Minimum HTTP version
- **User-Agent**: Khuyến nghị set User-Agent header

### Server Specifications
- **Response Time**: < 200ms cho 95% requests
- **Uptime**: 99.9% SLA
- **Rate Limits**: Theo plan subscription
- **Data Retention**: 90 days cho logs

## BEST PRACTICES

### Authentication
1. **Secure Storage**: Lưu trữ tokens/API keys an toàn
2. **Token Refresh**: Implement automatic token refresh
3. **Scope Limitation**: Chỉ request quyền cần thiết
4. **HTTPS Only**: Không bao giờ gửi credentials qua HTTP

### Error Handling
1. **Check Response Status**: Luôn kiểm tra HTTP status code
2. **Parse Error Details**: Sử dụng error.details cho debugging
3. **Implement Retry**: Retry cho 5xx errors với exponential backoff
4. **Log Errors**: Log requestId cho support

### Performance
1. **Use Pagination**: Không request quá nhiều records
2. **Field Selection**: Chỉ request fields cần thiết
3. **Caching**: Cache responses khi phù hợp
4. **Batch Operations**: Sử dụng batch APIs khi có

### Security
1. **Validate Input**: Validate tất cả input data
2. **Sanitize Output**: Sanitize data trước khi display
3. **Monitor Usage**: Theo dõi API usage patterns
4. **Regular Rotation**: Rotate API keys định kỳ

## SUPPORT VÀ RESOURCES

### Documentation
- **API Reference**: Chi tiết tất cả endpoints
- **Code Examples**: Ví dụ cho nhiều ngôn ngữ
- **Postman Collection**: Import vào Postman
- **OpenAPI Spec**: Swagger/OpenAPI 3.0 specification

### Developer Tools
- **API Explorer**: Test APIs trực tiếp trong browser
- **SDK Libraries**: Official SDKs cho popular languages
- **Webhooks Tester**: Tool để test webhooks
- **Rate Limit Monitor**: Dashboard theo dõi usage

### Support Channels
- **Documentation**: docs.nextflow.com/api
- **Developer Forum**: community.nextflow.com
- **Email Support**: api-support@nextflow.com
- **Status Page**: status.nextflow.com

### Changelog và Updates
- **API Changelog**: Theo dõi changes và deprecations
- **Breaking Changes**: Thông báo trước 90 ngày
- **New Features**: Announcement qua email và blog
- **Migration Guides**: Hướng dẫn upgrade versions

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản API**: v1.0.0
**Tác giả**: NextFlow Development Team
