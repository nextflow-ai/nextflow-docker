# TROUBLESHOOTING - TÍCH HỢP

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn khắc phục sự cố liên quan đến tích hợp trong hệ thống NextFlow CRM-AI. Các vấn đề tích hợp có thể bao gồm lỗi kết nối API, lỗi webhook, lỗi đồng bộ với marketplace, và các vấn đề tích hợp khác.

## 2. VẤN ĐỀ TÍCH HỢP API

### 2.1. Lỗi kết nối API

#### Triệu chứng
- Không thể kết nối đến API bên ngoài
- Timeout khi gọi API
- Lỗi "Connection refused" hoặc "Connection timeout"

#### Nguyên nhân có thể
1. API bên ngoài không khả dụng
2. Thông tin kết nối không chính xác
3. Tường lửa chặn kết nối
4. Vấn đề mạng
5. Lỗi SSL/TLS

#### Giải pháp

##### 2.1.1. Kiểm tra API bên ngoài có khả dụng

```bash
# Kiểm tra kết nối đến API
curl -v https://api.example.com/endpoint

# Kiểm tra ping
ping api.example.com

# Kiểm tra traceroute
traceroute api.example.com
```

##### 2.1.2. Kiểm tra thông tin kết nối

Xác minh thông tin kết nối trong file `.env`:

```
API_URL=https://api.example.com
API_KEY=your_api_key
API_SECRET=your_api_secret
```

##### 2.1.3. Kiểm tra tường lửa

```bash
# Ubuntu/Debian
sudo ufw status
sudo ufw allow out 443/tcp

# CentOS/RHEL
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

##### 2.1.4. Kiểm tra cấu hình proxy

Nếu sử dụng proxy, kiểm tra cấu hình proxy trong file `.env`:

```
HTTP_PROXY=http://proxy.example.com:8080
HTTPS_PROXY=http://proxy.example.com:8080
NO_PROXY=localhost,127.0.0.1
```

##### 2.1.5. Kiểm tra cấu hình SSL/TLS

```bash
# Kiểm tra chứng chỉ SSL
openssl s_client -connect api.example.com:443 -servername api.example.com
```

### 2.2. Lỗi xác thực API

#### Triệu chứng
- Lỗi "401 Unauthorized" khi gọi API
- Lỗi "403 Forbidden" khi gọi API
- Thông báo "Invalid API key" hoặc "Authentication failed"

#### Nguyên nhân có thể
1. API key không chính xác
2. API key hết hạn
3. API key không có quyền truy cập
4. Định dạng xác thực không đúng
5. Thời gian hệ thống không đồng bộ (đối với xác thực dựa trên thời gian)

#### Giải pháp

##### 2.2.1. Kiểm tra API key

Xác minh API key trong file `.env`:

```
API_KEY=your_api_key
```

Tạo API key mới nếu cần thiết.

##### 2.2.2. Kiểm tra định dạng xác thực

Đảm bảo định dạng xác thực đúng:

```typescript
// Bearer Token
headers: {
  'Authorization': `Bearer ${apiKey}`
}

// API Key in header
headers: {
  'X-API-Key': apiKey
}

// API Key in query parameter
url: `https://api.example.com/endpoint?api_key=${apiKey}`

// Basic Authentication
headers: {
  'Authorization': `Basic ${Buffer.from(`${username}:${password}`).toString('base64')}`
}
```

##### 2.2.3. Kiểm tra thời gian hệ thống

```bash
# Kiểm tra thời gian hệ thống
date

