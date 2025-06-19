# SCHEMA MARKETING NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Campaign Management](#2-campaign-management)
3. [Email Marketing](#3-email-marketing)
4. [Lead Generation](#4-lead-generation)
5. [Marketing Automation](#5-marketing-automation)
6. [Analytics và Tracking](#6-analytics-và-tracking)

## 1. GIỚI THIỆU

Schema Marketing của NextFlow CRM định nghĩa cấu trúc dữ liệu cho quản lý các hoạt động marketing, chiến dịch, email marketing và automation.

### 1.1. Mối quan hệ chính

```
Campaigns → Email Lists → Automation
    ↓           ↓            ↓
Leads → Tracking → Analytics
```

## 2. CAMPAIGN MANAGEMENT

### 2.1. Marketing Campaigns

```sql
CREATE TABLE marketing_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Campaign Details
    type campaign_type_enum NOT NULL,
    status campaign_status_enum DEFAULT 'draft',
    
    -- Targeting
    target_audience JSONB,
    segment_ids UUID[],
    
    -- Budget
    budget DECIMAL(15,2),
    actual_cost DECIMAL(15,2) DEFAULT 0,
    
    -- Timeline
    start_date DATE,
    end_date DATE,
    
    -- Goals
    primary_goal campaign_goal_enum,
    target_leads INTEGER,
    target_revenue DECIMAL(15,2),
    
    -- Assignment
    campaign_manager_id UUID REFERENCES users(id),
    
    -- Metadata
    tags TEXT[],
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);
```

### 2.2. Campaign Channels

```sql
CREATE TABLE campaign_channels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES marketing_campaigns(id) NOT NULL,
    
    channel_type channel_type_enum NOT NULL,
    channel_name VARCHAR(100),
    
    -- Budget Allocation
    allocated_budget DECIMAL(15,2),
    actual_spend DECIMAL(15,2) DEFAULT 0,
    
    -- Performance
    impressions INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    conversions INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 3. EMAIL MARKETING

### 3.1. Email Templates

```sql
CREATE TABLE email_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Template Content
    subject VARCHAR(255) NOT NULL,
    html_content TEXT NOT NULL,
    text_content TEXT,
    
    -- Template Type
    type template_type_enum NOT NULL,
    category VARCHAR(100),
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Metadata
    thumbnail_url VARCHAR(500),
    tags TEXT[],
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);
```

### 3.2. Email Campaigns

```sql
CREATE TABLE email_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    marketing_campaign_id UUID REFERENCES marketing_campaigns(id),
    template_id UUID REFERENCES email_templates(id) NOT NULL,
    
    -- Campaign Details
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    
    -- Content
    html_content TEXT NOT NULL,
    text_content TEXT,
    
    -- Targeting
    recipient_list_id UUID REFERENCES email_lists(id),
    recipient_count INTEGER DEFAULT 0,
    
    -- Scheduling
    scheduled_at TIMESTAMP,
    sent_at TIMESTAMP,
    
    -- Status
    status email_campaign_status_enum DEFAULT 'draft',
    
    -- Performance
    delivered_count INTEGER DEFAULT 0,
    opened_count INTEGER DEFAULT 0,
    clicked_count INTEGER DEFAULT 0,
    bounced_count INTEGER DEFAULT 0,
    unsubscribed_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);
```

### 3.3. Email Lists

```sql
CREATE TABLE email_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- List Details
    type list_type_enum DEFAULT 'static',
    criteria JSONB,
    
    -- Counts
    subscriber_count INTEGER DEFAULT 0,
    active_subscriber_count INTEGER DEFAULT 0,
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);
```

### 3.4. Email Subscribers

```sql
CREATE TABLE email_subscribers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    customer_id UUID REFERENCES customers(id),
    
    -- Subscriber Info
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    
    -- Status
    status subscriber_status_enum DEFAULT 'subscribed',
    
    -- Preferences
    email_frequency frequency_enum DEFAULT 'weekly',
    preferred_categories TEXT[],
    
    -- Tracking
    subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unsubscribed_at TIMESTAMP,
    last_activity_at TIMESTAMP,
    
    -- Source
    source VARCHAR(100),
    utm_source VARCHAR(100),
    utm_campaign VARCHAR(100),
    
    UNIQUE(email)
);
```

## 4. LEAD GENERATION

### 4.1. Landing Pages

```sql
CREATE TABLE landing_pages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES marketing_campaigns(id),
    
    -- Page Details
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Content
    html_content TEXT NOT NULL,
    css_content TEXT,
    js_content TEXT,
    
    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,
    meta_keywords TEXT,
    
    -- Status
    status page_status_enum DEFAULT 'draft',
    is_published BOOLEAN DEFAULT false,
    
    -- Performance
    views INTEGER DEFAULT 0,
    unique_views INTEGER DEFAULT 0,
    conversions INTEGER DEFAULT 0,
    conversion_rate DECIMAL(5,2) DEFAULT 0,
    
    -- Publishing
    published_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);
