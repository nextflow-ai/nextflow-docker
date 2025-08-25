# KIẾN TRÚC MICROSERVICES NextFlow CRM-AI

## Mục lục

1. [GIỚI THIỆU](#1-giới-thiệu)
   - [Mục đích](#11-mục-đích)
   - [Phạm vi](#12-phạm-vi)
2. [TỔNG QUAN KIẾN TRÚC MICROSERVICES](#2-tổng-quan-kiến-trúc-microservices)
   - [Nguyên tắc thiết kế](#21-nguyên-tắc-thiết-kế)
   - [Lợi ích và thách thức](#22-lợi-ích-và-thách-thức)
3. [PHÂN CHIA MICROSERVICES](#3-phân-chia-microservices)
   - [Domain-Driven Design](#31-domain-driven-design)
   - [Bounded Contexts](#32-bounded-contexts)
   - [Danh sách Microservices](#33-danh-sách-microservices)
4. [GIAO TIẾP GIỮA CÁC SERVICES](#4-giao-tiếp-giữa-các-services)
   - [Synchronous Communication](#41-synchronous-communication)
   - [Asynchronous Communication](#42-asynchronous-communication)
   - [API Gateway](#43-api-gateway)
5. [SERVICE DISCOVERY VÀ REGISTRY](#5-service-discovery-và-registry)
   - [Service Registry](#51-service-registry)
   - [Client-side Discovery](#52-client-side-discovery)
   - [Server-side Discovery](#53-server-side-discovery)
6. [RESILIENCE PATTERNS](#6-resilience-patterns)
   - [Circuit Breaker](#61-circuit-breaker)
   - [Bulkhead](#62-bulkhead)
   - [Timeout và Retry](#63-timeout-và-retry)
   - [Fallback](#64-fallback)
7. [DATA MANAGEMENT](#7-data-management)
   - [Database per Service](#71-database-per-service)
   - [Shared Database](#72-shared-database)
   - [Event Sourcing](#73-event-sourcing)
   - [CQRS](#74-cqrs)
8. [DEPLOYMENT VÀ ORCHESTRATION](#8-deployment-và-orchestration)
   - [Containerization](#81-containerization)
   - [Kubernetes Deployment](#82-kubernetes-deployment)
   - [Service Mesh](#83-service-mesh)
9. [MONITORING VÀ OBSERVABILITY](#9-monitoring-và-observability)
   - [Distributed Tracing](#91-distributed-tracing)
   - [Centralized Logging](#92-centralized-logging)
   - [Metrics Collection](#93-metrics-collection)
10. [TÀI LIỆU LIÊN QUAN](#10-tài-liệu-liên-quan)
11. [KẾT LUẬN](#11-kết-luận)

## 1. GIỚI THIỆU

Tài liệu này mô tả kiến trúc microservices của hệ thống NextFlow CRM-AI, bao gồm cách phân chia các microservices, giao tiếp giữa các services, service discovery, resilience patterns và các khía cạnh khác của kiến trúc microservices.

### 1.1. Mục đích

- Cung cấp cái nhìn tổng quan về kiến trúc microservices của NextFlow CRM-AI
- Mô tả cách phân chia các microservices dựa trên domain-driven design
- Giải thích các cơ chế giao tiếp giữa các services
- Mô tả các patterns và best practices được áp dụng
- Làm tài liệu tham khảo cho đội phát triển và vận hành

### 1.2. Phạm vi

Tài liệu này bao gồm:
- Tổng quan về kiến trúc microservices
- Phân chia microservices theo domain
- Giao tiếp giữa các services
- Service discovery và registry
- Resilience patterns
- Data management
- Deployment và orchestration
- Monitoring và observability

## 2. TỔNG QUAN KIẾN TRÚC MICROSERVICES

NextFlow CRM-AI được thiết kế theo kiến trúc microservices để đạt được tính linh hoạt, khả năng mở rộng và khả năng phát triển độc lập các thành phần. Kiến trúc này cho phép các team phát triển và triển khai các services một cách độc lập, đồng thời tạo điều kiện cho việc áp dụng các công nghệ phù hợp nhất cho từng service.

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Web Application |     |  Mobile App      |     |  Third-party     |
|                  |     |                  |     |  Applications    |
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         +------------------------+------------------------+
                                 |
                                 v
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  API Gateway     |     |  Authentication  |     |  Service         |
|                  |     |  Service         |     |  Registry        |
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         +------------------------+------------------------+
                                 |
                                 v
+-------+--------+  +-------+--------+  +-------+--------+  +-------+--------+
|                |  |                |  |                |  |                |
| Customer       |  | Order          |  | Product        |  | Integration    |
| Service        |  | Service        |  | Service        |  | Service        |
|                |  |                |  |                |  |                |
+-------+--------+  +-------+--------+  +-------+--------+  +-------+--------+
        |                   |                   |                   |
        +-------------------+-------------------+-------------------+
                            |
                            v
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Message Broker  |     |  Distributed     |     |  Monitoring      |
|  (Event Bus)     |     |  Data Store      |     |  System          |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
```

### 2.1. Nguyên tắc thiết kế

NextFlow CRM-AI áp dụng các nguyên tắc thiết kế microservices sau:

1. **Single Responsibility**: Mỗi microservice chỉ chịu trách nhiệm cho một chức năng nghiệp vụ cụ thể.

2. **Autonomy**: Các microservices hoạt động độc lập, có thể được phát triển, triển khai và mở rộng mà không ảnh hưởng đến các services khác.

3. **Resilience**: Hệ thống được thiết kế để chịu đựng sự cố của các services riêng lẻ mà không ảnh hưởng đến toàn bộ hệ thống.

4. **Decentralization**: Quyết định về thiết kế và triển khai được phân tán cho các team phát triển.

5. **Domain-Driven Design**: Các microservices được phân chia dựa trên các bounded contexts của domain.

6. **API-First**: Các microservices cung cấp API rõ ràng và được định nghĩa tốt.

7. **Polyglot Persistence**: Mỗi microservice có thể sử dụng loại cơ sở dữ liệu phù hợp nhất với nhu cầu của nó.

8. **Event-Driven**: Sử dụng event-driven architecture để giao tiếp không đồng bộ giữa các services.

9. **Infrastructure Automation**: Tự động hóa việc triển khai, mở rộng và giám sát các microservices.

10. **Observability**: Tích hợp logging, monitoring và tracing để đảm bảo khả năng quan sát của hệ thống.

### 2.2. Lợi ích và thách thức

**Lợi ích của kiến trúc microservices trong NextFlow CRM-AI**:

1. **Khả năng mở rộng**: Các services có thể được mở rộng độc lập dựa trên nhu cầu.

2. **Phát triển nhanh chóng**: Các team có thể làm việc song song trên các services khác nhau.

3. **Triển khai linh hoạt**: Các services có thể được triển khai độc lập, giảm thiểu rủi ro.

4. **Công nghệ đa dạng**: Có thể sử dụng công nghệ phù hợp nhất cho từng service.

5. **Khả năng chịu lỗi**: Lỗi trong một service không ảnh hưởng đến toàn bộ hệ thống.

6. **Dễ dàng thay thế**: Các services có thể được viết lại hoặc thay thế mà không ảnh hưởng đến hệ thống.

7. **Tối ưu hóa tài nguyên**: Các services có thể được triển khai trên các máy chủ phù hợp với nhu cầu tài nguyên.

**Thách thức của kiến trúc microservices trong NextFlow CRM-AI**:

1. **Phức tạp trong giao tiếp**: Giao tiếp giữa các services cần được quản lý cẩn thận.

2. **Quản lý dữ liệu phân tán**: Dữ liệu được phân tán giữa các services, gây khó khăn trong việc duy trì tính nhất quán.

3. **Phức tạp trong triển khai**: Triển khai và quản lý nhiều services đòi hỏi công cụ và quy trình phức tạp hơn.

4. **Overhead mạng**: Giao tiếp giữa các services qua mạng tạo ra overhead.

5. **Monitoring và debugging**: Theo dõi và gỡ lỗi trong hệ thống phân tán phức tạp hơn.

6. **Quản lý phiên bản API**: Cần quản lý cẩn thận các phiên bản API để đảm bảo khả năng tương thích.

7. **Kiểm thử end-to-end**: Kiểm thử toàn bộ hệ thống trở nên phức tạp hơn.

## 3. PHÂN CHIA MICROSERVICES

NextFlow CRM-AI sử dụng phương pháp Domain-Driven Design (DDD) để phân chia các microservices, đảm bảo rằng mỗi service tập trung vào một phần cụ thể của domain nghiệp vụ.

### 3.1. Domain-Driven Design

Domain-Driven Design là một phương pháp thiết kế phần mềm tập trung vào domain cốt lõi của hệ thống, sử dụng một mô hình để hình thành một ngôn ngữ chung giữa các bên liên quan. Trong NextFlow CRM-AI, DDD được áp dụng để:

1. **Xác định Ubiquitous Language**: Thiết lập một ngôn ngữ chung giữa các bên liên quan, đảm bảo rằng các thuật ngữ được sử dụng nhất quán trong toàn bộ hệ thống.

2. **Xác định Domain Model**: Tạo một mô hình phản ánh chính xác các khái niệm và quy tắc nghiệp vụ của domain.

3. **Phân chia Bounded Contexts**: Xác định các ranh giới rõ ràng giữa các phần khác nhau của domain.

4. **Thiết kế Aggregates**: Xác định các nhóm các entities và value objects được quản lý cùng nhau.

5. **Xác định Domain Events**: Xác định các sự kiện quan trọng trong domain để hỗ trợ giao tiếp giữa các bounded contexts.

### 3.2. Bounded Contexts

Bounded Context là một ranh giới rõ ràng trong đó một mô hình domain cụ thể có hiệu lực. NextFlow CRM-AI được phân chia thành các bounded contexts sau:

1. **Customer Context**: Quản lý thông tin khách hàng, bao gồm thông tin cá nhân, lịch sử tương tác, phân khúc khách hàng.

2. **Order Context**: Quản lý đơn hàng, bao gồm tạo đơn hàng, xử lý đơn hàng, thanh toán, vận chuyển.

3. **Product Context**: Quản lý sản phẩm, bao gồm thông tin sản phẩm, giá cả, kho hàng.

4. **E-commerce Integration Context**: Tích hợp với các nền tảng thương mại điện tử như Shopee, Lazada, TikTok Shop.

5. **Marketing Context**: Quản lý chiến dịch marketing, email marketing, social media marketing.

6. **Analytics Context**: Phân tích dữ liệu, báo cáo, dashboard.

7. **User Management Context**: Quản lý người dùng, phân quyền, xác thực.

Mỗi bounded context được triển khai thành một hoặc nhiều microservices, tùy thuộc vào độ phức tạp và quy mô của context.

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
| Customer Context |     | Order Context    |     | Product Context  |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+

+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
| E-commerce       |     | Marketing        |     | Analytics        |
| Integration      |     | Context          |     | Context          |
| Context          |     |                  |     |                  |
+------------------+     +------------------+     +------------------+

+------------------+
|                  |
| User Management  |
| Context          |
|                  |
+------------------+
```

### 3.3. Danh sách Microservices

Dựa trên các bounded contexts, NextFlow CRM-AI được phân chia thành các microservices sau:

1. **Customer Service**:
   - Quản lý thông tin khách hàng
   - Quản lý lịch sử tương tác
   - Phân khúc khách hàng
   - API: `/api/customers`

2. **Order Service**:
   - Quản lý đơn hàng
   - Xử lý đơn hàng
   - Quản lý thanh toán
   - API: `/api/orders`

3. **Product Service**:
   - Quản lý sản phẩm
   - Quản lý giá cả
   - Quản lý kho hàng
   - API: `/api/products`

4. **Integration Service**:
   - Tích hợp với Shopee
   - Tích hợp với Lazada
   - Tích hợp với TikTok Shop
   - Đồng bộ hóa dữ liệu
   - API: `/api/integrations`

5. **Marketing Service**:
   - Quản lý chiến dịch marketing
   - Email marketing
   - Social media marketing
   - API: `/api/marketing`

6. **Analytics Service**:
   - Phân tích dữ liệu
   - Báo cáo
   - Dashboard
   - API: `/api/analytics`

7. **User Service**:
   - Quản lý người dùng
   - Phân quyền
   - Xác thực
   - API: `/api/users`

8. **Notification Service**:
   - Gửi thông báo
   - Quản lý template thông báo
   - API: `/api/notifications`

9. **File Service**:
   - Lưu trữ và quản lý file
   - Xử lý hình ảnh
   - API: `/api/files`

10. **Search Service**:
    - Tìm kiếm toàn văn
    - Đánh index dữ liệu
    - API: `/api/search`

Mỗi microservice có cơ sở dữ liệu riêng (nếu cần) và cung cấp API RESTful hoặc GraphQL để giao tiếp với các services khác và frontend.

## 4. GIAO TIẾP GIỮA CÁC SERVICES

Giao tiếp hiệu quả giữa các microservices là một yếu tố quan trọng trong kiến trúc microservices. NextFlow CRM-AI sử dụng cả giao tiếp đồng bộ (synchronous) và không đồng bộ (asynchronous) tùy thuộc vào yêu cầu cụ thể.

### 4.1. Synchronous Communication

Giao tiếp đồng bộ được sử dụng khi client cần phản hồi ngay lập tức từ service. NextFlow CRM-AI sử dụng các phương thức giao tiếp đồng bộ sau:

1. **RESTful APIs**:
   - Sử dụng HTTP/HTTPS làm giao thức truyền tải
   - Tuân thủ các nguyên tắc REST (Resource-based, Stateless, Cacheable, Uniform Interface)
   - Sử dụng JSON làm định dạng dữ liệu
   - Versioning API (v1, v2, etc.)
   - Ví dụ: `GET /api/customers/123`, `POST /api/orders`

2. **GraphQL**:
   - Sử dụng cho các trường hợp cần truy vấn dữ liệu phức tạp
   - Cho phép client chỉ định chính xác dữ liệu cần lấy
   - Giảm số lượng request và lượng dữ liệu truyền tải
   - Endpoint duy nhất: `/graphql`

3. **gRPC**:
   - Sử dụng cho giao tiếp giữa các services nội bộ
   - Hiệu suất cao hơn so với REST nhờ Protocol Buffers và HTTP/2
   - Hỗ trợ streaming (unary, server streaming, client streaming, bidirectional streaming)
   - Định nghĩa interface bằng Protocol Buffers

Ví dụ về RESTful API trong NextFlow CRM-AI:

```
# Request
GET /api/customers/123 HTTP/1.1
Host: api.nextflow.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Accept: application/json

# Response
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": "123",
  "name": "Công ty ABC",
  "email": "contact@abc.com",
  "phone": "0123456789",
  "address": "123 Đường XYZ, Quận 1, TP.HCM",
  "segment": "Enterprise",
  "createdAt": "2023-01-15T08:30:00Z",
  "updatedAt": "2023-06-20T14:45:00Z"
}
```

### 4.2. Asynchronous Communication

Giao tiếp không đồng bộ được sử dụng khi không cần phản hồi ngay lập tức hoặc khi cần thông báo về các sự kiện. NextFlow CRM-AI sử dụng các phương thức giao tiếp không đồng bộ sau:

1. **Message Broker (RabbitMQ)**:
   - Sử dụng cho các tác vụ cần xử lý bất đồng bộ
   - Hỗ trợ các mô hình giao tiếp: Publish/Subscribe, Request/Reply, Competing Consumers
   - Đảm bảo tin nhắn được gửi đi ít nhất một lần
   - Ví dụ: Xử lý đơn hàng, gửi email, đồng bộ dữ liệu

2. **Event Streaming (Kafka)**:
   - Sử dụng cho event sourcing và CQRS
   - Lưu trữ và xử lý các sự kiện theo thứ tự
   - Hỗ trợ xử lý dữ liệu lớn và real-time
   - Ví dụ: Theo dõi hành vi người dùng, phân tích dữ liệu

3. **Webhook**:
   - Sử dụng cho giao tiếp với các hệ thống bên ngoài
   - Cho phép các hệ thống đăng ký nhận thông báo khi có sự kiện xảy ra
   - Ví dụ: Thông báo khi có đơn hàng mới, cập nhật trạng thái đơn hàng

Ví dụ về event trong NextFlow CRM-AI:

```json
{
  "eventId": "evt_12345",
  "eventType": "order.created",
  "timestamp": "2023-07-10T15:30:00Z",
  "data": {
    "orderId": "ord_6789",
    "customerId": "cus_123",
    "items": [
      {
        "productId": "prod_456",
        "quantity": 2,
        "price": 100000
      }
    ],
    "totalAmount": 200000,
    "status": "pending"
  }
}
```

### 4.3. API Gateway

API Gateway đóng vai trò là điểm vào duy nhất cho tất cả các clients, giúp đơn giản hóa giao tiếp giữa clients và microservices. NextFlow CRM-AI sử dụng API Gateway với các chức năng sau:

1. **Routing**: Định tuyến requests đến các microservices phù hợp.

2. **Authentication và Authorization**: Xác thực và phân quyền tập trung.

3. **Rate Limiting**: Giới hạn số lượng requests từ một client trong một khoảng thời gian.

4. **Caching**: Cache responses để giảm tải cho các services.

5. **Request/Response Transformation**: Chuyển đổi định dạng request/response giữa client và services.

6. **Circuit Breaking**: Ngăn chặn cascading failures khi một service gặp sự cố.

7. **Load Balancing**: Phân phối traffic giữa các instances của một service.

8. **Logging và Monitoring**: Ghi log và giám sát tất cả các requests.

NextFlow CRM-AI sử dụng Kong làm API Gateway, với cấu hình như sau:

```yaml
services:
  - name: customer-service
    url: http://customer-service:8080
    routes:
      - paths:
          - /api/customers
        strip_path: false
        methods:
          - GET
          - POST
          - PUT
          - DELETE
    plugins:
      - name: jwt
      - name: rate-limiting
        config:
          second: 5
          hour: 10000
      - name: cors
      - name: request-transformer
      - name: response-transformer

  - name: order-service
    url: http://order-service:8080
    routes:
      - paths:
          - /api/orders
        strip_path: false
        methods:
          - GET
          - POST
          - PUT
          - DELETE
    plugins:
      - name: jwt
      - name: rate-limiting
        config:
          second: 5
          hour: 10000
      - name: cors
```

## 5. SERVICE DISCOVERY VÀ REGISTRY

Trong môi trường microservices, các services cần biết cách tìm và giao tiếp với nhau. Service discovery là quá trình xác định vị trí của các service instances trong mạng. NextFlow CRM-AI sử dụng service discovery để đảm bảo rằng các services có thể tìm thấy và giao tiếp với nhau một cách đáng tin cậy.

### 5.1. Service Registry

Service Registry là một cơ sở dữ liệu trung tâm chứa thông tin về tất cả các service instances đang chạy. NextFlow CRM-AI sử dụng Consul làm Service Registry với các chức năng sau:

1. **Service Registration**: Các services đăng ký thông tin của mình (hostname, IP, port, health check) với Consul khi khởi động.

2. **Service Discovery**: Các services truy vấn Consul để tìm thông tin về các services khác.

3. **Health Checking**: Consul thực hiện health check định kỳ để đảm bảo rằng các services đang hoạt động bình thường.

4. **Key-Value Store**: Lưu trữ cấu hình và metadata của các services.

5. **DNS Interface**: Cung cấp DNS interface để các services có thể tìm thấy nhau thông qua DNS.

Ví dụ về cấu hình Consul trong NextFlow CRM-AI:

```json
{
  "service": {
    "name": "customer-service",
    "tags": ["api", "v1"],
    "port": 8080,
    "check": {
      "http": "http://localhost:8080/health",
      "interval": "10s",
      "timeout": "1s"
    }
  }
}
```

### 5.2. Client-side Discovery

Trong client-side discovery, client (service gọi) chịu trách nhiệm xác định vị trí của service được gọi. NextFlow CRM-AI sử dụng client-side discovery với quy trình như sau:

1. Client truy vấn Service Registry (Consul) để lấy danh sách các instances của service cần gọi.
2. Client áp dụng thuật toán load balancing để chọn một instance.
3. Client gửi request đến instance đã chọn.

```
+------------------+     +------------------+
|                  |     |                  |
|  Client Service  |     |  Service Registry|
|                  |     |  (Consul)        |
+--------+---------+     +--------+---------+
         |                        ^
         | 1. Query               | 2. Return instances
         v                        |
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Target Service  |     |  Target Service  |     |  Target Service  |
|  Instance 1      |     |  Instance 2      |     |  Instance 3      |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
         ^
         | 3. Send request
         |
```

Ưu điểm của client-side discovery:
- Đơn giản hóa infrastructure (không cần load balancer riêng)
- Client có quyền kiểm soát thuật toán load balancing
- Client có thể xử lý lỗi một cách thông minh (retry, circuit breaking)

Nhược điểm của client-side discovery:
- Client phải triển khai logic discovery cho mỗi ngôn ngữ/framework
- Client phải biết về Service Registry

### 5.3. Server-side Discovery

Trong server-side discovery, client gửi request đến một thành phần trung gian (load balancer), thành phần này chịu trách nhiệm xác định vị trí của service được gọi. NextFlow CRM-AI sử dụng server-side discovery với quy trình như sau:

1. Client gửi request đến load balancer.
2. Load balancer truy vấn Service Registry để lấy danh sách các instances của service cần gọi.
3. Load balancer áp dụng thuật toán load balancing để chọn một instance.
4. Load balancer chuyển tiếp request đến instance đã chọn.

```
                    +------------------+
                    |                  |
                    |  Service Registry|
                    |  (Consul)        |
                    +--------+---------+
                             ^
                             | 2. Query
+------------------+         |         +------------------+
|                  |         |         |                  |
|  Client Service  |-------->|-------->|  Load Balancer   |
|                  |         |         |                  |
+------------------+         |         +--------+---------+
                    1. Send  |                  |
                    request  |                  | 3. Forward request
                             v                  v
             +------------------+     +------------------+     +------------------+
             |                  |     |                  |     |                  |
             |  Target Service  |     |  Target Service  |     |  Target Service  |
             |  Instance 1      |     |  Instance 2      |     |  Instance 3      |
             |                  |     |                  |     |                  |
             +------------------+     +------------------+     +------------------+
```

Ưu điểm của server-side discovery:
- Client không cần biết về Service Registry
- Đơn giản hóa client (không cần triển khai logic discovery)
- Có thể sử dụng cho bất kỳ ngôn ngữ/framework nào

Nhược điểm của server-side discovery:
- Cần triển khai và quản lý load balancer
- Load balancer có thể trở thành single point of failure
- Thêm một hop trong quá trình giao tiếp

NextFlow CRM-AI sử dụng cả hai phương pháp discovery tùy thuộc vào ngữ cảnh:
- Server-side discovery cho giao tiếp từ bên ngoài vào hệ thống (thông qua API Gateway)
- Client-side discovery cho giao tiếp giữa các services nội bộ

## 6. RESILIENCE PATTERNS

Trong kiến trúc microservices, các services phụ thuộc vào nhau và giao tiếp qua mạng, điều này làm tăng khả năng xảy ra lỗi. Resilience patterns giúp hệ thống chịu đựng và phục hồi từ các lỗi, đảm bảo tính sẵn sàng và độ tin cậy. NextFlow CRM-AI áp dụng các resilience patterns sau:

### 6.1. Circuit Breaker

Circuit Breaker là một pattern giúp ngăn chặn lỗi lan truyền trong hệ thống khi một service gặp sự cố. Nó hoạt động tương tự như một cầu dao điện, ngắt kết nối khi phát hiện lỗi và khôi phục kết nối sau một khoảng thời gian.

NextFlow CRM-AI sử dụng Resilience4j làm thư viện Circuit Breaker với các trạng thái sau:

1. **Closed**: Trạng thái bình thường, tất cả các requests được chuyển tiếp đến service.

2. **Open**: Khi số lượng lỗi vượt quá ngưỡng, circuit breaker chuyển sang trạng thái open và từ chối tất cả các requests, trả về lỗi ngay lập tức.

3. **Half-Open**: Sau một khoảng thời gian, circuit breaker chuyển sang trạng thái half-open và cho phép một số lượng nhỏ requests đi qua để kiểm tra xem service đã phục hồi chưa.

```
                    +----------------+
                    |                |
                    |  Circuit       |
                    |  Breaker       |
                    |                |
                    +-------+--------+
                            |
                            v
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Closed State    |---->|  Open State      |---->|  Half-Open State |
|  (Normal)        |     |  (Failing)       |     |  (Testing)       |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
        ^                                                |
        |                                                |
        +------------------------------------------------+
```

Ví dụ cấu hình Circuit Breaker trong NextFlow CRM-AI:

```java
CircuitBreakerConfig circuitBreakerConfig = CircuitBreakerConfig.custom()
    .failureRateThreshold(50)
    .waitDurationInOpenState(Duration.ofMillis(1000))
    .permittedNumberOfCallsInHalfOpenState(10)
    .slidingWindowSize(100)
    .recordExceptions(IOException.class, TimeoutException.class)
    .build();

CircuitBreaker circuitBreaker = CircuitBreaker.of("orderService", circuitBreakerConfig);
```

### 6.2. Bulkhead

Bulkhead pattern giúp cô lập các lỗi trong một phần của hệ thống, ngăn chặn chúng ảnh hưởng đến toàn bộ hệ thống. Nó hoạt động tương tự như các vách ngăn trong tàu, nếu một phần bị ngập nước, các phần khác vẫn an toàn.

NextFlow CRM-AI sử dụng hai loại Bulkhead:

1. **Semaphore Bulkhead**: Giới hạn số lượng concurrent calls đến một service.

2. **Thread Pool Bulkhead**: Sử dụng thread pool riêng biệt cho mỗi service dependency.

```java
BulkheadConfig bulkheadConfig = BulkheadConfig.custom()
    .maxConcurrentCalls(25)
    .maxWaitDuration(Duration.ofMillis(500))
    .build();

Bulkhead bulkhead = Bulkhead.of("orderService", bulkheadConfig);
```

### 6.3. Timeout và Retry

Timeout và Retry patterns giúp xử lý các lỗi tạm thời trong giao tiếp giữa các services.

1. **Timeout**: Đặt thời gian tối đa cho một request, nếu vượt quá thời gian này, request sẽ bị hủy.

```java
TimeLimiterConfig timeLimiterConfig = TimeLimiterConfig.custom()
    .timeoutDuration(Duration.ofSeconds(5))
    .cancelRunningFuture(true)
    .build();

TimeLimiter timeLimiter = TimeLimiter.of("orderService", timeLimiterConfig);
```

2. **Retry**: Tự động thử lại request khi gặp lỗi, với số lần thử lại và khoảng thời gian giữa các lần thử có thể cấu hình.

```java
RetryConfig retryConfig = RetryConfig.custom()
    .maxAttempts(3)
    .waitDuration(Duration.ofMillis(500))
    .retryExceptions(IOException.class, TimeoutException.class)
    .ignoreExceptions(IllegalArgumentException.class)
    .build();

Retry retry = Retry.of("orderService", retryConfig);
```

NextFlow CRM-AI kết hợp Timeout, Retry và Circuit Breaker để xử lý các lỗi một cách hiệu quả:

```java
// Combine patterns
Supplier<Order> decoratedSupplier = Decorators.ofSupplier(() -> orderService.getOrder(orderId))
    .withRetry(retry)
    .withCircuitBreaker(circuitBreaker)
    .withBulkhead(bulkhead)
    .withTimeLimiter(timeLimiter)
    .decorate();

// Execute
Try<Order> result = Try.ofSupplier(decoratedSupplier);
```

### 6.4. Fallback

Fallback pattern cung cấp một giải pháp thay thế khi một service gặp sự cố. Thay vì trả về lỗi, hệ thống có thể trả về dữ liệu từ cache, dữ liệu mặc định, hoặc chuyển hướng đến một service dự phòng.

NextFlow CRM-AI sử dụng các loại fallback sau:

1. **Cache Fallback**: Trả về dữ liệu từ cache khi service gặp sự cố.

2. **Default Fallback**: Trả về dữ liệu mặc định hoặc empty response.

3. **Alternative Service Fallback**: Chuyển hướng request đến một service dự phòng.

```java
// Fallback function
Function<Throwable, Order> fallback = throwable -> {
    if (throwable instanceof TimeoutException) {
        return cacheService.getOrder(orderId);
    }
    return new Order(); // Default empty order
};

// Combine with other patterns
Supplier<Order> decoratedSupplier = Decorators.ofSupplier(() -> orderService.getOrder(orderId))
    .withFallback(fallback)
    .withRetry(retry)
    .withCircuitBreaker(circuitBreaker)
    .decorate();
```

Bằng cách kết hợp các resilience patterns này, NextFlow CRM-AI có thể xử lý các lỗi một cách hiệu quả, đảm bảo tính sẵn sàng và độ tin cậy của hệ thống, ngay cả khi một số services gặp sự cố.

## 7. DATA MANAGEMENT

Quản lý dữ liệu trong kiến trúc microservices là một thách thức lớn, đặc biệt là khi cần đảm bảo tính nhất quán của dữ liệu giữa các services. NextFlow CRM-AI áp dụng nhiều chiến lược quản lý dữ liệu khác nhau tùy thuộc vào yêu cầu cụ thể của từng service.

### 7.1. Database per Service

Database per Service là một pattern trong đó mỗi microservice có cơ sở dữ liệu riêng, độc lập với các services khác. NextFlow CRM-AI áp dụng pattern này cho hầu hết các services để đảm bảo tính độc lập và tự chủ của mỗi service.

**Ưu điểm**:
- Tính độc lập cao: Mỗi service có thể chọn loại database phù hợp nhất với nhu cầu của mình.
- Cô lập lỗi: Sự cố trong một database không ảnh hưởng đến các services khác.
- Khả năng mở rộng: Mỗi database có thể được mở rộng độc lập dựa trên nhu cầu.
- Tránh coupling: Giảm thiểu sự phụ thuộc giữa các services.

**Nhược điểm**:
- Phức tạp trong quản lý dữ liệu phân tán.
- Khó khăn trong việc duy trì tính nhất quán giữa các services.
- Cần triển khai các cơ chế đồng bộ hóa dữ liệu.

Ví dụ về Database per Service trong NextFlow CRM-AI:

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
| Customer Service |     | Order Service    |     | Product Service  |
|                  |     |                  |     |                  |
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         v                        v                        v
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
| Customer DB      |     | Order DB         |     | Product DB       |
| (PostgreSQL)     |     | (PostgreSQL)     |     | (PostgreSQL)     |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+

+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
| Analytics Service|     | Search Service   |     | File Service     |
|                  |     |                  |     |                  |
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         v                        v                        v
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
| Analytics DB     |     | Search DB        |     | File Storage     |
| (ClickHouse)     |     | (Elasticsearch)  |     | (MinIO)          |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
```

### 7.2. Shared Database

Trong một số trường hợp, NextFlow CRM-AI sử dụng Shared Database pattern, trong đó một số services chia sẻ cùng một cơ sở dữ liệu. Pattern này được áp dụng cho các services có mối quan hệ chặt chẽ và cần truy cập dữ liệu chung.

**Ưu điểm**:
- Đơn giản hóa việc quản lý dữ liệu.
- Dễ dàng duy trì tính nhất quán của dữ liệu.
- Giảm độ phức tạp trong việc đồng bộ hóa dữ liệu.

**Nhược điểm**:
- Giảm tính độc lập của các services.
- Tăng coupling giữa các services.
- Rủi ro về hiệu suất và khả năng mở rộng.

Trong NextFlow CRM-AI, Shared Database được áp dụng cho một số services cụ thể:

1. **User Service và Authentication Service**: Chia sẻ cùng một database để quản lý thông tin người dùng và xác thực.

2. **Notification Service và Marketing Service**: Chia sẻ database để quản lý templates và lịch sử gửi thông báo.

```
+------------------+     +------------------+
|                  |     |                  |
| User Service     |     | Auth Service     |
|                  |     |                  |
+--------+---------+     +--------+---------+
         |                        |
         +------------------------+
                    |
                    v
          +------------------+
          |                  |
          | User/Auth DB     |
          | (PostgreSQL)     |
          |                  |
          +------------------+
```

### 7.3. Event Sourcing

Event Sourcing là một pattern trong đó trạng thái của hệ thống được lưu trữ dưới dạng một chuỗi các sự kiện không thay đổi. NextFlow CRM-AI áp dụng Event Sourcing cho một số domain cụ thể để theo dõi lịch sử thay đổi và hỗ trợ CQRS.

**Ưu điểm**:
- Lưu trữ lịch sử đầy đủ của tất cả các thay đổi.
- Hỗ trợ debugging và auditing.
- Khả năng tái tạo trạng thái tại bất kỳ thời điểm nào trong quá khứ.
- Hỗ trợ tốt cho CQRS.

**Nhược điểm**:
- Phức tạp trong việc triển khai và quản lý.
- Cần xử lý event versioning.
- Có thể gặp vấn đề về hiệu suất khi số lượng events lớn.

Trong NextFlow CRM-AI, Event Sourcing được áp dụng cho:

1. **Order Service**: Lưu trữ tất cả các sự kiện liên quan đến đơn hàng (tạo đơn, cập nhật trạng thái, thanh toán, hủy, etc.).

2. **Customer Interaction Service**: Lưu trữ lịch sử tương tác với khách hàng.

```
+------------------+
|                  |
| Order Service    |
|                  |
+--------+---------+
         |
         v
+------------------+     +------------------+
|                  |     |                  |
| Event Store      |     | Snapshot Store   |
| (Kafka)          |     | (PostgreSQL)     |
|                  |     |                  |
+------------------+     +------------------+
```

Ví dụ về event trong Event Sourcing:

```json
{
  "eventId": "evt_12345",
  "eventType": "order.status_changed",
  "aggregateId": "ord_6789",
  "timestamp": "2023-07-10T15:30:00Z",
  "version": 3,
  "data": {
    "oldStatus": "processing",
    "newStatus": "shipped",
    "updatedBy": "user_123",
    "reason": "Order has been shipped via GHN"
  }
}
```

### 7.4. CQRS

CQRS (Command Query Responsibility Segregation) là một pattern tách biệt các operations đọc (queries) và ghi (commands) thành các models riêng biệt. NextFlow CRM-AI áp dụng CQRS kết hợp với Event Sourcing để tối ưu hóa hiệu suất và khả năng mở rộng.

**Ưu điểm**:
- Tối ưu hóa hiệu suất cho cả operations đọc và ghi.
- Khả năng mở rộng độc lập cho read và write models.
- Hỗ trợ tốt cho các truy vấn phức tạp và báo cáo.
- Phù hợp với Event Sourcing.

**Nhược điểm**:
- Tăng độ phức tạp của hệ thống.
- Có thể có độ trễ trong việc đồng bộ hóa giữa read và write models.
- Cần xử lý eventual consistency.

Trong NextFlow CRM-AI, CQRS được áp dụng cho:

1. **Order Service**: Tách biệt write model (xử lý commands như tạo đơn, cập nhật trạng thái) và read model (truy vấn thông tin đơn hàng, báo cáo).

2. **Analytics Service**: Sử dụng read model riêng biệt được tối ưu hóa cho các truy vấn phức tạp và báo cáo.

```
+------------------+     +------------------+
|                  |     |                  |
| Command API      |     | Query API        |
|                  |     |                  |
+--------+---------+     +--------+---------+
         |                        |
         v                        v
+------------------+     +------------------+
|                  |     |                  |
| Write Model      |     | Read Model       |
| (PostgreSQL)     |     | (ClickHouse)     |
|                  |     |                  |
+------------------+     +------------------+
         |
         v
+------------------+
|                  |
| Event Store      |
| (Kafka)          |
|                  |
+------------------+
```

Bằng cách kết hợp các patterns quản lý dữ liệu này, NextFlow CRM-AI có thể đạt được sự cân bằng giữa tính độc lập của các services và tính nhất quán của dữ liệu, đồng thời tối ưu hóa hiệu suất và khả năng mở rộng của hệ thống.

## 8. DEPLOYMENT VÀ ORCHESTRATION

Triển khai và quản lý một hệ thống microservices đòi hỏi các công cụ và quy trình hiện đại để đảm bảo tính nhất quán, độ tin cậy và khả năng mở rộng. NextFlow CRM-AI sử dụng các công nghệ containerization và orchestration để đơn giản hóa việc triển khai và quản lý hệ thống.

### 8.1. Containerization

Containerization là quá trình đóng gói ứng dụng và các dependencies của nó thành một container độc lập, có thể chạy trên bất kỳ môi trường nào hỗ trợ container runtime. NextFlow CRM-AI sử dụng Docker làm công nghệ containerization chính.

**Lợi ích của containerization**:
- **Tính nhất quán**: Đảm bảo ứng dụng chạy giống nhau trên mọi môi trường.
- **Cô lập**: Các containers hoạt động độc lập, không ảnh hưởng lẫn nhau.
- **Hiệu quả tài nguyên**: Sử dụng tài nguyên hiệu quả hơn so với máy ảo.
- **Khởi động nhanh**: Containers khởi động trong vài giây.
- **Khả năng mở rộng**: Dễ dàng mở rộng bằng cách tạo thêm container instances.

**Chiến lược containerization của NextFlow CRM-AI**:

1. **Multi-stage builds**: Sử dụng multi-stage builds để tối ưu hóa kích thước image và bảo mật.

```dockerfile
# Build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package*.json ./

USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]
```

2. **Base images**: Sử dụng các base images nhẹ và an toàn (alpine, distroless).

3. **Image versioning**: Sử dụng semantic versioning và git commit hash để đánh version cho images.

4. **Container registry**: Lưu trữ images trong private container registry với image scanning.

5. **Security best practices**:
   - Chạy containers với non-root user
   - Sử dụng read-only filesystem khi có thể
   - Giới hạn capabilities
   - Quét lỗ hổng bảo mật trong images

### 8.2. Kubernetes Deployment

Kubernetes là một platform orchestration cho các containers, giúp tự động hóa việc triển khai, mở rộng và quản lý các ứng dụng containerized. NextFlow CRM-AI sử dụng Kubernetes để quản lý và điều phối các microservices.

**Kiến trúc Kubernetes của NextFlow CRM-AI**:

1. **Cluster Configuration**:
   - Control Plane: 3 nodes cho high availability
   - Worker Nodes: Tối thiểu 6 nodes, chia thành các node pools khác nhau
   - Managed Kubernetes Service (AKS, EKS, hoặc GKE)

2. **Namespace Organization**:
   - `nextflow-prod`: Môi trường production
   - `nextflow-staging`: Môi trường staging
   - `nextflow-dev`: Môi trường development
   - `nextflow-system`: Các components hệ thống (monitoring, logging, etc.)

3. **Deployment Strategy**:
   - Rolling updates với maxSurge và maxUnavailable được cấu hình
   - Blue/Green deployments cho các thay đổi lớn
   - Canary deployments cho các tính năng mới

4. **Resource Management**:
   - Resource requests và limits được định nghĩa cho mỗi container
   - Horizontal Pod Autoscaler dựa trên CPU, memory và custom metrics
   - Cluster Autoscaler để tự động mở rộng cluster

5. **Configuration Management**:
   - ConfigMaps cho non-sensitive configuration
   - Secrets cho sensitive data
   - External Secrets Operator để tích hợp với Vault

Ví dụ về Kubernetes Deployment cho một service:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: customer-service
  namespace: nextflow-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: customer-service
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: customer-service
    spec:
      containers:
      - name: customer-service
        image: nextflow/customer-service:1.2.3
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 200m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 20
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: customer-service-config
              key: db.host
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: customer-service-secrets
              key: db.password
```

### 8.3. Service Mesh

Service Mesh là một lớp infrastructure dành riêng cho việc xử lý giao tiếp giữa các services, cung cấp các tính năng như service discovery, load balancing, encryption, observability, và resilience. NextFlow CRM-AI sử dụng Istio làm service mesh.

**Tính năng của Service Mesh trong NextFlow CRM-AI**:

1. **Traffic Management**:
   - Định tuyến thông minh (A/B testing, canary deployments)
   - Load balancing nâng cao (weighted, locality-aware)
   - Circuit breaking và fault injection
   - Retry và timeout

2. **Security**:
   - mTLS (mutual TLS) giữa các services
   - Authorization policies
   - Certificate management

3. **Observability**:
   - Distributed tracing (tích hợp với Jaeger)
   - Metrics collection (tích hợp với Prometheus)
   - Access logging

4. **Policy Enforcement**:
   - Rate limiting
   - Quota management
   - Header manipulation

Ví dụ về Istio VirtualService để định tuyến traffic:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: customer-service
  namespace: nextflow-prod
spec:
  hosts:
  - customer-service
  http:
  - match:
    - headers:
        x-api-version:
          exact: v2
    route:
    - destination:
        host: customer-service-v2
        port:
          number: 8080
      weight: 100
  - route:
    - destination:
        host: customer-service-v1
        port:
          number: 8080
      weight: 100
```

Ví dụ về Istio DestinationRule để cấu hình circuit breaking:

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: customer-service
  namespace: nextflow-prod
spec:
  host: customer-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        http1MaxPendingRequests: 10
        maxRequestsPerConnection: 10
    outlierDetection:
      consecutiveErrors: 5
      interval: 30s
      baseEjectionTime: 30s
```

Bằng cách kết hợp containerization, Kubernetes và service mesh, NextFlow CRM-AI có thể triển khai và quản lý các microservices một cách hiệu quả, đảm bảo tính sẵn sàng, khả năng mở rộng và bảo mật của hệ thống.

## 9. MONITORING VÀ OBSERVABILITY

Trong kiến trúc microservices, monitoring và observability là các yếu tố quan trọng để đảm bảo hệ thống hoạt động hiệu quả và phát hiện sớm các vấn đề. NextFlow CRM-AI áp dụng các công nghệ và practices hiện đại để đạt được khả năng quan sát toàn diện của hệ thống.

### 9.1. Distributed Tracing

Distributed tracing là kỹ thuật theo dõi một request khi nó đi qua nhiều services trong hệ thống microservices. NextFlow CRM-AI sử dụng OpenTelemetry và Jaeger để triển khai distributed tracing.

**Tính năng của distributed tracing trong NextFlow CRM-AI**:

1. **End-to-end Visibility**: Theo dõi toàn bộ hành trình của một request từ khi bắt đầu đến khi kết thúc.

2. **Performance Analysis**: Phân tích hiệu suất của từng service và xác định bottlenecks.

3. **Error Tracking**: Xác định service nào gây ra lỗi trong một chuỗi requests.

4. **Dependency Mapping**: Hiểu rõ các dependencies giữa các services.

**Triển khai distributed tracing**:

1. **Instrumentation**: Sử dụng OpenTelemetry SDK để instrument code.

```java
// Initialize OpenTelemetry
OpenTelemetry openTelemetry = initializeOpenTelemetry();
Tracer tracer = openTelemetry.getTracer("customer-service");

// Create a span
Span span = tracer.spanBuilder("processOrder")
    .setSpanKind(SpanKind.SERVER)
    .startSpan();

try (Scope scope = span.makeCurrent()) {
    // Business logic
    processOrder(orderId);
} catch (Exception e) {
    span.recordException(e);
    span.setStatus(StatusCode.ERROR, e.getMessage());
    throw e;
} finally {
    span.end();
}
```

2. **Context Propagation**: Truyền trace context giữa các services thông qua HTTP headers hoặc message headers.

3. **Sampling**: Áp dụng sampling strategy để giảm overhead.

4. **Visualization**: Sử dụng Jaeger UI để visualize và analyze traces.

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
| Frontend         |     | API Gateway      |     | Auth Service     |
|                  |     |                  |     |                  |
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         v                        v                        v
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
| Order Service    |     | Customer Service |     | Payment Service  |
|                  |     |                  |     |                  |
+--------+---------+     +------------------+     +--------+---------+
         |
         v
+------------------+
|                  |
| Notification     |
| Service          |
|                  |
+------------------+

Trace ID: 7ad6b1f87ad6b1f8
┌─────────┐     ┌─────────┐     ┌─────────┐
│Frontend │     │API      │     │Auth     │
│         │     │Gateway  │     │Service  │
└────┬────┘     └────┬────┘     └────┬────┘
     │                │               │
     │  Request       │               │
     │───────────────>│  Authenticate │
     │                │──────────────>│
     │                │               │
     │                │   Authorized  │
     │                │<──────────────│
     │                │               │
     │                │    ┌─────────┐
     │                │    │Order    │
     │                │    │Service  │
     │                │    └────┬────┘
     │                │         │
     │                │  Create │
     │                │────────>│
     │                │         │    ┌─────────┐
     │                │         │    │Customer │
     │                │         │    │Service  │
     │                │         │    └────┬────┘
     │                │         │         │
     │                │         │  Get    │
     │                │         │────────>│
     │                │         │         │
     │                │         │  Return │
     │                │         │<────────│
     │                │         │
     │                │         │    ┌─────────┐
     │                │         │    │Payment  │
     │                │         │    │Service  │
     │                │         │    └────┬────┘
     │                │         │         │
     │                │         │  Process│
     │                │         │────────>│
     │                │         │         │
     │                │         │  Success│
     │                │         │<────────│
     │                │         │
     │                │  Success│
     │                │<────────│
     │                │         │    ┌─────────┐
     │                │         │    │Notif.   │
     │                │         │    │Service  │
     │                │         │    └────┬────┘
     │                │         │         │
     │                │         │  Send   │
     │                │         │────────>│
     │                │         │         │
     │  Response      │         │         │
     │<───────────────│         │         │
```

### 9.2. Centralized Logging

Centralized logging là việc thu thập, lưu trữ và phân tích logs từ tất cả các services trong một hệ thống tập trung. NextFlow CRM-AI sử dụng ELK Stack (Elasticsearch, Logstash, Kibana) và Fluentd để triển khai centralized logging.

**Tính năng của centralized logging trong NextFlow CRM-AI**:

1. **Log Aggregation**: Thu thập logs từ tất cả các services và infrastructure components.

2. **Structured Logging**: Sử dụng JSON format cho logs để dễ dàng tìm kiếm và phân tích.

3. **Log Correlation**: Kết hợp logs với trace IDs để liên kết logs từ các services khác nhau.

4. **Log Retention**: Lưu trữ logs trong thời gian dài (30 ngày cho hot data, 1 năm cho archived data).

5. **Log Analysis**: Phân tích logs để phát hiện patterns, anomalies và issues.

**Triển khai centralized logging**:

1. **Log Collection**: Sử dụng Fluentd để thu thập logs từ các containers và nodes.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: nextflow-system
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      <parse>
        @type json
        time_format %Y-%m-%dT%H:%M:%S.%NZ
      </parse>
    </source>

    <filter kubernetes.**>
      @type kubernetes_metadata
      kubernetes_url https://kubernetes.default.svc
      bearer_token_file /var/run/secrets/kubernetes.io/serviceaccount/token
      ca_file /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    </filter>

    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch
      port 9200
      logstash_format true
      logstash_prefix k8s
      <buffer>
        @type file
        path /var/log/fluentd-buffers/kubernetes.system.buffer
        flush_mode interval
        retry_type exponential_backoff
        flush_thread_count 2
        flush_interval 5s
        retry_forever
        retry_max_interval 30
        chunk_limit_size 2M
        queue_limit_length 8
        overflow_action block
      </buffer>
    </match>
```

2. **Log Processing**: Sử dụng Logstash để xử lý và enrich logs.

3. **Log Storage**: Lưu trữ logs trong Elasticsearch với index lifecycle management.

4. **Log Visualization**: Sử dụng Kibana để visualize và analyze logs.

Ví dụ về structured log trong NextFlow CRM-AI:

```json
{
  "timestamp": "2023-07-10T15:30:00.123Z",
  "level": "INFO",
  "service": "order-service",
  "traceId": "7ad6b1f87ad6b1f8",
  "spanId": "9a3f5c6b9a3f5c6b",
  "userId": "user_123",
  "tenantId": "tenant_456",
  "message": "Order created successfully",
  "orderId": "ord_6789",
  "orderAmount": 200000,
  "paymentMethod": "credit_card",
  "processingTime": 150
}
```

### 9.3. Metrics Collection

Metrics collection là việc thu thập, lưu trữ và phân tích các metrics từ các services và infrastructure components. NextFlow CRM-AI sử dụng Prometheus và Grafana để triển khai metrics collection.

**Loại metrics trong NextFlow CRM-AI**:

1. **System Metrics**:
   - CPU, memory, disk usage
   - Network I/O
   - Container metrics

2. **Application Metrics**:
   - Request rate, error rate, latency (RED metrics)
   - Active users, sessions
   - Business transactions

3. **Business Metrics**:
   - Orders per minute
   - Revenue
   - Conversion rate
   - Customer acquisition

4. **Custom Metrics**:
   - Service-specific metrics
   - Feature usage
   - Performance indicators

**Triển khai metrics collection**:

1. **Metrics Exposition**: Các services expose metrics thông qua Prometheus endpoints.

```java
// Register metrics in Spring Boot application
@Bean
MeterRegistryCustomizer<MeterRegistry> metricsCommonTags() {
    return registry -> registry.config().commonTags("application", "order-service");
}

// Use metrics in code
@Autowired
private MeterRegistry meterRegistry;

public void processOrder(Order order) {
    Timer.Sample sample = Timer.start(meterRegistry);
    try {
        // Process order
        Counter.builder("orders.processed")
               .tag("paymentMethod", order.getPaymentMethod())
               .tag("status", "success")
               .register(meterRegistry)
               .increment();
    } catch (Exception e) {
        Counter.builder("orders.processed")
               .tag("paymentMethod", order.getPaymentMethod())
               .tag("status", "error")
               .register(meterRegistry)
               .increment();
        throw e;
    } finally {
        sample.stop(Timer.builder("orders.processing.time")
                    .tag("paymentMethod", order.getPaymentMethod())
                    .register(meterRegistry));
    }
}
```

2. **Metrics Collection**: Prometheus scrapes metrics từ các endpoints.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: nextflow-system
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          - action: labelmap
            regex: __meta_kubernetes_pod_label_(.+)
          - source_labels: [__meta_kubernetes_namespace]
            action: replace
            target_label: kubernetes_namespace
          - source_labels: [__meta_kubernetes_pod_name]
            action: replace
            target_label: kubernetes_pod_name
```

3. **Metrics Storage**: Prometheus lưu trữ time series data.

4. **Metrics Visualization**: Grafana visualize metrics thông qua dashboards.

5. **Alerting**: Prometheus AlertManager gửi alerts dựa trên rules.

```yaml
groups:
- name: example
  rules:
  - alert: HighErrorRate
    expr: sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.01
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: High error rate detected
      description: Error rate is above 1% for the last 5 minutes (current value: {{ $value }})
```

Bằng cách kết hợp distributed tracing, centralized logging và metrics collection, NextFlow CRM-AI có thể đạt được khả năng quan sát toàn diện của hệ thống, giúp phát hiện và giải quyết các vấn đề một cách nhanh chóng và hiệu quả.

## 10. TÀI LIỆU LIÊN QUAN

- [Kiến trúc tổng thể](./kien-truc-tong-the.md) - Tổng quan về kiến trúc hệ thống NextFlow CRM-AI
- [Kiến trúc multi-tenant](./kien-truc-multi-tenant.md) - Chi tiết về thiết kế và triển khai multi-tenant
- [Kiến trúc triển khai](./kien-truc-trien-khai.md) - Chi tiết về kiến trúc triển khai
- [Kiến trúc mạng và bảo mật](./kien-truc-mang-va-bao-mat.md) - Chi tiết về kiến trúc mạng và bảo mật
- [Kiến trúc dự phòng và khôi phục](./kien-truc-du-phong-va-khoi-phuc.md) - Chi tiết về dự phòng và khôi phục
- [Kiến trúc giám sát](./kien-truc-giam-sat.md) - Chi tiết về kiến trúc giám sát
- [Kiến trúc database](./kien-truc-database.md) - Chi tiết về kiến trúc cơ sở dữ liệu
- [Kiến trúc frontend](./kien-truc-frontend.md) - Chi tiết về kiến trúc frontend
- [Kiến trúc API](./kien-truc-api.md) - Chi tiết về kiến trúc API
- [Kiến trúc AI](./kien-truc-ai.md) - Chi tiết về kiến trúc tích hợp AI

## 11. KẾT LUẬN

Kiến trúc microservices của NextFlow CRM-AI được thiết kế để đạt được tính linh hoạt, khả năng mở rộng, độ tin cậy và khả năng phát triển độc lập các thành phần. Bằng cách áp dụng các nguyên tắc và patterns hiện đại, NextFlow CRM-AI có thể đáp ứng nhu cầu ngày càng tăng của người dùng và thích ứng nhanh chóng với các thay đổi của thị trường.

Các thành phần chính của kiến trúc microservices NextFlow CRM-AI bao gồm:

1. **Phân chia microservices** dựa trên domain-driven design, giúp tạo ra các services có tính độc lập và tự chủ cao.

2. **Giao tiếp giữa các services** thông qua RESTful APIs, GraphQL và message brokers, đảm bảo tính linh hoạt và độ tin cậy trong giao tiếp.

3. **Service discovery và registry** giúp các services tìm thấy và giao tiếp với nhau một cách đáng tin cậy.

4. **Resilience patterns** như circuit breaker, bulkhead, timeout, retry và fallback, giúp hệ thống chịu đựng và phục hồi từ các lỗi.

5. **Data management** với các patterns như database per service, event sourcing và CQRS, giúp quản lý dữ liệu hiệu quả trong môi trường phân tán.

6. **Deployment và orchestration** sử dụng containerization, Kubernetes và service mesh, giúp triển khai và quản lý hệ thống một cách hiệu quả.

7. **Monitoring và observability** thông qua distributed tracing, centralized logging và metrics collection, giúp phát hiện và giải quyết các vấn đề một cách nhanh chóng.

Kiến trúc microservices mang lại nhiều lợi ích cho NextFlow CRM-AI, nhưng cũng đi kèm với các thách thức về độ phức tạp, quản lý dữ liệu phân tán và vận hành. Để giải quyết các thách thức này, NextFlow CRM-AI áp dụng các công nghệ và practices hiện đại, cùng với quy trình DevOps và SRE.

Trong tương lai, kiến trúc microservices của NextFlow CRM-AI sẽ tiếp tục phát triển để đáp ứng các yêu cầu mới và áp dụng các công nghệ tiên tiến như serverless computing, edge computing và AI/ML. Việc liên tục cải tiến kiến trúc và áp dụng các best practices sẽ giúp NextFlow CRM-AI duy trì lợi thế cạnh tranh và cung cấp giá trị tốt nhất cho khách hàng.