# Đồng bộ thời gian hệ thống
sudo ntpdate pool.ntp.org
```

##### 2.2.4. Kiểm tra logs

```bash
# Kiểm tra logs ứng dụng
tail -f /path/to/NextFlow-crm/logs/application.log
```

### 2.3. Lỗi xử lý dữ liệu API

#### Triệu chứng
- Lỗi "400 Bad Request" khi gọi API
- Lỗi "422 Unprocessable Entity" khi gọi API
- Thông báo "Invalid data format" hoặc "Validation failed"

#### Nguyên nhân có thể
1. Dữ liệu gửi đi không đúng định dạng
2. Thiếu trường bắt buộc
3. Giá trị không hợp lệ
4. Lỗi chuyển đổi kiểu dữ liệu
5. Lỗi trong mã nguồn

#### Giải pháp

##### 2.3.1. Kiểm tra định dạng dữ liệu

```typescript
// Kiểm tra định dạng dữ liệu trước khi gửi
const payload = {
  name: 'John Doe',
  email: 'john.doe@example.com',
  age: 30
};

console.log('Payload:', JSON.stringify(payload, null, 2));
```

##### 2.3.2. Kiểm tra yêu cầu API

```bash
# Kiểm tra yêu cầu API với curl
curl -v -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_api_key" \
  -d '{"name":"John Doe","email":"john.doe@example.com","age":30}' \
  https://api.example.com/endpoint
```

##### 2.3.3. Kiểm tra xác thực dữ liệu

```typescript
// Kiểm tra xác thực dữ liệu
import { IsNotEmpty, IsString, IsEmail, IsNumber, Min } from 'class-validator';

export class CreateUserDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsNotEmpty()
  @IsEmail()
  email: string;

  @IsNotEmpty()
  @IsNumber()
  @Min(18)
  age: number;
}
```

##### 2.3.4. Kiểm tra chuyển đổi kiểu dữ liệu

```typescript
// Kiểm tra chuyển đổi kiểu dữ liệu
const age = parseInt(ageString, 10);
if (isNaN(age)) {
  throw new Error('Invalid age');
}
```

## 3. VẤN ĐỀ TÍCH HỢP WEBHOOK

### 3.1. Webhook không nhận được

#### Triệu chứng
- Webhook không được gọi
- Không có dữ liệu từ webhook
- Không có logs webhook

#### Nguyên nhân có thể
1. URL webhook không chính xác
2. Webhook không được đăng ký
3. Sự kiện không được kích hoạt
4. Tường lửa chặn webhook
5. Lỗi SSL/TLS

#### Giải pháp

##### 3.1.1. Kiểm tra URL webhook

Xác minh URL webhook trong cấu hình:

```
WEBHOOK_URL=https://yourdomain.com/api/webhooks/endpoint
```

##### 3.1.2. Kiểm tra đăng ký webhook

```bash
# Kiểm tra đăng ký webhook với curl
curl -v -X GET \
  -H "Authorization: Bearer your_api_key" \
  https://api.example.com/webhooks
```

##### 3.1.3. Kiểm tra logs webhook

```bash
# Kiểm tra logs webhook
tail -f /path/to/NextFlow-crm/logs/webhook.log
```

##### 3.1.4. Sử dụng công cụ debug webhook

```bash
# Cài đặt ngrok
npm install -g ngrok

# Chạy ngrok
ngrok http 3000

# Sử dụng URL ngrok làm webhook URL
# https://xxxx-xxxx-xxxx.ngrok.io/api/webhooks/endpoint
```

##### 3.1.5. Kiểm tra tường lửa

```bash
# Ubuntu/Debian
sudo ufw status
sudo ufw allow in 80/tcp
sudo ufw allow in 443/tcp

# CentOS/RHEL
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

### 3.2. Lỗi xác thực webhook

#### Triệu chứng
- Webhook bị từ chối
- Lỗi "401 Unauthorized" khi nhận webhook
- Thông báo "Invalid signature" hoặc "Authentication failed"

#### Nguyên nhân có thể
1. Webhook secret không chính xác
2. Định dạng chữ ký không đúng
3. Lỗi xác thực
4. Lỗi trong mã nguồn
5. Thời gian hệ thống không đồng bộ

#### Giải pháp

##### 3.2.1. Kiểm tra webhook secret

Xác minh webhook secret trong file `.env`:

```
WEBHOOK_SECRET=your_webhook_secret
```

##### 3.2.2. Kiểm tra xác thực webhook