```

### 4.2. Forms

```sql
CREATE TABLE marketing_forms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    landing_page_id UUID REFERENCES landing_pages(id),
    
    -- Form Details
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Form Configuration
    fields JSONB NOT NULL,
    validation_rules JSONB,
    
    -- Behavior
    redirect_url VARCHAR(500),
    thank_you_message TEXT,
    
    -- Integration
    webhook_url VARCHAR(500),
    email_notifications TEXT[],
    
    -- Status
    is_active BOOLEAN DEFAULT true,
    
    -- Performance
    submissions INTEGER DEFAULT 0,
    conversion_rate DECIMAL(5,2) DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4.3. Form Submissions

```sql
CREATE TABLE form_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    form_id UUID REFERENCES marketing_forms(id) NOT NULL,
    
    -- Submission Data
    form_data JSONB NOT NULL,
    
    -- Lead Information
    lead_id UUID REFERENCES leads(id),
    customer_id UUID REFERENCES customers(id),
    
    -- Tracking
    ip_address INET,
    user_agent TEXT,
    referrer VARCHAR(500),
    
    -- UTM Parameters
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100),
    utm_content VARCHAR(255),
    utm_term VARCHAR(100),
    
    -- Processing
    processed BOOLEAN DEFAULT false,
    processed_at TIMESTAMP,
    
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 5. MARKETING AUTOMATION

### 5.1. Automation Workflows

```sql
CREATE TABLE marketing_workflows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Workflow Configuration
    trigger_type trigger_type_enum NOT NULL,
    trigger_conditions JSONB NOT NULL,
    
    -- Workflow Steps
    steps JSONB NOT NULL,
    
    -- Status
    status workflow_status_enum DEFAULT 'draft',
    is_active BOOLEAN DEFAULT false,
    
    -- Performance
    total_entries INTEGER DEFAULT 0,
    completed_entries INTEGER DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by UUID REFERENCES users(id)
);
```

### 5.2. Workflow Executions

```sql
CREATE TABLE workflow_executions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID REFERENCES marketing_workflows(id) NOT NULL,
    
    -- Target
    customer_id UUID REFERENCES customers(id),
    lead_id UUID REFERENCES leads(id),
    
    -- Execution Details
    current_step INTEGER DEFAULT 0,
    status execution_status_enum DEFAULT 'running',
    
    -- Timing
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    next_action_at TIMESTAMP,
    
    -- Data
    execution_data JSONB,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 6. ANALYTICS VÀ TRACKING

### 6.1. Marketing Metrics

```sql
CREATE TABLE marketing_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID REFERENCES marketing_campaigns(id),
    
    -- Period
    metric_date DATE NOT NULL,
    metric_period period_enum NOT NULL,
    
    -- Traffic Metrics
    impressions INTEGER DEFAULT 0,
    clicks INTEGER DEFAULT 0,
    unique_clicks INTEGER DEFAULT 0,
    click_through_rate DECIMAL(5,2) DEFAULT 0,
    
    -- Conversion Metrics
    leads_generated INTEGER DEFAULT 0,
    conversions INTEGER DEFAULT 0,
    conversion_rate DECIMAL(5,2) DEFAULT 0,
    
    -- Financial Metrics
    cost DECIMAL(15,2) DEFAULT 0,
    revenue DECIMAL(15,2) DEFAULT 0,
    roi DECIMAL(8,2) DEFAULT 0,
    cost_per_lead DECIMAL(10,2) DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 6.2. Attribution Tracking

```sql
CREATE TABLE attribution_touchpoints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES customers(id),
    lead_id UUID REFERENCES leads(id),
    
    -- Touchpoint Details
    touchpoint_type touchpoint_type_enum NOT NULL,
    campaign_id UUID REFERENCES marketing_campaigns(id),
    channel VARCHAR(100),
    
    -- Attribution
    attribution_weight DECIMAL(5,4) DEFAULT 1.0,
    position_in_journey INTEGER,
    
    -- Timing
    occurred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Data
    touchpoint_data JSONB,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 2.0.0  
**Tác giả**: NextFlow CRM Schema Team
