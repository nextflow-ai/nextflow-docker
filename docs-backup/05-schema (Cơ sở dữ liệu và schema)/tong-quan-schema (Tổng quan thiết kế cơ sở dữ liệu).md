# TỔNG QUAN SCHEMA NextFlow CRM-AI v2.0.0

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Quy ước schema](#2-quy-ước-schema)
3. [Các nhóm schema chính](#3-các-nhóm-schema-chính)
4. [Mở rộng và tùy chỉnh schema](#4-mở-rộng-và-tùy-chỉnh-schema)
5. [Kết luận](#5-kết-luận)
6. [Tài liệu tham khảo](#6-tài-liệu-tham-khảo)

## 1. GIỚI THIỆU

Tài liệu này cung cấp tổng quan về cấu trúc schema trong hệ thống NextFlow CRM-AI. Schema là bản thiết kế cơ sở dữ liệu, định nghĩa cấu trúc và mối quan hệ giữa các bảng dữ liệu trong hệ thống NextFlow CRM-AI.

### 1.1. Mục đích

- Cung cấp cái nhìn tổng quan về cấu trúc cơ sở dữ liệu của NextFlow CRM-AI
- Giới thiệu các quy ước đặt tên và thiết kế schema
- Mô tả các nhóm schema chính và mục đích của chúng
- Hướng dẫn cách mở rộng và tùy chỉnh schema

### 1.2. Phạm vi

Tài liệu này bao gồm:

- Quy ước đặt tên và thiết kế schema
- Tổng quan về các nhóm schema chính
- Mối quan hệ giữa các schema
- Hướng dẫn mở rộng và tùy chỉnh schema

## 2. QUY ƯỚC SCHEMA

### 2.1. Quy ước đặt tên

NextFlow CRM-AI tuân theo các quy ước đặt tên sau để đảm bảo tính nhất quán và dễ đọc:

#### 2.1.1. Bảng

- Tên bảng sử dụng dạng số ít (singular)
- Sử dụng snake_case (chữ thường, phân cách bằng dấu gạch dưới)
- Tên bảng nên mô tả rõ ràng nội dung của bảng
- Bảng quan hệ nhiều-nhiều sử dụng tên của hai bảng liên quan, phân cách bằng dấu gạch dưới

Ví dụ:
```
user
organization
product
user_role
```

#### 2.1.2. Cột

- Sử dụng snake_case (chữ thường, phân cách bằng dấu gạch dưới)
- Khóa chính luôn là `id`
- Khóa ngoại sử dụng tên bảng tham chiếu + `_id`
- Cột thời gian tạo là `created_at`
- Cột thời gian cập nhật là `updated_at`
- Cột thời gian xóa (soft delete) là `deleted_at`
- Cột trạng thái là `status`
- Cột tenant là `tenant_id`

Ví dụ:
```
id
user_id
organization_id
created_at
updated_at
```

#### 2.1.3. Chỉ mục (Index)

- Chỉ mục chính: `pk_[tên bảng]`
- Chỉ mục ngoại: `fk_[tên bảng]_[tên bảng tham chiếu]`
- Chỉ mục thông thường: `idx_[tên bảng]_[tên cột]`
- Chỉ mục độc nhất: `uq_[tên bảng]_[tên cột]`

Ví dụ:
```
pk_user
fk_user_organization
idx_user_email
uq_user_email
```

### 2.2. Kiểu dữ liệu

NextFlow CRM-AI sử dụng các kiểu dữ liệu sau:

- **UUID**: Khóa chính và khóa ngoại
- **VARCHAR**: Chuỗi ký tự có độ dài giới hạn
- **TEXT**: Chuỗi ký tự không giới hạn độ dài
- **INTEGER**: Số nguyên
- **BIGINT**: Số nguyên lớn
- **DECIMAL**: Số thập phân
- **BOOLEAN**: Giá trị true/false
- **TIMESTAMP**: Thời gian
- **DATE**: Ngày
- **JSONB**: Dữ liệu JSON
- **ENUM**: Giá trị từ một tập hợp cố định

### 2.3. Quy ước thiết kế

#### 2.3.1. Khóa chính

- Mọi bảng đều có khóa chính là `id` kiểu UUID
- Không sử dụng khóa chính tự tăng (auto-increment)
- Khóa chính được tạo bằng UUID v4

#### 2.3.2. Khóa ngoại

- Khóa ngoại luôn tham chiếu đến khóa chính của bảng khác
- Tên khóa ngoại là tên bảng tham chiếu + `_id`
- Khóa ngoại có chỉ mục để tối ưu hiệu suất truy vấn

#### 2.3.3. Soft Delete

- Sử dụng cột `deleted_at` để đánh dấu bản ghi đã bị xóa
- Bản ghi bị xóa sẽ không hiển thị trong các truy vấn thông thường
- Có thể khôi phục bản ghi bị xóa bằng cách đặt `deleted_at` thành NULL

#### 2.3.4. Timestamps

- Mọi bảng đều có cột `created_at` và `updated_at`
- `created_at` được tự động đặt khi tạo bản ghi
- `updated_at` được tự động cập nhật khi sửa bản ghi

#### 2.3.5. Multi-tenant

- Mọi bảng đều có cột `tenant_id` để phân biệt dữ liệu giữa các tenant
- Cột `tenant_id` có chỉ mục để tối ưu hiệu suất truy vấn
- Truy vấn luôn bao gồm điều kiện `tenant_id` để đảm bảo cách ly dữ liệu

## 3. CÁC NHÓM SCHEMA CHÍNH

NextFlow CRM-AI chia schema thành các nhóm chính sau:

### 3.1. Schema hệ thống

Schema hệ thống quản lý các thông tin cơ bản của hệ thống, bao gồm:

- **User và Authentication**: Quản lý người dùng và xác thực
- **Organization và Team**: Quản lý tổ chức và nhóm
- **Role và Permission**: Quản lý vai trò và quyền hạn
- **Subscription và Billing**: Quản lý đăng ký và thanh toán
- **Cấu hình**: Quản lý cấu hình hệ thống

Chi tiết về schema hệ thống có thể được tìm thấy trong thư mục [he-thong](./he-thong/).

### 3.2. Schema tính năng

Schema tính năng quản lý các tính năng nghiệp vụ của hệ thống, bao gồm:

- **Khách hàng**: Quản lý thông tin khách hàng
- **Sản phẩm**: Quản lý thông tin sản phẩm
- **Đơn hàng**: Quản lý đơn hàng và giao dịch
- **Marketing**: Quản lý chiến dịch marketing
- **Bán hàng**: Quản lý quy trình bán hàng
- **Hỗ trợ khách hàng**: Quản lý ticket và hỗ trợ
- **Tích hợp đa nền tảng**: Quản lý tích hợp với các nền tảng khác
- **AI Integration**: Quản lý tích hợp AI

Chi tiết về schema tính năng có thể được tìm thấy trong thư mục [tinh-nang](./tinh-nang/).

### 3.3. Schema tích hợp

Schema tích hợp quản lý việc tích hợp với các hệ thống bên ngoài, bao gồm:

- **API**: Quản lý API và webhook
- **Database**: Quản lý kết nối database
- **Marketplace**: Quản lý tích hợp với các marketplace
- **Webhook**: Quản lý webhook

Chi tiết về schema tích hợp có thể được tìm thấy trong thư mục [tich-hop](./tich-hop/).

### 3.4. Schema bảo mật

Schema bảo mật quản lý các thông tin liên quan đến bảo mật, bao gồm:

- **Security**: Quản lý bảo mật và audit log

Chi tiết về schema bảo mật có thể được tìm thấy trong thư mục [bao-mat](./bao-mat/).

### 3.5. Schema kiến trúc

Schema kiến trúc quản lý các thông tin liên quan đến kiến trúc hệ thống, bao gồm:

- **System Architecture**: Quản lý kiến trúc hệ thống

Chi tiết về schema kiến trúc có thể được tìm thấy trong thư mục [kien-truc](./kien-truc/).

## 4. MỞ RỘNG VÀ TÙY CHỈNH SCHEMA

### 4.1. Nguyên tắc mở rộng

Khi mở rộng schema, cần tuân thủ các nguyên tắc sau:

- **Tương thích ngược**: Đảm bảo các thay đổi không ảnh hưởng đến dữ liệu hiện có
- **Tối thiểu hóa thay đổi**: Chỉ thêm cột mới, không xóa hoặc đổi tên cột hiện có
- **Sử dụng migration**: Mọi thay đổi schema phải được thực hiện thông qua migration
- **Kiểm thử kỹ lưỡng**: Kiểm thử kỹ lưỡng trước khi triển khai thay đổi schema

### 4.2. Custom Fields

NextFlow CRM-AI hỗ trợ custom fields thông qua cột `custom_fields` kiểu JSONB:

- Mỗi bảng chính đều có cột `custom_fields` để lưu trữ các trường tùy chỉnh
- Custom fields được lưu dưới dạng JSON với cấu trúc `{"field_name": "value"}`
- Custom fields có thể được tìm kiếm và lọc thông qua các toán tử JSONB

Ví dụ:
```sql
-- Thêm custom field
UPDATE customer
SET custom_fields = jsonb_set(custom_fields, '{favorite_color}', '"blue"')
WHERE id = '123e4567-e89b-12d3-a456-426614174000';

-- Tìm kiếm theo custom field
SELECT * FROM customer
WHERE custom_fields->>'favorite_color' = 'blue';
```

### 4.3. Tenant-specific Schema

NextFlow CRM-AI hỗ trợ schema riêng cho từng tenant:

- Mỗi tenant có thể có schema riêng với các bảng và cột tùy chỉnh
- Schema riêng được lưu trong schema PostgreSQL riêng biệt
- Truy cập schema riêng thông qua tenant context

Ví dụ:
```sql
-- Chuyển đến schema của tenant
SET search_path TO tenant_123;

-- Truy vấn bảng trong schema của tenant
SELECT * FROM customer;
```

### 4.4. Migration

Mọi thay đổi schema phải được thực hiện thông qua migration:

- Migration được viết bằng TypeORM hoặc SQL thuần
- Migration bao gồm cả up (áp dụng thay đổi) và down (hoàn tác thay đổi)
- Migration được chạy tự động khi triển khai phiên bản mới

Ví dụ:
```typescript
// Migration TypeORM
import { MigrationInterface, QueryRunner } from "typeorm";

export class AddPhoneNumberToCustomer1620000000000 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`
            ALTER TABLE customer
            ADD COLUMN phone_number VARCHAR(20)
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`
            ALTER TABLE customer
            DROP COLUMN phone_number
        `);
    }
}
```

## 5. KẾT LUẬN

Schema là nền tảng của hệ thống NextFlow CRM-AI, định nghĩa cấu trúc và mối quan hệ giữa các bảng dữ liệu. Việc tuân thủ các quy ước và nguyên tắc thiết kế schema giúp đảm bảo tính nhất quán, dễ bảo trì và mở rộng của hệ thống.

### 5.1. Lợi ích của thiết kế schema chuẩn

- **Tính nhất quán**: Quy ước đặt tên và thiết kế thống nhất
- **Dễ bảo trì**: Cấu trúc rõ ràng, dễ hiểu và sửa đổi
- **Khả năng mở rộng**: Hỗ trợ mở rộng tính năng mà không ảnh hưởng hệ thống hiện tại
- **Hiệu suất cao**: Thiết kế tối ưu cho truy vấn và xử lý dữ liệu
- **Multi-tenant**: Hỗ trợ nhiều tenant trên cùng một hệ thống

### 5.2. Khuyến nghị sử dụng

1. **Tuân thủ quy ước**: Luôn tuân thủ quy ước đặt tên và thiết kế
2. **Sử dụng migration**: Mọi thay đổi schema phải thông qua migration
3. **Kiểm thử kỹ lưỡng**: Test migration trên môi trường staging trước
4. **Backup trước khi thay đổi**: Luôn backup dữ liệu trước khi migration
5. **Tài liệu hóa**: Ghi chép đầy đủ mọi thay đổi schema

### 5.3. Tài liệu liên quan

Để hiểu rõ hơn về schema NextFlow CRM-AI, vui lòng tham khảo:

- [Mối quan hệ Schema](./moi-quan-he-schema.md)
- [Schema Hệ thống](./he-thong/tong-quan.md)
- [Schema Tính năng](./tinh-nang/tong-quan.md)
- [Schema Tích hợp](./tich-hop/tong-quan.md)
- [Schema Bảo mật](./bao-mat/security.md)
- [Schema Kiến trúc](./kien-truc/system-architecture.md)

## 6. TÀI LIỆU THAM KHẢO

### 6.1. Tài liệu NextFlow CRM-AI
- [Kiến trúc Hệ thống](../02-kien-truc/kien-truc-tong-the.md)
- [API Documentation](../06-api/tong-quan-api.md)
- [Triển khai Database](../07-trien-khai/cai-dat.md)

### 6.2. Tài liệu kỹ thuật
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [TypeORM Documentation](https://typeorm.io/)
- [Database Design Best Practices](https://www.postgresql.org/docs/current/ddl.html)

### 6.3. Standards và conventions
- [PostgreSQL Naming Conventions](https://www.postgresql.org/docs/current/sql-syntax-lexical.html)
- [Database Design Patterns](https://martinfowler.com/articles/dblogicaldesign.html)
- [Multi-tenant Architecture Patterns](https://docs.microsoft.com/en-us/azure/sql-database/saas-tenancy-app-design-patterns)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 1.0.0
**Tác giả**: NextFlow Development Team
