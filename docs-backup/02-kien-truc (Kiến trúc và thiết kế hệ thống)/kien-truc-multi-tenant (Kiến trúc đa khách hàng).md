# KIẾN TRÚC MULTI-TENANT

## Mục lục

1. [GIỚI THIỆU](#1-giới-thiệu)
   - [Định nghĩa Multi-tenant](#11-định-nghĩa-multi-tenant)
   - [Lợi ích của Multi-tenant](#12-lợi-ích-của-multi-tenant)
2. [CHIẾN LƯỢC MULTI-TENANT](#2-chiến-lược-multi-tenant)
   - [Các mô hình Multi-tenant](#21-các-mô-hình-multi-tenant)
   - [Chiến lược Multi-tenant của NextFlow CRM-AI](#22-chiến-lược-multi-tenant-của-nextFlow-crm)
3. [THIẾT KẾ MULTI-TENANT](#3-thiết-kế-multi-tenant)
   - [Kiến trúc tổng thể](#31-kiến-trúc-tổng-thể)
   - [Tenant Resolution](#32-tenant-resolution)
   - [Tenant Context](#33-tenant-context)
   - [Data Isolation](#34-data-isolation)
4. [TRIỂN KHAI MULTI-TENANT](#4-triển-khai-multi-tenant)
   - [Khởi tạo tenant mới](#41-khởi-tạo-tenant-mới)
   - [Quản lý tenant](#42-quản-lý-tenant)
   - [Mở rộng theo chiều ngang](#43-mở-rộng-theo-chiều-ngang)
5. [BẢO MẬT MULTI-TENANT](#5-bảo-mật-multi-tenant)
   - [Cách ly dữ liệu](#51-cách-ly-dữ-liệu)
   - [Phòng chống tấn công](#52-phòng-chống-tấn-công)
   - [Giám sát và cảnh báo](#53-giám-sát-và-cảnh-báo)
6. [HIỆU SUẤT VÀ TỐI ƯU HÓA](#6-hiệu-suất-và-tối-ưu-hóa)
   - [Tối ưu hóa database](#61-tối-ưu-hóa-database)
   - [Caching](#62-caching)
   - [Giám sát hiệu suất](#63-giám-sát-hiệu-suất)
7. [QUẢN LÝ TENANT](#7-quản-lý-tenant)
   - [Onboarding tenant mới](#71-onboarding-tenant-mới)
   - [Quản lý vòng đời tenant](#72-quản-lý-vòng-đời-tenant)
   - [Billing và Quota](#73-billing-và-quota)
8. [KẾT LUẬN](#8-kết-luận)

## 1. GIỚI THIỆU

Kiến trúc multi-tenant (đa người thuê) là một trong những đặc điểm quan trọng của NextFlow CRM-AI, cho phép hệ thống phục vụ nhiều tổ chức khách hàng trên cùng một cơ sở hạ tầng. Tài liệu này mô tả chi tiết về thiết kế và triển khai kiến trúc multi-tenant trong hệ thống.

### 1.1. Định nghĩa Multi-tenant

Multi-tenant là mô hình kiến trúc phần mềm trong đó một phiên bản ứng dụng duy nhất phục vụ nhiều khách hàng (tenant). Mỗi khách hàng có một "không gian" riêng biệt trong ứng dụng, với dữ liệu và cấu hình riêng, nhưng chia sẻ cùng một cơ sở hạ tầng, mã nguồn và tài nguyên tính toán.

### 1.2. Lợi ích của Multi-tenant

- **Hiệu quả về chi phí**: Chia sẻ tài nguyên giữa các tenant giúp giảm chi phí vận hành
- **Bảo trì dễ dàng**: Chỉ cần cập nhật một phiên bản duy nhất của ứng dụng
- **Khả năng mở rộng**: Dễ dàng thêm tenant mới mà không cần triển khai lại toàn bộ hệ thống
- **Tối ưu hóa tài nguyên**: Sử dụng hiệu quả tài nguyên phần cứng và phần mềm
- **Nâng cấp đồng bộ**: Tất cả tenant được nâng cấp cùng một lúc, đảm bảo tính nhất quán

## 2. CHIẾN LƯỢC MULTI-TENANT

### 2.1. Các mô hình Multi-tenant

NextFlow CRM-AI hỗ trợ ba mô hình multi-tenant chính, mỗi mô hình có ưu và nhược điểm riêng:

#### 2.1.1. Mô hình Database riêng biệt

```
[Application] ---> [Tenant 1 Database]
              ---> [Tenant 2 Database]
              ---> [Tenant N Database]
```

**Ưu điểm**:
- Cách ly dữ liệu hoàn toàn giữa các tenant
- Dễ dàng sao lưu và khôi phục dữ liệu cho từng tenant
- Hiệu suất ổn định, không bị ảnh hưởng bởi tenant khác
- Dễ dàng di chuyển tenant giữa các máy chủ

**Nhược điểm**:
- Chi phí cao hơn do cần nhiều instance database
- Quản lý phức tạp hơn khi số lượng tenant tăng
- Sử dụng tài nguyên kém hiệu quả hơn

#### 2.1.2. Mô hình Schema riêng biệt

```
[Application] ---> [Database]
                    |
                    +---> [Tenant 1 Schema]
                    +---> [Tenant 2 Schema]
                    +---> [Tenant N Schema]
```

**Ưu điểm**:
- Cách ly dữ liệu tốt giữa các tenant
- Chi phí thấp hơn mô hình database riêng biệt
- Dễ dàng quản lý quyền truy cập ở cấp schema
- Hiệu suất tương đối ổn định

**Nhược điểm**:
- Giới hạn về số lượng schema trong một database
- Khó khăn hơn trong việc di chuyển tenant
- Vẫn có thể bị ảnh hưởng hiệu suất nếu một tenant sử dụng nhiều tài nguyên

#### 2.1.3. Mô hình Bảng chia sẻ

```
[Application] ---> [Database]
                    |
                    +---> [Shared Tables with Tenant ID]
```

**Ưu điểm**:
- Chi phí thấp nhất
- Sử dụng tài nguyên hiệu quả nhất
- Dễ dàng triển khai và quản lý
- Phù hợp với số lượng tenant lớn

**Nhược điểm**:
- Cách ly dữ liệu kém hơn
- Rủi ro về bảo mật cao hơn
- Hiệu suất có thể bị ảnh hưởng bởi tenant khác
- Phức tạp hơn trong việc sao lưu và khôi phục dữ liệu cho từng tenant

### 2.2. Chiến lược Multi-tenant của NextFlow CRM-AI

NextFlow CRM-AI sử dụng chiến lược multi-tenant kết hợp, tận dụng ưu điểm của cả ba mô hình:

1. **Mô hình cơ bản**: Schema riêng biệt cho hầu hết các tenant
2. **Mô hình nâng cao**: Database riêng biệt cho tenant lớn hoặc có yêu cầu bảo mật cao
3. **Mô hình hybrid**: Một số bảng dùng chung (như cấu hình hệ thống) sử dụng mô hình bảng chia sẻ

Chiến lược này cho phép:
- Cân bằng giữa chi phí và hiệu suất
- Đáp ứng nhu cầu đa dạng của các tenant
- Mở rộng linh hoạt khi số lượng tenant tăng
- Đảm bảo cách ly dữ liệu và bảo mật

## 3. THIẾT KẾ MULTI-TENANT

### 3.1. Kiến trúc tổng thể

```
[Client Applications] ---> [API Gateway]
                             |
                             v
                      [Authentication &
                       Tenant Resolution]
                             |
                             v
                      [Application Services]
                             |
                             v
                      [Data Access Layer]
                             |
                             v
                      [Database Cluster]
```

### 3.2. Tenant Resolution

Quá trình xác định tenant cho mỗi yêu cầu:

1. **Dựa trên subdomain**: Mỗi tenant có một subdomain riêng (tenant1.nextFlow.com)
2. **Dựa trên header**: Sử dụng HTTP header (X-Tenant-ID) để xác định tenant
3. **Dựa trên token**: Thông tin tenant được mã hóa trong JWT token
4. **Dựa trên path**: Tenant ID là một phần của URL path (/api/tenant1/...)

NextFlow CRM-AI sử dụng kết hợp các phương pháp này, với subdomain là phương pháp chính.

### 3.3. Tenant Context

Sau khi xác định tenant, thông tin tenant được lưu trong context và truyền qua các lớp của ứng dụng:

```typescript
// tenant.middleware.ts
import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { TenantService } from './tenant.service';

@Injectable()
export class TenantMiddleware implements NestMiddleware {
  constructor(private tenantService: TenantService) {}

  async use(req: Request, res: Response, next: NextFunction) {
    // Xác định tenant từ request
    const tenantId = this.resolveTenant(req);

    if (tenantId) {
      // Lấy thông tin tenant
      const tenant = await this.tenantService.getTenantById(tenantId);

      if (tenant) {
        // Lưu thông tin tenant vào request
        req['tenantId'] = tenantId;
        req['tenant'] = tenant;
      }
    }

    next();
  }

  private resolveTenant(req: Request): string | null {
    // Thử lấy từ subdomain
    const host = req.headers.host;
    if (host && host.includes('.')) {
      const subdomain = host.split('.')[0];
      if (subdomain !== 'www' && subdomain !== 'api') {
        return subdomain;
      }
    }

    // Thử lấy từ header
    const tenantHeader = req.headers['x-tenant-id'];
    if (tenantHeader) {
      return tenantHeader.toString();
    }

    // Thử lấy từ token
    // Implement logic here

    return null;
  }
}
```

### 3.4. Data Isolation

Cách ly dữ liệu giữa các tenant:

#### 3.4.1. Cách ly ở tầng ứng dụng

```typescript
// tenant-aware.repository.ts
import { Repository, EntityManager } from 'typeorm';
import { Injectable } from '@nestjs/common';
import { TenantContext } from './tenant-context';

@Injectable()
export class TenantAwareRepository<T> extends Repository<T> {
  constructor(
    private readonly tenantContext: TenantContext,
    entityManager: EntityManager,
    entityType: any,
  ) {
    super(entityType, entityManager);
  }

  async find(options?: any): Promise<T[]> {
    const tenantId = this.tenantContext.getCurrentTenantId();

    if (!options) {
      options = {};
    }

    if (!options.where) {
      options.where = {};
    }

    options.where.tenantId = tenantId;

    return super.find(options);
  }

  // Override other methods similarly
}
```

#### 3.4.2. Cách ly ở tầng database

Đối với mô hình schema riêng biệt:

```typescript
// database.module.ts
import { Module, DynamicModule } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TenantContext } from './tenant-context';

@Module({})
export class DatabaseModule {
  static forRoot(): DynamicModule {
    return {
      module: DatabaseModule,
      imports: [
        TypeOrmModule.forRootAsync({
          useFactory: async (tenantContext: TenantContext) => {
            const tenantId = tenantContext.getCurrentTenantId();
            const tenant = await tenantContext.getCurrentTenant();

            return {
              type: 'postgres',
              host: tenant.dbHost || process.env.DB_HOST,
              port: tenant.dbPort || parseInt(process.env.DB_PORT),
              username: tenant.dbUsername || process.env.DB_USERNAME,
              password: tenant.dbPassword || process.env.DB_PASSWORD,
              database: process.env.DB_DATABASE,
              schema: `tenant_${tenantId}`,
              entities: [__dirname + '/**/*.entity{.ts,.js}'],
              synchronize: false,
            };
          },
          inject: [TenantContext],
        }),
      ],
      exports: [TypeOrmModule],
    };
  }
}
```

## 4. TRIỂN KHAI MULTI-TENANT

### 4.1. Khởi tạo tenant mới

Quy trình khởi tạo tenant mới:

1. **Đăng ký tenant**: Thu thập thông tin tenant (tên, subdomain, gói dịch vụ)
2. **Tạo cấu trúc dữ liệu**: Tạo schema hoặc database mới
3. **Khởi tạo dữ liệu**: Tạo dữ liệu ban đầu (người dùng admin, cấu hình mặc định)
4. **Cấu hình tenant**: Thiết lập các cấu hình đặc thù cho tenant
5. **Kích hoạt tenant**: Kích hoạt tenant và thông báo cho người dùng

```typescript
// tenant.service.ts
import { Injectable } from '@nestjs/common';
import { InjectEntityManager } from '@nestjs/typeorm';
import { EntityManager, getManager } from 'typeorm';
import { Tenant } from './tenant.entity';

@Injectable()
export class TenantService {
  constructor(
    @InjectEntityManager()
    private readonly entityManager: EntityManager,
  ) {}

  async createTenant(tenantData: any): Promise<Tenant> {
    // 1. Tạo bản ghi tenant trong bảng tenant
    const tenant = await this.entityManager.save(Tenant, {
      name: tenantData.name,
      subdomain: tenantData.subdomain,
      plan: tenantData.plan,
      status: 'initializing',
    });

    // 2. Tạo schema cho tenant
    await this.entityManager.query(`CREATE SCHEMA IF NOT EXISTS tenant_${tenant.id}`);

    // 3. Chạy migration để tạo cấu trúc bảng
    await this.runMigrations(tenant.id);

    // 4. Khởi tạo dữ liệu ban đầu
    await this.initializeTenantData(tenant.id, tenantData);

    // 5. Kích hoạt tenant
    await this.entityManager.update(Tenant, tenant.id, { status: 'active' });

    return tenant;
  }

  private async runMigrations(tenantId: string): Promise<void> {
    // Implement migration logic
  }

  private async initializeTenantData(tenantId: string, tenantData: any): Promise<void> {
    // Tạo người dùng admin
    await this.entityManager.query(`
      SET search_path TO tenant_${tenantId};
      INSERT INTO users (name, email, password, role)
      VALUES ('${tenantData.adminName}', '${tenantData.adminEmail}', '${tenantData.adminPassword}', 'admin');
    `);

    // Tạo cấu hình mặc định
    await this.entityManager.query(`
      SET search_path TO tenant_${tenantId};
      INSERT INTO settings (key, value)
      VALUES
        ('company_name', '${tenantData.name}'),
        ('timezone', '${tenantData.timezone || 'Asia/Ho_Chi_Minh'}'),
        ('currency', '${tenantData.currency || 'VND'}');
    `);
  }
}
```

### 4.2. Quản lý tenant

Các chức năng quản lý tenant:

1. **Danh sách tenant**: Xem và tìm kiếm tenant
2. **Chi tiết tenant**: Xem thông tin chi tiết về tenant
3. **Cập nhật tenant**: Cập nhật thông tin và cấu hình tenant
4. **Tạm dừng tenant**: Tạm dừng hoạt động của tenant
5. **Xóa tenant**: Xóa tenant và dữ liệu liên quan

### 4.3. Mở rộng theo chiều ngang

Khi số lượng tenant tăng lên, hệ thống cần mở rộng theo chiều ngang:

1. **Phân chia tenant**: Phân chia tenant vào các nhóm database
2. **Cân bằng tải**: Sử dụng load balancer để phân phối yêu cầu
3. **Sharding**: Phân chia dữ liệu dựa trên tenant ID
4. **Replica**: Sử dụng replica để tăng hiệu suất đọc
5. **Caching**: Sử dụng cache để giảm tải cho database

```typescript
// database-resolver.service.ts
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { TenantService } from './tenant.service';

@Injectable()
export class DatabaseResolverService {
  private databaseGroups: Map<string, string[]>;

  constructor(
    private configService: ConfigService,
    private tenantService: TenantService,
  ) {
    // Khởi tạo nhóm database
    this.databaseGroups = new Map();

    // Group 1: tenant 1-1000
    this.databaseGroups.set('group1', [
      'postgres-1.nextFlow.internal:5432',
      'postgres-2.nextFlow.internal:5432',
    ]);

    // Group 2: tenant 1001-2000
    this.databaseGroups.set('group2', [
      'postgres-3.nextFlow.internal:5432',
      'postgres-4.nextFlow.internal:5432',
    ]);

    // Thêm các nhóm khác...
  }

  async getDatabaseConnectionForTenant(tenantId: string): Promise<any> {
    // Lấy thông tin tenant
    const tenant = await this.tenantService.getTenantById(tenantId);

    // Nếu tenant có cấu hình database riêng
    if (tenant.dbHost) {
      return {
        host: tenant.dbHost,
        port: tenant.dbPort,
        username: tenant.dbUsername,
        password: tenant.dbPassword,
        database: tenant.dbName,
      };
    }

    // Xác định nhóm database dựa trên tenant ID
    const groupId = this.getGroupIdForTenant(tenantId);
    const servers = this.databaseGroups.get(groupId);

    // Chọn server trong nhóm (đơn giản là round-robin)
    const serverIndex = parseInt(tenantId) % servers.length;
    const server = servers[serverIndex];

    // Parse thông tin server
    const [host, port] = server.split(':');

    return {
      host,
      port: parseInt(port),
      username: this.configService.get('DB_USERNAME'),
      password: this.configService.get('DB_PASSWORD'),
      database: this.configService.get('DB_DATABASE'),
    };
  }

  private getGroupIdForTenant(tenantId: string): string {
    const id = parseInt(tenantId);

    if (id <= 1000) {
      return 'group1';
    } else if (id <= 2000) {
      return 'group2';
    }

    // Mặc định
    return 'group1';
  }
}
```

## 5. BẢO MẬT MULTI-TENANT

### 5.1. Cách ly dữ liệu

Đảm bảo dữ liệu giữa các tenant được cách ly hoàn toàn:

1. **Kiểm tra tenant ID**: Mọi truy vấn đều phải kiểm tra tenant ID
2. **Row-level security**: Sử dụng RLS của PostgreSQL để cách ly dữ liệu
3. **Kiểm soát truy cập**: Phân quyền chi tiết đến cấp schema
4. **Mã hóa dữ liệu**: Mã hóa dữ liệu nhạy cảm
5. **Audit logging**: Ghi nhật ký mọi truy cập và thay đổi dữ liệu

### 5.2. Phòng chống tấn công

Bảo vệ hệ thống khỏi các cuộc tấn công liên quan đến multi-tenant:

1. **Tenant enumeration**: Ngăn chặn việc liệt kê tenant
2. **Tenant hopping**: Ngăn chặn việc chuyển đổi giữa các tenant
3. **Resource abuse**: Giới hạn tài nguyên cho mỗi tenant
4. **SQL injection**: Sử dụng prepared statement và ORM
5. **Cross-tenant data leakage**: Kiểm tra kỹ lưỡng mọi truy vấn

### 5.3. Giám sát và cảnh báo

Giám sát hệ thống để phát hiện và xử lý các vấn đề:

1. **Giám sát truy cập**: Theo dõi các mẫu truy cập bất thường
2. **Giám sát tài nguyên**: Theo dõi việc sử dụng tài nguyên của mỗi tenant
3. **Cảnh báo xâm nhập**: Cảnh báo khi phát hiện dấu hiệu xâm nhập
4. **Cảnh báo hiệu suất**: Cảnh báo khi hiệu suất giảm
5. **Báo cáo định kỳ**: Tạo báo cáo về tình trạng bảo mật

## 6. HIỆU SUẤT VÀ TỐI ƯU HÓA

### 6.1. Tối ưu hóa database

Tối ưu hóa database cho môi trường multi-tenant:

1. **Indexing**: Tạo index cho các cột thường xuyên truy vấn, đặc biệt là tenant_id
2. **Partitioning**: Phân vùng dữ liệu dựa trên tenant_id
3. **Connection pooling**: Sử dụng connection pool để tái sử dụng kết nối
4. **Query optimization**: Tối ưu hóa các truy vấn phức tạp
5. **Database sharding**: Phân chia dữ liệu giữa nhiều database

### 6.2. Caching

Sử dụng cache để giảm tải cho database:

1. **Application cache**: Cache dữ liệu thường xuyên sử dụng trong ứng dụng
2. **Distributed cache**: Sử dụng Redis để cache dữ liệu giữa các instance
3. **Query cache**: Cache kết quả truy vấn
4. **Tenant-aware caching**: Cache dữ liệu theo tenant
5. **Cache invalidation**: Cơ chế hủy cache khi dữ liệu thay đổi

```typescript
// cache.service.ts
import { Injectable } from '@nestjs/common';
import { RedisService } from './redis.service';
import { TenantContext } from './tenant-context';

@Injectable()
export class CacheService {
  constructor(
    private redisService: RedisService,
    private tenantContext: TenantContext,
  ) {}

  async get(key: string): Promise<any> {
    const tenantId = this.tenantContext.getCurrentTenantId();
    const tenantKey = `tenant:${tenantId}:${key}`;

    const cachedData = await this.redisService.get(tenantKey);
    return cachedData ? JSON.parse(cachedData) : null;
  }

  async set(key: string, value: any, ttl?: number): Promise<void> {
    const tenantId = this.tenantContext.getCurrentTenantId();
    const tenantKey = `tenant:${tenantId}:${key}`;

    await this.redisService.set(
      tenantKey,
      JSON.stringify(value),
      ttl,
    );
  }

  async invalidate(key: string): Promise<void> {
    const tenantId = this.tenantContext.getCurrentTenantId();
    const tenantKey = `tenant:${tenantId}:${key}`;

    await this.redisService.del(tenantKey);
  }

  async invalidatePattern(pattern: string): Promise<void> {
    const tenantId = this.tenantContext.getCurrentTenantId();
    const tenantPattern = `tenant:${tenantId}:${pattern}`;

    const keys = await this.redisService.keys(tenantPattern);
    if (keys.length > 0) {
      await this.redisService.del(...keys);
    }
  }
}
```

### 6.3. Giám sát hiệu suất

Giám sát hiệu suất của hệ thống multi-tenant:

1. **Tenant-level metrics**: Thu thập metrics cho từng tenant
2. **Resource usage**: Theo dõi việc sử dụng tài nguyên (CPU, RAM, I/O)
3. **Query performance**: Theo dõi hiệu suất truy vấn
4. **Response time**: Đo thời gian phản hồi cho từng API
5. **Bottleneck detection**: Phát hiện điểm nghẽn trong hệ thống

## 7. QUẢN LÝ TENANT

### 7.1. Onboarding tenant mới

Quy trình onboarding tenant mới:

1. **Đăng ký**: Thu thập thông tin đăng ký
2. **Xác thực**: Xác thực thông tin và thanh toán
3. **Khởi tạo**: Tạo tenant và cấu trúc dữ liệu
4. **Cấu hình**: Thiết lập cấu hình ban đầu
5. **Đào tạo**: Hướng dẫn sử dụng hệ thống

### 7.2. Quản lý vòng đời tenant

Quản lý vòng đời của tenant:

1. **Kích hoạt**: Kích hoạt tenant mới
2. **Vận hành**: Giám sát và hỗ trợ tenant đang hoạt động
3. **Tạm dừng**: Tạm dừng tenant khi cần thiết
4. **Khôi phục**: Khôi phục tenant đã tạm dừng
5. **Hủy bỏ**: Xóa tenant và dữ liệu liên quan

### 7.3. Billing và Quota

Quản lý thanh toán và hạn ngạch cho tenant:

1. **Usage tracking**: Theo dõi việc sử dụng tài nguyên
2. **Billing calculation**: Tính toán chi phí dựa trên mức sử dụng
3. **Quota enforcement**: Áp dụng hạn ngạch theo gói dịch vụ
4. **Overage handling**: Xử lý khi vượt quá hạn ngạch
5. **Billing reports**: Tạo báo cáo thanh toán

## 8. TÀI LIỆU LIÊN QUAN

- [Kiến trúc tổng thể](./kien-truc-tong-the.md) - Tổng quan về kiến trúc hệ thống NextFlow CRM-AI
- [Kiến trúc triển khai](./kien-truc-trien-khai.md) - Chi tiết về kiến trúc triển khai
- [Kiến trúc mạng và bảo mật](./kien-truc-mang-va-bao-mat.md) - Chi tiết về kiến trúc mạng và bảo mật
- [Kiến trúc dự phòng và khôi phục](./kien-truc-du-phong-va-khoi-phuc.md) - Chi tiết về dự phòng và khôi phục
- [Kiến trúc giám sát](./kien-truc-giam-sat.md) - Chi tiết về kiến trúc giám sát
- [Tổng quan dự án](../01-tong-quan/tong-quan-du-an.md) - Giới thiệu tổng quan về dự án NextFlow CRM-AI
- [Tổng quan schema](../05-schema/tong-quan-schema.md) - Tổng quan về schema cơ sở dữ liệu
- [Tổng quan API](../06-api/tong-quan-api.md) - Tổng quan về API của hệ thống

## 9. KẾT LUẬN

Kiến trúc multi-tenant là một phần quan trọng của NextFlow CRM-AI, cho phép hệ thống phục vụ nhiều tổ chức khách hàng trên cùng một cơ sở hạ tầng. Với thiết kế linh hoạt, NextFlow CRM-AI có thể đáp ứng nhu cầu đa dạng của các tenant, từ doanh nghiệp nhỏ đến doanh nghiệp lớn, đồng thời đảm bảo cách ly dữ liệu, bảo mật và hiệu suất.

Việc triển khai multi-tenant đòi hỏi sự cân nhắc kỹ lưỡng về mô hình dữ liệu, cách ly dữ liệu, hiệu suất và khả năng mở rộng. Tuy nhiên, với chiến lược phù hợp, multi-tenant mang lại nhiều lợi ích về chi phí, bảo trì và khả năng mở rộng cho cả nhà cung cấp dịch vụ và khách hàng.
