# 🚀 Nextflow Omni - Thiết Kế Hệ Thống Tích Hợp Chat Zalo CRM AI

**Nextflow Omni** là thiết kế cho một hệ thống tích hợp chat Zalo toàn diện với tính năng CRM AI, được lên kế hoạch xây dựng trên Next.js 15 và TypeScript. Dự án hiện đang trong giai đoạn thiết kế và tài liệu hóa, chưa có source code thực tế được triển khai.

## ✨ Tính Năng Chính

### 🔗 Tích Hợp Zalo Toàn Diện

- **Zalo Personal**: Đăng nhập QR code, quản lý tin nhắn cá nhân
- **Zalo Official Account (OA)**: Tích hợp webhook, quản lý tài khoản doanh nghiệp
- **Real-time Communication**: WebSocket cho cập nhật thời gian thực
- **Multi-connection Support**: Hỗ trợ nhiều kết nối Zalo đồng thời

### 💬 Hệ Thống Chat & CRM

- **Quản Lý Tin Nhắn**: Giao diện chat hiện đại, quản lý hội thoại tập trung.
- **Quản Lý Liên Hệ**: Danh bạ tích hợp, thông tin chi tiết khách hàng.
- **Dashboard Trực Quan**: Theo dõi các chỉ số quan trọng (KPIs) về tương tác.
- **Hỗ Trợ Nhiều Loại Tin Nhắn**: Text, hình ảnh, file, sticker.

### 🔐 Bảo Mật & Authentication

- **QR Code Login**: Đăng nhập an toàn qua mã QR
- **Data Encryption**: Mã hóa dữ liệu nhạy cảm (AES-256)
- **Rate Limiting**: Bảo vệ API khỏi spam và tấn công
- **Input Validation**: Kiểm tra và làm sạch dữ liệu đầu vào

### 🎨 Giao Diện Hiện Đại

- **Glass Morphism Design**: Hiệu ứng kính mờ chuyên nghiệp
- **Responsive Layout**: Tối ưu cho mọi thiết bị

- **Smooth Animations**: Chuyển động mượt mà, trải nghiệm người dùng tốt

## 🛠️ Tech Stack

### Frontend

- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **Styling**: TailwindCSS v4
- **UI Components**: Headless UI, Lucide React
- **State Management**: React Context, Custom Hooks

### Backend & Database

- **Database**: MongoDB với Mongoose ODM
- **Authentication**: Custom JWT + QR Login
- **Real-time**: Socket.IO
- **File Storage**: Local filesystem (temp QR codes)

### Security & Utilities

- **Encryption**: crypto-js (AES-256)
- **Password Hashing**: bcryptjs
- **Rate Limiting**: Custom middleware
- **Error Handling**: Comprehensive error management

### Core SDK

- **nextflow-zalo-sdk**: v1.0.0-alpha.6
- **Chart.js**: Biểu đồ và thống kê
- **Sharp**: Xử lý hình ảnh tối ưu

## 📋 Tình Trạng Dự Án Hiện Tại

### Giai Đoạn Phát Triển

- **Trạng thái**: Giai đoạn thiết kế và tài liệu hóa
- **Source code**: Chưa được triển khai
- **Tài liệu**: Hoàn thiện chi tiết
- **Cấu hình Docker**: Đã sẵn sàng cho MongoDB và các dịch vụ hỗ trợ

### Yêu Cầu Hệ Thống (Khi Triển Khai)

- Node.js 18+
- MongoDB 5.0+
- Docker & Docker Compose
- npm hoặc yarn

### Cấu Hình Môi Trường (Thiết Kế)

```env
# Database - MongoDB
MONGODB_URI=mongodb://localhost:27017/nextflow-omni
MONGODB_DB_NAME=nextflow_omni

# Encryption - Mã hóa dữ liệu
ENCRYPTION_KEY=your-32-character-encryption-key

# Zalo Configuration - Cấu hình tích hợp Zalo
ZALO_APP_ID=your-zalo-app-id
ZALO_APP_SECRET=your-zalo-app-secret

# JWT - Xác thực người dùng
JWT_SECRET=your-jwt-secret

# Docker Environment - Môi trường Docker
DOCKER_NETWORK=nextflow_network
```

## 🏗️ Thiết Kế Kiến Trúc Hệ Thống

### Cấu Trúc Dự Án Hiện Tại

```
### Cấu Trúc Source Code (Thiết Kế)
```

