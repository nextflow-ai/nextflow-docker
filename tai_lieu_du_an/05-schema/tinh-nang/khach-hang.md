# SCHEMA KHÁCH HÀNG NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Customer Management](#2-customer-management)
3. [Contact Management](#3-contact-management)
4. [Address Management](#4-address-management)
5. [Customer Segmentation](#5-customer-segmentation)
6. [Customer Analytics](#6-customer-analytics)

## 1. GIỚI THIỆU

Schema Khách hàng của NextFlow CRM định nghĩa cấu trúc dữ liệu cho quản lý thông tin khách hàng, liên hệ, địa chỉ và phân khúc khách hàng.

### 1.1. Mối quan hệ chính

```
Customers → Contacts → Addresses
    ↓         ↓          ↓
Segments → Activities → Analytics
```

## 2. CUSTOMER MANAGEMENT

### 2.1. Customers Table

```sql
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_code VARCHAR(50) UNIQUE NOT NULL,
    
    -- Basic Information
    type customer_type_enum DEFAULT 'individual',
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    
    -- Company Information (for business customers)
    company_name VARCHAR(255),
    tax_number VARCHAR(50),
    industry VARCHAR(100),
    company_size company_size_enum,
    annual_revenue DECIMAL(15,2),
    
    -- Individual Information
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender gender_enum,
    
    -- Contact Information
    primary_email VARCHAR(255),
    primary_phone VARCHAR(20),
    website VARCHAR(255),
    
    -- Status
    status customer_status_enum DEFAULT 'active',
    lifecycle_stage lifecycle_stage_enum DEFAULT 'lead',
    
    -- Assignment
    assigned_to UUID REFERENCES users(id),
    account_manager_id UUID REFERENCES users(id),
    
    -- Financial
    credit_limit DECIMAL(15,2),
    payment_terms INTEGER DEFAULT 30,
    currency VARCHAR(3) DEFAULT 'VND',
    
    -- Preferences
    preferred_language VARCHAR(5) DEFAULT 'vi',
    preferred_contact_method contact_method_enum DEFAULT 'email',
    timezone VARCHAR(50) DEFAULT 'Asia/Ho_Chi_Minh',
    
    -- Marketing
    marketing_consent BOOLEAN DEFAULT false,
    email_consent BOOLEAN DEFAULT false,
    sms_consent BOOLEAN DEFAULT false,
    
    -- Metadata
    source VARCHAR(100),
    tags TEXT[],
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

### 2.2. Customer Custom Fields

```sql
CREATE TABLE customer_custom_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    field_type field_type_enum NOT NULL,
    field_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 3. CONTACT MANAGEMENT

### 3.1. Contacts Table

```sql
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    
    -- Personal Information
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    full_name VARCHAR(255) GENERATED ALWAYS AS (first_name || ' ' || last_name) STORED,
    
    -- Contact Information
    email VARCHAR(255),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    
    -- Professional Information
    job_title VARCHAR(100),
    department VARCHAR(100),
    
    -- Status
    is_primary BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    
    -- Preferences
    preferred_contact_method contact_method_enum DEFAULT 'email',
    
    -- Social
    linkedin_url VARCHAR(255),
    twitter_handle VARCHAR(100),
    
    -- Metadata
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3.2. Contact Activities

```sql
CREATE TABLE contact_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID REFERENCES contacts(id) NOT NULL,
    activity_type activity_type_enum NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Scheduling
    scheduled_at TIMESTAMP,
    completed_at TIMESTAMP,
    
    -- Status
    status activity_status_enum DEFAULT 'planned',
    
    -- Assignment
    assigned_to UUID REFERENCES users(id) NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 4. ADDRESS MANAGEMENT

### 4.1. Addresses Table

```sql
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    
    -- Address Type
    type address_type_enum NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    
    -- Address Information
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(2) NOT NULL DEFAULT 'VN',
    
    -- Geocoding
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    
    -- Metadata
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 5. CUSTOMER SEGMENTATION

### 5.1. Customer Segments

```sql
CREATE TABLE customer_segments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    
    -- Segment Criteria
    criteria JSONB NOT NULL,
    is_dynamic BOOLEAN DEFAULT true,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Metadata
    color VARCHAR(7),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);
```

### 5.2. Customer Segment Memberships

```sql
CREATE TABLE customer_segment_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    segment_id UUID REFERENCES customer_segments(id) NOT NULL,
    
    -- Membership
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    
    -- Automation
    auto_assigned BOOLEAN DEFAULT false,
    
    UNIQUE(customer_id, segment_id)
);
```

## 6. CUSTOMER ANALYTICS

### 6.1. Customer Metrics

```sql
CREATE TABLE customer_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    
    -- Period
    metric_date DATE NOT NULL,
    metric_period period_enum NOT NULL,
    
    -- Engagement Metrics
    total_orders INTEGER DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0,
    average_order_value DECIMAL(15,2) DEFAULT 0,
    
    -- Activity Metrics
    email_opens INTEGER DEFAULT 0,
    email_clicks INTEGER DEFAULT 0,
    website_visits INTEGER DEFAULT 0,
    
    -- Lifecycle Metrics
    days_since_last_order INTEGER,
    lifetime_value DECIMAL(15,2) DEFAULT 0,
    churn_probability DECIMAL(5,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 6.2. Customer Lifecycle Events

```sql
CREATE TABLE customer_lifecycle_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    
    event_type lifecycle_event_enum NOT NULL,
    from_stage lifecycle_stage_enum,
    to_stage lifecycle_stage_enum,
    
    event_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    triggered_by UUID REFERENCES users(id),
    
    -- Event Data
    event_data JSONB,
    notes TEXT
);
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM Schema Team
