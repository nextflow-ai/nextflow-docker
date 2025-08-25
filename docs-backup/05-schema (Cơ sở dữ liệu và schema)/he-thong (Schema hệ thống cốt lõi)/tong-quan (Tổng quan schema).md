# TỔNG QUAN SCHEMA HỆ THỐNG

## 1. GIỚI THIỆU

Tài liệu này cung cấp tổng quan về schema hệ thống trong NextFlow CRM-AI. Schema hệ thống quản lý các thông tin cơ bản của hệ thống, bao gồm người dùng, tổ chức, vai trò, quyền hạn, đăng ký và cấu hình.

### 1.1. Mục đích

- Cung cấp cái nhìn tổng quan về cấu trúc schema hệ thống
- Mô tả các bảng chính và mối quan hệ giữa chúng
- Giải thích cách sử dụng schema hệ thống trong kiến trúc multi-tenant

### 1.2. Phạm vi

Tài liệu này bao gồm:

- Tổng quan về các bảng trong schema hệ thống
- Mối quan hệ giữa các bảng
- Cách sử dụng schema hệ thống trong kiến trúc multi-tenant

## 2. CÁC BẢNG CHÍNH

### 2.1. User và Authentication

Schema User và Authentication quản lý thông tin người dùng và xác thực, bao gồm các bảng chính:

- **user**: Lưu trữ thông tin người dùng
- **user_profile**: Lưu trữ thông tin hồ sơ người dùng
- **user_preference**: Lưu trữ tùy chọn của người dùng
- **user_session**: Lưu trữ phiên đăng nhập của người dùng
- **user_token**: Lưu trữ token xác thực của người dùng
- **user_activity**: Lưu trữ hoạt động của người dùng
- **user_device**: Lưu trữ thông tin thiết bị của người dùng

Chi tiết về schema User và Authentication có thể được tìm thấy trong tài liệu [User và Authentication](./user-authentication.md).

### 2.2. Organization và Team

Schema Organization và Team quản lý thông tin tổ chức và nhóm, bao gồm các bảng chính:

- **organization**: Lưu trữ thông tin tổ chức
- **organization_profile**: Lưu trữ thông tin hồ sơ tổ chức
- **organization_setting**: Lưu trữ cài đặt của tổ chức
- **team**: Lưu trữ thông tin nhóm
- **team_member**: Lưu trữ thành viên của nhóm
- **team_role**: Lưu trữ vai trò trong nhóm
- **department**: Lưu trữ thông tin phòng ban
- **branch**: Lưu trữ thông tin chi nhánh

Chi tiết về schema Organization và Team có thể được tìm thấy trong tài liệu [Organization và Team](./organization-team.md).

### 2.3. Role và Permission

Schema Role và Permission quản lý vai trò và quyền hạn, bao gồm các bảng chính:

- **role**: Lưu trữ thông tin vai trò
- **permission**: Lưu trữ thông tin quyền hạn
- **role_permission**: Lưu trữ quyền hạn của vai trò
- **user_role**: Lưu trữ vai trò của người dùng
- **resource**: Lưu trữ thông tin tài nguyên
- **action**: Lưu trữ thông tin hành động
- **policy**: Lưu trữ chính sách bảo mật

Chi tiết về schema Role và Permission có thể được tìm thấy trong tài liệu [Role và Permission](./role-permission.md).

### 2.4. Subscription và Billing

Schema Subscription và Billing quản lý đăng ký và thanh toán, bao gồm các bảng chính:

- **plan**: Lưu trữ thông tin gói dịch vụ
- **plan_feature**: Lưu trữ tính năng của gói dịch vụ
- **subscription**: Lưu trữ thông tin đăng ký
- **subscription_item**: Lưu trữ các mục trong đăng ký
- **invoice**: Lưu trữ thông tin hóa đơn
- **invoice_item**: Lưu trữ các mục trong hóa đơn
- **payment**: Lưu trữ thông tin thanh toán
- **payment_method**: Lưu trữ phương thức thanh toán
- **coupon**: Lưu trữ thông tin mã giảm giá
- **tax**: Lưu trữ thông tin thuế

Chi tiết về schema Subscription và Billing có thể được tìm thấy trong tài liệu [Subscription và Billing](./subscription-billing.md).

### 2.5. Cấu hình

Schema Cấu hình quản lý cài đặt và cấu hình hệ thống, bao gồm các bảng chính:

