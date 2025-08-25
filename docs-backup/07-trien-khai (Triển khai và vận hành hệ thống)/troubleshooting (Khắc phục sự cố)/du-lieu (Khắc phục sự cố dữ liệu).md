# TROUBLESHOOTING - DỮ LIỆU

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn khắc phục sự cố liên quan đến dữ liệu trong hệ thống NextFlow CRM-AI. Các vấn đề dữ liệu có thể bao gồm dữ liệu không chính xác, dữ liệu bị mất, dữ liệu trùng lặp, lỗi đồng bộ dữ liệu, và các vấn đề dữ liệu khác.

## 2. VẤN ĐỀ DỮ LIỆU KHÔNG CHÍNH XÁC

### 2.1. Dữ liệu hiển thị không chính xác

#### Triệu chứng
- Dữ liệu hiển thị khác với dữ liệu đã nhập
- Dữ liệu bị sai định dạng
- Dữ liệu bị cắt ngắn hoặc làm tròn

#### Nguyên nhân có thể
1. Lỗi chuyển đổi kiểu dữ liệu
2. Lỗi định dạng hiển thị
3. Lỗi xử lý dữ liệu
4. Cache không được cập nhật
5. Lỗi đồng bộ dữ liệu

#### Giải pháp

##### 2.1.1. Kiểm tra dữ liệu trong cơ sở dữ liệu

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Truy vấn dữ liệu
SELECT * FROM table_name WHERE id = 'record_id';

# Thoát
\q
```

##### 2.1.2. Xóa cache

```bash
# Kết nối đến Redis
redis-cli -h localhost -p 6379 -a your_secure_password

# Xóa tất cả cache
FLUSHALL

# Hoặc xóa cache cụ thể
DEL cache_key

# Thoát
exit
```

##### 2.1.3. Kiểm tra mã xử lý dữ liệu

Kiểm tra mã xử lý dữ liệu trong các file:
- `src/modules/module_name/services/service_name.service.ts`
- `src/modules/module_name/controllers/controller_name.controller.ts`
- `src/modules/module_name/dto/dto_name.dto.ts`

##### 2.1.4. Cập nhật dữ liệu

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Cập nhật dữ liệu
UPDATE table_name SET column_name = 'correct_value' WHERE id = 'record_id';

# Thoát
\q
```

### 2.2. Dữ liệu không nhất quán

#### Triệu chứng
- Dữ liệu khác nhau giữa các phần của ứng dụng
- Dữ liệu không đồng bộ giữa các hệ thống
- Tổng số không khớp với chi tiết

#### Nguyên nhân có thể
1. Lỗi đồng bộ dữ liệu
2. Cache không được cập nhật
3. Lỗi xử lý đồng thời
4. Lỗi ràng buộc cơ sở dữ liệu
5. Lỗi trong mã nguồn

#### Giải pháp

##### 2.2.1. Kiểm tra tính nhất quán của dữ liệu

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Kiểm tra tính nhất quán
SELECT COUNT(*) FROM orders;
SELECT SUM(total) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT SUM(quantity) FROM order_items;

# Thoát
\q
```

##### 2.2.2. Sử dụng giao dịch (transaction)

```typescript
// Sử dụng giao dịch để đảm bảo tính nhất quán
await this.connection.transaction(async (manager) => {
  // Cập nhật đơn hàng
  await manager.update(Order, orderId, { status: 'completed' });
  
  // Cập nhật kho hàng
  await manager.update(Inventory, productId, { 
    quantity: () => `quantity - ${orderQuantity}` 
  });
  
  // Tạo lịch sử giao dịch
  await manager.insert(Transaction, {
    orderId,
    amount,
    type: 'payment',
    status: 'completed',
  });
});
```

##### 2.2.3. Đồng bộ lại dữ liệu

```bash
# Chạy script đồng bộ dữ liệu
cd /path/to/NextFlow-crm
pnpm data:sync
```

##### 2.2.4. Kiểm tra và sửa lỗi ràng buộc

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Kiểm tra ràng buộc
SELECT conname, contype, conrelid::regclass, confrelid::regclass, conkey, confkey
FROM pg_constraint
WHERE conrelid = 'table_name'::regclass;

# Thoát
\q
```

### 2.3. Dữ liệu bị trùng lặp

#### Triệu chứng
- Dữ liệu xuất hiện nhiều lần
- Tổng số lớn hơn dự kiến
- Báo cáo hiển thị số liệu không chính xác

#### Nguyên nhân có thể
1. Thiếu ràng buộc duy nhất
2. Lỗi xử lý đồng thời
3. Lỗi đồng bộ dữ liệu
4. Lỗi trong mã nguồn
5. Lỗi nhập liệu

#### Giải pháp