```typescript
// Kiểm tra xác thực webhook
import * as crypto from 'crypto';

function verifyWebhookSignature(payload: string, signature: string, secret: string): boolean {
  const hmac = crypto.createHmac('sha256', secret);
  const calculatedSignature = hmac.update(payload).digest('hex');
  return crypto.timingSafeEqual(
    Buffer.from(calculatedSignature),
    Buffer.from(signature)
  );
}
```

##### 3.2.3. Kiểm tra logs xác thực

```bash
# Kiểm tra logs xác thực
tail -f /path/to/NextFlow-crm/logs/auth.log
```

### 3.3. Lỗi xử lý dữ liệu webhook

#### Triệu chứng
- Webhook được nhận nhưng không xử lý
- Lỗi khi xử lý dữ liệu webhook
- Dữ liệu webhook không được lưu

#### Nguyên nhân có thể
1. Định dạng dữ liệu không đúng
2. Lỗi xử lý dữ liệu
3. Lỗi cơ sở dữ liệu
4. Lỗi trong mã nguồn
5. Timeout xử lý webhook

#### Giải pháp

##### 3.3.1. Kiểm tra định dạng dữ liệu webhook

```typescript
// Kiểm tra định dạng dữ liệu webhook
@Post('webhook')
async handleWebhook(@Body() payload: any) {
  console.log('Webhook payload:', JSON.stringify(payload, null, 2));
  
  // Xác thực dữ liệu
  if (!payload.event || !payload.data) {
    throw new BadRequestException('Invalid webhook payload');
  }
  
  // Xử lý dữ liệu
  try {
    await this.webhookService.processWebhook(payload);
    return { success: true };
  } catch (error) {
    console.error('Webhook processing error:', error);
    throw new InternalServerErrorException('Failed to process webhook');
  }
}
```

##### 3.3.2. Kiểm tra logs xử lý webhook

```bash
# Kiểm tra logs xử lý webhook
tail -f /path/to/NextFlow-crm/logs/webhook-processing.log
```

##### 3.3.3. Sử dụng hàng đợi cho xử lý webhook

```typescript
// Sử dụng hàng đợi cho xử lý webhook
@Post('webhook')
async handleWebhook(@Body() payload: any) {
  // Xác thực webhook
  // ...
  
  // Đưa vào hàng đợi để xử lý bất đồng bộ
  await this.queueService.add('webhook-processing', {
    event: payload.event,
    data: payload.data,
    timestamp: new Date().toISOString(),
  });
  
  return { success: true };
}
```

## 4. VẤN ĐỀ TÍCH HỢP MARKETPLACE

### 4.1. Lỗi kết nối marketplace

#### Triệu chứng
- Không thể kết nối đến marketplace
- Timeout khi gọi API marketplace
- Lỗi "Connection refused" hoặc "Connection timeout"

#### Nguyên nhân có thể
1. API marketplace không khả dụng
2. Thông tin kết nối không chính xác
3. Tường lửa chặn kết nối
4. Vấn đề mạng
5. Lỗi SSL/TLS

#### Giải pháp

##### 4.1.1. Kiểm tra API marketplace có khả dụng

```bash
# Kiểm tra kết nối đến API Shopee
curl -v https://partner.shopeemobile.com/api/v2/shop/get_shop_info

# Kiểm tra kết nối đến API Lazada
curl -v https://api.lazada.com/rest/shop/get
```

##### 4.1.2. Kiểm tra thông tin kết nối

Xác minh thông tin kết nối trong file `.env`:

```
# Shopee
SHOPEE_PARTNER_ID=your_partner_id
SHOPEE_PARTNER_KEY=your_partner_key
SHOPEE_API_URL=https://partner.shopeemobile.com/api/v2

# Lazada
LAZADA_APP_KEY=your_app_key
LAZADA_APP_SECRET=your_app_secret
LAZADA_API_URL=https://api.lazada.com/rest

# TikTok Shop
TIKTOK_APP_KEY=your_app_key
TIKTOK_APP_SECRET=your_app_secret
TIKTOK_API_URL=https://open-api.tiktokglobalshop.com
```

