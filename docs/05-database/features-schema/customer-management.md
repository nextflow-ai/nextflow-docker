# 👥 SCHEMA QUẢN LÝ KHÁCH HÀNG - NextFlow CRM-AI

## 🎯 TỔNG QUAN

**Schema Khách hàng** định nghĩa cách NextFlow CRM-AI lưu trữ và quản lý thông tin khách hàng. Đây là **trái tim của hệ thống CRM**, chứa tất cả dữ liệu về khách hàng từ thông tin cơ bản đến hành vi mua sắm.

### 💡 **Khái niệm cơ bản:**
- **Customer (Khách hàng):** Cá nhân hoặc doanh nghiệp mua sản phẩm/dịch vụ
- **Contact (Liên hệ):** Thông tin liên lạc (email, phone, address)
- **Segment (Phân khúc):** Nhóm khách hàng có đặc điểm tương tự
- **Profile (Hồ sơ):** Tập hợp thông tin chi tiết về khách hàng

### 🔗 **Mối quan hệ dữ liệu:**
```
Khách hàng (Customers) → Liên hệ (Contacts) → Địa chỉ (Addresses)
    ↓                        ↓                    ↓
Phân khúc (Segments) → Hoạt động (Activities) → Phân tích (Analytics)
```

---

## 🏢 CẤU TRÚC BẢNG CHÍNH

### 👤 **1. BẢNG CUSTOMERS (KHÁCH HÀNG)**

**Mục đích:** Lưu thông tin cơ bản về khách hàng

#### **Các trường dữ liệu quan trọng:**

```sql
-- Bảng khách hàng chính
CREATE TABLE customers (
    -- Mã định danh duy nhất (UUID: Universal Unique Identifier)
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Mã khách hàng (dễ nhớ, ví dụ: KH001, KH002)
    customer_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- === THÔNG TIN CƠ BẢN ===
    -- Loại khách hàng: cá nhân hoặc doanh nghiệp
    type customer_type_enum DEFAULT 'individual',
    
    -- Tên hiển thị chính
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    
    -- === THÔNG TIN DOANH NGHIỆP ===
    -- Tên công ty (nếu là khách hàng doanh nghiệp)
    company_name VARCHAR(255),
    
    -- Mã số thuế (MST)
    tax_number VARCHAR(50),
    
    -- Ngành nghề kinh doanh
    industry VARCHAR(100),
    
    -- Quy mô công ty (nhỏ, vừa, lớn)
    company_size company_size_enum,
    
    -- Doanh thu hàng năm (để đánh giá tiềm năng)
    annual_revenue DECIMAL(15,2),
    
    -- === THÔNG TIN CÁ NHÂN ===
    first_name VARCHAR(100),    -- Tên
    last_name VARCHAR(100),     -- Họ
    date_of_birth DATE,         -- Ngày sinh
    gender gender_enum,         -- Giới tính
    
    -- === THÔNG TIN LIÊN HỆ ===
    primary_email VARCHAR(255),     -- Email chính
    primary_phone VARCHAR(20),      -- Số điện thoại chính
    website VARCHAR(255),           -- Website (cho doanh nghiệp)
    
    -- === THÔNG TIN KINH DOANH ===
    -- Trạng thái khách hàng (mới, đang hoạt động, ngừng hoạt động)
    status customer_status_enum DEFAULT 'active',
    
    -- Nguồn khách hàng (website, quảng cáo, giới thiệu)
    source VARCHAR(100),
    
    -- Nhân viên phụ trách
    assigned_user_id UUID REFERENCES users(id),
    
    -- Giá trị khách hàng suốt đời (Customer Lifetime Value)
    lifetime_value DECIMAL(15,2) DEFAULT 0,
    
    -- Tổng số đơn hàng đã mua
    total_orders INTEGER DEFAULT 0,
    
    -- Tổng giá trị đã mua
    total_spent DECIMAL(15,2) DEFAULT 0,
    
    -- Lần mua cuối cùng
    last_purchase_date TIMESTAMP,
    
    -- === METADATA ===
    -- Thông tin tổ chức (multi-tenant)
    organization_id UUID NOT NULL REFERENCES organizations(id),
    
    -- Thời gian tạo và cập nhật
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id),
    
    -- Soft delete (xóa mềm - không xóa thật khỏi database)
    deleted_at TIMESTAMP,
    deleted_by UUID REFERENCES users(id)
);
```

#### **Giải thích các enum types:**

```sql
-- Loại khách hàng
CREATE TYPE customer_type_enum AS ENUM (
    'individual',    -- Cá nhân
    'business'       -- Doanh nghiệp
);

-- Quy mô công ty
CREATE TYPE company_size_enum AS ENUM (
    'micro',         -- Vi mô (1-10 nhân viên)
    'small',         -- Nhỏ (11-50 nhân viên)
    'medium',        -- Vừa (51-250 nhân viên)
    'large',         -- Lớn (251-1000 nhân viên)
    'enterprise'     -- Tập đoàn (>1000 nhân viên)
);

-- Trạng thái khách hàng
CREATE TYPE customer_status_enum AS ENUM (
    'prospect',      -- Tiềm năng (chưa mua)
    'active',        -- Đang hoạt động
    'inactive',      -- Ngừng hoạt động
    'churned',       -- Đã rời bỏ
    'blocked'        -- Bị chặn
);

-- Giới tính
CREATE TYPE gender_enum AS ENUM (
    'male',          -- Nam
    'female',        -- Nữ
    'other',         -- Khác
    'prefer_not_to_say' -- Không muốn tiết lộ
);
```

