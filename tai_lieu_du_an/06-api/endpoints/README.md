# API ENDPOINTS NextFlow CRM

## TỔNG QUAN

Thư mục này chứa tài liệu chi tiết về tất cả các API endpoints của NextFlow CRM. Mỗi tệp mô tả một nhóm chức năng cụ thể với các endpoints, request/response format và error codes.

## CẤU TRÚC THƯ MỤC

```
06-api/endpoints/
├── README.md                           # Tổng quan về API endpoints
├── ai-chatbot.md                       # API Quản lý Chatbot AI
├── ai-knowledge-base.md                # API Quản lý Knowledge Base AI
├── ai-model.md                         # API Quản lý Mô hình AI
├── ai-provider.md                      # API Quản lý Nhà cung cấp AI
├── ai-workflow.md                      # API Quản lý Workflow AI
├── bao-cao-ban-hang.md                 # API Báo cáo Bán hàng
├── bao-cao-khach-hang.md               # API Báo cáo Khách hàng
├── bao-cao-kho-hang.md                 # API Báo cáo Kho hàng
├── bao-cao-marketing.md                # API Báo cáo Marketing
├── bao-cao-tai-chinh.md                # API Báo cáo Tài chính
├── bien-the-san-pham.md                # API Quản lý Biến thể Sản phẩm
├── danh-muc-san-pham.md                # API Quản lý Danh mục Sản phẩm
├── don-hang.md                         # API Quản lý Đơn hàng
├── form.md                             # API Quản lý Form
├── hoan-tien.md                        # API Quản lý Hoàn tiền
├── khach-hang.md                       # API Quản lý Khách hàng
├── kho-hang.md                         # API Quản lý Kho hàng
├── khuyen-mai.md                       # API Quản lý Khuyến mãi
├── landing-page.md                     # API Quản lý Landing Page
├── lazada-api.md                       # API Tích hợp Lazada
├── lien-he.md                          # API Quản lý Liên hệ
├── ma-giam-gia.md                      # API Quản lý Mã giảm giá
├── marketing.md                        # API Quản lý Marketing
├── phan-khuc-khach-hang.md             # API Quản lý Phân khúc Khách hàng
├── san-pham.md                         # API Quản lý Sản phẩm
├── shopee-api.md                       # API Tích hợp Shopee
├── thanh-toan.md                       # API Quản lý Thanh toán
├── thuoc-tinh-san-pham.md              # API Quản lý Thuộc tính Sản phẩm
├── tiktok-shop-api.md                  # API Tích hợp TikTok Shop
├── tuong-tac-khach-hang.md             # API Quản lý Tương tác Khách hàng
├── van-chuyen.md                       # API Quản lý Vận chuyển
├── wordpress-api.md                    # API Tích hợp WordPress
├── zalo-api.md                         # API Tích hợp Zalo
├── notification.md                     # ⭐ API Hệ thống Thông báo ✅ P1
├── email-system.md                     # ⭐ API Hệ thống Email ✅ P1
├── live-chat.md                        # ⭐ API Live Chat ✅ P1
├── mobile-app.md                       # ⭐ API Mobile App ✅ P1
├── call-center.md                      # 🚀 API Hệ thống Tổng đài ✅ P2
├── advanced-security.md                # 🚀 API Bảo mật Nâng cao ✅ P2
├── invoice-management.md               # 💼 API Quản lý Hóa đơn ✅ P3
└── project-management.md               # 💼 API Quản lý Dự án ✅ P3
```

## NHÓM CHỨC NĂNG

### 🤖 AI & AUTOMATION (5 endpoints)
- **ai-chatbot.md**: Quản lý chatbot AI, hội thoại, tin nhắn
- **ai-knowledge-base.md**: Quản lý cơ sở kiến thức AI, tài liệu, truy vấn
- **ai-model.md**: Quản lý mô hình AI, cấu hình, kiểm tra
- **ai-provider.md**: Quản lý nhà cung cấp AI, xác thực, thống kê
- **ai-workflow.md**: Quản lý workflow AI, execution, template

### 📊 BÁO CÁO & THỐNG KÊ (5 endpoints)
- **bao-cao-ban-hang.md**: Báo cáo doanh thu, hiệu suất bán hàng
- **bao-cao-khach-hang.md**: Phân tích khách hàng, churn, CLV
- **bao-cao-kho-hang.md**: Báo cáo tồn kho, xuất nhập, hiệu suất
- **bao-cao-marketing.md**: Báo cáo chiến dịch, ROI, conversion
- **bao-cao-tai-chinh.md**: Báo cáo tài chính, lợi nhuận, công nợ

