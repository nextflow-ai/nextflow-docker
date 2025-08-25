# MONITORING VÀ LOGGING

## 1. GIỚI THIỆU

Tài liệu này mô tả hệ thống monitoring và logging của NextFlow CRM-AI, bao gồm các công cụ, cấu hình và quy trình để giám sát, ghi log và phát hiện vấn đề trong hệ thống. Một hệ thống monitoring và logging hiệu quả là yếu tố quan trọng để đảm bảo tính khả dụng, hiệu suất và bảo mật của hệ thống.

### 1.1. Mục đích

- Cung cấp hướng dẫn chi tiết về hệ thống monitoring và logging
- Mô tả các công cụ và cấu hình được sử dụng
- Xác định các metrics và logs quan trọng cần theo dõi
- Thiết lập quy trình phát hiện và xử lý sự cố
- Đảm bảo tính khả dụng và hiệu suất của hệ thống

### 1.2. Phạm vi

Tài liệu này áp dụng cho tất cả các thành phần của hệ thống NextFlow CRM-AI, bao gồm:

- Backend services (NestJS)
- Frontend applications (Next.js)
- Database (PostgreSQL)
- Cache (Redis)
- Message queue (RabbitMQ)
- API Gateway (Kong)
- Infrastructure (Kubernetes, Docker)
- Third-party integrations (n8n, Flowise)

## 2. KIẾN TRÚC MONITORING VÀ LOGGING

### 2.1. Tổng quan kiến trúc

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Applications    |     |  Infrastructure  |     |  External        |
|                  |     |                  |     |  Services        |
|  - Backend       |     |  - Kubernetes    |     |                  |
|  - Frontend      |     |  - Docker        |     |  - n8n           |
|  - Database      |     |  - Network       |     |  - Flowise       |
|  - Cache         |     |  - Storage       |     |  - Marketplace   |
|  - Message Queue |     |                  |     |  APIs            |
|                  |     |                  |     |                  |
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         v                        v                        v
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Metrics         |     |  Logs            |     |  Traces          |
|  Collection      |     |  Collection      |     |  Collection      |
|                  |     |                  |     |                  |
|  - Prometheus    |     |  - Fluentd       |     |  - Jaeger        |
|  - Node Exporter |     |  - Filebeat      |     |  - OpenTelemetry |
|                  |     |                  |     |                  |
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         v                        v                        v
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  Storage         |     |  Storage         |     |  Storage         |
|                  |     |                  |     |                  |
|  - Prometheus    |     |  - Elasticsearch |     |  - Jaeger        |
|  - VictoriaMetrics|    |  - Loki          |     |                  |
|                  |     |                  |     |                  |
+--------+---------+     +--------+---------+     +--------+---------+
         |                        |                        |
         v                        v                        v
+------------------------------------------------------------------+
|                                                                  |
|                       Visualization & Alerting                   |
|                                                                  |
|  - Grafana (Dashboards)                                          |
|  - Alertmanager (Alerts)                                         |
|  - Kibana (Log Analysis)                                         |
|                                                                  |
+------------------------------------------------------------------+
```

### 2.2. Thành phần chính

#### 2.2.1. Metrics Collection

- **Prometheus**: Thu thập và lưu trữ metrics từ các services
- **Node Exporter**: Thu thập metrics từ các máy chủ
- **Kubernetes Exporter**: Thu thập metrics từ Kubernetes
- **Custom Exporters**: Thu thập metrics từ các dịch vụ cụ thể (PostgreSQL, Redis, RabbitMQ)

#### 2.2.2. Logs Collection

- **Fluentd**: Thu thập logs từ các containers và services
- **Filebeat**: Thu thập logs từ các file logs
- **Logstash**: Xử lý và chuyển đổi logs

#### 2.2.3. Traces Collection

- **Jaeger**: Thu thập và phân tích distributed traces
- **OpenTelemetry**: Chuẩn hóa việc thu thập traces

#### 2.2.4. Storage

- **Prometheus**: Lưu trữ metrics
- **VictoriaMetrics**: Lưu trữ metrics dài hạn
- **Elasticsearch**: Lưu trữ và tìm kiếm logs
- **Loki**: Lưu trữ logs với chi phí thấp

#### 2.2.5. Visualization & Alerting

- **Grafana**: Tạo dashboards và visualizations
- **Alertmanager**: Quản lý và gửi cảnh báo
- **Kibana**: Phân tích và tìm kiếm logs

## 3. MONITORING

### 3.1. Metrics Collection

#### 3.1.1. Application Metrics

NextFlow CRM-AI thu thập các metrics sau từ các services:

- **HTTP Metrics**:
  - Request count
  - Request duration
  - Request size
  - Response size
  - Error count

- **Database Metrics**:
  - Query count
  - Query duration
  - Connection pool stats
  - Transaction count

- **Cache Metrics**:
  - Hit rate
  - Miss rate
  - Latency
  - Memory usage

- **Message Queue Metrics**:
  - Queue size
  - Message rate
  - Consumer lag
  - Processing time

#### 3.1.2. Infrastructure Metrics

- **Node Metrics**:
  - CPU usage
  - Memory usage
  - Disk I/O
  - Network I/O
  - File system usage

- **Kubernetes Metrics**:
  - Pod status
  - Node status
  - Deployment status
  - Resource usage

- **Container Metrics**:
  - CPU usage
  - Memory usage
  - Network I/O
  - Restart count

### 3.2. Prometheus Configuration

#### 3.2.1. Cấu hình cơ bản

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'NextFlow-api'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['api:3000']
    
  - job_name: 'NextFlow-worker'
    metrics_path: '/metrics'
    static_configs:
      - targets: ['worker:3001']
    
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    
  - job_name: 'postgres-exporter'
    static_configs:
      - targets: ['postgres-exporter:9187']
    
  - job_name: 'redis-exporter'
    static_configs:
      - targets: ['redis-exporter:9121']
    
  - job_name: 'rabbitmq-exporter'
    static_configs:
      - targets: ['rabbitmq-exporter:9419']
```

