# API MOBILE APP NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Authentication](#2-endpoints-authentication)
3. [Endpoints Sync](#3-endpoints-sync)
4. [Endpoints Offline](#4-endpoints-offline)
5. [Endpoints Push Notifications](#5-endpoints-push-notifications)
6. [Endpoints Location](#6-endpoints-location)
7. [Endpoints Device Management](#7-endpoints-device-management)
8. [Error Codes](#8-error-codes)

## 1. GIỚI THIỆU

API Mobile App của NextFlow CRM cung cấp các endpoint chuyên biệt cho ứng dụng di động, bao gồm sync, offline support, push notifications và location services.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1/mobile
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
X-Device-ID: {device_id}
X-App-Version: {app_version}
```

### 1.3. Rate Limiting

- **Limit**: 2000 requests/hour (cao hơn web API)
- **Burst**: 200 requests/minute

## 2. ENDPOINTS AUTHENTICATION

### 2.1. Mobile login

```http
POST /auth/login
Content-Type: application/json
```

#### Request Body

```json
{
  "email": "user@nextflow-crm.com",
  "password": "SecurePassword123!",
  "deviceInfo": {
    "deviceId": "device_123456789",
    "deviceName": "iPhone 15 Pro",
    "platform": "iOS",
    "osVersion": "17.0",
    "appVersion": "2.1.0",
    "pushToken": "fcm_token_123456789"
  },
  "biometricEnabled": true,
  "rememberDevice": true
}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Đăng nhập thành công",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_123456789",
    "expiresIn": 3600,
    "user": {
      "id": "user_123456789",
      "name": "Nguyễn Văn A",
      "role": "sales_rep",
      "permissions": ["customers.read", "orders.write"],
      "territory": {
        "id": "territory_123",
        "name": "Hà Nội",
        "bounds": {
          "north": 21.0285,
          "south": 20.9975,
          "east": 105.8542,
          "west": 105.8019
        }
      }
    },
    "appConfig": {
      "syncInterval": 300,
      "offlineMode": true,
      "locationTracking": true,
      "pushNotifications": true
    }
  }
}
```

### 2.2. Biometric authentication setup

```http
POST /auth/biometric/setup
Content-Type: application/json
```

#### Request Body

```json
{
  "biometricType": "face_id",
  "publicKey": "base64_encoded_public_key",
  "deviceId": "device_123456789"
}
```

### 2.3. Biometric login

```http
POST /auth/biometric/login
Content-Type: application/json
```

#### Request Body

```json
{
  "deviceId": "device_123456789",
  "signature": "base64_encoded_signature",
  "challenge": "challenge_string"
}
```

## 3. ENDPOINTS SYNC

### 3.1. Get sync manifest

```http
GET /sync/manifest
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| lastSync | string | Timestamp của lần sync cuối (ISO 8601) |
| entities | string | Danh sách entities cần sync (comma-separated) |
| territory | string | ID territory của user |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "syncId": "sync_123456789",
    "serverTime": "2023-10-27T10:30:00Z",
    "changes": {
      "customers": {
        "created": 5,
        "updated": 12,
        "deleted": 2,
        "totalSize": 245760
      },
      "products": {
        "created": 0,
        "updated": 3,
        "deleted": 0,
        "totalSize": 15360
      },
      "orders": {
        "created": 8,
        "updated": 4,
        "deleted": 1,
        "totalSize": 102400
      }
    },
    "estimatedDownloadTime": 45,
    "compressionEnabled": true
  }
}
```

### 3.2. Download sync data

```http
GET /sync/data/{entity}
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| syncId | string | ID của sync session |
| lastSync | string | Timestamp của lần sync cuối |
| page | integer | Số trang cho pagination |
| compress | boolean | Nén dữ liệu (mặc định: true) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "entity": "customers",
    "page": 1,
    "totalPages": 3,
    "records": [
      {
        "id": "customer_123456789",
        "action": "updated",
        "data": {
          "name": "Nguyễn Văn A",
          "email": "customer@example.com",
          "phone": "+84901234567",
          "updatedAt": "2023-10-27T10:25:00Z"
        }
      }
    ],
    "checksum": "md5_checksum_here",
    "compressed": true
  }
}
```

### 3.3. Upload local changes

```http
POST /sync/upload
Content-Type: application/json
```

#### Request Body

```json
{
  "syncId": "sync_123456789",
  "changes": [
    {
      "entity": "customers",
      "localId": "local_customer_1",
      "action": "created",
      "data": {
        "name": "Trần Thị B",
        "email": "customer2@example.com",
        "phone": "+84907654321",
        "createdAt": "2023-10-27T09:45:00Z"
      },
      "timestamp": "2023-10-27T09:45:00Z"
    },
    {
      "entity": "orders",
      "id": "order_123456789",
      "action": "updated",
      "data": {
        "status": "completed",
        "notes": "Delivered successfully",
        "updatedAt": "2023-10-27T10:15:00Z"
      },
      "timestamp": "2023-10-27T10:15:00Z"
    }
  ]
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Upload thành công",
  "data": {
    "processed": 2,
    "conflicts": 0,
    "errors": 0,
    "mappings": [
      {
        "localId": "local_customer_1",
        "serverId": "customer_234567890"
      }
    ],
    "conflicts": [],
    "errors": []
  }
}
```

### 3.4. Resolve sync conflicts

```http
POST /sync/resolve-conflicts
Content-Type: application/json
```

#### Request Body

```json
{
  "syncId": "sync_123456789",
  "resolutions": [
    {
      "conflictId": "conflict_123",
      "resolution": "server_wins",
      "mergedData": null
    },
    {
      "conflictId": "conflict_124",
      "resolution": "manual_merge",
      "mergedData": {
        "name": "Nguyễn Văn A",
        "email": "updated@example.com",
        "phone": "+84901234567"
      }
    }
  ]
}
```

## 4. ENDPOINTS OFFLINE

### 4.1. Get offline data package

```http
GET /offline/package
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| territory | string | ID territory |
| entities | string | Entities cần download |
| maxSize | integer | Kích thước tối đa (MB) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "packageId": "package_123456789",
    "downloadUrl": "https://cdn.nextflow-crm.com/offline/package_123456789.zip",
    "size": 15728640,
    "entities": ["customers", "products", "orders"],
    "expiresAt": "2023-10-27T18:30:00Z",
    "checksum": "sha256_checksum_here"
  }
}
```

### 4.2. Validate offline data

```http
POST /offline/validate
Content-Type: application/json
```

#### Request Body

```json
{
  "packageId": "package_123456789",
  "checksum": "sha256_checksum_here",
  "entities": {
    "customers": 1250,
    "products": 450,
    "orders": 890
  }
}
```

### 4.3. Queue offline actions

```http
POST /offline/queue
Content-Type: application/json
```

#### Request Body

```json
{
  "actions": [
    {
      "id": "action_1",
      "entity": "customers",
      "action": "create",
      "data": {...},
      "timestamp": "2023-10-27T10:30:00Z",
      "priority": "high"
    }
  ]
}
```

## 5. ENDPOINTS PUSH NOTIFICATIONS

### 5.1. Register device for push

```http
POST /push/register
Content-Type: application/json
```

#### Request Body

```json
{
  "deviceId": "device_123456789",
  "pushToken": "fcm_token_123456789",
  "platform": "iOS",
  "appVersion": "2.1.0",
  "preferences": {
    "leads": true,
    "appointments": true,
    "tasks": true,
    "marketing": false
  }
}
```

### 5.2. Update push preferences

```http
PUT /push/preferences
Content-Type: application/json
```

#### Request Body

```json
{
  "deviceId": "device_123456789",
  "preferences": {
    "leads": true,
    "appointments": true,
    "tasks": false,
    "marketing": false,
    "doNotDisturb": {
      "enabled": true,
      "startTime": "22:00",
      "endTime": "08:00",
      "timezone": "Asia/Ho_Chi_Minh"
    }
  }
}
```

### 5.3. Send test notification

```http
POST /push/test
Content-Type: application/json
```

#### Request Body

```json
{
  "deviceId": "device_123456789",
  "title": "Test Notification",
  "body": "This is a test notification",
  "data": {
    "type": "test",
    "timestamp": "2023-10-27T10:30:00Z"
  }
}
```

## 6. ENDPOINTS LOCATION

### 6.1. Update location

```http
POST /location/update
Content-Type: application/json
```

#### Request Body

```json
{
  "latitude": 21.0285,
  "longitude": 105.8542,
  "accuracy": 5.0,
  "timestamp": "2023-10-27T10:30:00Z",
  "activity": "visit",
  "customerId": "customer_123456789"
}
```

### 6.2. Get nearby customers

```http
GET /location/nearby-customers
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| latitude | number | Vĩ độ hiện tại |
| longitude | number | Kinh độ hiện tại |
| radius | number | Bán kính tìm kiếm (km) |
| limit | integer | Số lượng kết quả tối đa |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "customer_123456789",
      "name": "Nguyễn Văn A",
      "company": "ABC Corp",
      "address": "123 Đường ABC, Hà Nội",
      "distance": 0.8,
      "latitude": 21.0275,
      "longitude": 105.8535,
      "lastVisit": "2023-10-20T14:30:00Z",
      "priority": "high"
    }
  ]
}
```

### 6.3. Log visit

```http
POST /location/visits
Content-Type: application/json
```

#### Request Body

```json
{
  "customerId": "customer_123456789",
  "checkInTime": "2023-10-27T10:30:00Z",
  "checkOutTime": "2023-10-27T11:15:00Z",
  "location": {
    "latitude": 21.0285,
    "longitude": 105.8542,
    "accuracy": 5.0
  },
  "purpose": "sales_meeting",
  "notes": "Discussed Q4 contract renewal",
  "outcome": "follow_up_required"
}
```

## 7. ENDPOINTS DEVICE MANAGEMENT

### 7.1. Register device

```http
POST /devices/register
Content-Type: application/json
```

#### Request Body

```json
{
  "deviceId": "device_123456789",
  "deviceName": "iPhone 15 Pro",
  "platform": "iOS",
  "osVersion": "17.0",
  "appVersion": "2.1.0",
  "deviceModel": "iPhone15,2",
  "screenResolution": "1179x2556",
  "timezone": "Asia/Ho_Chi_Minh"
}
```

### 7.2. Update device info

```http
PUT /devices/{deviceId}
Content-Type: application/json
```

### 7.3. Remote wipe device

```http
POST /devices/{deviceId}/wipe
Content-Type: application/json
```

#### Request Body

```json
{
  "reason": "Device lost/stolen",
  "wipeData": true,
  "revokeTokens": true
}
```

### 7.4. Get device status

```http
GET /devices/{deviceId}/status
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "deviceId": "device_123456789",
    "status": "active",
    "lastSeen": "2023-10-27T10:30:00Z",
    "appVersion": "2.1.0",
    "osVersion": "17.0",
    "batteryLevel": 85,
    "networkType": "wifi",
    "location": {
      "latitude": 21.0285,
      "longitude": 105.8542,
      "timestamp": "2023-10-27T10:30:00Z"
    },
    "securityStatus": {
      "jailbroken": false,
      "debugMode": false,
      "screenLock": true
    }
  }
}
```

## 8. ERROR CODES

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Device not registered | Thiết bị chưa được đăng ký |
| 4002 | Sync conflict | Xung đột dữ liệu sync |
| 4003 | Offline data expired | Dữ liệu offline đã hết hạn |
| 4004 | Location permission denied | Không có quyền truy cập vị trí |
| 4005 | Push token invalid | Push token không hợp lệ |
| 4006 | Device compromised | Thiết bị bị tấn công |
| 4007 | App version outdated | Phiên bản app cũ |
| 5001 | Sync failed | Đồng bộ thất bại |
| 5002 | Push delivery failed | Gửi push notification thất bại |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM API Team