##### 2.3.1. Xác định dữ liệu trùng lặp

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Tìm dữ liệu trùng lặp
SELECT column1, column2, COUNT(*)
FROM table_name
GROUP BY column1, column2
HAVING COUNT(*) > 1;

# Thoát
\q
```

##### 2.3.2. Xóa dữ liệu trùng lặp

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Xóa dữ liệu trùng lặp (giữ lại bản ghi mới nhất)
DELETE FROM table_name
WHERE id IN (
  SELECT id
  FROM (
    SELECT id,
      ROW_NUMBER() OVER (PARTITION BY column1, column2 ORDER BY created_at DESC) as row_num
    FROM table_name
  ) t
  WHERE t.row_num > 1
);

# Thoát
\q
```

##### 2.3.3. Thêm ràng buộc duy nhất

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Thêm ràng buộc duy nhất
ALTER TABLE table_name ADD CONSTRAINT unique_constraint_name UNIQUE (column1, column2);

# Thoát
\q
```

##### 2.3.4. Sử dụng xử lý đồng thời an toàn

```typescript
// Sử dụng findOneOrFail trước khi tạo mới
const existingRecord = await this.repository.findOne({
  where: { key1: value1, key2: value2 }
});

if (!existingRecord) {
  await this.repository.save({
    key1: value1,
    key2: value2,
    // ...
  });
}
```

## 3. VẤN ĐỀ DỮ LIỆU BỊ MẤT

### 3.1. Dữ liệu bị mất sau khi lưu

#### Triệu chứng
- Dữ liệu đã nhập nhưng không được lưu
- Dữ liệu biến mất sau khi lưu
- Thông báo lưu thành công nhưng dữ liệu không có

#### Nguyên nhân có thể
1. Lỗi xử lý form
2. Lỗi xác thực dữ liệu
3. Lỗi kết nối cơ sở dữ liệu
4. Lỗi xử lý giao dịch
5. Lỗi trong mã nguồn

#### Giải pháp

##### 3.1.1. Kiểm tra logs

```bash
# Kiểm tra logs ứng dụng
tail -f /path/to/NextFlow-crm/logs/application.log

# Kiểm tra logs cơ sở dữ liệu
sudo tail -f /var/log/postgresql/postgresql-13-main.log
```

##### 3.1.2. Kiểm tra xử lý form

Kiểm tra mã xử lý form trong các file:
- `src/modules/module_name/controllers/controller_name.controller.ts`
- `src/modules/module_name/dto/dto_name.dto.ts`

##### 3.1.3. Kiểm tra xác thực dữ liệu

```typescript
// Kiểm tra xác thực dữ liệu
import { IsNotEmpty, IsString, IsEmail, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsNotEmpty()
  @IsEmail()
  email: string;

  @IsOptional()
  @IsString()
  phone?: string;
}
```

##### 3.1.4. Kiểm tra xử lý giao dịch

```typescript
// Kiểm tra xử lý giao dịch
try {
  await this.connection.transaction(async (manager) => {
    // Các thao tác cơ sở dữ liệu
  });
} catch (error) {
  // Xử lý lỗi
  console.error('Transaction failed:', error);
  throw new Error('Failed to save data');
}
```

### 3.2. Dữ liệu bị mất sau khi cập nhật

#### Triệu chứng
- Dữ liệu biến mất sau khi cập nhật
- Dữ liệu bị ghi đè không đúng
- Dữ liệu bị thay đổi không như mong đợi

#### Nguyên nhân có thể
1. Lỗi xử lý cập nhật một phần
2. Lỗi xử lý đồng thời
3. Lỗi ràng buộc cơ sở dữ liệu
4. Lỗi trong mã nguồn
5. Lỗi xử lý form

#### Giải pháp

##### 3.2.1. Kiểm tra xử lý cập nhật một phần

```typescript
// Thay vì
await this.repository.update(id, dto);

// Sử dụng
const entity = await this.repository.findOneOrFail(id);
const updatedEntity = this.repository.merge(entity, dto);
await this.repository.save(updatedEntity);
```

##### 3.2.2. Sử dụng khóa lạc quan (optimistic locking)

```typescript
// entity.ts
import { Entity, Column, Version } from 'typeorm';

@Entity()
export class User {
  // ...

  @Version()
  version: number;
}

// service.ts
async update(id: string, dto: UpdateUserDto) {
  try {
    const user = await this.userRepository.findOneOrFail(id);
    const updatedUser = this.userRepository.merge(user, dto);
    await this.userRepository.save(updatedUser);
    return updatedUser;
  } catch (error) {
    if (error.name === 'OptimisticLockVersionMismatchError') {
      throw new ConflictException('Data has been modified by another user');
    }
    throw error;
  }
}
```

##### 3.2.3. Kiểm tra lịch sử thay đổi

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Kiểm tra lịch sử thay đổi (nếu có bảng audit)
SELECT * FROM audit_logs WHERE entity_id = 'record_id' ORDER BY created_at DESC;

# Thoát
\q
```

