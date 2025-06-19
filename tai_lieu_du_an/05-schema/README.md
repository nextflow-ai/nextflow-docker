# SCHEMA DATABASE NextFlow CRM

## TỔNG QUAN

Thư mục này chứa tài liệu chi tiết về cấu trúc schema database của NextFlow CRM. Schema database định nghĩa cấu trúc và mối quan hệ giữa các bảng dữ liệu, đảm bảo tính toàn vẹn và hiệu suất của hệ thống.

NextFlow CRM sử dụng PostgreSQL làm hệ quản trị cơ sở dữ liệu chính với kiến trúc multi-tenant, hỗ trợ nhiều tổ chức trên cùng một hệ thống.

## CẤU TRÚC THƯ MỤC

```
05-schema/
├── README.md                           # Tổng quan về schema database
├── tong-quan-schema.md                 # Tài liệu tổng quan chi tiết (276 dòng)
├── moi-quan-he-schema.md               # Mối quan hệ giữa các schema (640 dòng)
├── bao-mat/                            # Schema bảo mật
│   └── security.md                     # Bảo mật và audit log
├── he-thong/                           # Schema hệ thống
│   ├── tong-quan.md                    # Tổng quan schema hệ thống (173 dòng)
│   ├── users.md                        # Schema người dùng
│   ├── organizations.md                # Schema tổ chức
│   ├── user-authentication.md          # Schema xác thực
│   ├── organization-team.md            # Schema tổ chức và team
│   ├── role-permission.md              # Schema vai trò và quyền
│   ├── subscription-billing.md         # Schema đăng ký và thanh toán
│   └── cau-hinh.md                     # Schema cấu hình
├── kien-truc/                          # Schema kiến trúc
│   └── system-architecture.md          # Kiến trúc hệ thống
├── tich-hop/                           # Schema tích hợp
│   ├── tong-quan.md                    # Tổng quan tích hợp
│   ├── api.md                          # Schema API
│   ├── database.md                     # Schema database
│   ├── marketplace.md                  # Schema marketplace
│   └── webhook.md                      # Schema webhook
└── tinh-nang/                          # Schema tính năng
    ├── tong-quan.md                    # Tổng quan tính năng
    ├── khach-hang_phan1.md             # Schema khách hàng
    ├── san-pham_phan1.md               # Schema sản phẩm
    ├── don-hang_phan1.md               # Schema đơn hàng
    ├── ban-hang_phan1.md               # Schema bán hàng
    ├── marketing_phan1.md              # Schema marketing
    ├── ai-integration.md               # Schema tích hợp AI
    ├── chatbot-nlp.md                  # Schema chatbot và NLP
    ├── bao-cao-phan-tich.md            # Schema báo cáo phân tích
    ├── ho-tro-khach-hang.md            # Schema hỗ trợ khách hàng
    ├── quan-ly-du-an.md               # Schema quản lý dự án
    ├── nhan-su.md                      # Schema nhân sự
    ├── tai-chinh.md                    # Schema tài chính
    ├── tong-dai.md                     # Schema tổng đài
    ├── landing-page-form.md            # Schema landing page và form
    ├── quan-ly-noi-dung.md             # Schema quản lý nội dung
    ├── quan-ly-tai-lieu.md             # Schema quản lý tài liệu
    ├── tich-hop-da-nen-tang.md         # Schema tích hợp đa nền tảng
    ├── cham-cong-nghi-phep.md          # Schema chấm công nghỉ phép
    ├── dao-tao-phat-trien.md           # Schema đào tạo phát triển
    ├── danh-gia-hieu-suat.md           # Schema đánh giá hiệu suất
    └── kpi-muc-tieu.md                 # Schema KPI và mục tiêu
```

## CÁC NHÓM SCHEMA CHÍNH

### 1. Schema Hệ thống
**Mô tả**: Quản lý các thông tin cơ bản của hệ thống  
**Bao gồm**: Users, Organizations, Roles, Permissions, Subscriptions, Settings  
**Tài liệu**: [Schema Hệ thống](./he-thong/tong-quan.md)

### 2. Schema Tính năng
**Mô tả**: Quản lý các tính năng nghiệp vụ của NextFlow CRM  
**Bao gồm**: Customers, Products, Orders, Sales, Marketing, AI Integration  
**Tài liệu**: [Schema Tính năng](./tinh-nang/tong-quan.md)

### 3. Schema Tích hợp
**Mô tả**: Quản lý việc tích hợp với các hệ thống bên ngoài  
**Bao gồm**: APIs, Webhooks, Marketplace, Database connections  
**Tài liệu**: [Schema Tích hợp](./tich-hop/tong-quan.md)

