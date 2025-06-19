# CẤU TRÚC PHẢN HỒI API NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Cấu trúc phản hồi chuẩn](#2-cấu-trúc-phản-hồi-chuẩn)
3. [Phản hồi thành công](#3-phản-hồi-thành-công)
4. [Phản hồi lỗi](#4-phản-hồi-lỗi)
5. [Mã code hệ thống](#5-mã-code-hệ-thống)
6. [Kết luận](#6-kết-luận)
7. [Tài liệu tham khảo](#7-tài-liệu-tham-khảo)

## 1. GIỚI THIỆU

API của NextFlow CRM sử dụng cấu trúc phản hồi chuẩn và nhất quán để giúp bạn dễ dàng xử lý dữ liệu trả về. Tất cả các phản hồi đều được trả về dưới dạng JSON và tuân theo cấu trúc chung của NextFlow CRM.

## 2. CẤU TRÚC PHẢN HỒI CHUẨN

NextFlow API sử dụng cấu trúc response chuẩn để đảm bảo tính nhất quán và dễ dàng xử lý dữ liệu.

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": { ... },
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0"
  }
}
```

### 2.1. Các trường trong phản hồi chuẩn

| Trường | Kiểu dữ liệu | Mô tả |
|--------|--------------|-------|
| success | boolean | Trạng thái của yêu cầu (true/false) |
| code | number | Mã code hệ thống, duy nhất cho mỗi loại response |
| message | string | Thông báo mô tả kết quả của yêu cầu |
| data | object/array | Dữ liệu trả về từ API, có thể là một đối tượng hoặc một mảng các đối tượng |
| meta | object | Thông tin bổ sung về yêu cầu, bao gồm timestamp, requestId và phiên bản API |
| meta.pagination | object | Thông tin phân trang (chỉ có khi trả về danh sách dữ liệu) |

### 2.2. Mẹo sử dụng

- Luôn kiểm tra trường `success` trước khi xử lý dữ liệu
- Lưu trữ `meta.requestId` để hỗ trợ gỡ lỗi
- Xử lý các trường hợp lỗi một cách phù hợp

## 3. PHẢN HỒI THÀNH CÔNG

Khi yêu cầu thành công, API trả về `success: true` và dữ liệu trong trường `data`.

### 3.1. Các loại phản hồi thành công

#### 3.1.1. Đối tượng đơn (GET /api/v1/customers/{id})

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "id": "cust_123456",
    "name": "Nguyễn Văn A",
    "email": "nguyenvana@example.com",
    "phone": "+84901234567",
    "status": "active",
    "createdAt": "2023-10-15T08:30:45Z",
    "updatedAt": "2023-11-15T08:30:45Z"
  },
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0"
  }
}
```

#### 3.1.2. Danh sách (GET /api/v1/customers)

```json
{
  "success": true,
  "code": 1004,
  "message": "Dữ liệu một phần",
  "data": [
    {
      "id": "cust_123456",
      "name": "Nguyễn Văn A",
      "email": "nguyenvana@example.com",
      "status": "active"
    },
    {
      "id": "cust_789012",
      "name": "Trần Thị B",
      "email": "tranthib@example.com",
      "status": "inactive"
    }
  ],
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0",
    "pagination": {
      "page": 1,
      "perPage": 10,
      "totalPages": 5,
      "totalItems": 42,
      "hasNextPage": true,
      "hasPrevPage": false
    }
  }
}
```

#### 3.1.3. Tạo mới (POST /api/v1/customers)

```json
{
  "success": true,
  "code": 1001,
  "message": "Tạo mới thành công",
  "data": {
    "id": "cust_987654",
    "name": "Lê Thị C",
    "email": "lethic@example.com",
    "phone": "+84909876543",
    "status": "active",
    "createdAt": "2023-11-15T08:30:45Z",
    "updatedAt": "2023-11-15T08:30:45Z"
  },
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_9a8b7c6d5e4f",
    "version": "1.0"
  }
}
```

### 3.2. Ví dụ xử lý phản hồi thành công

```javascript
// Hàm xử lý response API
async function handleApiResponse(response) {
  const result = await response.json();

  // Kiểm tra trạng thái thành công
  if (!result.success) {
    throw new Error(result.error?.message || 'Đã xảy ra lỗi');
  }

  // Xử lý dữ liệu thành công
  return result.data;
}

// Ví dụ sử dụng
async function getCustomer(customerId) {
  try {
    const response = await fetch(`/api/v1/customers/${customerId}`);
    const customerData = await handleApiResponse(response);

    // customerData là đối tượng trong trường data
    console.log('Tên khách hàng:', customerData.name);
    return customerData;
  } catch (error) {
    console.error('Lỗi khi lấy thông tin khách hàng:', error.message);
    throw error;
  }
}
```

## 4. PHẢN HỒI LỖI

Khi xảy ra lỗi, API trả về `success: false` và thông tin lỗi trong trường `error`.

### 4.1. Cấu trúc phản hồi lỗi

```json
{
  "success": false,
  "code": 4007,
  "message": "Dữ liệu không hợp lệ",
  "error": {
    "type": "VALIDATION_ERROR",
    "message": "Dữ liệu đầu vào không đáp ứng các yêu cầu validation",
    "details": {
      "resourceType": "customer",
      "resourceId": "cust_123456",
      "fields": {
        "email": ["Email là bắt buộc", "Email không đúng định dạng"],
        "phone": ["Số điện thoại không hợp lệ"]
      }
    }
  },
  "meta": {
    "timestamp": "2023-11-15T08:30:45Z",
    "requestId": "req_1a2b3c4d5e6f",
    "version": "1.0"
  }
}
```

### 4.2. Chi tiết các trường lỗi

| Trường | Kiểu dữ liệu | Mô tả |
|--------|--------------|-------|
| success | boolean | Luôn là `false` khi xảy ra lỗi |
| code | number | Mã code hệ thống, duy nhất cho mỗi loại lỗi |
| message | string | Thông báo mô tả ngắn gọn về lỗi |
| error.type | string | Loại lỗi cụ thể (ví dụ: "VALIDATION_ERROR", "RESOURCE_NOT_FOUND") |
| error.message | string | Thông báo lỗi chi tiết |
| error.details | object | Thông tin chi tiết về lỗi, thay đổi tùy theo loại lỗi |
| meta | object | Thông tin bổ sung về yêu cầu |

## 5. MÃ CODE HỆ THỐNG

Ngoài các HTTP status code tiêu chuẩn, NextFlow API còn sử dụng hệ thống mã code riêng để cung cấp thông tin chi tiết hơn về kết quả của yêu cầu.

### 5.1. Mã thành công (1000-1999)

| Mã code | Tên | HTTP Status | Mô tả |
|---------|-----|-------------|-------|
| 1000 | SUCCESS | 200 | Yêu cầu được xử lý thành công |
| 1001 | CREATED | 201 | Tài nguyên đã được tạo thành công |
| 1002 | UPDATED | 200 | Tài nguyên đã được cập nhật thành công |
| 1003 | DELETED | 200 | Tài nguyên đã được xóa thành công |
| 1004 | PARTIAL_CONTENT | 206 | Chỉ một phần của dữ liệu được trả về |

### 5.2. Mã lỗi client (4000-4999)

| Mã code | Tên | HTTP Status | Mô tả |
|---------|-----|-------------|-------|
| 4000 | BAD_REQUEST | 400 | Yêu cầu không hợp lệ, thiếu thông tin hoặc sai định dạng |
| 4001 | UNAUTHORIZED | 401 | Người dùng chưa xác thực hoặc token không hợp lệ |
| 4002 | INVALID_CREDENTIALS | 401 | Thông tin đăng nhập không chính xác |
| 4003 | FORBIDDEN | 403 | Người dùng không có quyền truy cập tài nguyên |
| 4004 | NOT_FOUND | 404 | Tài nguyên yêu cầu không tồn tại |
| 4006 | CONFLICT | 409 | Yêu cầu xung đột với trạng thái hiện tại của tài nguyên |
| 4007 | VALIDATION_FAILED | 422 | Dữ liệu không đáp ứng các yêu cầu validation |
| 4008 | TOO_MANY_REQUESTS | 429 | Đã vượt quá giới hạn số lượng request trong một khoảng thời gian |

### 5.3. Mã lỗi server (5000-5999)

| Mã code | Tên | HTTP Status | Mô tả |
|---------|-----|-------------|-------|
| 5000 | SERVER_ERROR | 500 | Lỗi server nội bộ, không thể xử lý yêu cầu |
| 5002 | SERVICE_UNAVAILABLE | 503 | Dịch vụ tạm thời không khả dụng, có thể do bảo trì hoặc quá tải |

## 6. KẾT LUẬN

Cấu trúc phản hồi chuẩn của NextFlow CRM API được thiết kế để đảm bảo tính nhất quán và dễ dàng xử lý cho developers. Việc hiểu rõ cấu trúc này sẽ giúp bạn xây dựng các ứng dụng tích hợp mạnh mẽ và xử lý lỗi hiệu quả.

### 6.1. Lợi ích của cấu trúc chuẩn

- **Tính nhất quán**: Tất cả API endpoints đều sử dụng cùng format
- **Dễ xử lý**: Cấu trúc rõ ràng, dễ parse và validate
- **Debugging**: RequestId và timestamp giúp troubleshooting
- **Error handling**: Thông tin lỗi chi tiết và có cấu trúc
- **Monitoring**: Meta information hỗ trợ logging và analytics

### 6.2. Best practices khi sử dụng

1. **Luôn kiểm tra success field**: Trước khi xử lý data
2. **Sử dụng code field**: Để xử lý logic cụ thể cho từng loại response
3. **Log requestId**: Để hỗ trợ debugging và support
4. **Handle pagination**: Sử dụng meta.pagination cho danh sách
5. **Implement retry logic**: Cho các lỗi 5xx với exponential backoff

### 6.3. Ví dụ xử lý response tổng quát

```javascript
async function handleApiResponse(response) {
  const result = await response.json();

  // Log request ID cho debugging
  console.log('Request ID:', result.meta?.requestId);

  if (!result.success) {
    // Xử lý lỗi dựa trên code
    switch (result.code) {
      case 4001:
        // Token expired, redirect to login
        redirectToLogin();
        break;
      case 4007:
        // Validation error, show field errors
        showValidationErrors(result.error.details.fields);
        break;
      case 5000:
        // Server error, show generic message
        showErrorMessage('Đã xảy ra lỗi hệ thống, vui lòng thử lại sau');
        break;
      default:
        showErrorMessage(result.message);
    }
    throw new Error(result.error?.message || result.message);
  }

  return result.data;
}
```

### 6.4. Tài liệu liên quan

- [Tổng quan API](./tong-quan-api.md)
- [Xác thực và Bảo mật](./xac-thuc-va-bao-mat.md)
- [API Endpoints](./he-thong/users.md)
- [Error Handling Best Practices](https://docs.nextflow.com/api/error-handling)

## 7. TÀI LIỆU THAM KHẢO

### 7.1. API Documentation
- [NextFlow API Reference](https://docs.nextflow.com/api)
- [HTTP Status Codes](https://httpstatuses.com/)
- [JSON API Specification](https://jsonapi.org/)

### 7.2. Error Handling
- [Error Handling Best Practices](https://restfulapi.net/http-status-codes/)
- [API Error Design](https://blog.restcase.com/rest-api-error-codes-101/)
- [HTTP Response Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)

### 7.3. Development Tools
- [Postman Collection](https://www.postman.com/nextflow/workspace/nextflow-api)
- [API Testing Tools](https://docs.nextflow.com/api/testing)
- [Response Validation](https://docs.nextflow.com/api/validation)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 1.0.0
**Tác giả**: NextFlow Development Team