- **setting**: Lưu trữ cài đặt hệ thống
- **setting_group**: Lưu trữ nhóm cài đặt
- **setting_value**: Lưu trữ giá trị cài đặt
- **language**: Lưu trữ thông tin ngôn ngữ
- **translation**: Lưu trữ bản dịch
- **currency**: Lưu trữ thông tin tiền tệ
- **country**: Lưu trữ thông tin quốc gia
- **region**: Lưu trữ thông tin vùng miền
- **timezone**: Lưu trữ thông tin múi giờ
- **template**: Lưu trữ mẫu (email, SMS, v.v.)

Chi tiết về schema Cấu hình có thể được tìm thấy trong tài liệu [Cấu hình](./cau-hinh.md).

## 3. MỐI QUAN HỆ GIỮA CÁC BẢNG

### 3.1. User và Organization

- Mỗi người dùng (user) thuộc về một hoặc nhiều tổ chức (organization) thông qua bảng user_organization
- Mỗi tổ chức có một người dùng là chủ sở hữu (owner)
- Mỗi người dùng có thể là thành viên của nhiều nhóm (team) thông qua bảng team_member

### 3.2. Role và Permission

- Mỗi vai trò (role) có nhiều quyền hạn (permission) thông qua bảng role_permission
- Mỗi người dùng có một hoặc nhiều vai trò thông qua bảng user_role
- Quyền hạn được định nghĩa dựa trên tài nguyên (resource) và hành động (action)

### 3.3. Subscription và Organization

- Mỗi tổ chức có một đăng ký (subscription) active
- Mỗi đăng ký liên kết với một gói dịch vụ (plan)
- Mỗi gói dịch vụ có nhiều tính năng (feature) thông qua bảng plan_feature

### 3.4. Setting và Organization

- Mỗi tổ chức có nhiều cài đặt riêng thông qua bảng organization_setting
- Cài đặt hệ thống (setting) được áp dụng cho tất cả tổ chức
- Mỗi người dùng có thể có cài đặt riêng thông qua bảng user_preference

## 4. MULTI-TENANT TRONG SCHEMA HỆ THỐNG

### 4.1. Tenant Isolation

Schema hệ thống được thiết kế để hỗ trợ kiến trúc multi-tenant:

- Mỗi tenant được đại diện bởi một tổ chức (organization)
- Mỗi bảng (trừ các bảng hệ thống chung) có cột tenant_id để phân biệt dữ liệu giữa các tenant
- Truy vấn luôn bao gồm điều kiện tenant_id để đảm bảo cách ly dữ liệu

### 4.2. Shared Tables

Một số bảng được chia sẻ giữa các tenant:

- **plan**: Các gói dịch vụ được chia sẻ giữa các tenant
- **currency**: Thông tin tiền tệ được chia sẻ
- **country**: Thông tin quốc gia được chia sẻ
- **language**: Thông tin ngôn ngữ được chia sẻ

### 4.3. Tenant-specific Tables

Hầu hết các bảng là riêng biệt cho từng tenant:

- **user**: Người dùng thuộc về một tenant cụ thể
- **team**: Nhóm thuộc về một tenant cụ thể
- **role**: Vai trò thuộc về một tenant cụ thể
- **subscription**: Đăng ký thuộc về một tenant cụ thể

### 4.4. Cross-tenant Access

Trong một số trường hợp, cần truy cập dữ liệu giữa các tenant:

- **Super Admin**: Quản trị viên hệ thống có thể truy cập dữ liệu của tất cả tenant
- **Shared Resources**: Một số tài nguyên có thể được chia sẻ giữa các tenant
- **Multi-organization Users**: Người dùng có thể thuộc về nhiều tổ chức (tenant)

## 5. TỔNG KẾT

Schema hệ thống là nền tảng của NextFlow CRM-AI, quản lý các thông tin cơ bản như người dùng, tổ chức, vai trò, quyền hạn, đăng ký và cấu hình. Schema được thiết kế để hỗ trợ kiến trúc multi-tenant, đảm bảo cách ly dữ liệu giữa các tenant.

Để hiểu rõ hơn về từng phần của schema hệ thống, vui lòng tham khảo các tài liệu chi tiết:

- [User và Authentication](./user-authentication.md)
- [Organization và Team](./organization-team.md)
- [Role và Permission](./role-permission.md)
- [Subscription và Billing](./subscription-billing.md)
- [Cấu hình](./cau-hinh.md)