### 3.3. Dữ liệu bị mất sau khi xóa

#### Triệu chứng
- Dữ liệu bị xóa không đúng
- Dữ liệu liên quan bị xóa theo
- Không thể khôi phục dữ liệu đã xóa

#### Nguyên nhân có thể
1. Lỗi xóa cứng thay vì xóa mềm
2. Lỗi xóa cascade
3. Lỗi xử lý đồng thời
4. Lỗi trong mã nguồn
5. Lỗi xác thực quyền

#### Giải pháp

##### 3.3.1. Sử dụng xóa mềm (soft delete)

```typescript
// entity.ts
import { Entity, Column, DeleteDateColumn } from 'typeorm';

@Entity()
export class User {
  // ...

  @DeleteDateColumn()
  deletedAt: Date;
}

// service.ts
async softDelete(id: string) {
  await this.userRepository.softDelete(id);
}

async restore(id: string) {
  await this.userRepository.restore(id);
}
```

##### 3.3.2. Kiểm tra ràng buộc cascade

```bash
# Kết nối đến PostgreSQL
psql -h localhost -U NextFlow -d NextFlow_crm

# Kiểm tra ràng buộc cascade
SELECT conname, contype, conrelid::regclass, confrelid::regclass, confdeltype
FROM pg_constraint
WHERE contype = 'f' AND confdeltype = 'c';

# Thoát
\q
```

##### 3.3.3. Khôi phục từ backup

```bash
# Khôi phục từ backup
pg_restore -h localhost -U NextFlow -d NextFlow_crm /path/to/backup.dump
```

##### 3.3.4. Kiểm tra xác thực quyền

```typescript
// Kiểm tra xác thực quyền trước khi xóa
@Delete(':id')
@UseGuards(JwtAuthGuard, PermissionGuard)
@Permission('users.delete')
async remove(@Param('id') id: string) {
  return this.usersService.remove(id);
}
```

## 4. VẤN ĐỀ ĐỒNG BỘ DỮ LIỆU

### 4.1. Dữ liệu không đồng bộ giữa các hệ thống

#### Triệu chứng
- Dữ liệu khác nhau giữa NextFlow CRM-AI và các hệ thống bên ngoài
- Dữ liệu không được cập nhật khi có thay đổi
- Lỗi đồng bộ dữ liệu

#### Nguyên nhân có thể
1. Lỗi kết nối API
2. Lỗi xử lý webhook
3. Lỗi cấu hình đồng bộ
4. Lỗi xử lý dữ liệu
5. Lỗi xác thực

#### Giải pháp

##### 4.1.1. Kiểm tra logs đồng bộ

```bash
# Kiểm tra logs đồng bộ
tail -f /path/to/NextFlow-crm/logs/sync.log
```

##### 4.1.2. Kiểm tra cấu hình đồng bộ

Kiểm tra cấu hình đồng bộ trong file `.env`:

```
SYNC_ENABLED=true
SYNC_INTERVAL=15
SYNC_RETRY_COUNT=3
SYNC_RETRY_DELAY=5
```

##### 4.1.3. Kiểm tra webhook

```bash
# Kiểm tra logs webhook
tail -f /path/to/NextFlow-crm/logs/webhook.log
```

##### 4.1.4. Đồng bộ lại dữ liệu thủ công

```bash
# Chạy script đồng bộ dữ liệu
cd /path/to/NextFlow-crm
pnpm sync:run --entity=products
pnpm sync:run --entity=customers
pnpm sync:run --entity=orders
```

### 4.2. Lỗi đồng bộ với marketplace

#### Triệu chứng
- Sản phẩm không đồng bộ với marketplace
- Đơn hàng không được cập nhật từ marketplace
- Lỗi khi đồng bộ dữ liệu với marketplace

#### Nguyên nhân có thể
1. Lỗi kết nối API marketplace
2. Lỗi xác thực marketplace
3. Lỗi cấu hình đồng bộ
4. Lỗi xử lý dữ liệu
5. Giới hạn API bị vượt quá

#### Giải pháp

##### 4.2.1. Kiểm tra kết nối API marketplace

```bash
# Kiểm tra kết nối API Shopee
curl -v -H "Authorization: Bearer your_token" https://partner.shopeemobile.com/api/v2/shop/get_shop_info

# Kiểm tra kết nối API Lazada
curl -v -H "Authorization: Bearer your_token" https://api.lazada.com/rest/shop/get
```

##### 4.2.2. Kiểm tra cấu hình marketplace

Kiểm tra cấu hình marketplace trong file `.env`:

```
SHOPEE_PARTNER_ID=your_partner_id
SHOPEE_PARTNER_KEY=your_partner_key
SHOPEE_API_URL=https://partner.shopeemobile.com/api/v2

LAZADA_APP_KEY=your_app_key
LAZADA_APP_SECRET=your_app_secret
LAZADA_API_URL=https://api.lazada.com/rest
```

##### 4.2.3. Kiểm tra logs đồng bộ marketplace

```bash
# Kiểm tra logs đồng bộ marketplace
tail -f /path/to/NextFlow-crm/logs/marketplace.log
```

##### 4.2.4. Đồng bộ lại dữ liệu marketplace

```bash
# Chạy script đồng bộ marketplace
cd /path/to/NextFlow-crm
pnpm marketplace:sync --platform=shopee
pnpm marketplace:sync --platform=lazada
pnpm marketplace:sync --platform=tiktok
```

### 4.3. Lỗi đồng bộ với n8n và Flowise

#### Triệu chứng
- Workflow n8n không được kích hoạt
- Chatbot Flowise không nhận được dữ liệu
- Lỗi khi gọi API n8n hoặc Flowise

#### Nguyên nhân có thể
1. Lỗi kết nối API
2. Lỗi xác thực
3. Lỗi cấu hình
4. Lỗi xử lý dữ liệu
5. n8n hoặc Flowise không chạy

#### Giải pháp

##### 4.3.1. Kiểm tra kết nối API n8n và Flowise

```bash
# Kiểm tra kết nối API n8n
curl -v -H "X-N8N-API-KEY: your_api_key" https://n8n.yourdomain.com/api/v1/workflows

# Kiểm tra kết nối API Flowise
curl -v -H "Authorization: Bearer your_api_key" https://flowise.yourdomain.com/api/v1/chatflows
```

##### 4.3.2. Kiểm tra cấu hình n8n và Flowise

Kiểm tra cấu hình n8n và Flowise trong file `.env`:

```
N8N_URL=https://n8n.yourdomain.com
N8N_API_KEY=your_n8n_api_key

FLOWISE_URL=https://flowise.yourdomain.com
FLOWISE_API_KEY=your_flowise_api_key
```

##### 4.3.3. Kiểm tra logs n8n và Flowise

```bash
# Kiểm tra logs n8n
docker logs NextFlow-n8n

# Kiểm tra logs Flowise
docker logs NextFlow-flowise
```

##### 4.3.4. Khởi động lại n8n và Flowise

```bash
# Khởi động lại n8n
cd /opt/NextFlow/n8n
docker-compose restart

# Khởi động lại Flowise
cd /opt/NextFlow/flowise
docker-compose restart
```

## 5. CÔNG CỤ KHẮC PHỤC SỰ CỐ DỮ LIỆU

### 5.1. Data Validator

Data Validator là công cụ trong NextFlow CRM-AI giúp kiểm tra tính hợp lệ của dữ liệu:

1. Truy cập **Cài đặt > Hệ thống > Data Validator**
2. Chọn loại dữ liệu cần kiểm tra
3. Nhấp vào **Chạy kiểm tra**

### 5.2. Data Repair Tool

Data Repair Tool giúp sửa chữa dữ liệu bị lỗi:

1. Truy cập **Cài đặt > Hệ thống > Data Repair Tool**
2. Chọn loại dữ liệu cần sửa chữa
3. Nhấp vào **Chạy sửa chữa**

### 5.3. Sync Monitor

Sync Monitor giúp giám sát và quản lý đồng bộ dữ liệu:

1. Truy cập **Cài đặt > Hệ thống > Sync Monitor**
2. Xem trạng thái đồng bộ
3. Chọn đồng bộ lại dữ liệu nếu cần

### 5.4. Công cụ dòng lệnh

#### 5.4.1. Kiểm tra tính toàn vẹn dữ liệu

```bash
# Chạy script kiểm tra tính toàn vẹn dữ liệu
cd /path/to/NextFlow-crm
pnpm data:validate
```

#### 5.4.2. Sửa chữa dữ liệu

```bash
# Chạy script sửa chữa dữ liệu
cd /path/to/NextFlow-crm
pnpm data:repair
```

#### 5.4.3. Đồng bộ dữ liệu

```bash
# Chạy script đồng bộ dữ liệu
cd /path/to/NextFlow-crm
pnpm data:sync
```

## 6. TÀI LIỆU THAM KHẢO

1. [Tài liệu TypeORM](https://typeorm.io/)
2. [Tài liệu PostgreSQL](https://www.postgresql.org/docs/)
3. [Tài liệu NestJS](https://docs.nestjs.com/)
4. [Tài liệu n8n](https://docs.n8n.io/)
5. [Tài liệu Flowise](https://docs.flowiseai.com/)