### 4. Schema Bảo mật
**Mô tả**: Quản lý bảo mật và audit log  
**Bao gồm**: Security policies, Audit trails, Access logs  
**Tài liệu**: [Schema Bảo mật](./bao-mat/security.md)

### 5. Schema Kiến trúc
**Mô tả**: Quản lý thông tin kiến trúc hệ thống  
**Bao gồm**: System architecture, Infrastructure metadata  
**Tài liệu**: [Schema Kiến trúc](./kien-truc/system-architecture.md)

## ĐỘC ĐIỂM SCHEMA NextFlow CRM

### Multi-tenant Architecture
- **Tenant Isolation**: Mỗi tenant có dữ liệu riêng biệt
- **Shared Resources**: Một số tài nguyên được chia sẻ giữa các tenant
- **Scalable Design**: Thiết kế cho phép mở rộng theo chiều ngang

### Quy ước Đặt tên
- **Tables**: snake_case, singular form
- **Columns**: snake_case, descriptive names
- **Primary Keys**: `id` (UUID)
- **Foreign Keys**: `[table_name]_id`
- **Timestamps**: `created_at`, `updated_at`, `deleted_at`

### Kiểu Dữ liệu
- **UUID**: Primary keys và foreign keys
- **JSONB**: Flexible data storage
- **ENUM**: Predefined value sets
- **TIMESTAMP**: Date and time with timezone

## HƯỚNG DẪN SỬ DỤNG

### 1. Đọc Tài liệu Tổng quan
Bắt đầu với [Tổng quan Schema](./tong-quan-schema.md) để hiểu:
- Quy ước đặt tên và thiết kế
- Các nhóm schema chính
- Nguyên tắc mở rộng schema

### 2. Tìm hiểu Mối quan hệ
Đọc [Mối quan hệ Schema](./moi-quan-he-schema.md) để:
- Hiểu mối quan hệ giữa các bảng
- Nắm được luồng dữ liệu
- Thiết kế truy vấn hiệu quả

### 3. Khám phá Schema theo Nhóm
Tham khảo tài liệu chi tiết theo nhóm:
- **Hệ thống**: [he-thong/](./he-thong/)
- **Tính năng**: [tinh-nang/](./tinh-nang/)
- **Tích hợp**: [tich-hop/](./tich-hop/)
- **Bảo mật**: [bao-mat/](./bao-mat/)
- **Kiến trúc**: [kien-truc/](./kien-truc/)

### 4. Thiết kế và Mở rộng
Khi cần mở rộng schema:
- Tuân thủ quy ước đặt tên
- Sử dụng migration scripts
- Đảm bảo tương thích ngược
- Kiểm thử kỹ lưỡng

## YÊU CẦU KỸ THUẬT

### Database Engine
- **PostgreSQL**: 14.0 trở lên
- **Extensions**: UUID-OSSP, JSONB operators
- **Collation**: UTF-8 support

### Migration Tools
- **TypeORM**: Primary migration tool
- **SQL Scripts**: For complex migrations
- **Version Control**: All migrations tracked

### Performance Considerations
- **Indexing**: Proper indexes on foreign keys
- **Partitioning**: For large tables
- **Connection Pooling**: Efficient connection management

## BEST PRACTICES

### Schema Design
1. **Normalization**: Reduce data redundancy
2. **Referential Integrity**: Use foreign key constraints
3. **Soft Deletes**: Use `deleted_at` for data retention
4. **Audit Trails**: Track all data changes

### Migration Management
1. **Incremental Changes**: Small, focused migrations
2. **Rollback Plans**: Always include down migrations
3. **Testing**: Test migrations on staging environment
4. **Documentation**: Document all schema changes

### Security
1. **Access Control**: Role-based database access
2. **Data Encryption**: Encrypt sensitive data
3. **Audit Logging**: Log all database operations
4. **Backup Strategy**: Regular automated backups

## LIÊN KẾT THAM KHẢO

### Tài liệu liên quan
- [Kiến trúc Hệ thống](../02-kien-truc/kien-truc-tong-the.md)
- [API Documentation](../06-api/tong-quan-api.md)
- [Triển khai Database](../07-trien-khai/cai-dat.md)

### External Resources
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [TypeORM Documentation](https://typeorm.io/)
- [Database Design Best Practices](https://www.postgresql.org/docs/current/ddl.html)

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 1.0.0  
**Tác giả**: NextFlow Development Team