##### 4.1.3. Kiểm tra logs marketplace

```bash
# Kiểm tra logs marketplace
tail -f /path/to/NextFlow-crm/logs/marketplace.log
```

### 4.2. Lỗi xác thực marketplace

#### Triệu chứng
- Lỗi "401 Unauthorized" khi gọi API marketplace
- Lỗi "403 Forbidden" khi gọi API marketplace
- Thông báo "Invalid API key" hoặc "Authentication failed"

#### Nguyên nhân có thể
1. API key không chính xác
2. API key hết hạn
3. API key không có quyền truy cập
4. Định dạng xác thực không đúng
5. Thời gian hệ thống không đồng bộ

#### Giải pháp

##### 4.2.1. Kiểm tra API key marketplace

Xác minh API key marketplace trong file `.env`.

##### 4.2.2. Làm mới token marketplace

```typescript
// Làm mới token Shopee
async refreshShopeeToken() {
  try {
    const timestamp = Math.floor(Date.now() / 1000);
    const path = '/api/v2/auth/token/get';
    const baseString = `${this.partnerId}${path}${timestamp}`;
    const sign = crypto
      .createHmac('sha256', this.partnerKey)
      .update(baseString)
      .digest('hex');
    
    const response = await axios.post(
      `${this.apiUrl}${path}`,
      {
        partner_id: this.partnerId,
        shop_id: this.shopId,
        refresh_token: this.refreshToken,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'Authorization': sign,
        },
        params: {
          partner_id: this.partnerId,
          timestamp,
          sign,
        },
      }
    );
    
    this.accessToken = response.data.access_token;
    this.refreshToken = response.data.refresh_token;
    this.tokenExpiresAt = Date.now() + response.data.expire_in * 1000;
    
    return this.accessToken;
  } catch (error) {
    console.error('Failed to refresh Shopee token:', error);
    throw new Error('Failed to refresh Shopee token');
  }
}
```

##### 4.2.3. Kiểm tra logs xác thực marketplace

```bash
# Kiểm tra logs xác thực marketplace
tail -f /path/to/NextFlow-crm/logs/marketplace-auth.log
```

### 4.3. Lỗi đồng bộ sản phẩm

#### Triệu chứng
- Sản phẩm không đồng bộ với marketplace
- Lỗi khi đồng bộ sản phẩm
- Sản phẩm bị từ chối bởi marketplace

#### Nguyên nhân có thể
1. Định dạng sản phẩm không đúng
2. Thiếu thông tin bắt buộc
3. Hình ảnh không hợp lệ
4. Giới hạn API bị vượt quá
5. Lỗi xử lý dữ liệu

#### Giải pháp

##### 4.3.1. Kiểm tra định dạng sản phẩm

```typescript
// Kiểm tra định dạng sản phẩm trước khi đồng bộ
function validateProduct(product) {
  const requiredFields = ['name', 'description', 'price', 'stock', 'category_id'];
  for (const field of requiredFields) {
    if (!product[field]) {
      throw new Error(`Missing required field: ${field}`);
    }
  }
  
  if (product.price <= 0) {
    throw new Error('Price must be greater than 0');
  }
  
  if (product.stock < 0) {
    throw new Error('Stock cannot be negative');
  }
  
  if (!product.images || product.images.length === 0) {
    throw new Error('At least one image is required');
  }
  
  return true;
}
```

##### 4.3.2. Kiểm tra logs đồng bộ sản phẩm

```bash
# Kiểm tra logs đồng bộ sản phẩm
tail -f /path/to/NextFlow-crm/logs/product-sync.log
```

##### 4.3.3. Đồng bộ lại sản phẩm thủ công

```bash
# Chạy script đồng bộ sản phẩm
cd /path/to/NextFlow-crm
pnpm marketplace:sync-products --platform=shopee
pnpm marketplace:sync-products --platform=lazada
pnpm marketplace:sync-products --platform=tiktok
```

### 4.4. Lỗi đồng bộ đơn hàng