### 📞 **2. BẢNG CUSTOMER_CONTACTS (LIÊN HỆ KHÁCH HÀNG)**

**Mục đích:** Lưu nhiều thông tin liên hệ cho một khách hàng

```sql
CREATE TABLE customer_contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Liên kết với khách hàng
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    
    -- Loại liên hệ (email, phone, social media)
    contact_type contact_type_enum NOT NULL,
    
    -- Giá trị liên hệ
    contact_value VARCHAR(255) NOT NULL,
    
    -- Nhãn mô tả (công việc, cá nhân, khẩn cấp)
    label VARCHAR(100),
    
    -- Có phải liên hệ chính không
    is_primary BOOLEAN DEFAULT FALSE,
    
    -- Đã xác minh chưa (email verified, phone verified)
    is_verified BOOLEAN DEFAULT FALSE,
    
    -- Thời gian xác minh
    verified_at TIMESTAMP,
    
    -- Metadata
    organization_id UUID NOT NULL REFERENCES organizations(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Loại liên hệ
CREATE TYPE contact_type_enum AS ENUM (
    'email',         -- Email
    'phone',         -- Điện thoại
    'mobile',        -- Di động
    'fax',           -- Fax
    'website',       -- Website
    'facebook',      -- Facebook
    'zalo',          -- Zalo
    'telegram',      -- Telegram
    'linkedin',      -- LinkedIn
    'other'          -- Khác
);
```

### 🏠 **3. BẢNG CUSTOMER_ADDRESSES (ĐỊA CHỈ KHÁCH HÀNG)**

**Mục đích:** Lưu địa chỉ giao hàng, thanh toán của khách hàng

```sql
CREATE TABLE customer_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Liên kết với khách hàng
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    
    -- Loại địa chỉ
    address_type address_type_enum NOT NULL,
    
    -- Thông tin địa chỉ chi tiết
    address_line_1 VARCHAR(255) NOT NULL,  -- Số nhà, tên đường
    address_line_2 VARCHAR(255),           -- Phường, quận (optional)
    
    -- Đơn vị hành chính Việt Nam
    ward VARCHAR(100),          -- Phường/Xã
    district VARCHAR(100),      -- Quận/Huyện
    city VARCHAR(100),          -- Tỉnh/Thành phố
    country VARCHAR(100) DEFAULT 'Vietnam', -- Quốc gia
    postal_code VARCHAR(20),    -- Mã bưu điện
    
    -- Tọa độ GPS (để tính khoảng cách giao hàng)
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Có phải địa chỉ mặc định không
    is_default BOOLEAN DEFAULT FALSE,
    
    -- Ghi chú thêm (cách tìm đường, landmark)
    notes TEXT,
    
    -- Metadata
    organization_id UUID NOT NULL REFERENCES organizations(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Loại địa chỉ
CREATE TYPE address_type_enum AS ENUM (
    'billing',       -- Địa chỉ thanh toán
    'shipping',      -- Địa chỉ giao hàng
    'office',        -- Địa chỉ văn phòng
    'home',          -- Địa chỉ nhà riêng
    'warehouse',     -- Địa chỉ kho
    'other'          -- Khác
);
```

### 🎯 **4. BẢNG CUSTOMER_SEGMENTS (PHÂN KHÚC KHÁCH HÀNG)**

**Mục đích:** Nhóm khách hàng theo tiêu chí để marketing hiệu quả

```sql
CREATE TABLE customer_segments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Tên phân khúc
    name VARCHAR(255) NOT NULL,
    
    -- Mô tả chi tiết
    description TEXT,
    
    -- Màu sắc hiển thị trên UI
    color VARCHAR(7), -- Hex color code (#FF0000)
    
    -- Điều kiện phân khúc (JSON format)
    criteria JSONB,
    
    -- Loại phân khúc (tự động hoặc thủ công)
    segment_type segment_type_enum DEFAULT 'manual',
    
    -- Có hoạt động không
    is_active BOOLEAN DEFAULT TRUE,
    
    -- Số lượng khách hàng trong phân khúc
    customer_count INTEGER DEFAULT 0,
    
    -- Metadata
    organization_id UUID NOT NULL REFERENCES organizations(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);

-- Loại phân khúc
CREATE TYPE segment_type_enum AS ENUM (
    'manual',        -- Thủ công (admin tự chọn khách hàng)
    'automatic',     -- Tự động (dựa trên điều kiện)
    'ai_generated'   -- AI tạo tự động
);

-- Bảng liên kết khách hàng với phân khúc (many-to-many)
CREATE TABLE customer_segment_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    segment_id UUID NOT NULL REFERENCES customer_segments(id) ON DELETE CASCADE,
    
    -- Thời gian thêm vào phân khúc
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    added_by UUID REFERENCES users(id),
    
    -- Unique constraint để tránh duplicate
    UNIQUE(customer_id, segment_id)
);
```

