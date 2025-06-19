# KIẾN TRÚC TỔNG THỂ NextFlow CRM

## Mục lục

1. [GIỚI THIỆU](#1-giới-thiệu)
   - [Mục đích](#11-mục-đích)
   - [Phạm vi](#12-phạm-vi)
2. [TỔNG QUAN KIẾN TRÚC](#2-tổng-quan-kiến-trúc)
   - [Mô hình kiến trúc tổng thể](#21-mô-hình-kiến-trúc-tổng-thể)
   - [Nguyên tắc kiến trúc](#22-nguyên-tắc-kiến-trúc)
3. [KIẾN TRÚC MICROSERVICES](#3-kiến-trúc-microservices)
   - [Core Services](#31-core-services)
   - [Integration Services](#32-integration-services)
   - [AI Services](#33-ai-services)
   - [Giao tiếp giữa các Services](#34-giao-tiếp-giữa-các-services)
4. [KIẾN TRÚC FRONTEND](#4-kiến-trúc-frontend)
   - [Web Application](#41-web-application)
   - [Mobile Application](#42-mobile-application)
   - [Desktop Application](#43-desktop-application)
5. [KIẾN TRÚC BACKEND](#5-kiến-trúc-backend)
   - [API Layer](#51-api-layer)
   - [Business Logic Layer](#52-business-logic-layer)
   - [Data Access Layer](#53-data-access-layer)
6. [KIẾN TRÚC CƠ SỞ DỮ LIỆU](#6-kiến-trúc-cơ-sở-dữ-liệu)
   - [Relational Database](#61-relational-database)
   - [Cache](#62-cache)
   - [Message Queue](#63-message-queue)
7. [KIẾN TRÚC TÍCH HỢP](#7-kiến-trúc-tích-hợp)
   - [API Gateway](#71-api-gateway)
   - [External Integrations](#72-external-integrations)
   - [Webhooks](#73-webhooks)
8. [KIẾN TRÚC BẢO MẬT](#8-kiến-trúc-bảo-mật)
   - [Authentication](#81-authentication)
   - [Authorization](#82-authorization)
   - [Data Security](#83-data-security)
9. [KẾT LUẬN](#9-kết-luận)

## 1. GIỚI THIỆU

Tài liệu này mô tả kiến trúc tổng thể của hệ thống NextFlow CRM, bao gồm các thành phần chính, mối quan hệ giữa chúng và các công nghệ được sử dụng. Kiến trúc được thiết kế để đáp ứng các yêu cầu về khả năng mở rộng, bảo mật, hiệu suất và tính linh hoạt của hệ thống.

### 1.1. Mục đích

- Cung cấp cái nhìn tổng quan về kiến trúc hệ thống NextFlow CRM
- Mô tả các thành phần chính và mối quan hệ giữa chúng
- Giải thích các quyết định kiến trúc và lý do đằng sau chúng
- Hướng dẫn cho việc phát triển và mở rộng hệ thống

### 1.2. Phạm vi

Tài liệu này bao gồm:
- Kiến trúc tổng thể hệ thống
- Kiến trúc microservices
- Kiến trúc frontend
- Kiến trúc backend
- Kiến trúc cơ sở dữ liệu
- Kiến trúc tích hợp
- Kiến trúc bảo mật

## 2. TỔNG QUAN KIẾN TRÚC

### 2.1. Mô hình kiến trúc tổng thể

NextFlow CRM sử dụng kiến trúc microservices kết hợp với mô hình multi-tenant để đạt được khả năng mở rộng và linh hoạt cao.

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Client Apps     |     |  API Gateway     |     |  Authentication  |
|                  |     |                  |     |  & Authorization |
|  - Web (Next.js) |     |  - Kong          |     |                  |
|  - Mobile (RN)   |<--->|  - Rate Limiting |<--->|  - JWT          |
|  - Desktop       |     |  - Routing       |     |  - OAuth2       |
|                  |     |  - Caching       |     |  - CASL         |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
                                  ^
                                  |
                                  v
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Core Services   |     |  Integration     |     |  AI Services     |
|                  |     |  Services        |     |                  |
|  - User          |     |  - Marketplace   |     |  - n8n           |
|  - Organization  |<--->|  - Payment       |<--->|  - Flowise       |
|  - Customer      |     |  - Notification  |     |  - NLP           |
|  - Product       |     |  - Webhook       |     |  - ML            |
|  - Order         |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
          ^                       ^                       ^
          |                       |                       |
          v                       v                       v
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Database        |     |  Message Queue   |     |  Cache           |
|                  |     |                  |     |                  |
|  - PostgreSQL    |     |  - RabbitMQ      |     |  - Redis         |
|  - Multi-tenant  |     |  - Event-driven  |     |  - Distributed   |
|  - Sharding      |     |  - Pub/Sub       |     |  - In-memory     |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
```

### 2.2. Nguyên tắc kiến trúc

NextFlow CRM tuân theo các nguyên tắc kiến trúc sau:

1. **Microservices**: Hệ thống được chia thành các dịch vụ nhỏ, độc lập, có thể triển khai và mở rộng riêng biệt.
2. **API-first**: Tất cả các tương tác giữa các dịch vụ đều thông qua API, tạo điều kiện cho việc tích hợp và mở rộng.
3. **Event-driven**: Sử dụng kiến trúc hướng sự kiện để giảm sự phụ thuộc giữa các dịch vụ và tăng khả năng mở rộng.
4. **Multi-tenant**: Hỗ trợ nhiều tenant trên cùng một hạ tầng, với cách ly dữ liệu và cấu hình.
5. **Cloud-native**: Thiết kế để hoạt động tối ưu trong môi trường cloud, với khả năng tự động mở rộng và tự phục hồi.
6. **Security-by-design**: Bảo mật được tích hợp từ giai đoạn thiết kế, không phải là một tính năng bổ sung.

## 3. KIẾN TRÚC MICROSERVICES

### 3.1. Core Services

Core Services là các dịch vụ cốt lõi của hệ thống, bao gồm:

- **User Service**: Quản lý người dùng, xác thực và phân quyền
- **Organization Service**: Quản lý tổ chức, nhóm và cấu trúc tổ chức
- **Customer Service**: Quản lý thông tin khách hàng và tương tác
- **Product Service**: Quản lý sản phẩm, danh mục và kho hàng
- **Order Service**: Quản lý đơn hàng, thanh toán và giao hàng
- **Marketing Service**: Quản lý chiến dịch marketing, email và automation
- **Sales Service**: Quản lý quy trình bán hàng, cơ hội và dự báo
- **Support Service**: Quản lý ticket hỗ trợ, chat và knowledge base

### 3.2. Integration Services

Integration Services là các dịch vụ tích hợp với hệ thống bên ngoài:

- **Marketplace Service**: Tích hợp với các sàn thương mại điện tử (Shopee, Lazada, TikTok Shop)
- **Payment Service**: Tích hợp với các cổng thanh toán
- **Notification Service**: Gửi thông báo qua nhiều kênh (email, SMS, push)
- **Webhook Service**: Quản lý webhook để tích hợp với các hệ thống khác

### 3.3. AI Services

AI Services là các dịch vụ liên quan đến trí tuệ nhân tạo:

- **n8n Service**: Quản lý và thực thi các workflow tự động hóa
- **Flowise Service**: Orchestration các mô hình AI và xử lý ngôn ngữ tự nhiên
- **NLP Service**: Xử lý ngôn ngữ tự nhiên, chatbot và phân tích cảm xúc
- **ML Service**: Machine learning, dự đoán và phân khúc khách hàng

### 3.4. Giao tiếp giữa các Services

Các services giao tiếp với nhau thông qua:

- **REST API**: Cho các tương tác đồng bộ
- **Message Queue**: Cho các tương tác bất đồng bộ và event-driven
- **gRPC**: Cho các tương tác yêu cầu hiệu suất cao
- **GraphQL**: Cho các truy vấn phức tạp và linh hoạt

## 4. KIẾN TRÚC FRONTEND

### 4.1. Web Application

- **Framework**: Next.js (React)
- **State Management**: Redux Toolkit
- **Styling**: TailwindCSS
- **Component Library**: Custom components dựa trên TailwindCSS
- **API Client**: React Query
- **Authentication**: JWT và OAuth2
- **Internationalization**: i18next
- **Testing**: Jest và React Testing Library

### 4.2. Mobile Application

- **Framework**: React Native
- **State Management**: Redux Toolkit
- **Navigation**: React Navigation
- **Styling**: Styled Components
- **API Client**: React Query
- **Authentication**: JWT và OAuth2
- **Offline Support**: Realm và AsyncStorage
- **Testing**: Jest và React Native Testing Library

### 4.3. Desktop Application

- **Framework**: Electron
- **Frontend**: Giống với Web Application
- **Native Integration**: Node.js APIs
- **Packaging**: electron-builder
- **Auto Update**: electron-updater

## 5. KIẾN TRÚC BACKEND

### 5.1. API Layer

- **Framework**: NestJS
- **API Style**: RESTful
- **Documentation**: Swagger/OpenAPI
- **Validation**: class-validator
- **Serialization**: class-transformer
- **Rate Limiting**: Throttler
- **Caching**: Redis

### 5.2. Business Logic Layer

- **Architecture**: Domain-Driven Design (DDD)
- **Pattern**: CQRS (Command Query Responsibility Segregation)
- **Validation**: Custom validators
- **Error Handling**: Exception filters
- **Logging**: Winston
- **Monitoring**: Prometheus

### 5.3. Data Access Layer

- **ORM**: TypeORM
- **Query Builder**: Custom query builders
- **Transactions**: Transaction management
- **Migrations**: TypeORM migrations
- **Seeding**: Custom seeders

## 6. KIẾN TRÚC CƠ SỞ DỮ LIỆU

### 6.1. Relational Database

- **Database**: PostgreSQL
- **Multi-tenant**: Schema per tenant
- **Sharding**: Horizontal sharding based on tenant
- **Indexing**: B-tree và GIN indexes
- **Performance**: Query optimization và connection pooling

### 6.2. Cache

- **Cache System**: Redis
- **Cache Patterns**: Cache-aside, Write-through
- **Distributed Cache**: Redis Cluster
- **Expiration**: TTL-based expiration
- **Invalidation**: Event-based invalidation

### 6.3. Message Queue

- **Queue System**: RabbitMQ
- **Exchange Types**: Direct, Topic, Fanout
- **Message Patterns**: Pub/Sub, RPC
- **Reliability**: Message acknowledgment và dead letter queues
- **Scaling**: RabbitMQ Cluster

## 7. KIẾN TRÚC TÍCH HỢP

### 7.1. API Gateway

- **Gateway**: Kong
- **Features**: Routing, Rate limiting, Authentication, Logging
- **Plugins**: Custom plugins for tenant resolution
- **Scaling**: Horizontal scaling

### 7.2. External Integrations

- **Marketplace**: API integration với Shopee, Lazada, TikTok Shop
- **Payment**: API integration với các cổng thanh toán
- **Communication**: API integration với email, SMS, push notification services
- **AI**: API integration với OpenAI, GeminiAI

### 7.3. Webhooks

- **Outgoing Webhooks**: Gửi sự kiện đến các hệ thống bên ngoài
- **Incoming Webhooks**: Nhận sự kiện từ các hệ thống bên ngoài
- **Security**: HMAC signature verification
- **Reliability**: Retry mechanism và dead letter queues

## 8. KIẾN TRÚC BẢO MẬT

### 8.1. Authentication

- **JWT**: JSON Web Tokens cho API authentication
- **OAuth2**: Cho third-party authentication
- **MFA**: Multi-factor authentication
- **SSO**: Single Sign-On

### 8.2. Authorization

- **RBAC**: Role-Based Access Control
- **ABAC**: Attribute-Based Access Control
- **CASL**: Declarative authorization
- **Tenant Isolation**: Data isolation between tenants

### 8.3. Data Security

- **Encryption**: Data encryption at rest và in transit
- **Masking**: Sensitive data masking
- **Auditing**: Comprehensive audit logging
- **Compliance**: GDPR, PDPA compliance

## 9. TÀI LIỆU LIÊN QUAN

- [Kiến trúc multi-tenant](./kien-truc-multi-tenant.md) - Chi tiết về thiết kế và triển khai multi-tenant
- [Kiến trúc triển khai](./kien-truc-trien-khai.md) - Chi tiết về kiến trúc triển khai
- [Kiến trúc mạng và bảo mật](./kien-truc-mang-va-bao-mat.md) - Chi tiết về kiến trúc mạng và bảo mật
- [Kiến trúc dự phòng và khôi phục](./kien-truc-du-phong-va-khoi-phuc.md) - Chi tiết về dự phòng và khôi phục
- [Kiến trúc giám sát](./kien-truc-giam-sat.md) - Chi tiết về kiến trúc giám sát
- [Tổng quan dự án](../01-tong-quan/tong-quan-du-an.md) - Giới thiệu tổng quan về dự án NextFlow CRM
- [Tổng quan schema](../05-schema/tong-quan-schema.md) - Tổng quan về schema cơ sở dữ liệu
- [Tổng quan API](../06-api/tong-quan-api.md) - Tổng quan về API của hệ thống

## 10. KẾT LUẬN

Kiến trúc tổng thể của NextFlow CRM được thiết kế để đáp ứng các yêu cầu về khả năng mở rộng, bảo mật, hiệu suất và tính linh hoạt. Bằng cách sử dụng kiến trúc microservices kết hợp với mô hình multi-tenant, hệ thống có thể phục vụ nhiều khách hàng với các nhu cầu khác nhau trên cùng một hạ tầng, đồng thời vẫn đảm bảo cách ly dữ liệu và hiệu suất.

Các công nghệ hiện đại như NestJS, Next.js, PostgreSQL, Redis, RabbitMQ và Kong được sử dụng để xây dựng một hệ thống mạnh mẽ, có khả năng mở rộng và dễ bảo trì. Kiến trúc này cũng tạo điều kiện cho việc tích hợp AI và tự động hóa, là những tính năng cốt lõi của NextFlow CRM.