### 🛍️ SẢN PHẨM & KHO HÀNG (4 endpoints)
- **san-pham.md**: Quản lý sản phẩm, kho, giá cả, hình ảnh
- **danh-muc-san-pham.md**: Quản lý danh mục sản phẩm phân cấp
- **bien-the-san-pham.md**: Quản lý biến thể sản phẩm (size, màu, v.v.)
- **thuoc-tinh-san-pham.md**: Quản lý thuộc tính sản phẩm
- **kho-hang.md**: Quản lý kho hàng, xuất nhập, kiểm kê

### 👥 KHÁCH HÀNG & ĐỐI TÁC (4 endpoints)
- **khach-hang.md**: Quản lý thông tin khách hàng, lịch sử
- **don-hang.md**: Quản lý đơn hàng, trạng thái, thanh toán
- **phan-khuc-khach-hang.md**: Phân khúc khách hàng, targeting
- **tuong-tac-khach-hang.md**: Quản lý tương tác, hoạt động

### 🛒 E-COMMERCE & MARKETPLACE (5 endpoints)
- **lazada-api.md**: Tích hợp với Lazada marketplace
- **shopee-api.md**: Tích hợp với Shopee marketplace
- **tiktok-shop-api.md**: Tích hợp với TikTok Shop
- **wordpress-api.md**: Tích hợp với WordPress/WooCommerce
- **zalo-api.md**: Tích hợp với Zalo Business

### 💰 THANH TOÁN & TÀI CHÍNH (4 endpoints)
- **thanh-toan.md**: Quản lý thanh toán, gateway, transaction
- **hoan-tien.md**: Quản lý hoàn tiền, refund
- **ma-giam-gia.md**: Quản lý mã giảm giá, voucher
- **khuyen-mai.md**: Quản lý chương trình khuyến mãi

### 📧 MARKETING & COMMUNICATION (4 endpoints)
- **marketing.md**: Quản lý chiến dịch marketing, email
- **landing-page.md**: Quản lý landing page, conversion
- **form.md**: Quản lý form, lead capture
- **lien-he.md**: Quản lý liên hệ, support ticket

### 🚚 VẬN HÀNH (2 endpoints)
- **van-chuyen.md**: Quản lý vận chuyển, tracking, carrier

### ⭐ PRIORITY 1 - ĐÃ HOÀN THÀNH (4 endpoints)
- **notification.md**: Multi-channel notification system với real-time alerts
- **email-system.md**: Email marketing automation và campaign management
- **live-chat.md**: Real-time chat support với AI chatbot integration
- **mobile-app.md**: Mobile app API với offline sync và push notifications

### 🚀 PRIORITY 2 - ĐÃ HOÀN THÀNH (2 endpoints)
- **call-center.md**: VoIP call center API với ghi âm và phân tích AI
- **advanced-security.md**: 2FA, audit logs, compliance GDPR/SOC2

### 💼 PRIORITY 3 - MỚI HOÀN THÀNH (2 endpoints)
- **invoice-management.md**: Hóa đơn điện tử API tuân thủ pháp luật Việt Nam
- **project-management.md**: Project management API với Gantt, time tracking

## THÔNG TIN CHUNG

### Base URL
```
https://api.nextflow-crm.com/v1
```

### Xác thực
Tất cả API endpoints yêu cầu xác thực:
```http
Authorization: Bearer {your_token}
```
hoặc
```http
X-API-Key: {your_api_key}
```

### Rate Limiting
- **Limit**: 1000 requests/hour cho mỗi API key
- **Burst**: 100 requests/minute
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

### Response Format
Tất cả responses đều có format chuẩn:
```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {},
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0"
  }
}
```

### Error Handling
Mỗi endpoint có bảng error codes riêng. Các error codes chung:
- **4xx**: Client errors (Bad request, Unauthorized, Not found, v.v.)
- **5xx**: Server errors (Internal error, Service unavailable, v.v.)

## HƯỚNG DẪN SỬ DỤNG

1. **Chọn endpoint phù hợp** từ danh sách trên
2. **Đọc tài liệu chi tiết** của endpoint đó
3. **Chuẩn bị authentication** (Bearer token hoặc API key)
4. **Thực hiện API call** theo format được mô tả
5. **Xử lý response** và error codes

## LIÊN KẾT THAM KHẢO

- [Tổng quan API](../tong-quan-api.md)
- [Xác thực và Bảo mật](../xac-thuc-va-bao-mat.md)
- [Rate Limiting](../rate-limiting.md)
- [Webhooks](../webhooks.md)
- [SDK và Libraries](../sdk-va-libraries.md)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 2.0.0
**Tác giả**: NextFlow CRM API Team