---

## 📊 CHỈ MỤC VÀ TỐI ƯU HIỆU SUẤT

### 🚀 **Indexes quan trọng:**

```sql
-- Tìm kiếm khách hàng theo tên (full-text search)
CREATE INDEX idx_customers_name_fulltext ON customers 
USING gin(to_tsvector('vietnamese', name || ' ' || COALESCE(company_name, '')));

-- Tìm kiếm theo email và phone
CREATE INDEX idx_customers_email ON customers(primary_email);
CREATE INDEX idx_customers_phone ON customers(primary_phone);

-- Lọc theo trạng thái và nguồn
CREATE INDEX idx_customers_status_source ON customers(status, source);

-- Sắp xếp theo giá trị khách hàng
CREATE INDEX idx_customers_lifetime_value ON customers(lifetime_value DESC);

-- Multi-tenant index
CREATE INDEX idx_customers_org_id ON customers(organization_id);

-- Soft delete index
CREATE INDEX idx_customers_not_deleted ON customers(id) WHERE deleted_at IS NULL;
```

### ⚡ **Performance Tips:**
- **Partition by organization_id:** Chia bảng theo tổ chức để tăng tốc
- **Archive old data:** Chuyển khách hàng cũ sang bảng archive
- **Use materialized views:** Cho các báo cáo phức tạp
- **Cache frequent queries:** Dùng Redis cache cho top customers

---

## 🔒 BẢO MẬT VÀ QUYỀN RIÊNG TƯ

### 🛡️ **Row Level Security (RLS):**

```sql
-- Chỉ cho phép xem khách hàng trong tổ chức của mình
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY customers_org_isolation ON customers
    FOR ALL TO authenticated_users
    USING (organization_id = current_setting('app.current_org_id')::UUID);
```

### 🔐 **Data Encryption:**
- **PII Fields:** Mã hóa email, phone, address
- **Sensitive Data:** Mã hóa tax_number, annual_revenue
- **At Rest:** Database encryption
- **In Transit:** SSL/TLS cho API calls

### 📝 **Audit Trail:**
```sql
-- Bảng audit log cho customers
CREATE TABLE customer_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    action VARCHAR(50) NOT NULL, -- CREATE, UPDATE, DELETE
    old_values JSONB,
    new_values JSONB,
    changed_by UUID REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address INET,
    user_agent TEXT
);
```

---

## 🎯 USE CASES THỰC TẾ

### 📈 **1. Customer Segmentation (Phân khúc khách hàng)**
```sql
-- Tìm khách hàng VIP (mua > 50 triệu trong năm)
SELECT c.*, 
       c.total_spent as "Tổng chi tiêu",
       c.total_orders as "Số đơn hàng"
FROM customers c 
WHERE c.total_spent > 50000000 
  AND c.status = 'active'
  AND c.organization_id = :org_id
ORDER BY c.total_spent DESC;
```

### 🎂 **2. Birthday Marketing Campaign**
```sql
-- Khách hàng có sinh nhật trong tháng này
SELECT c.name, c.primary_email, c.date_of_birth
FROM customers c
WHERE EXTRACT(MONTH FROM c.date_of_birth) = EXTRACT(MONTH FROM CURRENT_DATE)
  AND c.status = 'active'
  AND c.primary_email IS NOT NULL;
```

### 📞 **3. Customer Support Priority**
```sql
-- Khách hàng cần ưu tiên hỗ trợ (VIP + có vấn đề gần đây)
SELECT c.name, c.lifetime_value, 
       COUNT(t.id) as "Số ticket gần đây"
FROM customers c
LEFT JOIN support_tickets t ON c.id = t.customer_id 
    AND t.created_at > CURRENT_DATE - INTERVAL '30 days'
WHERE c.lifetime_value > 10000000
GROUP BY c.id, c.name, c.lifetime_value
HAVING COUNT(t.id) > 0
ORDER BY c.lifetime_value DESC;
```

---

## 📞 HỖ TRỢ VÀ TÀI LIỆU

### 🆘 **Cần hỗ trợ về Customer Schema?**
- **📧 Email:** customer-schema@nextflow-crm.com
- **📞 Hotline:** 1900-xxx-xxx (ext. 7)
- **💬 Live Chat:** Trong ứng dụng NextFlow CRM-AI

### 📚 **Tài liệu liên quan:**
- **📊 [Schema Analytics](./bao-cao-phan-tich.md.md)** - Báo cáo khách hàng
- **🛒 [Schema Đơn hàng](./don-hang.md.md)** - Liên kết với orders
- **📢 [Schema Marketing](./marketing.md.md)** - Campaigns cho customers
- **🔗 [Mối quan hệ Schema](../moi-quan-he-schema%20(Mối%20quan%20hệ%20giữa%20các%20schema).md)**

---

**Cập nhật:** [Ngày tháng năm] | **Version:** 1.0.0 | **NextFlow Database Team**