#### 3.2.2. Tích hợp với NestJS

```typescript
// metrics.module.ts
import { Module } from '@nestjs/common';
import { PrometheusModule } from '@willsoto/nestjs-prometheus';
import { MetricsController } from './metrics.controller';

@Module({
  imports: [
    PrometheusModule.register({
      defaultMetrics: {
        enabled: true,
      },
    }),
  ],
  controllers: [MetricsController],
})
export class MetricsModule {}

// metrics.controller.ts
import { Controller, Get } from '@nestjs/common';
import { PrometheusController } from '@willsoto/nestjs-prometheus';

@Controller('metrics')
export class MetricsController extends PrometheusController {}

// http.metrics.ts
import { Injectable } from '@nestjs/common';
import { Counter, Histogram } from 'prom-client';
import { InjectMetric } from '@willsoto/nestjs-prometheus';

@Injectable()
export class HttpMetricsService {
  constructor(
    @InjectMetric('http_requests_total')
    private readonly requestCounter: Counter<string>,
    @InjectMetric('http_request_duration_seconds')
    private readonly requestDuration: Histogram<string>,
  ) {}

  recordRequest(method: string, route: string, status: number) {
    this.requestCounter.inc({ method, route, status });
  }

  recordRequestDuration(method: string, route: string, duration: number) {
    this.requestDuration.observe({ method, route }, duration);
  }
}
```

### 3.3. Grafana Dashboards

#### 3.3.1. System Overview Dashboard

- CPU, Memory, Disk, Network usage
- Node status
- Container status

#### 3.3.2. Application Dashboard

- Request rate
- Error rate
- Response time (p50, p90, p99)
- Active users
- Business metrics (orders, users, etc.)

#### 3.3.3. Database Dashboard

- Query performance
- Connection pool
- Transaction rate
- Table size
- Index usage

#### 3.3.4. Custom Business Dashboards

- User registration rate
- Order completion rate
- Revenue metrics
- Marketplace integration status

### 3.4. Alerting

#### 3.4.1. Alert Rules

```yaml
groups:
  - name: NextFlow-alerts
    rules:
      - alert: HighCPUUsage
        expr: avg(rate(node_cpu_seconds_total{mode!="idle"}[5m])) by (instance) > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% for 5 minutes"
      
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 90% for 5 minutes"
      
      - alert: HighErrorRate
        expr: sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m])) > 0.05
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "High error rate"
          description: "Error rate is above 5% for 1 minute"
```

#### 3.4.2. Alertmanager Configuration

```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'job']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: 'slack'
  routes:
    - match:
        severity: critical
      receiver: 'pagerduty'
      continue: true

receivers:
  - name: 'slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX'
        channel: '#monitoring'
        title: '{{ .GroupLabels.alertname }}'
        text: '{{ .CommonAnnotations.description }}'
  
  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: 'your_pagerduty_service_key'
```

## 4. LOGGING

