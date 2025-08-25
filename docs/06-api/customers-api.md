# 👥 API QUẢN LÝ KHÁCH HÀNG - NextFlow CRM-AI

## 🎯 TỔNG QUAN

**Customers API** cung cấp tất cả endpoints để **quản lý thông tin khách hàng** trong NextFlow CRM-AI. Từ tạo khách hàng mới đến phân tích hành vi mua sắm.

### 💡 **Use cases thực tế:**
- **Website e-commerce:** Tự động tạo khách hàng khi có đăng ký mới
- **Mobile app:** Sync danh bạ khách hàng offline/online
- **Chatbot:** Lấy thông tin khách hàng để tư vấn cá nhân hóa
- **Marketing automation:** Phân khúc khách hàng cho campaigns

### 🔗 **Base URL:**
```
https://api.nextflow.com/v1/customers
```

---

## 🏗️ ENDPOINTS CƠ BẢN

### 📋 **1. LẤY DANH SÁCH KHÁCH HÀNG**

```http
GET /customers
```

**Query Parameters (Tham số truy vấn):**
| Tham số | Kiểu | Mô tả | Ví dụ |
|---------|------|-------|-------|
| `limit` | integer | Số lượng records trả về (mặc định: 20, tối đa: 100) | `?limit=50` |
| `offset` | integer | Bỏ qua bao nhiêu records (để phân trang) | `?offset=20` |
| `status` | string | Lọc theo trạng thái: `active`, `inactive`, `prospect` | `?status=active` |
| `type` | string | Loại khách hàng: `individual`, `business` | `?type=business` |
| `search` | string | Tìm kiếm theo tên, email, phone | `?search=nguyen` |
| `created_from` | date | Lọc từ ngày tạo (YYYY-MM-DD) | `?created_from=2024-01-01` |
| `created_to` | date | Lọc đến ngày tạo | `?created_to=2024-12-31` |

**Response thành công (200):**
```json
{
  "success": true,
  "data": {
    "customers": [
      {
        "id": "cust_abc123",
        "customer_code": "KH001",
        "name": "Nguyễn Văn A",
        "display_name": "Anh Nguyễn",
        "type": "individual",
        "status": "active",
        "primary_email": "nguyenvana@email.com",
        "primary_phone": "0901234567",
        "company_name": null,
        "total_orders": 5,
        "total_spent": 2500000,
        "lifetime_value": 3000000,
        "last_purchase_date": "2024-01-15T10:30:00Z",
        "created_at": "2023-12-01T09:00:00Z",
        "updated_at": "2024-01-15T10:30:00Z"
      }
    ],
    "pagination": {
      "total": 1250,
      "limit": 20,
      "offset": 0,
      "has_more": true
    }
  }
}
```

### 👤 **2. LẤY THÔNG TIN CHI TIẾT KHÁCH HÀNG**

```http
GET /customers/{customer_id}
```

**Path Parameters:**
- `customer_id` (string, required): ID hoặc customer_code của khách hàng

**Response thành công (200):**
```json
{
  "success": true,
  "data": {
    "customer": {
      "id": "cust_abc123",
      "customer_code": "KH001",
      "name": "Nguyễn Văn A",
      "display_name": "Anh Nguyễn",
      "type": "individual",
      "status": "active",
      
      // Thông tin cá nhân
      "first_name": "A",
      "last_name": "Nguyễn Văn",
      "date_of_birth": "1990-05-15",
      "gender": "male",
      
      // Thông tin liên hệ
      "primary_email": "nguyenvana@email.com",
      "primary_phone": "0901234567",
      "contacts": [
        {
          "type": "email",
          "value": "nguyenvana@email.com",
          "is_primary": true,
          "is_verified": true
        },
        {
          "type": "phone",
          "value": "0901234567",
          "is_primary": true,
          "is_verified": false
        }
      ],
      
      // Địa chỉ
      "addresses": [
        {
          "id": "addr_xyz789",
          "type": "shipping",
          "address_line_1": "123 Nguyễn Huệ",
          "ward": "Bến Nghé",
          "district": "Quận 1",
          "city": "TP.HCM",
          "country": "Vietnam",
          "postal_code": "70000",
          "is_default": true
        }
      ],
      
      // Thống kê kinh doanh
      "total_orders": 5,
      "total_spent": 2500000,
      "lifetime_value": 3000000,
      "average_order_value": 500000,
      "last_purchase_date": "2024-01-15T10:30:00Z",
      "first_purchase_date": "2023-12-15T14:20:00Z",
      
      // Phân khúc
      "segments": [
        {
          "id": "seg_vip001",
          "name": "Khách hàng VIP",
          "color": "#FFD700"
        }
      ],
      
      // Metadata
      "source": "website",
      "assigned_user_id": "user_def456",
      "assigned_user_name": "Trần Thị B - Sales",
      "created_at": "2023-12-01T09:00:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    }
  }
}
```

### ➕ **3. TẠO KHÁCH HÀNG MỚI**

