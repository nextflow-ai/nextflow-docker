# API BẢO MẬT NÂNG CAO NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Xác thực](#2-endpoints-xác-thực)
3. [Endpoints Phân quyền](#3-endpoints-phân-quyền)
4. [Endpoints Audit Log](#4-endpoints-audit-log)
5. [Endpoints Security Monitoring](#5-endpoints-security-monitoring)
6. [Endpoints Compliance](#6-endpoints-compliance)
7. [Endpoints Device Management](#7-endpoints-device-management)
8. [Mã lỗi bảo mật](#8-mã-lỗi-bảo-mật)

## 1. GIỚI THIỆU

API Bảo mật Nâng cao NextFlow CRM-AI cung cấp các endpoint để quản lý xác thực đa yếu tố, phân quyền, giám sát bảo mật và tuân thủ quy định.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1/security
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
X-Security-Token: {security_token}
X-Device-ID: {device_id}
```

## 2. ENDPOINTS XÁC THỰC

### 2.1. Thiết lập 2FA

```http
POST /auth/2fa/setup
Content-Type: application/json
```

#### Request Body

```json
{
  "method": "totp",
  "deviceName": "iPhone 15 Pro của Nguyễn Văn A",
  "backupCodes": true
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "2FA đã được thiết lập",
  "data": {
    "qrCode": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
    "secretKey": "JBSWY3DPEHPK3PXP",
    "backupCodes": [
      "12345678",
      "87654321",
      "11223344",
      "44332211",
      "55667788"
    ],
    "setupInstructions": "Quét mã QR bằng Google Authenticator hoặc nhập mã bí mật"
  }
}
```

### 2.2. Xác thực 2FA

```http
POST /auth/2fa/verify
Content-Type: application/json
```

#### Request Body

```json
{
  "token": "123456",
  "method": "totp",
  "deviceId": "device_123456789"
}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Xác thực thành công",
  "data": {
    "verified": true,
    "trustDevice": true,
    "expiresAt": "2024-10-27T18:30:00Z",
    "remainingAttempts": 2
  }
}
```

### 2.3. Gửi OTP qua SMS

```http
POST /auth/otp/send
Content-Type: application/json
```

#### Request Body

```json
{
  "phoneNumber": "+84901234567",
  "purpose": "login",
  "language": "vi"
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "OTP đã được gửi",
  "data": {
    "otpId": "otp_123456789",
    "maskedPhone": "+8490***4567",
    "expiresIn": 300,
    "remainingAttempts": 3,
    "nextResendIn": 60
  }
}
```

### 2.4. Xác thực OTP

```http
POST /auth/otp/verify
Content-Type: application/json
```

#### Request Body

```json
{
  "otpId": "otp_123456789",
  "code": "123456"
}
```

## 3. ENDPOINTS PHÂN QUYỀN

### 3.1. Lấy danh sách vai trò

```http
GET /roles
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "role_admin",
      "name": "Quản trị viên",
      "description": "Toàn quyền quản lý hệ thống",
      "level": 1,
      "permissions": [
        "users.create",
        "users.read",
        "users.update",
        "users.delete",
        "system.config",
        "reports.all"
      ],
      "userCount": 3,
      "isSystem": true
    },
    {
      "id": "role_sales_manager",
      "name": "Quản lý bán hàng",
      "description": "Quản lý đội ngũ bán hàng và báo cáo",
      "level": 2,
      "permissions": [
        "customers.read",
        "orders.read",
        "reports.sales",
        "team.manage"
      ],
      "userCount": 5,
      "isSystem": false
    }
  ]
}
```

### 3.2. Tạo vai trò mới

```http
POST /roles
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "Nhân viên kế toán",
  "description": "Quản lý tài chính và kế toán",
  "permissions": [
    "invoices.read",
    "invoices.create",
    "payments.read",
    "reports.financial"
  ],
  "restrictions": {
    "ipWhitelist": ["203.162.4.0/24"],
    "timeRestriction": {
      "workingHours": "08:00-17:00",
      "workingDays": ["monday", "tuesday", "wednesday", "thursday", "friday"]
    },
    "dataAccess": {
      "customerTiers": ["standard", "premium"],
      "departments": ["accounting", "finance"]
    }
  }
}
```

### 3.3. Gán vai trò cho người dùng

```http
POST /users/{userId}/roles
Content-Type: application/json
```

#### Request Body

```json
{
  "roleIds": ["role_sales_manager", "role_customer_support"],
  "expiresAt": "2024-12-31T23:59:59Z",
  "reason": "Thăng chức lên quản lý bán hàng"
}
```

### 3.4. Kiểm tra quyền

```http
POST /permissions/check
Content-Type: application/json
```

#### Request Body

```json
{
  "userId": "user_123456789",
  "permission": "customers.delete",
  "resourceId": "customer_987654321",
  "context": {
    "ipAddress": "203.162.4.100",
    "userAgent": "Mozilla/5.0...",
    "timestamp": "2024-10-27T10:30:00Z"
  }
}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "allowed": false,
    "reason": "Không có quyền xóa khách hàng VIP",
    "requiredPermissions": ["customers.delete", "customers.vip.manage"],
    "userPermissions": ["customers.read", "customers.update"],
    "restrictions": {
      "timeRestriction": false,
      "ipRestriction": true,
      "dataRestriction": true
    }
  }
}
```

## 4. ENDPOINTS AUDIT LOG

### 4.1. Lấy audit logs

```http
GET /audit-logs
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số log mỗi trang (mặc định: 50) |
| userId | string | Lọc theo người dùng |
| action | string | Lọc theo hành động |
| resource | string | Lọc theo tài nguyên |
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |
| severity | string | Mức độ (low, medium, high, critical) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "log_123456789",
      "timestamp": "2024-10-27T10:30:15Z",
      "userId": "user_123456789",
      "userName": "Nguyễn Văn A",
      "action": "customer.delete",
      "resource": "customer_987654321",
      "resourceName": "Công ty ABC",
      "ipAddress": "203.162.4.100",
      "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)...",
      "severity": "high",
      "status": "success",
      "details": {
        "reason": "Khách hàng yêu cầu xóa dữ liệu (GDPR)",
        "approvedBy": "manager_456789",
        "dataRetention": "7_years_financial_records"
      },
      "changes": {
        "before": {"status": "active", "tier": "vip"},
        "after": {"status": "deleted", "deletedAt": "2024-10-27T10:30:15Z"}
      }
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "perPage": 50,
      "totalPages": 25,
      "totalItems": 1247
    },
    "summary": {
      "totalLogs": 1247,
      "criticalEvents": 3,
      "highSeverity": 45,
      "mediumSeverity": 234,
      "lowSeverity": 965
    }
  }
}
```

### 4.2. Tạo audit log

```http
POST /audit-logs
Content-Type: application/json
```

#### Request Body

```json
{
  "action": "data.export",
  "resource": "customer_data",
  "severity": "medium",
  "details": {
    "exportType": "csv",
    "recordCount": 1500,
    "reason": "Báo cáo tháng 10",
    "approvedBy": "manager_456789"
  },
  "metadata": {
    "fileSize": 2048576,
    "fileName": "customer_export_202410.csv",
    "encryptionUsed": true
  }
}
```

## 5. ENDPOINTS SECURITY MONITORING

### 5.1. Lấy security alerts

```http
GET /security/alerts
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| status | string | Trạng thái (open, investigating, resolved) |
| severity | string | Mức độ (low, medium, high, critical) |
| type | string | Loại cảnh báo |
| fromDate | string | Từ ngày |
| toDate | string | Đến ngày |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "alert_123456789",
      "type": "suspicious_login",
      "severity": "high",
      "status": "investigating",
      "title": "Đăng nhập nghi ngờ từ IP lạ",
      "description": "Phát hiện 15 lần đăng nhập thất bại từ IP 185.220.101.42",
      "detectedAt": "2024-10-27T14:23:15Z",
      "userId": "user_123456789",
      "userName": "admin@company.com",
      "sourceIp": "185.220.101.42",
      "location": "Unknown (Tor Exit Node)",
      "evidence": {
        "failedAttempts": 15,
        "timeWindow": "5 minutes",
        "userAgent": "curl/7.68.0",
        "geoLocation": "Unknown",
        "isTorExit": true,
        "isVpn": true
      },
      "actions": [
        {
          "action": "account_locked",
          "timestamp": "2024-10-27T14:23:20Z",
          "automated": true
        },
        {
          "action": "notification_sent",
          "timestamp": "2024-10-27T14:23:25Z",
          "recipients": ["security@company.com"]
        }
      ],
      "assignedTo": "security_analyst_001",
      "notes": "Đang điều tra nguồn gốc IP và mục đích tấn công"
    }
  ]
}
```

### 5.2. Cập nhật security alert

```http
PUT /security/alerts/{alertId}
Content-Type: application/json
```

#### Request Body

```json
{
  "status": "resolved",
  "resolution": "False positive - CEO đang công tác nước ngoài",
  "actions": [
    "Xác nhận với CEO qua điện thoại",
    "Whitelist IP tạm thời",
    "Mở khóa tài khoản"
  ],
  "notes": "IP thuộc về khách sạn tại Singapore, CEO đang công tác"
}
```

### 5.3. Threat intelligence

```http
GET /security/threats
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "summary": {
      "totalThreats": 1247,
      "activeThreats": 23,
      "blockedIps": 5678,
      "malwareSamples": 89
    },
    "recentThreats": [
      {
        "type": "malicious_ip",
        "value": "185.220.101.42",
        "severity": "high",
        "source": "Tor Exit Node",
        "firstSeen": "2024-10-27T14:20:00Z",
        "lastSeen": "2024-10-27T14:25:00Z",
        "attempts": 15,
        "blocked": true
      }
    ],
    "threatCategories": {
      "malicious_ips": 3456,
      "phishing_domains": 1234,
      "malware_hashes": 567,
      "suspicious_patterns": 890
    }
  }
}
```

## 6. ENDPOINTS COMPLIANCE

### 6.1. GDPR Data Subject Request

```http
POST /compliance/gdpr/data-request
Content-Type: application/json
```

#### Request Body

```json
{
  "requestType": "access",
  "subjectEmail": "customer@example.com",
  "subjectPhone": "+84901234567",
  "requestReason": "Khách hàng muốn xem dữ liệu cá nhân",
  "verificationMethod": "email_otp",
  "requestedBy": "customer_service_rep_001"
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Yêu cầu GDPR đã được tạo",
  "data": {
    "requestId": "gdpr_123456789",
    "status": "pending_verification",
    "estimatedCompletion": "2024-11-26T23:59:59Z",
    "verificationCode": "VERIFY123",
    "nextSteps": [
      "Gửi mã xác thực đến email khách hàng",
      "Khách hàng xác nhận danh tính",
      "Xử lý yêu cầu trong 30 ngày"
    ]
  }
}
```

### 6.2. Compliance report

```http
GET /compliance/reports/{reportType}
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| period | string | Kỳ báo cáo (monthly, quarterly, yearly) |
| year | integer | Năm báo cáo |
| month | integer | Tháng báo cáo (nếu period=monthly) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "reportType": "gdpr_compliance",
    "period": "2024-10",
    "generatedAt": "2024-10-27T10:30:00Z",
    "summary": {
      "totalDataSubjects": 15420,
      "dataRequests": {
        "access": 45,
        "rectification": 12,
        "erasure": 8,
        "portability": 3
      },
      "processingTime": {
        "average": 12.5,
        "maximum": 28,
        "withinSla": 98.5
      },
      "breaches": 0,
      "dpoActivities": 23
    },
    "details": {
      "requestsByType": [
        {"type": "access", "count": 45, "avgDays": 8.2},
        {"type": "erasure", "count": 8, "avgDays": 15.6}
      ],
      "complianceScore": 98.7,
      "recommendations": [
        "Cải thiện thời gian phản hồi yêu cầu erasure",
        "Tăng cường đào tạo GDPR cho nhân viên"
      ]
    }
  }
}
```

## 7. ENDPOINTS DEVICE MANAGEMENT

### 7.1. Đăng ký thiết bị

```http
POST /devices/register
Content-Type: application/json
```

#### Request Body

```json
{
  "deviceName": "iPhone 15 Pro của Nguyễn Văn A",
  "deviceType": "mobile",
  "platform": "iOS",
  "osVersion": "17.0.1",
  "appVersion": "2.1.0",
  "deviceFingerprint": "sha256_hash_of_device_characteristics",
  "pushToken": "fcm_token_123456789"
}
```

### 7.2. Remote wipe thiết bị

```http
POST /devices/{deviceId}/wipe
Content-Type: application/json
```

#### Request Body

```json
{
  "reason": "Thiết bị bị mất cắp",
  "wipeType": "full",
  "notifyUser": true,
  "revokeTokens": true
}
```

### 7.3. Lấy danh sách thiết bị

```http
GET /devices
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "device_123456789",
      "name": "iPhone 15 Pro của Nguyễn Văn A",
      "type": "mobile",
      "platform": "iOS",
      "status": "active",
      "lastSeen": "2024-10-27T10:25:00Z",
      "location": "Hà Nội, Việt Nam",
      "ipAddress": "203.162.4.100",
      "isJailbroken": false,
      "securityScore": 95,
      "registeredAt": "2024-10-01T08:30:00Z"
    }
  ]
}
```

## 8. MÃ LỖI BẢO MẬT

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Invalid 2FA token | Mã 2FA không hợp lệ |
| 4002 | 2FA not enabled | Chưa bật 2FA |
| 4003 | OTP expired | Mã OTP đã hết hạn |
| 4004 | Too many attempts | Quá nhiều lần thử |
| 4005 | Device not trusted | Thiết bị không tin cậy |
| 4006 | IP not whitelisted | IP không trong danh sách cho phép |
| 4007 | Access denied | Không có quyền truy cập |
| 4008 | Account locked | Tài khoản bị khóa |
| 4009 | Session expired | Phiên đăng nhập hết hạn |
| 5001 | Security service unavailable | Dịch vụ bảo mật không khả dụng |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI Security Team