### 4.1. Log Levels

NextFlow CRM-AI sử dụng các log levels sau:

- **ERROR**: Lỗi nghiêm trọng ảnh hưởng đến hoạt động của hệ thống
- **WARN**: Cảnh báo về các vấn đề tiềm ẩn
- **INFO**: Thông tin chung về hoạt động của hệ thống
- **DEBUG**: Thông tin chi tiết hữu ích cho debugging
- **TRACE**: Thông tin rất chi tiết, thường chỉ được bật khi cần debug sâu

### 4.2. Log Format

Logs được định dạng theo chuẩn JSON để dễ dàng phân tích:

```json
{
  "timestamp": "2023-10-25T10:15:30.123Z",
  "level": "INFO",
  "service": "api",
  "traceId": "1234567890abcdef",
  "userId": "user_123456",
  "tenantId": "tenant_123456",
  "message": "User logged in successfully",
  "context": {
    "ip": "192.168.1.1",
    "userAgent": "Mozilla/5.0...",
    "method": "POST",
    "path": "/auth/login"
  }
}
```

### 4.3. Logging trong NestJS

```typescript
// logger.module.ts
import { Module } from '@nestjs/common';
import { WinstonModule } from 'nest-winston';
import * as winston from 'winston';

@Module({
  imports: [
    WinstonModule.forRoot({
      transports: [
        new winston.transports.Console({
          format: winston.format.combine(
            winston.format.timestamp(),
            winston.format.json(),
          ),
        }),
      ],
    }),
  ],
  exports: [WinstonModule],
})
export class LoggerModule {}

// app.module.ts
import { Module } from '@nestjs/common';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { LoggerModule } from './logger.module';
import { LoggingInterceptor } from './logging.interceptor';

@Module({
  imports: [LoggerModule],
  providers: [
    {
      provide: APP_INTERCEPTOR,
      useClass: LoggingInterceptor,
    },
  ],
})
export class AppModule {}

// logging.interceptor.ts
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { Logger } from 'winston';
import { InjectLogger } from 'nest-winston';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  constructor(@InjectLogger() private readonly logger: Logger) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const { method, path, ip, headers } = request;
    const userAgent = headers['user-agent'] || '';
    const userId = request.user?.id || 'anonymous';
    const tenantId = request.tenantId || 'unknown';
    
    const now = Date.now();
    
    return next.handle().pipe(
      tap({
        next: (data) => {
          const response = context.switchToHttp().getResponse();
          const statusCode = response.statusCode;
          const responseTime = Date.now() - now;
          
          this.logger.info('Request completed', {
            method,
            path,
            statusCode,
            responseTime,
            ip,
            userAgent,
            userId,
            tenantId,
          });
        },
        error: (error) => {
          const statusCode = error.status || 500;
          const responseTime = Date.now() - now;
          
          this.logger.error('Request failed', {
            method,
            path,
            statusCode,
            responseTime,
            ip,
            userAgent,
            userId,
            tenantId,
            error: {
              name: error.name,
              message: error.message,
              stack: error.stack,
            },
          });
        },
      }),
    );
  }
}
```

### 4.4. Fluentd Configuration

```
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<filter NextFlow.**>
  @type parser
  key_name log
  reserve_data true
  <parse>
    @type json
  </parse>
</filter>

<match NextFlow.**>
  @type elasticsearch
  host elasticsearch
  port 9200
  logstash_format true
  logstash_prefix NextFlow
  include_tag_key true
  tag_key @log_name
  flush_interval 5s
</match>
```

### 4.5. Kibana Dashboards

- **Overview Dashboard**: Tổng quan về logs của hệ thống
- **Error Dashboard**: Hiển thị các lỗi và cảnh báo
- **API Dashboard**: Phân tích API calls và performance
- **User Activity Dashboard**: Theo dõi hoạt động của người dùng
- **Security Dashboard**: Phát hiện các vấn đề bảo mật

## 5. DISTRIBUTED TRACING

### 5.1. OpenTelemetry Integration

```typescript
// tracing.module.ts
import { Module } from '@nestjs/common';
import { OpenTelemetryModule } from 'nestjs-otel';

@Module({
  imports: [
    OpenTelemetryModule.forRoot({
      serviceName: 'NextFlow-api',
      spanProcessor: 'batch',
      traceExporter: 'jaeger',
      jaegerExporter: {
        host: 'jaeger',
        port: 6832,
      },
    }),
  ],
})
export class TracingModule {}
```

