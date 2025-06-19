# SCHEMA SẢN PHẨM NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Product Management](#2-product-management)
3. [Category Management](#3-category-management)
4. [Inventory Management](#4-inventory-management)
5. [Pricing Management](#5-pricing-management)
6. [Product Analytics](#6-product-analytics)

## 1. GIỚI THIỆU

Schema Sản phẩm của NextFlow CRM định nghĩa cấu trúc dữ liệu cho quản lý sản phẩm, danh mục, kho hàng và giá cả trong hệ thống CRM.

### 1.1. Mối quan hệ chính

```
Categories → Products → Variants → Inventory
     ↓          ↓         ↓          ↓
Attributes → Pricing → Stock → Analytics
```

## 2. PRODUCT MANAGEMENT

### 2.1. Products Table

```sql
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    short_description TEXT,
    
    -- Classification
    category_id UUID REFERENCES product_categories(id),
    brand_id UUID REFERENCES brands(id),
    type product_type_enum DEFAULT 'simple',
    
    -- Status
    status product_status_enum DEFAULT 'draft',
    visibility visibility_enum DEFAULT 'public',
    
    -- Physical Properties
    weight DECIMAL(8,3),
    dimensions JSONB,
    color VARCHAR(50),
    size VARCHAR(50),
    material VARCHAR(100),
    
    -- Inventory
    track_inventory BOOLEAN DEFAULT true,
    manage_stock BOOLEAN DEFAULT true,
    stock_quantity INTEGER DEFAULT 0,
    low_stock_threshold INTEGER DEFAULT 10,
    
    -- Pricing
    regular_price DECIMAL(15,2),
    sale_price DECIMAL(15,2),
    cost_price DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'VND',
    
    -- SEO
    slug VARCHAR(255) UNIQUE,
    meta_title VARCHAR(255),
    meta_description TEXT,
    meta_keywords TEXT,
    
    -- Media
    featured_image_url VARCHAR(500),
    gallery_images JSONB,
    
    -- Shipping
    shipping_class VARCHAR(100),
    shipping_weight DECIMAL(8,3),
    shipping_dimensions JSONB,
    
    -- Metadata
    tags TEXT[],
    notes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

### 2.2. Product Variants

```sql
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    
    -- Variant Details
    name VARCHAR(255),
    description TEXT,
    
    -- Attributes
    attributes JSONB,
    
    -- Inventory
    stock_quantity INTEGER DEFAULT 0,
    reserved_quantity INTEGER DEFAULT 0,
    available_quantity INTEGER GENERATED ALWAYS AS (stock_quantity - reserved_quantity) STORED,
    
    -- Pricing
    regular_price DECIMAL(15,2),
    sale_price DECIMAL(15,2),
    cost_price DECIMAL(15,2),
    
    -- Physical Properties
    weight DECIMAL(8,3),
    dimensions JSONB,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Media
    image_url VARCHAR(500),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2.3. Product Attributes

```sql
CREATE TABLE product_attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    
    -- Attribute Type
    type attribute_type_enum NOT NULL,
    
    -- Configuration
    is_required BOOLEAN DEFAULT false,
    is_variation BOOLEAN DEFAULT false,
    is_filterable BOOLEAN DEFAULT false,
    
    -- Options (for select/multiselect types)
    options JSONB,
    
    -- Validation
    validation_rules JSONB,
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2.4. Product Attribute Values

```sql
CREATE TABLE product_attribute_values (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) NOT NULL,
    attribute_id UUID REFERENCES product_attributes(id) NOT NULL,
    
    value TEXT NOT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(product_id, attribute_id)
);
```

## 3. CATEGORY MANAGEMENT

### 3.1. Product Categories

```sql
CREATE TABLE product_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    
    -- Hierarchy
    parent_id UUID REFERENCES product_categories(id),
    level INTEGER DEFAULT 0,
    path VARCHAR(500),
    
    -- Display
    sort_order INTEGER DEFAULT 0,
    image_url VARCHAR(500),
    
    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,
    meta_keywords TEXT,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Counts
    product_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3.2. Brands

```sql
CREATE TABLE brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    
    -- Brand Details
    logo_url VARCHAR(500),
    website VARCHAR(255),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Counts
    product_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 4. INVENTORY MANAGEMENT

### 4.1. Inventory Transactions

```sql
CREATE TABLE inventory_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id),
    product_variant_id UUID REFERENCES product_variants(id),
    
    -- Transaction Details
    type transaction_type_enum NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_cost DECIMAL(15,2),
    total_cost DECIMAL(15,2),
    
    -- Reference
    reference_type VARCHAR(100),
    reference_id UUID,
    
    -- Location
    warehouse_id UUID REFERENCES warehouses(id),
    location VARCHAR(100),
    
    -- Reason
    reason VARCHAR(255),
    notes TEXT,
    
    -- Metadata
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);
```

### 4.2. Warehouses

```sql
CREATE TABLE warehouses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    
    -- Location
    address JSONB,
    
    -- Contact
    manager_id UUID REFERENCES users(id),
    phone VARCHAR(20),
    email VARCHAR(255),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4.3. Stock Levels

```sql
CREATE TABLE stock_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id),
    product_variant_id UUID REFERENCES product_variants(id),
    warehouse_id UUID REFERENCES warehouses(id) NOT NULL,
    
    -- Stock Information
    quantity_on_hand INTEGER DEFAULT 0,
    quantity_reserved INTEGER DEFAULT 0,
    quantity_available INTEGER GENERATED ALWAYS AS (quantity_on_hand - quantity_reserved) STORED,
    
    -- Thresholds
    reorder_point INTEGER DEFAULT 0,
    maximum_stock INTEGER,
    
    -- Costs
    average_cost DECIMAL(15,2) DEFAULT 0,
    last_cost DECIMAL(15,2) DEFAULT 0,
    
    -- Dates
    last_counted_at TIMESTAMP,
    last_received_at TIMESTAMP,
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(product_id, product_variant_id, warehouse_id)
);
```

## 5. PRICING MANAGEMENT

### 5.1. Price Lists

```sql
CREATE TABLE price_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Pricing Rules
    type price_list_type_enum DEFAULT 'standard',
    currency VARCHAR(3) DEFAULT 'VND',
    
    -- Validity
    effective_from DATE,
    effective_to DATE,
    
    -- Customer Targeting
    customer_segments UUID[],
    customer_types customer_type_enum[],
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    is_default BOOLEAN DEFAULT false,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5.2. Price List Items

```sql
CREATE TABLE price_list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    price_list_id UUID REFERENCES price_lists(id) NOT NULL,
    product_id UUID REFERENCES products(id),
    product_variant_id UUID REFERENCES product_variants(id),
    
    -- Pricing
    price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    minimum_quantity INTEGER DEFAULT 1,
    
    -- Validity
    effective_from DATE,
    effective_to DATE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(price_list_id, product_id, product_variant_id, minimum_quantity)
);
```

### 5.3. Price History

```sql
CREATE TABLE price_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id),
    product_variant_id UUID REFERENCES product_variants(id),
    
    -- Price Information
    old_price DECIMAL(15,2),
    new_price DECIMAL(15,2),
    price_type price_type_enum NOT NULL,
    
    -- Change Details
    change_reason VARCHAR(255),
    changed_by UUID REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 6. PRODUCT ANALYTICS