```http
POST /customers
Content-Type: application/json
```

**Request Body:**
```json
{
  // Thông tin bắt buộc
  "name": "Trần Thị C",
  "type": "individual",  // "individual" hoặc "business"
  
  // Thông tin liên hệ (ít nhất 1 trong 2)
  "primary_email": "tranthic@email.com",
  "primary_phone": "0907654321",
  
  // Thông tin tùy chọn
  "display_name": "Chị Trần",
  "first_name": "C",
  "last_name": "Trần Thị",
  "date_of_birth": "1985-08-20",
  "gender": "female",
  
  // Thông tin doanh nghiệp (nếu type = "business")
  "company_name": "Công ty ABC",
  "tax_number": "0123456789",
  "industry": "retail",
  "company_size": "small",
  "annual_revenue": 5000000000,
  
  // Địa chỉ
  "address": {
    "type": "shipping",
    "address_line_1": "456 Lê Lợi",
    "ward": "Bến Thành",
    "district": "Quận 1", 
    "city": "TP.HCM",
    "country": "Vietnam",
    "postal_code": "70000"
  },
  
  // Metadata
  "source": "facebook_ads",
  "assigned_user_id": "user_def456",
  "notes": "Khách hàng tiềm năng từ campaign Q1"
}
```

**Response thành công (201):**
```json
{
  "success": true,
  "message": "Khách hàng đã được tạo thành công",
  "data": {
    "customer": {
      "id": "cust_new789",
      "customer_code": "KH1251",
      "name": "Trần Thị C",
      // ... thông tin đầy đủ như GET endpoint
    }
  }
}
```

### ✏️ **4. CẬP NHẬT THÔNG TIN KHÁCH HÀNG**

```http
PUT /customers/{customer_id}
Content-Type: application/json
```

**Request Body:** (Chỉ gửi fields cần update)
```json
{
  "name": "Trần Thị C - Updated",
  "primary_phone": "0907654322",
  "status": "active",
  "notes": "Đã xác nhận thông tin liên hệ"
}
```

**Response thành công (200):**
```json
{
  "success": true,
  "message": "Thông tin khách hàng đã được cập nhật",
  "data": {
    "customer": {
      // Thông tin khách hàng sau khi update
    }
  }
}
```

### 🗑️ **5. XÓA KHÁCH HÀNG (SOFT DELETE)**

```http
DELETE /customers/{customer_id}
```

**Response thành công (200):**
```json
{
  "success": true,
  "message": "Khách hàng đã được xóa thành công",
  "data": {
    "customer_id": "cust_abc123",
    "deleted_at": "2024-01-20T15:30:00Z"
  }
}
```

**Lưu ý:** NextFlow sử dụng **soft delete** - khách hàng không bị xóa vĩnh viễn mà chỉ được đánh dấu `deleted_at`. Có thể khôi phục nếu cần.

---

## 🔍 ENDPOINTS TÌM KIẾM NÂNG CAO

### 🎯 **6. TÌM KIẾM KHÁCH HÀNG THÔNG MINH**

```http
POST /customers/search
Content-Type: application/json
```

**Request Body:**
```json
{
  // Tìm kiếm text
  "query": "nguyen",
  
  // Filters nâng cao
  "filters": {
    "status": ["active", "prospect"],
    "type": "individual",
    "total_spent_min": 1000000,
    "total_spent_max": 10000000,
    "last_purchase_days": 30,  // Mua trong 30 ngày qua
    "segments": ["seg_vip001", "seg_loyal002"],
    "assigned_users": ["user_def456"],
    "sources": ["website", "facebook_ads"],
    "cities": ["TP.HCM", "Hà Nội"],
    "age_min": 25,
    "age_max": 45
  },
  
  // Sắp xếp
  "sort": {
    "field": "total_spent",  // lifetime_value, created_at, last_purchase_date
    "direction": "desc"      // asc hoặc desc
  },
  
  // Phân trang
  "limit": 50,
  "offset": 0
}
```

### 📊 **7. THỐNG KÊ KHÁCH HÀNG**

```http
GET /customers/analytics
```

**Query Parameters:**
- `period`: `today`, `week`, `month`, `quarter`, `year`, `custom`
- `from_date`: Từ ngày (nếu period=custom)
- `to_date`: Đến ngày (nếu period=custom)
- `group_by`: `day`, `week`, `month` (để group data)

**Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "total_customers": 1250,
      "new_customers": 45,      // Trong period
      "active_customers": 890,
      "churned_customers": 12,
      "average_lifetime_value": 2500000,
      "total_revenue": 3125000000
    },
    "trends": [
      {
        "date": "2024-01-01",
        "new_customers": 5,
        "total_customers": 1205,
        "revenue": 125000000
      }
      // ... more data points
    ],
    "segments_breakdown": [
      {
        "segment_name": "Khách hàng VIP",
        "customer_count": 125,
        "percentage": 10.0,
        "total_revenue": 1250000000
      }
    ]
  }
}
```

---

## 👥 ENDPOINTS PHÂN KHÚC KHÁCH HÀNG

### 🎯 **8. TẠO PHÂN KHÚC KHÁCH HÀNG**

```http
POST /customers/segments
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Khách hàng Trung thành",
  "description": "Khách hàng mua >= 5 lần và tổng chi tiêu > 2 triệu",
  "color": "#4CAF50",
  "criteria": {
    "total_orders_min": 5,
    "total_spent_min": 2000000,
    "last_purchase_days": 90
  },
  "is_auto_update": true  // Tự động cập nhật khi có KH mới phù hợp
}
```

### 👥 **9. THÊM KHÁCH HÀNG VÀO PHÂN KHÚC**

```http
POST /customers/segments/{segment_id}/members
Content-Type: application/json
```

**Request Body:**
```json
{
  "customer_ids": ["cust_abc123", "cust_def456", "cust_ghi789"]
}
```

---

## 📱 ENDPOINTS TƯƠNG TÁC

### 💬 **10. LẤY LỊCH SỬ TƯƠNG TÁC**

```http
GET /customers/{customer_id}/activities
```

**Response:**
```json
{
  "success": true,
  "data": {
    "activities": [
      {
        "id": "act_123",
        "type": "order_created",
        "title": "Đặt đơn hàng mới",
        "description": "Đơn hàng #ORD001 - 3 sản phẩm - 1,500,000 VNĐ",
        "metadata": {
          "order_id": "ord_abc123",
          "order_total": 1500000,
          "items_count": 3
        },
        "created_at": "2024-01-15T10:30:00Z",
        "created_by": "system"
      },
      {
        "id": "act_124", 
        "type": "email_sent",
        "title": "Gửi email marketing",
        "description": "Campaign: Khuyến mãi tháng 1",
        "metadata": {
          "campaign_id": "camp_xyz789",
          "email_subject": "🎉 Giảm giá 50% - Chỉ 3 ngày!"
        },
        "created_at": "2024-01-10T08:00:00Z",
        "created_by": "user_marketing"
      }
    ]
  }
}
```

### 📝 **11. THÊM GHI CHÚ CHO KHÁCH HÀNG**

```http
POST /customers/{customer_id}/notes
Content-Type: application/json
```

**Request Body:**
```json
{
  "content": "Khách hàng quan tâm đến sản phẩm cao cấp. Có thể upsell premium package.",
  "type": "sales_note",  // sales_note, support_note, general
  "is_important": true
}
```

---

## ❌ MÃ LỖI THƯỜNG GẶP

| HTTP Code | Error Code | Mô tả | Giải pháp |
|-----------|------------|-------|-----------|
| **400** | `INVALID_EMAIL` | Email không đúng định dạng | Kiểm tra format email |
| **400** | `INVALID_PHONE` | Số điện thoại không hợp lệ | Sử dụng format: 09xxxxxxxx |
| **400** | `MISSING_REQUIRED_FIELD` | Thiếu trường bắt buộc | Kiểm tra name, type, contact info |
| **404** | `CUSTOMER_NOT_FOUND` | Không tìm thấy khách hàng | Kiểm tra customer_id |
| **409** | `EMAIL_ALREADY_EXISTS` | Email đã tồn tại | Sử dụng email khác hoặc update |
| **409** | `PHONE_ALREADY_EXISTS` | Số điện thoại đã tồn tại | Sử dụng số khác hoặc update |
| **422** | `INVALID_CUSTOMER_TYPE` | Loại khách hàng không hợp lệ | Chỉ dùng: individual, business |

**Ví dụ Error Response:**
```json
{
  "success": false,
  "error": {
    "code": "INVALID_EMAIL",
    "message": "Email không đúng định dạng",
    "details": {
      "field": "primary_email",
      "value": "invalid-email",
      "expected_format": "user@domain.com"
    }
  }
}
```

---

## 📞 HỖ TRỢ VÀ TÀI LIỆU

### 🆘 **Cần hỗ trợ Customers API?**
- **📧 Email:** customers-api@nextflow-crm.com
- **💬 Live Chat:** Trong ứng dụng NextFlow CRM-AI
- **📞 Hotline:** 1900-xxx-xxx (ext. 10)

### 📚 **Tài liệu liên quan:**
- **🔗 [API Overview](./api-overview%20(Tổng%20quan%20API%20NextFlow%20CRM-AI).md)** - Tổng quan API
- **🛒 [Orders API](./orders-api%20(API%20Quản%20lý%20Đơn%20hàng).md)** - Liên kết với đơn hàng
- **📢 [Marketing API](./marketing-api%20(API%20Marketing%20&%20Campaigns).md)** - Marketing campaigns
- **🔐 [Authentication](./xac-thuc-va-bao-mat%20(Xác%20thực%20và%20bảo%20mật%20API).md)** - Xác thực API

---

**Cập nhật:** [Ngày tháng năm] | **Version:** 1.0.0 | **NextFlow API Team**
