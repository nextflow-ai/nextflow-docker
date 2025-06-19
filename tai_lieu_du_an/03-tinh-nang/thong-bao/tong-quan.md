# HỆ THỐNG THÔNG BÁO NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Các loại thông báo](#2-các-loại-thông-báo)
3. [Kênh gửi thông báo](#3-kênh-gửi-thông-báo)
4. [Quản lý thông báo](#4-quản-lý-thông-báo)
5. [Tự động hóa thông báo](#5-tự-động-hóa-thông-báo)
6. [Cài đặt người dùng](#6-cài-đặt-người-dùng)
7. [Tích hợp bên thứ ba](#7-tích-hợp-bên-thứ-ba)
8. [Báo cáo và phân tích](#8-báo-cáo-và-phân-tích)

## 1. GIỚI THIỆU

Hệ thống Thông báo của NextFlow CRM giúp doanh nghiệp gửi thông báo đa kênh, thời gian thực để đảm bảo nhân viên và khách hàng luôn được cập nhật về các hoạt động quan trọng.

### 1.1. Mục tiêu chính

- **Thông báo kịp thời**: Cập nhật ngay lập tức về đơn hàng mới, khách hàng tiềm năng, cuộc hẹn
- **Đa kênh linh hoạt**: Gửi qua ứng dụng, email, SMS, push notification
- **Cá nhân hóa thông minh**: Tùy chỉnh nội dung theo vai trò và sở thích người dùng
- **Tự động hóa hoàn toàn**: Thiết lập quy tắc gửi thông báo tự động

### 1.2. Lợi ích thực tế

- **Tăng 40% hiệu quả bán hàng**: Phản ứng nhanh với khách hàng tiềm năng
- **Cải thiện 60% dịch vụ khách hàng**: Xử lý yêu cầu kịp thời
- **Giảm 30% thời gian quản lý**: Tự động hóa thông báo và nhắc nhở
- **Tăng 25% doanh thu**: Không bỏ lỡ cơ hội bán hàng và chăm sóc khách hàng

### 1.3. Ví dụ thực tế

**Kịch bản 1 - Nhân viên bán hàng:**
```
🔔 10:30 AM: "Khách hàng Công ty ABC vừa xem báo giá #BG001"
📧 10:31 AM: Email chi tiết gửi đến sales@company.com
📱 10:32 AM: Push notification trên điện thoại
💬 10:35 AM: Tin nhắn Zalo: "Anh Minh ơi, có khách quan tâm báo giá rồi!"
```

**Kịch bản 2 - Quản lý:**
```
📊 8:00 AM: "Báo cáo doanh số hôm qua: 50.000.000đ (đạt 120% mục tiêu)"
⚠️ 2:00 PM: "Cảnh báo: Kho hàng sản phẩm A còn 5 sản phẩm"
🎯 6:00 PM: "Tổng kết tuần: 15 đơn hàng mới, 3 khách hàng VIP"
```

## 2. LOẠI THÔNG BÁO

### 2.1. Thông báo hệ thống

**Bảo trì và cập nhật:**
- Thông báo bảo trì hệ thống
- Cập nhật phiên bản mới
- Thay đổi chính sách
- Cảnh báo bảo mật

**Hiệu suất hệ thống:**
- Cảnh báo tải cao
- Lỗi hệ thống
- Backup thành công/thất bại
- Giám sát uptime

### 2.2. Thông báo kinh doanh

**Khách hàng:**
- Khách hàng mới đăng ký
- Khách hàng có nguy cơ rời bỏ
- Sinh nhật khách hàng
- Cập nhật thông tin khách hàng

**Bán hàng:**
- Lead mới
- Cơ hội bán hàng mới
- Đơn hàng mới
- Mục tiêu bán hàng đạt được

**Marketing:**
- Chiến dịch bắt đầu/kết thúc
- Kết quả chiến dịch
- Form submission mới
- Email bounce/unsubscribe

### 2.3. Thông báo tác vụ

**Công việc được giao:**
- Task mới được giao
- Deadline sắp đến
- Task hoàn thành
- Task quá hạn

**Lịch hẹn:**
- Cuộc hẹn sắp tới
- Thay đổi lịch hẹn
- Hủy cuộc hẹn
- Nhắc nhở cuộc hẹn

## 3. KÊNH THÔNG BÁO

### 3.1. Thông báo trong ứng dụng

**Thông báo thời gian thực:**
- Hiển thị ngay trong giao diện NextFlow CRM
- Biểu tượng đếm số thông báo chưa đọc (ví dụ: 🔔 5)
- Cửa sổ bật lên cho thông báo khẩn cấp
- Trung tâm thông báo tập trung tất cả tin nhắn

**Ví dụ thông báo:**
```
🔔 Khách hàng mới: "Công ty ABC vừa đăng ký dùng thử"
📞 Cuộc gọi nhỡ: "Nguyễn Văn A đã gọi 3 lần (10:30 AM)"
💰 Đơn hàng mới: "Đơn hàng #DH001 trị giá 15.000.000đ"
⏰ Nhắc nhở: "Cuộc họp với khách hàng XYZ lúc 2:00 PM"
```

**Đặc điểm kỹ thuật:**
- Kết nối WebSocket để nhận thông báo tức thì
- Lưu trữ lịch sử 30 ngày gần nhất
- Đánh dấu trạng thái: đã đọc/chưa đọc/đã xử lý
- Phân loại: Khẩn cấp (đỏ), Quan trọng (vàng), Thông thường (xanh)

### 3.2. Thông báo qua Email

**Các loại email thông báo:**
- Email tức thì cho sự kiện quan trọng (đơn hàng mới, khách hàng VIP)
- Email tổng hợp hàng ngày (báo cáo doanh số, hoạt động)
- Email báo cáo định kỳ (tuần/tháng)
- Email nhắc nhở (deadline, cuộc họp)

**Ví dụ email thông báo:**
```
Tiêu đề: [NextFlow CRM] Đơn hàng mới #DH001 - 15.000.000đ

Xin chào Anh/Chị Nguyễn Văn A,

Bạn có đơn hàng mới cần xử lý:
- Mã đơn hàng: #DH001
- Khách hàng: Công ty ABC
- Giá trị: 15.000.000đ
- Thời gian: 27/10/2024 10:30

👉 Xem chi tiết: https://crm.nextflow.vn/orders/DH001
```

**Hệ thống mẫu email:**
- Mẫu email chuyên nghiệp với logo NextFlow CRM
- Tùy chỉnh màu sắc theo thương hiệu công ty
- Hiển thị tốt trên mọi thiết bị (responsive)
- Hỗ trợ tiếng Việt và tiếng Anh

### 3.3. Thông báo qua SMS

**Các trường hợp sử dụng:**
- Thông báo khẩn cấp (hệ thống gặp sự cố, đơn hàng lớn)
- Mã xác thực OTP khi đăng nhập
- Nhắc nhở cuộc hẹn quan trọng
- Cập nhật trạng thái đơn hàng

**Ví dụ tin nhắn SMS:**
```
[NextFlow CRM] Ma OTP cua ban la: 123456.
Ma co hieu luc trong 5 phut.

[NextFlow CRM] Don hang #DH001 da duoc
giao thanh cong. Cam on ban!

[NextFlow CRM] Nhac nho: Cuoc hop voi
khach hang ABC luc 14:00 ngay mai.
```

**Tính năng kỹ thuật:**
- Tích hợp với Viettel, Vinaphone, Mobifone
- Mẫu tin nhắn có sẵn và tùy chỉnh
- Lên lịch gửi SMS tự động
- Theo dõi trạng thái gửi thành công/thất bại

### 3.4. Thông báo đẩy (Push Notifications)

**Thông báo trên điện thoại:**
- Hiển thị ngay trên màn hình khóa iPhone/Android
- Thông báo có hình ảnh và nút bấm tương tác
- Nhấn để mở trực tiếp trang liên quan trong app
- Hoạt động ngay cả khi không mở ứng dụng

**Ví dụ push notification:**
```
📱 NextFlow CRM
🔔 Đơn hàng mới #DH001
💰 Trị giá: 15.000.000đ
👤 Khách hàng: Công ty ABC
[XEM CHI TIẾT] [BỎ QUA]
```

**Thông báo trên trình duyệt web:**
- Hiển thị góc phải màn hình máy tính
- Có âm thanh báo hiệu (có thể tắt)
- Tùy chỉnh logo công ty và màu sắc
- Theo dõi số lượng người nhấn xem

## 4. QUẢN LÝ THÔNG BÁO

### 4.1. Trung tâm thông báo

**Giao diện quản lý thông báo:**
- Hiển thị tất cả thông báo theo thời gian (mới nhất trước)
- Lọc theo: Loại (đơn hàng, khách hàng, hệ thống), Trạng thái (đã đọc/chưa đọc), Thời gian
- Tìm kiếm thông báo theo từ khóa
- Thao tác hàng loạt: đánh dấu đã đọc, xóa nhiều thông báo cùng lúc

**Ví dụ giao diện trung tâm thông báo:**
```
🔔 TRUNG TÂM THÔNG BÁO (15 chưa đọc)

[Tất cả] [Chưa đọc] [Đơn hàng] [Khách hàng] [Hệ thống]

🟢 10:30 - Đơn hàng mới #DH001 từ Công ty ABC (15.000.000đ)
🟡 10:25 - Khách hàng VIP Nguyễn Văn A vừa xem báo giá #BG001
🔴 10:20 - Cảnh báo: Kho hàng sản phẩm iPhone 15 còn 3 chiếc
⚪ 10:15 - Cuộc họp với khách hàng XYZ lúc 14:00 hôm nay
🟢 10:10 - Thanh toán thành công đơn hàng #DH002 (8.500.000đ)

[Đánh dấu tất cả đã đọc] [Xóa đã đọc] [Xuất báo cáo]
```

**Tính năng nâng cao:**
- Tự động tải thêm khi cuộn xuống (không cần chuyển trang)
- Cập nhật thông báo mới ngay lập tức không cần refresh
- Lưu trữ thông báo cũ (có thể xem lại sau 30 ngày)
- Xuất lịch sử thông báo ra file Excel

### 4.2. Quản lý mẫu thông báo

**Quản lý template thông báo:**
- Tạo và chỉnh sửa mẫu thông báo cho từng loại sự kiện
- Xem trước mẫu thông báo trước khi gửi
- Quản lý phiên bản và lịch sử thay đổi
- Kiểm tra A/B testing để tối ưu hiệu quả

**Ví dụ template đơn hàng mới:**
```
📋 TEMPLATE: Thông báo đơn hàng mới
🎯 Sự kiện: Khi có đơn hàng mới được tạo

📱 In-app: "Đơn hàng mới #{{orderNumber}} từ {{customerName}} - {{amount}}đ"
📧 Email: "Bạn có đơn hàng mới cần xử lý từ khách hàng {{customerName}}"
📱 SMS: "[NextFlow] Don hang moi #{{orderNumber}} - {{amount}}d"
🔔 Push: "Đơn hàng mới #{{orderNumber}} - {{customerName}}"
```

**Cá nhân hóa thông báo:**
- Nội dung động với biến số (tên khách hàng, số tiền, ngày tháng)
- Nội dung có điều kiện (VIP customer có thông báo khác)
- Đa ngôn ngữ (tiếng Việt, tiếng Anh)
- Tùy chỉnh theo thương hiệu công ty

### 4.3. Theo dõi gửi thông báo

**Chỉ số theo dõi:**
- Tỷ lệ gửi thành công (delivery rate)
- Tỷ lệ mở email (open rate)
- Tỷ lệ nhấn link (click rate)
- Tỷ lệ bounce (email bị trả về)

**Ví dụ báo cáo delivery:**
```
📊 BÁO CÁO GỬI THÔNG BÁO - 27/10/2024

📱 In-app: 1,250 thông báo
   ✅ Gửi thành công: 1,250 (100%)
   👀 Đã xem: 1,100 (88%)

📧 Email: 850 email
   ✅ Gửi thành công: 820 (96.5%)
   📬 Bounce: 30 (3.5%)
   👀 Đã mở: 492 (60%)
   🖱️ Đã click: 147 (30%)

📱 SMS: 500 tin nhắn
   ✅ Gửi thành công: 485 (97%)
   ❌ Thất bại: 15 (3%)
```

**Xử lý lỗi gửi:**
- Cơ chế thử lại tự động (retry 3 lần)
- Chuyển sang kênh dự phòng (email → SMS)
- Ghi log chi tiết lỗi
- Cảnh báo khi có lỗi nghiêm trọng

## 5. TỰ ĐỘNG HÓA THÔNG BÁO

### 5.1. Thông báo dựa trên sự kiện

**Các sự kiện kích hoạt:**
- Thay đổi dữ liệu trong database (đơn hàng mới, khách hàng mới)
- Hành động của người dùng (đăng nhập, xem sản phẩm, thanh toán)
- Sự kiện theo thời gian (sinh nhật, deadline, nhắc nhở)
- Gọi API từ hệ thống bên ngoài

**Ví dụ workflow tự động:**
```
🎯 SỰ KIỆN: Khách hàng VIP đặt đơn hàng > 50 triệu

⬇️ BƯỚC 1: Gửi thông báo tức thì cho Sales Manager
📱 "Khách VIP {{customerName}} vừa đặt đơn {{amount}}đ"

⬇️ BƯỚC 2: Chờ 5 phút, gửi email chi tiết
📧 "Thông tin chi tiết đơn hàng VIP #{{orderNumber}}"

⬇️ BƯỚC 3: Nếu chưa xử lý sau 30 phút → Escalate
🚨 "KHẨN CẤP: Đơn hàng VIP chưa được xử lý"

⬇️ BƯỚC 4: Gửi SMS cho Giám đốc
📱 "Don hang VIP {{orderNumber}} can xu ly gap"
```

**Tự động hóa quy trình:**
- Chuỗi thông báo nhiều bước
- Logic có điều kiện (if-then-else)
- Trì hoãn và lên lịch gửi
- Lặp lại và thử lại khi lỗi

### 5.2. Công cụ tạo quy tắc

**Quy tắc kinh doanh:**
- Logic if-then-else đơn giản
- Điều kiện phức tạp (AND, OR, NOT)
- Tính điểm ưu tiên
- Quy tắc leo thang (escalation)

**Ví dụ quy tắc:**
```
📋 QUY TẮC: Thông báo khách hàng quan trọng

🔍 ĐIỀU KIỆN:
   - Khách hàng tier = "VIP"
   AND
   - Đơn hàng > 20.000.000đ
   AND
   - Thời gian = "Ngoài giờ hành chính"

⚡ HÀNH ĐỘNG:
   1. Gửi push notification cho Sales Manager
   2. Gửi SMS cho Account Manager
   3. Tạo task "Xử lý đơn VIP" với priority HIGH
   4. Log vào CRM với tag "VIP_ORDER"
```

**Cấu hình quy tắc:**
- Trình tạo quy tắc bằng giao diện kéo thả
- Thư viện template quy tắc có sẵn
- Kiểm tra và mô phỏng quy tắc
- Quản lý phiên bản quy tắc

### 5.3. Thông báo thông minh

**Tính năng AI:**
- Dự đoán thời gian gửi tối ưu (khi nào user hay check phone)
- Tối ưu nội dung thông báo (A/B test tự động)
- Tối ưu tần suất gửi (tránh spam)
- Cảnh báo khách hàng có nguy cơ rời bỏ

**Ví dụ AI optimization:**
```
🤖 AI PHÂN TÍCH: Nguyễn Văn A

📊 Thói quen:
   - Hay check phone: 8:00-9:00, 12:00-13:00, 18:00-20:00
   - Ít check phone: 22:00-7:00, 14:00-17:00
   - Phản hồi tốt nhất: Push notification
   - Ít phản hồi: Email dài

💡 KHUYẾN NGHỊ:
   - Gửi thông báo quan trọng lúc 8:30 AM
   - Dùng push notification thay vì email
   - Nội dung ngắn gọn, có emoji
   - Tránh gửi sau 9 PM
```

**Machine learning:**
- Phân tích hành vi người dùng
- Dự đoán mức độ tương tác
- Cá nhân hóa nội dung
- Phát hiện bất thường

## 6. CÀI ĐẶT NGƯỜI DÙNG

### 6.1. Tùy chỉnh thông báo cá nhân

**Cài đặt kênh thông báo:**
- Bật/tắt từng kênh (in-app, email, SMS, push)
- Thời gian nhận thông báo (8:00-18:00)
- Tần suất gửi (ngay lập tức, tổng hợp hàng ngày)
- Giờ không làm phiền (22:00-7:00)

**Ví dụ cài đặt cá nhân:**
```
👤 CÀI ĐẶT THÔNG BÁO - Nguyễn Văn A (Sales Manager)

📱 In-app: BẬT
   ✅ Đơn hàng mới
   ✅ Khách hàng VIP
   ✅ Deadline task
   ❌ Thông báo hệ thống

📧 Email: BẬT (Tổng hợp 2 lần/ngày)
   ✅ Báo cáo doanh số
   ✅ Khách hàng mới
   ❌ Marketing

📱 SMS: TẮT (chỉ khẩn cấp)
   ✅ Đơn hàng > 100 triệu
   ❌ Tất cả khác

🔔 Push: BẬT
   ✅ Cuộc gọi nhỡ
   ✅ Meeting reminder
   ❌ Chat message

⏰ Không làm phiền: 22:00 - 7:00
🌍 Múi giờ: Asia/Ho_Chi_Minh
🗣️ Ngôn ngữ: Tiếng Việt
```

**Tùy chỉnh nội dung:**
- Loại thông báo muốn nhận (bán hàng, marketing, hệ thống)
- Mức độ chi tiết (tóm tắt, chi tiết, đầy đủ)
- Ngôn ngữ thông báo (tiếng Việt, tiếng Anh)
- Định dạng hiển thị (text, rich media)

### 6.2. Quản lý đăng ký

**Các loại đăng ký:**
- Thông báo bắt buộc (hệ thống, bảo mật)
- Thông báo tùy chọn (marketing, tips)
- Thông báo marketing (khuyến mãi, sự kiện)
- Cập nhật hệ thống (tính năng mới, bảo trì)

**Ví dụ quản lý subscription:**
```
📋 QUẢN LÝ ĐĂNG KÝ THÔNG BÁO

🔒 BẮT BUỘC (không thể tắt):
   ✅ Thông báo bảo mật
   ✅ Thay đổi mật khẩu
   ✅ Đăng nhập bất thường

⚙️ HỆ THỐNG (có thể tắt):
   ✅ Cập nhật phần mềm
   ✅ Bảo trì hệ thống
   ❌ Tips sử dụng

💼 KINH DOANH (có thể tắt):
   ✅ Đơn hàng và khách hàng
   ✅ Báo cáo doanh số
   ❌ Webinar và training

📢 MARKETING (có thể tắt):
   ❌ Khuyến mãi sản phẩm
   ❌ Sự kiện và hội thảo
   ❌ Newsletter
```

**Tùy chọn hủy đăng ký:**
- Hủy đăng ký một cú nhấp (one-click unsubscribe)
- Kiểm soát chi tiết từng loại
- Tạm dừng thông báo (1 tuần, 1 tháng)
- Đăng ký lại dễ dàng

## 7. TÍCH HỢP BÊN THỨ BA

### 7.1. Nhà cung cấp dịch vụ

**Nhà cung cấp Email:**
- SendGrid (quốc tế, 99.9% uptime)
- Mailgun (developer-friendly)
- Amazon SES (cost-effective)
- SMTP servers (tự host)

**Nhà cung cấp SMS Việt Nam:**
- Viettel SMS (coverage tốt nhất VN)
- Vinaphone SMS (giá cạnh tranh)
- Mobifone SMS (doanh nghiệp)
- Stringee (API hiện đại)

**Ví dụ cấu hình SMS:**
```
📱 CẤU HÌNH SMS VIETTEL

🔧 Thông tin kết nối:
   - API URL: https://api.viettel.vn/sms
   - Username: nextflow_crm
   - Password: ********
   - Brandname: NEXTFLOW

📊 Giá cước:
   - SMS nội mạng: 230đ/tin
   - SMS ngoại mạng: 280đ/tin
   - SMS quốc tế: 1,500đ/tin

⚙️ Cài đặt:
   - Tối đa 160 ký tự/tin
   - Hỗ trợ Unicode (tiếng Việt)
   - Delivery report: Có
   - Thời gian gửi: 6:00-22:00
```

**Dịch vụ Push Notification:**
- Firebase Cloud Messaging (Android + iOS)
- Apple Push Notification (iOS only)
- OneSignal (đa nền tảng)
- Pusher (real-time)

### 7.2. Tích hợp Webhook

**Webhook gửi đi:**
- Gửi thông báo đến hệ thống bên ngoài
- Định dạng payload tùy chỉnh
- Cơ chế thử lại khi lỗi
- Xác thực bảo mật

**Ví dụ webhook payload:**
```json
{
  "event": "notification_sent",
  "timestamp": "2024-10-27T10:30:00Z",
  "notification": {
    "id": "notif_123456789",
    "type": "order_created",
    "recipient": "user_123456789",
    "channels": ["email", "push"],
    "status": "delivered"
  },
  "delivery": {
    "email": {
      "status": "delivered",
      "deliveredAt": "2024-10-27T10:30:05Z"
    },
    "push": {
      "status": "delivered",
      "deliveredAt": "2024-10-27T10:30:01Z"
    }
  }
}
```

**Webhook nhận vào:**
- Nhận trạng thái gửi từ nhà cung cấp
- Xử lý bounce và complaint
- Xử lý hủy đăng ký
- Cập nhật preferences người dùng

## 8. BÁO CÁO VÀ PHÂN TÍCH

### 8.1. Phân tích hiệu quả thông báo

**Chỉ số gửi thông báo:**
- Tổng số thông báo đã gửi
- Tỷ lệ gửi thành công
- Hiệu suất từng kênh
- Phân tích theo thời gian

**Ví dụ báo cáo hàng ngày:**
```
📊 BÁO CÁO THÔNG BÁO - 27/10/2024

📈 TỔNG QUAN:
├── Tổng gửi: 2,450 thông báo
├── Thành công: 2,380 (97.1%)
├── Thất bại: 70 (2.9%)
└── Tương tác: 1,456 (61.2%)

📱 THEO KÊNH:
├── In-app: 1,200 (100% delivered, 88% viewed)
├── Email: 800 (96% delivered, 65% opened, 25% clicked)
├── SMS: 300 (95% delivered)
└── Push: 150 (98% delivered, 75% opened)

⏰ THEO GIỜ:
├── 8:00-9:00: 450 thông báo (peak time)
├── 12:00-13:00: 380 thông báo
├── 18:00-19:00: 420 thông báo
└── 22:00-7:00: 50 thông báo (do not disturb)
```

**Chỉ số tương tác:**
- Tỷ lệ mở thông báo
- Tỷ lệ nhấn link
- Tỷ lệ phản hồi
- Theo dõi chuyển đổi

### 8.2. Giám sát hiệu suất

**Hiệu suất hệ thống:**
- Tốc độ gửi thông báo (messages/second)
- Thời gian xử lý hàng đợi
- Tỷ lệ lỗi hệ thống
- Sử dụng tài nguyên server

**Ví dụ monitoring dashboard:**
```
🖥️ DASHBOARD GIÁM SÁT REAL-TIME

⚡ HIỆU SUẤT:
├── Tốc độ gửi: 150 msg/sec
├── Queue size: 45 messages
├── Avg processing: 0.8 seconds
└── Error rate: 0.2%

🔧 HỆ THỐNG:
├── CPU usage: 35%
├── Memory usage: 2.1GB/8GB
├── Disk I/O: Normal
└── Network: 15 Mbps

⚠️ CẢNH BÁO:
├── 🟡 SMS provider slow response (3s)
├── 🟢 All other services normal
└── 🟢 No critical issues
```

**Phân tích người dùng:**
- Người dùng tương tác nhiều nhất
- Phân tích notification fatigue
- Phân tích thời gian tối ưu
- Hiệu quả nội dung

### 8.3. Dashboard báo cáo

**Dashboard thời gian thực:**
- Trạng thái thông báo trực tiếp
- Giám sát hàng đợi
- Theo dõi lỗi
- Chỉ số hiệu suất

**Ví dụ dashboard tổng quan:**
```
📊 DASHBOARD THÔNG BÁO - REAL-TIME

🎯 KPI CHÍNH:
├── Delivery Rate: 97.1% ↗️ (+0.5%)
├── Open Rate: 65.2% ↗️ (+2.1%)
├── Click Rate: 24.8% ↘️ (-1.2%)
└── Response Time: 0.8s ↗️ (+0.1s)

📈 TREND 7 NGÀY:
Mon: 2,100 | Tue: 2,300 | Wed: 2,450 | Thu: 2,200
Fri: 2,600 | Sat: 1,800 | Sun: 1,500

🏆 TOP PERFORMERS:
├── Best channel: In-app (100% delivery)
├── Best time: 8:00-9:00 AM (highest engagement)
├── Best content: Order notifications (85% CTR)
└── Best user segment: VIP customers (90% engagement)
```

**Báo cáo lịch sử:**
- Phân tích xu hướng
- Báo cáo so sánh
- Khoảng thời gian tùy chỉnh
- Xuất báo cáo (Excel, PDF)

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 1.0.0
**Tác giả**: NextFlow CRM Product Team

---

**Cập nhật lần cuối**: 2024-01-15
**Phiên bản**: 1.0.0
**Tác giả**: NextFlow CRM Product Team