### 6.1. Product Metrics

```sql
CREATE TABLE product_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) NOT NULL,
    
    -- Period
    metric_date DATE NOT NULL,
    metric_period period_enum NOT NULL,
    
    -- Sales Metrics
    units_sold INTEGER DEFAULT 0,
    revenue DECIMAL(15,2) DEFAULT 0,
    profit DECIMAL(15,2) DEFAULT 0,
    
    -- Inventory Metrics
    stock_turnover DECIMAL(8,2) DEFAULT 0,
    days_in_stock INTEGER DEFAULT 0,
    stockout_days INTEGER DEFAULT 0,
    
    -- Performance Metrics
    views INTEGER DEFAULT 0,
    conversion_rate DECIMAL(5,2) DEFAULT 0,
    return_rate DECIMAL(5,2) DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 6.2. Product Performance

```sql
CREATE TABLE product_performance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID REFERENCES products(id) NOT NULL,
    
    -- Performance Scores
    sales_velocity DECIMAL(8,2) DEFAULT 0,
    profit_margin DECIMAL(5,2) DEFAULT 0,
    inventory_turnover DECIMAL(8,2) DEFAULT 0,
    customer_rating DECIMAL(3,2) DEFAULT 0,
    
    -- Rankings
    sales_rank INTEGER,
    profit_rank INTEGER,
    popularity_rank INTEGER,
    
    -- Calculated At
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM Schema Team
