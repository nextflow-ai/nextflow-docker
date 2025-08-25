# 🚀 Nextflow Omni - Hệ Thống Tích Hợp Chat Zalo CRM AI

**Nextflow Omni** là một hệ thống tích hợp chat Zalo toàn diện với tính năng CRM AI, được xây dựng trên Next.js 15 và TypeScript. Hệ thống cung cấp giao diện demo tương tác và các API mạnh mẽ để tích hợp Zalo vào các ứng dụng CRM.

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

## 📦 Cài Đặt & Khởi Chạy

### Yêu Cầu Hệ Thống
- Node.js 18+ 
- MongoDB 5.0+
- npm hoặc yarn

### Cài Đặt
```bash
# Clone repository
git clone <repository-url>
cd nextflow-omni/client

# Cài đặt dependencies
npm install

# Cấu hình environment variables
cp .env.example .env.local
# Chỉnh sửa .env.local với thông tin cấu hình

# Khởi chạy development server
npm run dev
```

### Environment Variables
```env
# Database
MONGODB_URI=mongodb://localhost:27017/nextflow-omni

# Encryption
ENCRYPTION_KEY=your-32-character-encryption-key

# Zalo Configuration
ZALO_APP_ID=your-zalo-app-id
ZALO_APP_SECRET=your-zalo-app-secret

# JWT
JWT_SECRET=your-jwt-secret
```

## 🏗️ Kiến Trúc Hệ Thống

### Cấu Trúc Thư Mục
```
client/
├── app/                          # Next.js App Router
│   ├── api/                      # API Routes
│   │   ├── auth/                 # Authentication APIs
│   │   ├── connections/          # Zalo Connection Management
│   │   ├── zalo/                 # Zalo Integration APIs
│   │   └── socket/               # WebSocket Handler
│   ├── demo/                     # Demo Application
│   │   ├── components/           # Các component của trang Demo
│   │   ├── hooks/                # Các React Hooks tùy chỉnh
│   │   └── types/                # Các định nghĩa kiểu TypeScript
│   └── globals.css               # CSS toàn cục
├── components/                   # Shared Components
├── lib/                          # Utility Libraries
│   ├── mongodb.ts                # Database Connection
│   ├── encryption.ts             # Data Encryption
│   ├── rateLimit.ts              # Rate Limiting
│   └── errorHandler.ts           # Error Management
├── models/                       # Database Models
│   ├── User.ts                   # User Model
│   ├── Message.ts                # Message & Conversation
│   ├── QRSession.ts              # QR Login Sessions
│   └── ZaloConnection.ts         # Zalo Connections
└── public/                       # Static Assets
```

### Database Schema

#### User Model
```typescript
interface IUser {
  email: string;
  password: string;          // Hashed với bcryptjs
  name: string;
  accountType: 'trial' | 'premium' | 'admin';
  trialExpiresAt?: Date;
  isActive: boolean;
}
```

Các schema chi tiết cho `Message` và `ZaloConnection` được định nghĩa trong thư mục `models/`. Chúng bao gồm các trường để lưu trữ nội dung tin nhắn, trạng thái, thông tin kết nối Zalo OA và Zalo Personal đã được mã hóa.

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register` - Đăng ký tài khoản mới
- `POST /api/auth/login` - Đăng nhập
- `GET /api/auth/profile` - Lấy thông tin profile

### Zalo Integration
- `POST /api/zalo/generate-qr` - Tạo mã QR đăng nhập
- `GET /api/zalo/qr-status` - Kiểm tra trạng thái QR
- `GET /api/zalo/qr-image/[sessionId]` - Lấy hình ảnh QR

### Connection Management
- `GET /api/connections/zalo-personal` - Lấy danh sách kết nối Personal
- `POST /api/connections/zalo-personal` - Tạo kết nối Personal mới
- `DELETE /api/connections/zalo-personal/:id` - Xóa một kết nối Personal
- `GET /api/connections/zalo-oa` - Lấy danh sách kết nối OA
- `POST /api/connections/zalo-oa` - Tạo kết nối OA mới
- `DELETE /api/connections/zalo-oa/:id` - Xóa một kết nối OA

### WebSocket Events
- `qr-status-update` - Cập nhật trạng thái QR
- `qr-expired` - QR code hết hạn
- `message-received` - Tin nhắn mới
- `connection-status` - Trạng thái kết nối

## 🚀 Deployment

### Production Build
```bash
# Build ứng dụng
npm run build

# Khởi chạy production server
npm start
```

### Docker Deployment
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

## 🔧 Development

### Available Scripts
```bash
npm run dev          # Development server với Turbopack
npm run build        # Production build
npm run start        # Production server
npm run lint         # ESLint checking
```

### Code Quality
- **ESLint**: Kiểm tra code quality
- **TypeScript**: Type safety
- **Prettier**: Code formatting
- **Husky**: Git hooks cho quality gates

## 📞 Hỗ Trợ

- **Email**: support@nextflow.ai
- **Documentation**: [docs.nextflow.ai](https://docs.nextflow.ai)
- **Issues**: [GitHub Issues](https://github.com/nextflow/omni/issues)

---