#### Triệu chứng
- Đơn hàng không đồng bộ từ marketplace
- Lỗi khi đồng bộ đơn hàng
- Trạng thái đơn hàng không được cập nhật

#### Nguyên nhân có thể
1. Webhook không được cấu hình
2. Lỗi xử lý webhook
3. Lỗi kết nối API
4. Lỗi xử lý dữ liệu
5. Lỗi cơ sở dữ liệu

#### Giải pháp

##### 4.4.1. Kiểm tra cấu hình webhook

Xác minh cấu hình webhook marketplace:

```
# Shopee
SHOPEE_WEBHOOK_URL=https://yourdomain.com/api/webhooks/shopee
SHOPEE_WEBHOOK_SECRET=your_webhook_secret

# Lazada
LAZADA_WEBHOOK_URL=https://yourdomain.com/api/webhooks/lazada
LAZADA_WEBHOOK_SECRET=your_webhook_secret

# TikTok Shop
TIKTOK_WEBHOOK_URL=https://yourdomain.com/api/webhooks/tiktok
TIKTOK_WEBHOOK_SECRET=your_webhook_secret
```

##### 4.4.2. Kiểm tra logs webhook marketplace

```bash
# Kiểm tra logs webhook marketplace
tail -f /path/to/NextFlow-crm/logs/marketplace-webhook.log
```

##### 4.4.3. Đồng bộ lại đơn hàng thủ công

```bash
# Chạy script đồng bộ đơn hàng
cd /path/to/NextFlow-crm
pnpm marketplace:sync-orders --platform=shopee
pnpm marketplace:sync-orders --platform=lazada
pnpm marketplace:sync-orders --platform=tiktok
```

## 5. CÔNG CỤ KHẮC PHỤC SỰ CỐ TÍCH HỢP

### 5.1. Integration Monitor

Integration Monitor là công cụ trong NextFlow CRM-AI giúp giám sát và quản lý tích hợp:

1. Truy cập **Cài đặt > Hệ thống > Integration Monitor**
2. Xem trạng thái tích hợp
3. Kiểm tra logs tích hợp
4. Thử lại tích hợp thất bại

### 5.2. API Tester

API Tester giúp kiểm tra kết nối API:

1. Truy cập **Cài đặt > Hệ thống > API Tester**
2. Nhập URL API
3. Chọn phương thức (GET, POST, PUT, DELETE)
4. Nhập headers và body
5. Nhấp vào **Gửi yêu cầu**

### 5.3. Webhook Tester

Webhook Tester giúp kiểm tra webhook:

1. Truy cập **Cài đặt > Hệ thống > Webhook Tester**
2. Xem webhook đã nhận
3. Mô phỏng webhook
4. Kiểm tra xác thực webhook

### 5.4. Công cụ dòng lệnh

#### 5.4.1. Kiểm tra kết nối API

```bash
# Kiểm tra kết nối API
curl -v -X GET \
  -H "Authorization: Bearer your_api_key" \
  https://api.example.com/endpoint
```

#### 5.4.2. Mô phỏng webhook

```bash
# Mô phỏng webhook
curl -v -X POST \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Signature: your_signature" \
  -d '{"event":"order.created","data":{"id":"123","status":"pending"}}' \
  https://yourdomain.com/api/webhooks/endpoint
```

#### 5.4.3. Kiểm tra logs tích hợp

```bash
# Kiểm tra logs tích hợp
tail -f /path/to/NextFlow-crm/logs/integration.log
```

## 6. TÀI LIỆU THAM KHẢO

1. [Tài liệu API Shopee](https://open.shopee.com/documents)
2. [Tài liệu API Lazada](https://open.lazada.com/doc/doc.htm)
3. [Tài liệu API TikTok Shop](https://developers.tiktok-shops.com/documents/document/introduction)
4. [Tài liệu Webhook](https://docs.github.com/en/developers/webhooks-and-events/webhooks/about-webhooks)
5. [Tài liệu NestJS](https://docs.nestjs.com/)