nextflow_omni/
├── app/ # Next.js App Router
│ ├── api/ # API Routes
│ │ ├── auth/ # Authentication APIs
│ │ ├── connections/ # Zalo Connection Management
│ │ ├── zalo/ # Zalo Integration APIs
│ │ └── socket/ # WebSocket Handler
│ ├── demo/ # Demo Application
│ └── globals.css # CSS toàn cục
├── components/ # Shared Components
├── lib/ # Utility Libraries
├── models/ # Database Models (MongoDB)
└── public/ # Static Assets

````

### Thiết Kế Database Schema (MongoDB)

#### User Model - Mô hình người dùng
```typescript
interface IUser {
  _id: ObjectId;                 // MongoDB ObjectId
  fullName: string;              // Tên đầy đủ người dùng
  email: string;                 // Email đăng nhập
  phoneNumber: string;           // Số điện thoại
  password: string;              // Mật khẩu đã hash với bcrypt
  isActive: boolean;             // Trạng thái hoạt động
  isEmailVerified: boolean;      // Trạng thái xác thực email
  loginCount: number;            // Số lần đăng nhập
  registrationSource: string;    // Nguồn đăng ký (web, mobile, api)
  accountType: 'trial' | 'premium' | 'admin';  // Loại tài khoản
  isTrialExpired: boolean;       // Trạng thái hết hạn trial
  metadata: {                    // Thông tin metadata
    ipAddress: string;           // Địa chỉ IP
    userAgent: string;           // User Agent
  };
  trialStartDate: Date;          // Ngày bắt đầu trial
  trialEndDate: Date;            // Ngày kết thúc trial
  createdAt: Date;               // Ngày tạo
  updatedAt: Date;               // Ngày cập nhật
  lastLoginAt?: Date;            // Lần đăng nhập cuối
  __v: number;                   // Version key của MongoDB
}
```

**Ví dụ dữ liệu thực tế từ MongoDB Collection:**
```json
{
  "_id": ObjectId("68a6e846337152228d3bf8e3"),
  "fullName": "Trial User New",
  "email": "trial3@example.com",
  "phoneNumber": "0777666555",
  "password": "$2b$10$FI1C0FTfgJ3jUkq2CJc94u3exxMDdWHjABUI5KJZydpHCAa2gb6qa",
  "isActive": true,
  "isEmailVerified": false,
  "loginCount": 1,
  "registrationSource": "web",
  "accountType": "trial",
  "isTrialExpired": false,
  "metadata": {
    "ipAddress": "::1",
    "userAgent": "curl/8.14.1"
  },
  "trialStartDate": ISODate("2025-08-21T09:35:02.031Z"),
  "trialEndDate": ISODate("2025-08-28T09:35:02.031Z"),
  "createdAt": ISODate("2025-08-21T09:35:02.038Z"),
  "updatedAt": ISODate("2025-08-21T09:35:09.348Z"),
  "__v": 0,
  "lastLoginAt": ISODate("2025-08-21T09:35:09.346Z")
}
```

#### Message Model - Mô hình tin nhắn

```typescript
interface IMessage {
  _id: ObjectId;
  userId: ObjectId; // Tham chiếu đến User
  zaloConnectionId: ObjectId; // Tham chiếu đến ZaloConnection
  content: string; // Nội dung tin nhắn (đã mã hóa)
  messageType: "text" | "image" | "file" | "sticker";
  direction: "incoming" | "outgoing"; // Chiều tin nhắn
  timestamp: Date; // Thời gian tin nhắn
  isRead: boolean; // Trạng thái đã đọc
}
```

#### ZaloConnection Model - Mô hình kết nối Zalo

```typescript
interface IZaloConnection {
  _id: ObjectId;
  userId: ObjectId; // Tham chiếu đến User
  connectionType: "personal" | "oa"; // Loại kết nối
  zaloId: string; // ID Zalo (đã mã hóa)
  displayName: string; // Tên hiển thị
  avatar?: string; // URL avatar
  accessToken?: string; // Token truy cập (đã mã hóa)
  refreshToken?: string; // Token làm mới (đã mã hóa)
  isActive: boolean; // Trạng thái kết nối
  lastSyncAt?: Date; // Lần đồng bộ cuối
  createdAt: Date;
  updatedAt: Date;
}
```

## 🔌 Thiết Kế API Endpoints

### Authentication - Xác thực người dùng

- `POST /api/auth/register` - Đăng ký tài khoản mới
- `POST /api/auth/login` - Đăng nhập hệ thống
- `GET /api/auth/profile` - Lấy thông tin profile người dùng
- `POST /api/auth/logout` - Đăng xuất
- `POST /api/auth/refresh` - Làm mới JWT token

