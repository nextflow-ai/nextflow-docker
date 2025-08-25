# SCHEMA BÁN HÀNG NextFlow CRM-AI

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Leads Management](#2-leads-management)
3. [Opportunities](#3-opportunities)
4. [Sales Pipeline](#4-sales-pipeline)
5. [Quotes và Proposals](#5-quotes-và-proposals)
6. [Sales Activities](#6-sales-activities)
7. [Commission và Incentives](#7-commission-và-incentives)
8. [Sales Analytics](#8-sales-analytics)

## 1. GIỚI THIỆU

Schema Bán hàng của NextFlow CRM-AI định nghĩa cấu trúc dữ liệu cho toàn bộ quy trình bán hàng từ lead generation đến deal closure, bao gồm quản lý cơ hội, pipeline, báo giá và phân tích hiệu suất.

### 1.1. Mối quan hệ chính

```
Leads → Opportunities → Quotes → Deals → Orders
  ↓         ↓            ↓        ↓       ↓
Activities → Pipeline → Proposals → Commission → Revenue
```

## 2. LEADS MANAGEMENT

### 2.1. Leads Table

```sql
CREATE TABLE leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_source_id UUID REFERENCES lead_sources(id),
    customer_id UUID REFERENCES customers(id),
    assigned_to UUID REFERENCES users(id),
    
    -- Lead Information
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    company VARCHAR(255),
    job_title VARCHAR(100),
    
    -- Lead Details
    status lead_status_enum DEFAULT 'new',
    quality lead_quality_enum DEFAULT 'unqualified',
    score INTEGER DEFAULT 0,
    temperature lead_temperature_enum DEFAULT 'cold',
    
    -- Lead Data
    industry VARCHAR(100),
    company_size company_size_enum,
    annual_revenue DECIMAL(15,2),
    budget_range budget_range_enum,
    decision_timeframe timeframe_enum,
    
    -- Tracking
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100),
    utm_content VARCHAR(255),
    utm_term VARCHAR(100),
    
    -- Conversion
    converted_at TIMESTAMP,
    converted_to_customer_id UUID REFERENCES customers(id),
    converted_to_opportunity_id UUID REFERENCES opportunities(id),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

### 2.2. Lead Sources

```sql
CREATE TABLE lead_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    type source_type_enum NOT NULL,
    description TEXT,
    cost_per_lead DECIMAL(10,2),
    conversion_rate DECIMAL(5,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 2.3. Lead Scoring Rules

```sql
CREATE TABLE lead_scoring_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    condition_field VARCHAR(100) NOT NULL,
    condition_operator operator_enum NOT NULL,
    condition_value VARCHAR(255) NOT NULL,
    score_points INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 3. OPPORTUNITIES

### 3.1. Opportunities Table

```sql
CREATE TABLE opportunities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    lead_id UUID REFERENCES leads(id),
    assigned_to UUID REFERENCES users(id) NOT NULL,
    
    -- Opportunity Information
    name VARCHAR(255) NOT NULL,
    description TEXT,
    stage_id UUID REFERENCES sales_stages(id) NOT NULL,
    probability DECIMAL(5,2) DEFAULT 0,
    
    -- Financial Information
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'VND',
    expected_revenue DECIMAL(15,2),
    weighted_amount DECIMAL(15,2),
    
    -- Timeline
    expected_close_date DATE,
    actual_close_date DATE,
    sales_cycle_days INTEGER,
    
    -- Classification
    type opportunity_type_enum DEFAULT 'new_business',
    priority priority_enum DEFAULT 'medium',
    source VARCHAR(100),
    
    -- Competition
    competitors TEXT[],
    competitive_position competitive_position_enum,
    
    -- Status
    status opportunity_status_enum DEFAULT 'open',
    close_reason VARCHAR(255),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

### 3.2. Sales Stages

```sql
CREATE TABLE sales_stages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    stage_order INTEGER NOT NULL,
    probability DECIMAL(5,2) NOT NULL,
    is_closed BOOLEAN DEFAULT false,
    is_won BOOLEAN DEFAULT false,
    color VARCHAR(7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3.3. Opportunity Products

```sql
CREATE TABLE opportunity_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID REFERENCES opportunities(id) NOT NULL,
    product_id UUID REFERENCES products(id) NOT NULL,
    
    quantity DECIMAL(10,2) NOT NULL DEFAULT 1,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 4. SALES PIPELINE

### 4.1. Pipeline Configuration

```sql
CREATE TABLE sales_pipelines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4.2. Pipeline Stages

```sql
CREATE TABLE pipeline_stages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pipeline_id UUID REFERENCES sales_pipelines(id) NOT NULL,
    stage_id UUID REFERENCES sales_stages(id) NOT NULL,
    stage_order INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4.3. Stage History

```sql
CREATE TABLE opportunity_stage_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opportunity_id UUID REFERENCES opportunities(id) NOT NULL,
    from_stage_id UUID REFERENCES sales_stages(id),
    to_stage_id UUID REFERENCES sales_stages(id) NOT NULL,
    
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by UUID REFERENCES users(id) NOT NULL,
    duration_days INTEGER,
    notes TEXT
);
```

## 5. QUOTES VÀ PROPOSALS

### 5.1. Quotes Table

```sql
CREATE TABLE quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quote_number VARCHAR(50) UNIQUE NOT NULL,
    opportunity_id UUID REFERENCES opportunities(id),
    customer_id UUID REFERENCES customers(id) NOT NULL,
    
    -- Quote Information
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status quote_status_enum DEFAULT 'draft',
    
    -- Financial
    subtotal DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'VND',
    
    -- Validity
    valid_until DATE,
    expires_at TIMESTAMP,
    
    -- Terms
    payment_terms TEXT,
    delivery_terms TEXT,
    notes TEXT,
    
    -- Approval
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    
    -- Conversion
    converted_to_order_id UUID REFERENCES orders(id),
    converted_at TIMESTAMP,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id),
    updated_by UUID REFERENCES users(id)
);
```

### 5.2. Quote Items

```sql
CREATE TABLE quote_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quote_id UUID REFERENCES quotes(id) NOT NULL,
    product_id UUID REFERENCES products(id) NOT NULL,
    
    quantity DECIMAL(10,2) NOT NULL DEFAULT 1,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) NOT NULL,
    
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 6. SALES ACTIVITIES

### 6.1. Activities Table

```sql
CREATE TABLE sales_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type activity_type_enum NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT,

    -- Relationships
    lead_id UUID REFERENCES leads(id),
    opportunity_id UUID REFERENCES opportunities(id),
    customer_id UUID REFERENCES customers(id),
    contact_id UUID REFERENCES contacts(id),

    -- Assignment
    assigned_to UUID REFERENCES users(id) NOT NULL,

    -- Scheduling
    scheduled_at TIMESTAMP,
    completed_at TIMESTAMP,
    duration_minutes INTEGER,

    -- Status
    status activity_status_enum DEFAULT 'planned',
    priority priority_enum DEFAULT 'medium',

    -- Results
    outcome activity_outcome_enum,
    next_action TEXT,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);
```

### 6.2. Activity Types

```sql
CREATE TABLE activity_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(50),
    color VARCHAR(7),
    default_duration INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 7. COMMISSION VÀ INCENTIVES

### 7.1. Commission Plans

```sql
CREATE TABLE commission_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    plan_type commission_type_enum NOT NULL,

    -- Rates
    base_rate DECIMAL(5,2),
    tier_rates JSONB,

    -- Conditions
    minimum_amount DECIMAL(15,2),
    maximum_amount DECIMAL(15,2),

    -- Period
    effective_from DATE NOT NULL,
    effective_to DATE,

    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 7.2. Commission Calculations

```sql
CREATE TABLE commission_calculations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) NOT NULL,
    opportunity_id UUID REFERENCES opportunities(id),
    order_id UUID REFERENCES orders(id),

    commission_plan_id UUID REFERENCES commission_plans(id) NOT NULL,

    -- Calculation
    base_amount DECIMAL(15,2) NOT NULL,
    commission_rate DECIMAL(5,2) NOT NULL,
    commission_amount DECIMAL(15,2) NOT NULL,

    -- Period
    calculation_period DATE NOT NULL,

    -- Status
    status commission_status_enum DEFAULT 'calculated',
    paid_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 8. SALES ANALYTICS

### 8.1. Sales Metrics

```sql
CREATE TABLE sales_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    team_id UUID REFERENCES teams(id),

    -- Period
    metric_date DATE NOT NULL,
    metric_period period_enum NOT NULL,

    -- Lead Metrics
    leads_generated INTEGER DEFAULT 0,
    leads_qualified INTEGER DEFAULT 0,
    leads_converted INTEGER DEFAULT 0,

    -- Opportunity Metrics
    opportunities_created INTEGER DEFAULT 0,
    opportunities_won INTEGER DEFAULT 0,
    opportunities_lost INTEGER DEFAULT 0,

    -- Revenue Metrics
    revenue_target DECIMAL(15,2),
    revenue_actual DECIMAL(15,2),
    revenue_pipeline DECIMAL(15,2),

    -- Activity Metrics
    calls_made INTEGER DEFAULT 0,
    emails_sent INTEGER DEFAULT 0,
    meetings_held INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 8.2. Sales Forecasts

```sql
CREATE TABLE sales_forecasts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) NOT NULL,

    -- Period
    forecast_period DATE NOT NULL,
    forecast_type forecast_type_enum NOT NULL,

    -- Forecast Data
    pipeline_amount DECIMAL(15,2),
    best_case DECIMAL(15,2),
    most_likely DECIMAL(15,2),
    worst_case DECIMAL(15,2),

    -- Confidence
    confidence_level DECIMAL(5,2),

    -- Submission
    submitted_at TIMESTAMP,
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 2.0.0
**Tác giả**: NextFlow CRM-AI Schema Team
