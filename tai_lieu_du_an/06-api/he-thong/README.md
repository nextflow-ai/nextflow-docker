# API HỆ THỐNG NextFlow CRM

## TỔNG QUAN

Thư mục này chứa tài liệu về các API hệ thống cốt lõi của NextFlow CRM, bao gồm quản lý người dùng, tổ chức, phân quyền, xác thực và các dịch vụ hệ thống khác.

## CẤU TRÚC THƯ MỤC

```
06-api/he-thong/
├── README.md                           # Tổng quan API hệ thống
├── authentication.md                   # API Xác thực và Authorization
├── user.md                            # API Quản lý Người dùng
├── organization.md                     # API Quản lý Tổ chức
├── role-permission.md                  # API Vai trò và Phân quyền
├── file-media.md                      # API Quản lý File và Media
├── notification.md                     # API Thông báo
└── webhook.md                         # API Webhook
```

## NHÓM CHỨC NĂNG

### 🔐 XÁC THỰC VÀ BẢO MẬT
- **authentication.md**: Login, logout, token management, OAuth
- **role-permission.md**: Roles, permissions, access control

### 👥 QUẢN LÝ NGƯỜI DÙNG VÀ TỔ CHỨC
- **user.md**: User management, profiles, activities
- **organization.md**: Organization structure, teams, settings

### 📁 DỊCH VỤ HỆ THỐNG
- **file-media.md**: File upload, media management, storage
- **notification.md**: Push notifications, email, SMS
- **webhook.md**: Event webhooks, integrations

## THÔNG TIN CHUNG

### Base URL
```
https://api.nextflow-crm.com/v1
```

### Xác thực
```http
Authorization: Bearer {your_token}
```

### Rate Limiting
- **Limit**: 1000 requests/hour
- **Burst**: 100 requests/minute

## LIÊN KẾT THAM KHẢO

- [Tổng quan API](../tong-quan-api.md)
- [Xác thực và Bảo mật](../xac-thuc-va-bao-mat.md)
- [API Endpoints](../endpoints/)

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM API Team