### 5.2. Jaeger UI

Jaeger UI cung cấp các tính năng:

- Tìm kiếm traces theo nhiều tiêu chí
- Phân tích thời gian thực hiện của từng span
- Visualize luồng xử lý giữa các services
- Phát hiện bottlenecks và lỗi

## 6. MONITORING INFRASTRUCTURE

### 6.1. Kubernetes Monitoring

#### 6.1.1. Prometheus Operator

```yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
  namespace: monitoring
spec:
  serviceAccountName: prometheus
  serviceMonitorSelector:
    matchLabels:
      team: NextFlow
  resources:
    requests:
      memory: 400Mi
  enableAdminAPI: false
```

#### 6.1.2. Service Monitors

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: NextFlow-api
  namespace: monitoring
  labels:
    team: NextFlow
spec:
  selector:
    matchLabels:
      app: NextFlow-api
  endpoints:
  - port: http
    path: /metrics
    interval: 15s
```

### 6.2. Docker Monitoring

```yaml
version: '3'
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
    
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    
  node-exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"
    
  cadvisor:
    image: gcr.io/cadvisor/cadvisor
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
    ports:
      - "8080:8080"
```

## 7. BEST PRACTICES

### 7.1. Monitoring Best Practices

- **Xác định SLIs và SLOs**: Định nghĩa các chỉ số hiệu suất quan trọng
- **Thiết lập baseline**: Xác định ngưỡng bình thường cho các metrics
- **Alerting có ý nghĩa**: Cảnh báo khi có vấn đề thực sự, tránh alert fatigue
- **Phân tầng cảnh báo**: Phân loại cảnh báo theo mức độ nghiêm trọng
- **Tự động hóa**: Tự động hóa việc thu thập và phân tích metrics

### 7.2. Logging Best Practices

- **Structured logging**: Sử dụng định dạng có cấu trúc (JSON)
- **Contextual information**: Bao gồm thông tin ngữ cảnh (user, tenant, trace ID)
- **Log rotation**: Thiết lập rotation để quản lý kích thước logs
- **Log levels**: Sử dụng log levels phù hợp
- **Sensitive data**: Không log thông tin nhạy cảm (passwords, tokens)

### 7.3. Tracing Best Practices

- **Sampling**: Thiết lập sampling rate phù hợp
- **Consistent trace IDs**: Đảm bảo trace IDs được truyền qua các services
- **Meaningful span names**: Đặt tên spans rõ ràng và có ý nghĩa
- **Span attributes**: Thêm attributes hữu ích cho spans
- **Error tagging**: Đánh dấu spans có lỗi

## 8. TROUBLESHOOTING

### 8.1. Common Issues

#### 8.1.1. High CPU/Memory Usage

1. Kiểm tra Grafana dashboard để xác định service nào sử dụng nhiều tài nguyên
2. Xem logs của service đó để tìm dấu hiệu bất thường
3. Kiểm tra traces để xác định các operations tốn nhiều thời gian
4. Kiểm tra code và queries để tối ưu hóa

#### 8.1.2. High Error Rate

1. Kiểm tra logs để xác định loại lỗi
2. Phân tích error distribution theo endpoint, user, tenant
3. Kiểm tra traces của các requests lỗi
4. Xác định nguyên nhân gốc rễ và khắc phục

#### 8.1.3. Slow Response Time

1. Kiểm tra latency metrics để xác định endpoint nào chậm
2. Xem traces để xác định bottleneck
3. Kiểm tra database performance
4. Kiểm tra external service calls
5. Tối ưu hóa code và queries

### 8.2. Debugging Tools

- **Prometheus Query Language (PromQL)**: Truy vấn và phân tích metrics
- **Kibana Query Language (KQL)**: Tìm kiếm và lọc logs
- **Jaeger UI**: Phân tích distributed traces
- **kubectl logs**: Xem logs của pods trong Kubernetes
- **kubectl exec**: Truy cập vào containers để debug

## 9. KẾT LUẬN

Hệ thống monitoring và logging là thành phần quan trọng của NextFlow CRM-AI, giúp đảm bảo tính khả dụng, hiệu suất và bảo mật của hệ thống. Bằng cách tuân thủ các best practices và sử dụng các công cụ phù hợp, chúng ta có thể phát hiện và giải quyết các vấn đề trước khi chúng ảnh hưởng đến người dùng.

Tài liệu này sẽ được cập nhật thường xuyên để phản ánh các thay đổi trong hệ thống và công nghệ mới.
