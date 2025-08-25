# XÁC THỰC VÀ BẢO MẬT API NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Phương thức xác thực](#2-phương-thức-xác-thực)
3. [Bảo mật API](#3-bảo-mật-api)
4. [Xử lý lỗi xác thực](#4-xử-lý-lỗi-xác-thực)
5. [Phương pháp thực hành tốt nhất](#5-phương-pháp-thực-hành-tốt-nhất)
6. [Kết luận](#6-kết-luận)
7. [Tài liệu tham khảo](#7-tài-liệu-tham-khảo)

## 1. GIỚI THIỆU

Tài liệu này mô tả các phương thức xác thực và bảo mật API của NextFlow CRM-AI. Việc xác thực đúng cách là bắt buộc để truy cập vào các API của hệ thống NextFlow CRM-AI và đảm bảo an toàn dữ liệu.

## 2. PHƯƠNG THỨC XÁC THỰC

NextFlow CRM-AI hỗ trợ các phương thức xác thực sau:

1. **Bearer Token Authentication**: Sử dụng JWT (JSON Web Token)
2. **API Key Authentication**: Sử dụng API key
3. **OAuth 2.0**: Sử dụng OAuth 2.0 cho ứng dụng bên thứ ba

### 2.1. Bearer Token Authentication

Bearer Token Authentication là phương thức xác thực chính được sử dụng trong NextFlow CRM-AI. Token được tạo sau khi đăng nhập thành công và phải được gửi kèm trong header của mỗi request.

#### 2.1.1. Lấy token

Để lấy token, gửi request đến endpoint đăng nhập:

```
POST /api/v1/auth/login
```

Body:
```json
{
  "email": "user@example.com",
  "password": "your_password"
}
```

Phản hồi:
```json
{
  "success": true,
  "code": 1000,
  "message": "Đăng nhập thành công",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600
  },
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0"
  }
}
```

#### 2.1.2. Sử dụng token

Thêm token vào header `Authorization` của mỗi request:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Ví dụ sử dụng cURL:
```bash
curl -X GET \
  https://api.NextFlow.com/api/v1/customers \
  -H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
```

#### 2.1.3. Làm mới token

Khi token hết hạn, bạn có thể sử dụng refresh token để lấy token mới:

```
POST /api/v1/auth/refresh
```

Body:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

Phản hồi:
```json
{
  "success": true,
  "code": 1000,
  "message": "Làm mới token thành công",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600
  },
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0"
  }
}
```

### 2.2. API Key Authentication

API Key Authentication được sử dụng cho các ứng dụng máy chủ hoặc các tích hợp không yêu cầu xác thực người dùng.

#### 2.2.1. Tạo API Key

API Key có thể được tạo từ giao diện quản trị NextFlow CRM-AI:

1. Đăng nhập vào NextFlow CRM-AI
2. Truy cập **Cài đặt > API > API Keys**
3. Nhấn **Tạo API Key mới**
4. Đặt tên và chọn quyền cho API Key
5. Lưu lại API Key được tạo (API Key chỉ hiển thị một lần)

#### 2.2.2. Sử dụng API Key

Thêm API Key vào header `X-API-Key` của mỗi request:

```
X-API-Key: your_api_key
```

Ví dụ sử dụng cURL:
```bash
curl -X GET \
  https://api.NextFlow.com/api/v1/customers \
  -H 'X-API-Key: your_api_key'
```

### 2.3. OAuth 2.0

OAuth 2.0 được sử dụng cho các ứng dụng bên thứ ba cần truy cập vào tài nguyên của người dùng.

#### 2.3.1. Đăng ký ứng dụng

Để sử dụng OAuth 2.0, bạn cần đăng ký ứng dụng của mình với NextFlow CRM-AI:

1. Đăng nhập vào NextFlow CRM-AI
2. Truy cập **Cài đặt > API > OAuth Apps**
3. Nhấn **Đăng ký ứng dụng mới**
4. Điền thông tin ứng dụng và URL callback
5. Lưu lại Client ID và Client Secret

#### 2.3.2. Luồng xác thực

NextFlow CRM-AI hỗ trợ các luồng xác thực OAuth 2.0 sau:

1. **Authorization Code Flow**: Cho ứng dụng web
2. **Implicit Flow**: Cho ứng dụng SPA
3. **Client Credentials Flow**: Cho ứng dụng máy chủ
4. **Password Flow**: Cho ứng dụng đáng tin cậy

Chi tiết về các luồng xác thực OAuth 2.0 có thể được tìm thấy trong [tài liệu OAuth 2.0](./he-thong/oauth.md).

## 3. BẢO MẬT API

### 3.1. HTTPS

Tất cả các request API phải được thực hiện qua HTTPS để đảm bảo bảo mật trong quá trình truyền tải dữ liệu.

### 3.2. Rate Limiting

NextFlow CRM-AI áp dụng rate limiting để ngăn chặn lạm dụng API:

- **Basic Plan**: 60 requests/phút
- **Professional Plan**: 120 requests/phút
- **Enterprise Plan**: 300 requests/phút

Khi vượt quá giới hạn, API sẽ trả về lỗi 429 (Too Many Requests).

Header phản hồi sẽ bao gồm thông tin về rate limit:

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1635789600
```

### 3.3. CORS

NextFlow CRM-AI hỗ trợ Cross-Origin Resource Sharing (CORS) cho các ứng dụng web. Các domain được phép truy cập API có thể được cấu hình trong giao diện quản trị.

### 3.4. Phân quyền

NextFlow CRM-AI sử dụng hệ thống phân quyền dựa trên vai trò (RBAC) để kiểm soát quyền truy cập vào các API:

1. **Vai trò (Roles)**: Xác định nhóm quyền hạn
2. **Quyền hạn (Permissions)**: Xác định các hành động cụ thể
3. **Phạm vi (Scopes)**: Xác định phạm vi truy cập (cho OAuth 2.0)

Khi không có đủ quyền, API sẽ trả về lỗi 403 (Forbidden).

## 4. XỬ LÝ LỖI XÁC THỰC

### 4.1. Lỗi xác thực (401)

```json
{
  "success": false,
  "code": 4001,
  "message": "Chưa xác thực",
  "error": {
    "type": "AUTHENTICATION_FAILED",
    "message": "Phiên làm việc đã hết hạn, vui lòng đăng nhập lại",
    "details": {
      "resourceType": "session",
      "reason": "Token expired"
    }
  },
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0"
  }
}
```

### 4.2. Lỗi phân quyền (403)

```json
{
  "success": false,
  "code": 4003,
  "message": "Không có quyền truy cập",
  "error": {
    "type": "ACCESS_DENIED",
    "message": "Bạn không có quyền thực hiện hành động này",
    "details": {
      "resourceType": "customer",
      "resourceId": "cust_123456789",
      "required_permission": "customers.delete"
    }
  },
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0"
  }
}
```

### 4.3. Lỗi rate limit (429)

```json
{
  "success": false,
  "code": 4008,
  "message": "Quá nhiều yêu cầu",
  "error": {
    "type": "RATE_LIMIT_EXCEEDED",
    "message": "Bạn đã vượt quá giới hạn số lượng request cho phép",
    "details": {
      "resourceType": "api",
      "retry_after": 60
    }
  },
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0"
  }
}
```

## 5. PHƯƠNG PHÁP THỰC HÀNH TỐT NHẤT

### 5.1. Bảo mật thông tin xác thực

1. **Không hardcode credentials**: Sử dụng environment variables
2. **Secure storage**: Lưu trữ tokens/API keys trong secure storage
3. **Regular rotation**: Rotate API keys định kỳ
4. **Principle of least privilege**: Chỉ cấp quyền tối thiểu cần thiết
5. **Monitor usage**: Theo dõi và log việc sử dụng API

### 5.2. Network security

1. **HTTPS only**: Luôn sử dụng HTTPS cho tất cả requests
2. **Certificate validation**: Validate SSL certificates
3. **IP whitelisting**: Giới hạn IP được phép truy cập (nếu có thể)
4. **VPN usage**: Sử dụng VPN cho môi trường sensitive

### 5.3. Application security

1. **Input validation**: Validate tất cả input data
2. **Output encoding**: Encode output để tránh injection attacks
3. **Error handling**: Không expose sensitive information trong errors
4. **Logging**: Log security events để audit

### 5.4. Token management

1. **Automatic refresh**: Implement automatic token refresh
2. **Secure storage**: Store tokens securely (không trong localStorage)
3. **Token expiration**: Handle token expiration gracefully
4. **Logout cleanup**: Clear tokens khi logout

### 5.5. Monitoring và alerting

1. **Failed attempts**: Monitor failed authentication attempts
2. **Unusual patterns**: Detect unusual API usage patterns
3. **Rate limit violations**: Alert khi có rate limit violations
4. **Security incidents**: Có plan response cho security incidents

## 6. KẾT LUẬN

Bảo mật API là một yếu tố quan trọng trong việc xây dựng ứng dụng tích hợp với NextFlow CRM-AI. Việc hiểu và áp dụng đúng các phương thức xác thực và best practices sẽ giúp đảm bảo an toàn cho dữ liệu và hệ thống.

### 6.1. Tóm tắt các phương thức xác thực

| Phương thức | Use Case | Bảo mật | Phức tạp |
|-------------|----------|---------|----------|
| **Bearer Token** | Web/Mobile apps | Cao | Trung bình |
| **API Key** | Server-to-server | Trung bình | Thấp |
| **OAuth 2.0** | Third-party apps | Rất cao | Cao |

### 6.2. Khuyến nghị triển khai

1. **Bắt đầu với Bearer Token**: Cho hầu hết use cases
2. **Sử dụng API Key**: Cho server-to-server integration
3. **Implement OAuth 2.0**: Khi cần third-party access
4. **Luôn sử dụng HTTPS**: Không có ngoại lệ
5. **Monitor và log**: Để detect và respond với security issues

### 6.3. Tài liệu liên quan

- [Tổng quan API](./tong-quan-api.md)
- [Cấu trúc Phản hồi](./cau-truc-phan-hoi.md)
- [OAuth 2.0 Documentation](./he-thong/oauth.md)
- [API Keys Management](./tich-hop/api-keys.md)

## 7. TÀI LIỆU THAM KHẢO

### 7.1. Security Standards
- [OAuth 2.0 RFC](https://tools.ietf.org/html/rfc6749)
- [JWT RFC](https://tools.ietf.org/html/rfc7519)
- [OWASP API Security](https://owasp.org/www-project-api-security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

### 7.2. Best Practices
- [API Security Best Practices](https://restfulapi.net/security-essentials/)
- [Token-based Authentication](https://auth0.com/learn/token-based-authentication-made-easy/)
- [API Rate Limiting](https://nordicapis.com/everything-you-need-to-know-about-api-rate-limiting/)

### 7.3. NextFlow CRM-AI Resources
- [Security Policy](https://docs.nextflow.com/security)
- [Compliance Documentation](https://docs.nextflow.com/compliance)
- [Security Incident Response](https://docs.nextflow.com/security/incident-response)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 1.0.0
**Tác giả**: NextFlow Development Team
