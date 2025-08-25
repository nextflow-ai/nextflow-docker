# SCHEMA ĐỚN HÀNG NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Orders Management](#2-orders-management)
3. [Order Items](#3-order-items)
4. [Payment Processing](#4-payment-processing)
5. [Shipping và Fulfillment](#5-shipping-và-fulfillment)
6. [Order Status Tracking](#6-order-status-tracking)
7. [Returns và Refunds](#7-returns-và-refunds)
8. [Order Analytics](#8-order-analytics)

## 1. GIỚI THIỆU

Schema Đơn hàng của NextFlow CRM-AI định nghĩa cấu trúc dữ liệu cho toàn bộ quy trình xử lý đơn hàng từ tạo đơn đến hoàn thành, bao gồm thanh toán, vận chuyển và theo dõi trạng thái.

### 1.1. Mối quan hệ chính

```
Quotes → Orders → Order Items → Payments
  ↓        ↓         ↓           ↓
Customers → Shipping → Fulfillment → Invoices
```

## 2. ORDERS MANAGEMENT

### 2.1. Orders Table

```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    quote_id UUID REFERENCES quotes(id),
    opportunity_id UUID REFERENCES opportunities(id),
    
    -- Order Information
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status order_status_enum DEFAULT 'pending',
    priority priority_enum DEFAULT 'medium',
    
    -- Financial Information
    subtotal DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    shipping_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'VND',
    
    -- Billing Information
    billing_address_id UUID REFERENCES addresses(id),
    billing_contact_id UUID REFERENCES contacts(id),
    
    -- Shipping Information
    shipping_address_id UUID REFERENCES addresses(id),
    shipping_contact_id UUID REFERENCES contacts(id),
    shipping_method_id UUID REFERENCES shipping_methods(id),
    
    -- Dates
    required_date DATE,
    promised_date DATE,
    shipped_date DATE,
    delivered_date DATE,
    
    -- Notes
    customer_notes TEXT,
    internal_notes TEXT,
    special_instructions TEXT,
    
    -- Assignment
    assigned_to UUID REFERENCES users(id),
    sales_rep_id UUID REFERENCES users(id),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

### 2.2. Order Status History

```sql
CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) NOT NULL,
    from_status order_status_enum,
    to_status order_status_enum NOT NULL,
    
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by UUID REFERENCES users(id) NOT NULL,
    notes TEXT,
    
    -- Notification
    customer_notified BOOLEAN DEFAULT false,
    notification_sent_at TIMESTAMP
);
```

## 3. ORDER ITEMS

### 3.1. Order Items Table

```sql
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) NOT NULL,
    product_id UUID REFERENCES products(id) NOT NULL,
    product_variant_id UUID REFERENCES product_variants(id),
    
    -- Product Information
    product_name VARCHAR(255) NOT NULL,
    product_sku VARCHAR(100),
    product_description TEXT,
    
    -- Quantity and Pricing
    quantity DECIMAL(10,2) NOT NULL DEFAULT 1,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    
    -- Fulfillment
    quantity_shipped DECIMAL(10,2) DEFAULT 0,
    quantity_delivered DECIMAL(10,2) DEFAULT 0,
    quantity_returned DECIMAL(10,2) DEFAULT 0,
    
    -- Status
    status order_item_status_enum DEFAULT 'pending',
    
    -- Metadata
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3.2. Order Item Tracking

```sql
CREATE TABLE order_item_tracking (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_item_id UUID REFERENCES order_items(id) NOT NULL,
    
    -- Tracking Information
    tracking_number VARCHAR(100),
    carrier VARCHAR(100),
    service_type VARCHAR(100),
    
    -- Status
    status tracking_status_enum DEFAULT 'pending',
    
    -- Dates
    shipped_at TIMESTAMP,
    estimated_delivery TIMESTAMP,
    delivered_at TIMESTAMP,
    
    -- Location
    current_location VARCHAR(255),
    destination_location VARCHAR(255),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 4. PAYMENT PROCESSING

### 4.1. Payments Table

```sql
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) NOT NULL,
    payment_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- Payment Information
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'VND',
    payment_method payment_method_enum NOT NULL,
    payment_gateway VARCHAR(100),
    
    -- Status
    status payment_status_enum DEFAULT 'pending',
    
    -- Transaction Details
    transaction_id VARCHAR(255),
    gateway_transaction_id VARCHAR(255),
    gateway_response JSONB,
    
    -- Dates
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP,
    
    -- Failure Information
    failure_reason TEXT,
    failure_code VARCHAR(50),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4.2. Payment Methods

```sql
CREATE TABLE payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    
    -- Method Information
    type payment_method_enum NOT NULL,
    provider VARCHAR(100),
    
    -- Card Information (if applicable)
    card_last_four VARCHAR(4),
    card_brand VARCHAR(50),
    card_expiry_month INTEGER,
    card_expiry_year INTEGER,
    
    -- Bank Information (if applicable)
    bank_name VARCHAR(100),
    account_number_masked VARCHAR(50),
    
    -- Status
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    
    -- Security
    token VARCHAR(255),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 5. SHIPPING VÀ FULFILLMENT

### 5.1. Shipping Methods

```sql
CREATE TABLE shipping_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    carrier VARCHAR(100),
    service_type VARCHAR(100),
    
    -- Pricing
    base_cost DECIMAL(10,2),
    cost_per_kg DECIMAL(10,2),
    free_shipping_threshold DECIMAL(15,2),
    
    -- Delivery
    estimated_days_min INTEGER,
    estimated_days_max INTEGER,
    
    -- Availability
    is_active BOOLEAN DEFAULT true,
    available_countries TEXT[],
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5.2. Shipments

```sql
CREATE TABLE shipments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES orders(id) NOT NULL,
    shipment_number VARCHAR(50) UNIQUE NOT NULL,
    
    -- Shipping Information
    shipping_method_id UUID REFERENCES shipping_methods(id) NOT NULL,
    carrier VARCHAR(100),
    service_type VARCHAR(100),
    tracking_number VARCHAR(100),
    
    -- Addresses
    from_address JSONB NOT NULL,
    to_address JSONB NOT NULL,
    
    -- Package Information
    weight DECIMAL(8,2),
    dimensions JSONB,
    package_count INTEGER DEFAULT 1,
    
    -- Costs
    shipping_cost DECIMAL(10,2),
    insurance_cost DECIMAL(10,2),
    
    -- Status
    status shipment_status_enum DEFAULT 'pending',
    
    -- Dates
    shipped_at TIMESTAMP,
    estimated_delivery TIMESTAMP,
    delivered_at TIMESTAMP,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 6. ORDER STATUS TRACKING

### 6.1. Order Workflows

```sql
CREATE TABLE order_workflows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 6.2. Workflow Steps

```sql
CREATE TABLE workflow_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID REFERENCES order_workflows(id) NOT NULL,
    step_name VARCHAR(100) NOT NULL,
    step_order INTEGER NOT NULL,
    status_value order_status_enum NOT NULL,
    
    -- Automation
    auto_advance BOOLEAN DEFAULT false,
    auto_advance_conditions JSONB,
    
    -- Notifications
    notify_customer BOOLEAN DEFAULT false,
    notify_staff BOOLEAN DEFAULT false,
    notification_template_id UUID,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 7. RETURNS VÀ REFUNDS

### 7.1. Returns Table

```sql
CREATE TABLE returns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    return_number VARCHAR(50) UNIQUE NOT NULL,
    order_id UUID REFERENCES orders(id) NOT NULL,
    customer_id UUID REFERENCES customers(id) NOT NULL,
    
    -- Return Information
    reason return_reason_enum NOT NULL,
    description TEXT,
    status return_status_enum DEFAULT 'requested',
    
    -- Financial
    return_amount DECIMAL(15,2) NOT NULL,
    refund_amount DECIMAL(15,2),
    restocking_fee DECIMAL(15,2) DEFAULT 0,
    
    -- Dates
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    received_at TIMESTAMP,
    processed_at TIMESTAMP,
    
    -- Processing
    approved_by UUID REFERENCES users(id),
    processed_by UUID REFERENCES users(id),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 7.2. Return Items

```sql
CREATE TABLE return_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    return_id UUID REFERENCES returns(id) NOT NULL,
    order_item_id UUID REFERENCES order_items(id) NOT NULL,
    
    quantity_returned DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    
    condition item_condition_enum,
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 8. ORDER ANALYTICS

### 8.1. Order Metrics

```sql
CREATE TABLE order_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Period
    metric_date DATE NOT NULL,
    metric_period period_enum NOT NULL,
    
    -- Order Counts
    orders_total INTEGER DEFAULT 0,
    orders_completed INTEGER DEFAULT 0,
    orders_cancelled INTEGER DEFAULT 0,
    orders_returned INTEGER DEFAULT 0,
    
    -- Revenue
    revenue_total DECIMAL(15,2) DEFAULT 0,
    revenue_net DECIMAL(15,2) DEFAULT 0,
    average_order_value DECIMAL(15,2) DEFAULT 0,
    
    -- Performance
    fulfillment_time_avg DECIMAL(8,2),
    shipping_time_avg DECIMAL(8,2),
    return_rate DECIMAL(5,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM-AI Schema Team