### Zalo Integration - Tích hợp Zalo

- `POST /api/zalo/generate-qr` - Tạo mã QR đăng nhập Zalo
- `GET /api/zalo/qr-status/:sessionId` - Kiểm tra trạng thái QR
- `GET /api/zalo/qr-image/:sessionId` - Lấy hình ảnh QR code
- `POST /api/zalo/webhook` - Webhook nhận tin nhắn từ Zalo
- `GET /api/zalo/contacts` - Lấy danh sách liên hệ

### Connection Management - Quản lý kết nối

- `GET /api/connections/zalo-personal` - Danh sách kết nối Personal
- `POST /api/connections/zalo-personal` - Tạo kết nối Personal mới
- `PUT /api/connections/zalo-personal/:id` - Cập nhật kết nối Personal
- `DELETE /api/connections/zalo-personal/:id` - Xóa kết nối Personal
- `GET /api/connections/zalo-oa` - Danh sách kết nối Official Account
- `POST /api/connections/zalo-oa` - Tạo kết nối OA mới
- `PUT /api/connections/zalo-oa/:id` - Cập nhật kết nối OA
- `DELETE /api/connections/zalo-oa/:id` - Xóa kết nối OA

### Messages - Quản lý tin nhắn

- `GET /api/messages` - Lấy danh sách tin nhắn
- `POST /api/messages/send` - Gửi tin nhắn
- `PUT /api/messages/:id/read` - Đánh dấu đã đọc
- `GET /api/messages/conversations` - Lấy danh sách hội thoại

### WebSocket Events - Sự kiện thời gian thực

- `qr-status-update` - Cập nhật trạng thái QR code
- `qr-expired` - QR code hết hạn
- `message-received` - Tin nhắn mới nhận được
- `message-sent` - Tin nhắn đã gửi thành công
- `connection-status` - Thay đổi trạng thái kết nối
- `user-online` - Người dùng online
- `user-offline` - Người dùng offline

## 🚀 Kế Hoạch Triển Khai

### Giai Đoạn 1: Phát Triển Source Code

```bash
# Tạo cấu trúc dự án Next.js
npx create-next-app@latest client --typescript --tailwind --app
cd client

# Cài đặt dependencies cần thiết
npm install mongoose socket.io bcryptjs crypto-js jsonwebtoken
npm install -D @types/bcryptjs @types/jsonwebtoken

# Thiết lập MongoDB connection
# Tạo các models theo thiết kế
# Phát triển API endpoints
```

### Giai Đoạn 2: Docker Deployment

```dockerfile
# Dockerfile cho Next.js app
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

### Cấu Hình Docker Compose Hiện Tại

```yaml
# Đã có sẵn cấu hình cho:
# - MongoDB service
# - Monitoring stack (Grafana, Prometheus)
# - Cloudflare Tunnel
# - Cần thêm: Next.js application service
```

## 🔧 Kế Hoạch Phát Triển

### Scripts Dự Kiến (Khi Có Source Code)

```bash
npm run dev          # Development server với Turbopack
npm run build        # Production build
npm run start        # Production server
npm run lint         # ESLint checking
npm run test         # Unit testing
npm run type-check   # TypeScript type checking
```

### Tiêu Chuẩn Code Quality

- **ESLint**: Kiểm tra code quality và coding standards
- **TypeScript**: Type safety và IntelliSense
- **Prettier**: Code formatting tự động
- **Husky**: Git hooks cho quality gates
- **Jest**: Unit testing framework
- **Cypress**: End-to-end testing

### Quy Trình Phát Triển

1. **Thiết kế Database Schema** ✅ (Hoàn thành)
2. **Tạo API Documentation** ✅ (Hoàn thành)
3. **Setup Next.js Project** ⏳ (Chưa bắt đầu)
4. **Implement Database Models** ⏳ (Chưa bắt đầu)
5. **Develop API Endpoints** ⏳ (Chưa bắt đầu)
6. **Create UI Components** ⏳ (Chưa bắt đầu)
7. **Integrate Zalo SDK** ⏳ (Chưa bắt đầu)
8. **Testing & Deployment** ⏳ (Chưa bắt đầu)

## 📞 Hỗ Trợ

- **Email**: support@nextflow.ai
- **Documentation**: [docs.nextflow.ai](https://docs.nextflow.ai)
- **Issues**: [GitHub Issues](https://github.com/nextflow/omni/issues)

---
