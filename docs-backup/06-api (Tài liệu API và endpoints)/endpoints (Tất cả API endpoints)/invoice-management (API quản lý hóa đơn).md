# API QUẢN LÝ HÓA ĐƠN NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Endpoints Hóa đơn](#2-endpoints-hóa-đơn)
3. [Endpoints Hóa đơn điện tử](#3-endpoints-hóa-đơn-điện-tử)
4. [Endpoints Thanh toán](#4-endpoints-thanh-toán)
5. [Endpoints Báo cáo](#5-endpoints-báo-cáo)
6. [Endpoints Thuế](#6-endpoints-thuế)
7. [Endpoints Tích hợp](#7-endpoints-tích-hợp)
8. [Mã lỗi](#8-mã-lỗi)

## 1. GIỚI THIỆU

API Quản lý Hóa đơn NextFlow CRM-AI cung cấp các endpoint để tạo, quản lý hóa đơn điện tử, theo dõi thanh toán và báo cáo tài chính tuân thủ pháp luật Việt Nam.

### 1.1. Base URL

```
https://api.nextflow-crm.com/v1/invoices
```

### 1.2. Xác thực

```http
Authorization: Bearer {your_token}
X-Company-Tax-Code: {company_tax_code}
```

## 2. ENDPOINTS HÓA ĐƠN

### 2.1. Tạo hóa đơn từ đơn hàng

```http
POST /invoices/from-order
Content-Type: application/json
```

#### Request Body

```json
{
  "orderId": "order_123456789",
  "invoiceDate": "2024-10-27",
  "paymentTerms": 30,
  "notes": "Thanh toán trong vòng 30 ngày",
  "discountPercent": 5,
  "customFields": {
    "projectCode": "PRJ001",
    "salesRep": "Nguyễn Văn A"
  }
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Hóa đơn đã được tạo thành công",
  "data": {
    "id": "invoice_123456789",
    "invoiceNumber": "HD001",
    "series": "1C24TAA",
    "invoiceDate": "2024-10-27",
    "customer": {
      "id": "customer_123456789",
      "name": "Công ty ABC",
      "taxCode": "0123456789",
      "address": "123 Đường XYZ, Hà Nội",
      "phone": "024.1234.5678",
      "email": "contact@abc.com"
    },
    "items": [
      {
        "productId": "product_123456789",
        "productName": "iPhone 15 Pro Max",
        "quantity": 2,
        "unitPrice": 30000000,
        "discountPercent": 5,
        "discountAmount": 3000000,
        "taxRate": 10,
        "taxAmount": 5700000,
        "totalAmount": 62700000
      }
    ],
    "summary": {
      "subtotal": 57000000,
      "totalDiscount": 3000000,
      "totalTax": 5700000,
      "totalAmount": 62700000,
      "totalAmountInWords": "Sáu mươi hai triệu bảy trăm nghìn đồng"
    },
    "status": "draft",
    "paymentDueDate": "2024-11-26",
    "createdAt": "2024-10-27T10:30:00Z"
  }
}
```

### 2.2. Lấy danh sách hóa đơn

```http
GET /invoices
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| page | integer | Số trang (mặc định: 1) |
| perPage | integer | Số hóa đơn mỗi trang (mặc định: 20) |
| status | string | Trạng thái (draft, sent, paid, overdue, cancelled) |
| customerId | string | Lọc theo khách hàng |
| fromDate | string | Từ ngày (YYYY-MM-DD) |
| toDate | string | Đến ngày (YYYY-MM-DD) |
| minAmount | number | Số tiền tối thiểu |
| maxAmount | number | Số tiền tối đa |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "invoice_123456789",
      "invoiceNumber": "HD001",
      "invoiceDate": "2024-10-27",
      "customer": {
        "name": "Công ty ABC",
        "taxCode": "0123456789"
      },
      "totalAmount": 62700000,
      "status": "sent",
      "paymentDueDate": "2024-11-26",
      "daysOverdue": 0,
      "paidAmount": 0,
      "remainingAmount": 62700000
    }
  ],
  "meta": {
    "pagination": {
      "page": 1,
      "perPage": 20,
      "totalPages": 5,
      "totalItems": 95
    },
    "summary": {
      "totalInvoices": 95,
      "totalAmount": 2500000000,
      "paidAmount": 2100000000,
      "unpaidAmount": 400000000,
      "overdueAmount": 100000000
    }
  }
}
```

### 2.3. Cập nhật hóa đơn

```http
PUT /invoices/{invoiceId}
Content-Type: application/json
```

#### Request Body

```json
{
  "paymentTerms": 45,
  "notes": "Gia hạn thanh toán thêm 15 ngày theo yêu cầu khách hàng",
  "items": [
    {
      "id": "item_123456789",
      "quantity": 3,
      "unitPrice": 29000000,
      "discountPercent": 10
    }
  ]
}
```

### 2.4. Hủy hóa đơn

```http
POST /invoices/{invoiceId}/cancel
Content-Type: application/json
```

#### Request Body

```json
{
  "reason": "Khách hàng yêu cầu hủy đơn hàng",
  "cancelledBy": "manager_123456789",
  "refundRequired": true,
  "refundAmount": 62700000
}
```

## 3. ENDPOINTS HÓA ĐƠN ĐIỆN TỬ

### 3.1. Ký số hóa đơn

```http
POST /invoices/{invoiceId}/sign
Content-Type: application/json
```

#### Request Body

```json
{
  "provider": "vnpt_ca",
  "certificateSerial": "1234567890ABCDEF",
  "signatureMethod": "RSA_SHA256"
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Hóa đơn đã được ký số thành công",
  "data": {
    "invoiceId": "invoice_123456789",
    "lookupCode": "123456789012345678901234567890AB",
    "signedAt": "2024-10-27T10:35:00Z",
    "signedBy": "Nguyễn Văn A - Giám đốc",
    "certificateInfo": {
      "issuer": "VNPT-CA",
      "serial": "1234567890ABCDEF",
      "validFrom": "2024-01-01T00:00:00Z",
      "validTo": "2025-12-31T23:59:59Z"
    },
    "xmlData": "<?xml version=\"1.0\" encoding=\"UTF-8\"?>...",
    "pdfUrl": "https://cdn.nextflow-crm.com/invoices/HD001_signed.pdf",
    "qrCode": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."
  }
}
```

### 3.2. Gửi hóa đơn điện tử

```http
POST /invoices/{invoiceId}/send
Content-Type: application/json
```

#### Request Body

```json
{
  "recipients": [
    {
      "email": "contact@abc.com",
      "name": "Nguyễn Văn B - Kế toán trưởng",
      "type": "primary"
    },
    {
      "email": "ceo@abc.com", 
      "name": "Trần Thị C - Giám đốc",
      "type": "cc"
    }
  ],
  "emailTemplate": "invoice_standard",
  "customMessage": "Kính gửi Quý khách hàng, đây là hóa đơn cho đơn hàng #DH001. Xin cảm ơn!",
  "attachments": ["contract.pdf", "delivery_note.pdf"]
}
```

### 3.3. Tra cứu hóa đơn

```http
GET /invoices/{invoiceId}/lookup
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "invoiceNumber": "HD001",
    "series": "1C24TAA",
    "lookupCode": "123456789012345678901234567890AB",
    "lookupUrl": "https://tracuuhoadon.gdt.gov.vn/tcnnt/mtt.jsp",
    "qrCodeData": "0123456789|1C24TAA|00000001|2024-10-27|62700000|123456789012345678901234567890AB",
    "verificationStatus": "valid",
    "lastVerified": "2024-10-27T10:40:00Z"
  }
}
```

## 4. ENDPOINTS THANH TOÁN

### 4.1. Ghi nhận thanh toán

```http
POST /invoices/{invoiceId}/payments
Content-Type: application/json
```

#### Request Body

```json
{
  "amount": 62700000,
  "paymentDate": "2024-10-30",
  "paymentMethod": "bank_transfer",
  "bankAccount": "1234567890",
  "bankName": "Vietcombank",
  "transactionRef": "FT24303123456789",
  "notes": "Chuyển khoản thanh toán hóa đơn HD001",
  "receivedBy": "accountant_123456789"
}
```

#### Response

```json
{
  "success": true,
  "code": 1001,
  "message": "Thanh toán đã được ghi nhận",
  "data": {
    "paymentId": "payment_123456789",
    "invoiceId": "invoice_123456789",
    "amount": 62700000,
    "paymentDate": "2024-10-30",
    "remainingAmount": 0,
    "status": "fully_paid",
    "receiptNumber": "PT001",
    "receiptUrl": "https://cdn.nextflow-crm.com/receipts/PT001.pdf"
  }
}
```

### 4.2. Lấy lịch sử thanh toán

```http
GET /invoices/{invoiceId}/payments
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": [
    {
      "id": "payment_123456789",
      "amount": 30000000,
      "paymentDate": "2024-10-28",
      "paymentMethod": "bank_transfer",
      "transactionRef": "FT24302123456789",
      "notes": "Thanh toán một phần 50%"
    },
    {
      "id": "payment_234567890",
      "amount": 32700000,
      "paymentDate": "2024-10-30", 
      "paymentMethod": "bank_transfer",
      "transactionRef": "FT24304123456789",
      "notes": "Thanh toán phần còn lại"
    }
  ],
  "summary": {
    "totalPaid": 62700000,
    "totalInvoice": 62700000,
    "remainingAmount": 0,
    "paymentCount": 2
  }
}
```

### 4.3. Nhắc nhở thanh toán

```http
POST /invoices/{invoiceId}/payment-reminder
Content-Type: application/json
```

#### Request Body

```json
{
  "reminderType": "overdue",
  "customMessage": "Kính gửi Quý khách, hóa đơn HD001 đã quá hạn thanh toán 5 ngày. Xin vui lòng thanh toán sớm nhất có thể.",
  "sendEmail": true,
  "sendSms": false,
  "escalateToManager": true
}
```

## 5. ENDPOINTS BÁO CÁO

### 5.1. Báo cáo doanh thu

```http
GET /reports/revenue
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| period | string | Kỳ báo cáo (daily, weekly, monthly, yearly) |
| fromDate | string | Từ ngày |
| toDate | string | Đến ngày |
| groupBy | string | Nhóm theo (customer, product, salesperson) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "period": "monthly",
    "fromDate": "2024-10-01",
    "toDate": "2024-10-31",
    "summary": {
      "totalRevenue": 2500000000,
      "totalInvoices": 150,
      "averageInvoiceValue": 16666667,
      "paidRevenue": 2100000000,
      "unpaidRevenue": 400000000,
      "paymentRate": 84.0
    },
    "trends": [
      {
        "date": "2024-10-01",
        "revenue": 85000000,
        "invoiceCount": 5
      },
      {
        "date": "2024-10-02", 
        "revenue": 120000000,
        "invoiceCount": 8
      }
    ],
    "topCustomers": [
      {
        "customerId": "customer_123456789",
        "customerName": "Công ty ABC",
        "revenue": 200000000,
        "invoiceCount": 8,
        "percentage": 8.0
      }
    ],
    "topProducts": [
      {
        "productId": "product_123456789",
        "productName": "iPhone 15 Pro",
        "revenue": 800000000,
        "quantity": 40,
        "percentage": 32.0
      }
    ]
  }
}
```

### 5.2. Báo cáo công nợ

```http
GET /reports/receivables
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "summary": {
      "totalReceivables": 400000000,
      "currentReceivables": 300000000,
      "overdueReceivables": 100000000,
      "averageDaysOverdue": 12
    },
    "agingAnalysis": {
      "current": 300000000,
      "days1to30": 50000000,
      "days31to60": 30000000,
      "days61to90": 15000000,
      "over90days": 5000000
    },
    "topDebtors": [
      {
        "customerId": "customer_123456789",
        "customerName": "Công ty ABC",
        "totalDebt": 50000000,
        "overdueAmount": 20000000,
        "daysOverdue": 15,
        "oldestInvoiceDate": "2024-09-15"
      }
    ]
  }
}
```

## 6. ENDPOINTS THUẾ

### 6.1. Tính thuế

```http
POST /tax/calculate
Content-Type: application/json
```

#### Request Body

```json
{
  "items": [
    {
      "productId": "product_123456789",
      "productType": "goods",
      "quantity": 2,
      "unitPrice": 30000000,
      "taxCategory": "standard"
    },
    {
      "productId": "product_234567890", 
      "productType": "service",
      "quantity": 1,
      "unitPrice": 5000000,
      "taxCategory": "reduced"
    }
  ],
  "customerType": "business",
  "invoiceDate": "2024-10-27"
}
```

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "items": [
      {
        "productId": "product_123456789",
        "subtotal": 60000000,
        "taxRate": 10,
        "taxAmount": 6000000,
        "total": 66000000
      },
      {
        "productId": "product_234567890",
        "subtotal": 5000000,
        "taxRate": 5,
        "taxAmount": 250000,
        "total": 5250000
      }
    ],
    "summary": {
      "subtotal": 65000000,
      "totalTax": 6250000,
      "grandTotal": 71250000,
      "taxBreakdown": [
        {"rate": 10, "taxableAmount": 60000000, "taxAmount": 6000000},
        {"rate": 5, "taxableAmount": 5000000, "taxAmount": 250000}
      ]
    }
  }
}
```

### 6.2. Báo cáo thuế VAT

```http
GET /tax/vat-report
```

#### Query Parameters

| Tham số | Kiểu | Mô tả |
|---------|------|-------|
| month | integer | Tháng (1-12) |
| year | integer | Năm |
| quarter | integer | Quý (1-4, thay thế month) |

#### Response

```json
{
  "success": true,
  "code": 1000,
  "message": "Thành công",
  "data": {
    "period": "2024-10",
    "outputTax": {
      "taxableRevenue0": 200000000,
      "taxAmount0": 0,
      "taxableRevenue5": 300000000,
      "taxAmount5": 15000000,
      "taxableRevenue10": 2000000000,
      "taxAmount10": 200000000,
      "totalTaxableRevenue": 2500000000,
      "totalOutputTax": 215000000
    },
    "inputTax": {
      "totalInputTax": 150000000,
      "deductibleInputTax": 150000000
    },
    "vatPayable": {
      "outputTax": 215000000,
      "inputTax": 150000000,
      "vatToPay": 65000000,
      "dueDate": "2024-11-20"
    }
  }
}
```

## 7. ENDPOINTS TÍCH HỢP

### 7.1. Đồng bộ với phần mềm kế toán

```http
POST /integrations/accounting/sync
Content-Type: application/json
```

#### Request Body

```json
{
  "software": "misa_sme",
  "invoiceIds": ["invoice_123456789", "invoice_234567890"],
  "syncType": "full",
  "createJournalEntries": true
}
```

### 7.2. Kết nối ngân hàng

```http
POST /integrations/banking/connect
Content-Type: application/json
```

#### Request Body

```json
{
  "bankCode": "VCB",
  "accountNumber": "1234567890",
  "apiKey": "bank_api_key_here",
  "webhookUrl": "https://api.nextflow-crm.com/webhooks/banking"
}
```

## 8. MÃ LỖI

| Code | Message | Mô tả |
|------|---------|-------|
| 4001 | Invoice not found | Không tìm thấy hóa đơn |
| 4002 | Invoice already signed | Hóa đơn đã được ký số |
| 4003 | Invalid tax calculation | Tính thuế không hợp lệ |
| 4004 | Payment amount exceeds invoice | Số tiền thanh toán vượt quá hóa đơn |
| 4005 | Certificate expired | Chứng thư số đã hết hạn |
| 4006 | Invalid customer tax code | Mã số thuế khách hàng không hợp lệ |
| 5001 | E-invoice service unavailable | Dịch vụ hóa đơn điện tử không khả dụng |
| 5002 | Tax calculation failed | Tính thuế thất bại |

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI Finance Team
