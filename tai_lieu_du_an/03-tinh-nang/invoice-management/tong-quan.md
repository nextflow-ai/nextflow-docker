# HỆ THỐNG QUẢN LÝ HÓA ĐƠN NextFlow CRM

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Tạo và quản lý hóa đơn](#2-tạo-và-quản-lý-hóa-đơn)
3. [Hóa đơn điện tử](#3-hóa-đơn-điện-tử)
4. [Thanh toán và thu tiền](#4-thanh-toán-và-thu-tiền)
5. [Báo cáo tài chính](#5-báo-cáo-tài-chính)
6. [Tích hợp kế toán](#6-tích-hợp-kế-toán)
7. [Quản lý thuế](#7-quản-lý-thuế)
8. [Tự động hóa quy trình](#8-tự-động-hóa-quy-trình)

## 1. GIỚI THIỆU

Hệ thống Quản lý Hóa đơn của NextFlow CRM giúp doanh nghiệp tạo, gửi và theo dõi hóa đơn một cách chuyên nghiệp, tuân thủ pháp luật Việt Nam về hóa đơn điện tử.

### 1.1. Mục tiêu chính

- **Tạo hóa đơn nhanh chóng**: Từ báo giá chuyển thành hóa đơn chỉ 1 cú nhấp
- **Hóa đơn điện tử hợp pháp**: Tuân thủ Thông tư 78/2021/TT-BTC
- **Theo dõi thanh toán**: Quản lý công nợ và nhắc nhở tự động
- **Báo cáo tài chính**: Doanh thu, lợi nhuận, thuế VAT

### 1.2. Lợi ích thực tế

- **Tiết kiệm 80% thời gian** tạo hóa đơn so với làm thủ công
- **Giảm 95% sai sót** nhờ tự động tính toán thuế và tổng tiền
- **Thu tiền nhanh hơn 40%** với nhắc nhở thanh toán tự động
- **Tuân thủ 100% pháp luật** về hóa đơn điện tử

### 1.3. Ví dụ thực tế

**Quy trình tạo hóa đơn:**
```
📋 Bước 1: Chọn đơn hàng #DH001 (Công ty ABC - 15.000.000đ)
⚡ Bước 2: Nhấn "Tạo hóa đơn" → Tự động điền thông tin
📝 Bước 3: Kiểm tra và điều chỉnh (nếu cần)
✅ Bước 4: Ký số và gửi hóa đơn điện tử
📧 Bước 5: Email hóa đơn PDF đến khách hàng
📊 Bước 6: Theo dõi trạng thái thanh toán

⏱️ Tổng thời gian: 2 phút (thay vì 30 phút làm thủ công)
```

## 2. TẠO VÀ QUẢN LÝ HÓA ĐƠN

### 2.1. Tạo hóa đơn từ đơn hàng

**Chuyển đổi tự động:**
- Chọn đơn hàng đã xác nhận → Nhấn "Tạo hóa đơn"
- Hệ thống tự động điền: thông tin khách hàng, sản phẩm, giá, thuế
- Kiểm tra và điều chỉnh thông tin (nếu cần)
- Tạo hóa đơn trong 30 giây

**Ví dụ chuyển đổi:**
```
📦 ĐỚN HÀNG #DH001
👤 Khách hàng: Công ty ABC
📍 Địa chỉ: 123 Đường XYZ, Hà Nội
🏢 MST: 0123456789

📋 Sản phẩm:
- iPhone 15 Pro Max x 2 = 60.000.000đ
- Ốp lưng x 2 = 1.000.000đ
- Subtotal: 61.000.000đ
- VAT 10%: 6.100.000đ
- Tổng cộng: 67.100.000đ

⬇️ [TẠO HÓA ĐƠN] ⬇️

🧾 HÓA ĐƠN #HD001
📅 Ngày: 27/10/2024
👤 Người mua: Công ty ABC (MST: 0123456789)
🏢 Người bán: NextFlow Corp (MST: 9876543210)
💰 Tổng tiền: 67.100.000đ (Sáu mươi bảy triệu một trăm nghìn đồng)
```

### 2.2. Tạo hóa đơn thủ công

**Hóa đơn linh hoạt:**
- Tạo hóa đơn không từ đơn hàng (dịch vụ, tư vấn)
- Nhập thông tin khách hàng mới hoặc chọn từ danh sách
- Thêm sản phẩm/dịch vụ với giá tùy chỉnh
- Áp dụng chiết khấu và thuế suất khác nhau

**Mẫu hóa đơn dịch vụ:**
```
🧾 HÓA ĐƠN DỊCH VỤ #HD002
📅 Ngày: 27/10/2024
👤 Khách hàng: Công ty XYZ
📞 Điện thoại: 024.1234.5678

📋 Dịch vụ:
1. Tư vấn triển khai CRM - 3 ngày
   Đơn giá: 5.000.000đ/ngày
   Thành tiền: 15.000.000đ

2. Đào tạo sử dụng hệ thống - 2 ngày  
   Đơn giá: 3.000.000đ/ngày
   Thành tiền: 6.000.000đ

💰 Tổng trước thuế: 21.000.000đ
🏛️ Thuế VAT 10%: 2.100.000đ
💵 Tổng thanh toán: 23.100.000đ
```

### 2.3. Quản lý trạng thái hóa đơn

**Vòng đời hóa đơn:**
```
📝 Nháp → ✅ Đã gửi → 💰 Đã thanh toán → 📁 Đã lưu trữ
    ↓         ↓           ↓              ↓
  Chỉnh sửa  Nhắc nhở   Đối soát      Báo cáo thuế
```

**Theo dõi chi tiết:**
- **Nháp**: Có thể chỉnh sửa, chưa có giá trị pháp lý
- **Đã gửi**: Đã ký số, gửi cho khách hàng, chờ thanh toán
- **Quá hạn**: Đã quá ngày thanh toán, cần nhắc nhở
- **Đã thanh toán**: Đã nhận tiền, đối soát xong
- **Đã hủy**: Hóa đơn bị hủy (có lý do và người phê duyệt)

## 3. HÓA ĐƠN ĐIỆN TỬ

### 3.1. Tuân thủ pháp luật Việt Nam

**Thông tư 78/2021/TT-BTC:**
- Hóa đơn điện tử có chữ ký số hợp pháp
- Mã số thuế và thông tin doanh nghiệp đầy đủ
- Định dạng XML chuẩn của Tổng cục Thuế
- Lưu trữ tối thiểu 10 năm

**Ví dụ thông tin bắt buộc:**
```
🏢 THÔNG TIN NGƯỜI BÁN
Tên: Công ty TNHH NextFlow Việt Nam
MST: 0123456789-001
Địa chỉ: Tầng 10, Tòa nhà ABC, 123 Đường XYZ, Hà Nội
Điện thoại: 024.1234.5678
Email: info@nextflow.vn

👤 THÔNG TIN NGƯỜI MUA  
Tên: Công ty Cổ phần DEF
MST: 9876543210
Địa chỉ: 456 Đường UVW, TP.HCM
Điện thoại: 028.8765.4321

🔐 CHỮ KÝ SỐ
Cơ quan cấp: VNPT-CA
Số serial: 1234567890ABCDEF
Thời gian ký: 27/10/2024 10:30:15
```

### 3.2. Tích hợp nhà cung cấp hóa đơn điện tử

**Các nhà cung cấp hỗ trợ:**
- VNPT Invoice (VNPT-CA)
- FPT Invoice (FPT-CA) 
- Viettel Invoice (Viettel-CA)
- MISA eInvoice
- Fast Invoice

**Quy trình ký số tự động:**
```
📝 Tạo hóa đơn trong NextFlow CRM
⬇️
🔐 Gửi đến nhà cung cấp ký số (VNPT-CA)
⬇️
✅ Nhận hóa đơn đã ký số + mã tra cứu
⬇️
📧 Gửi email PDF đến khách hàng
⬇️
📊 Cập nhật trạng thái trong hệ thống
```

### 3.3. Tra cứu và xác thực

**Mã tra cứu hóa đơn:**
- Mỗi hóa đơn có mã tra cứu duy nhất
- Khách hàng có thể tra cứu trên website Tổng cục Thuế
- Xác thực tính hợp pháp của hóa đơn
- Tải về bản PDF gốc có chữ ký số

**Ví dụ mã tra cứu:**
```
🔍 THÔNG TIN TRA CỨU HÓA ĐƠN
Số hóa đơn: 00000001
Ký hiệu: 1C24TAA
Mã tra cứu: 123456789012345678901234567890AB
Website tra cứu: https://tracuuhoadon.gdt.gov.vn

📱 QR Code để tra cứu nhanh:
[QR CODE IMAGE]
```

## 4. THANH TOÁN VÀ THU TIỀN

### 4.1. Theo dõi công nợ

**Dashboard công nợ:**
```
💰 TỔNG QUAN CÔNG NỢ (tháng 10/2024)

📊 Tổng hóa đơn: 150 hóa đơn - 2.5 tỷ đồng
✅ Đã thanh toán: 120 hóa đơn - 2.1 tỷ đồng (84%)
⏰ Chưa đến hạn: 20 hóa đơn - 300 triệu đồng
🔴 Quá hạn: 10 hóa đơn - 100 triệu đồng

📈 TOP KHÁCH HÀNG NỢ NHIỀU NHẤT:
1. Công ty ABC: 50 triệu đồng (quá hạn 15 ngày)
2. Công ty XYZ: 30 triệu đồng (quá hạn 7 ngày)  
3. Công ty DEF: 20 triệu đồng (chưa đến hạn)
```

### 4.2. Nhắc nhở thanh toán tự động

**Email nhắc nhở thông minh:**
- 7 ngày trước hạn: Email nhắc nhở lịch sự
- Ngày đến hạn: Email nhắc nhở chính thức
- 3 ngày quá hạn: Email nhắc nhở khẩn cấp
- 7 ngày quá hạn: Email cảnh báo và gọi điện

**Mẫu email nhắc nhở:**
```
📧 Tiêu đề: [NextFlow CRM] Nhắc nhở thanh toán hóa đơn #HD001

Kính gửi Anh/Chị,

Chúng tôi xin nhắc nhở về hóa đơn sau:
- Số hóa đơn: #HD001
- Ngày phát hành: 15/10/2024
- Hạn thanh toán: 30/10/2024 (còn 3 ngày)
- Số tiền: 67.100.000đ

Để thanh toán, Quý khách có thể:
💳 Chuyển khoản: 1234567890 - Ngân hàng Vietcombank
💰 Thanh toán trực tiếp tại văn phòng
🌐 Thanh toán online: https://pay.nextflow.vn/HD001

Trân trọng cảm ơn!
```

### 4.3. Đối soát thanh toán

**Đối soát tự động:**
- Kết nối API ngân hàng để nhận thông báo chuyển khoản
- Tự động ghép nối với hóa đơn dựa trên nội dung chuyển khoản
- Cập nhật trạng thái "Đã thanh toán" ngay lập tức
- Gửi email xác nhận đã nhận tiền

**Ví dụ đối soát:**
```
🏦 THÔNG BÁO CHUYỂN KHOẢN
Ngày: 27/10/2024 14:30:15
Số tiền: 67.100.000 VND
Nội dung: "Thanh toan HD001 Cong ty ABC"
Từ TK: 9876543210 (Công ty ABC)
Đến TK: 1234567890 (NextFlow Corp)

⚡ TỰ ĐỘNG GHÉP NỐI:
✅ Tìm thấy hóa đơn #HD001
✅ Số tiền khớp: 67.100.000đ  
✅ Cập nhật trạng thái: Đã thanh toán
✅ Gửi email xác nhận đến khách hàng
```

## 5. BÁO CÁO TÀI CHÍNH

### 5.1. Báo cáo doanh thu

**Báo cáo theo thời gian:**
```
📊 BÁO CÁO DOANH THU THÁNG 10/2024

💰 Tổng doanh thu: 2.500.000.000đ
📈 Tăng trưởng: +15% so với tháng 9
🧾 Số hóa đơn: 150 hóa đơn
💵 Giá trị TB/hóa đơn: 16.667.000đ

📊 PHÂN TÍCH THEO TUẦN:
Tuần 1: 600 triệu đồng (35 hóa đơn)
Tuần 2: 650 triệu đồng (38 hóa đơn)  
Tuần 3: 700 triệu đồng (42 hóa đơn)
Tuần 4: 550 triệu đồng (35 hóa đơn)

🏆 TOP SẢN PHẨM BÁN CHẠY:
1. iPhone 15 Pro: 800 triệu đồng (32%)
2. MacBook Air M3: 500 triệu đồng (20%)
3. iPad Pro: 300 triệu đồng (12%)
```

### 5.2. Báo cáo thuế VAT

**Báo cáo chuẩn bị nộp thuế:**
```
🏛️ BÁO CÁO THUẾ VAT THÁNG 10/2024

📊 THUẾ ĐẦU RA (bán hàng):
- Doanh thu chịu thuế 10%: 2.000.000.000đ
- Thuế VAT 10%: 200.000.000đ
- Doanh thu chịu thuế 8%: 300.000.000đ  
- Thuế VAT 8%: 24.000.000đ
- Doanh thu không chịu thuế: 200.000.000đ

📊 THUẾ ĐẦU VÀO (mua hàng):
- Thuế VAT được khấu trừ: 150.000.000đ

💰 THUẾ VAT PHẢI NỘP:
Thuế đầu ra: 224.000.000đ
Thuế đầu vào: 150.000.000đ
Thuế phải nộp: 74.000.000đ

📅 Hạn nộp: 20/11/2024
```

### 5.3. Phân tích khách hàng

**Báo cáo khách hàng theo doanh thu:**
```
👥 PHÂN TÍCH KHÁCH HÀNG THÁNG 10/2024

🏆 TOP 10 KHÁCH HÀNG LỚN NHẤT:
1. Công ty ABC: 200 triệu đồng (8 hóa đơn)
2. Công ty XYZ: 150 triệu đồng (5 hóa đơn)
3. Công ty DEF: 120 triệu đồng (12 hóa đơn)

📊 PHÂN KHÚC KHÁCH HÀNG:
- VIP (>100 triệu): 15 khách hàng - 1.2 tỷ đồng (48%)
- Trung bình (20-100 triệu): 35 khách hàng - 1.0 tỷ đồng (40%)  
- Nhỏ (<20 triệu): 100 khách hàng - 300 triệu đồng (12%)

⚠️ KHÁCH HÀNG CẦN QUAN TÂM:
- Công ty GHI: Giảm 50% doanh thu so với tháng trước
- Công ty JKL: Chưa mua hàng trong 3 tháng
```

## 6. TÍCH HỢP KẾ TOÁN

### 6.1. Kết nối phần mềm kế toán

**Các phần mềm hỗ trợ:**
- MISA SME.NET
- FAST Accounting  
- BRAVO
- SAP Business One
- Tự động đồng bộ dữ liệu

**Quy trình đồng bộ:**
```
🧾 Tạo hóa đơn trong NextFlow CRM
⬇️
📊 Tự động tạo bút toán trong phần mềm kế toán:
   - Nợ TK 131 (Phải thu khách hàng): 67.100.000đ
   - Có TK 511 (Doanh thu bán hàng): 61.000.000đ  
   - Có TK 3331 (Thuế VAT phải nộp): 6.100.000đ
⬇️
💰 Khi nhận tiền:
   - Nợ TK 111 (Tiền mặt): 67.100.000đ
   - Có TK 131 (Phải thu khách hàng): 67.100.000đ
```

### 6.2. Báo cáo tài chính tự động

**Báo cáo được tạo tự động:**
- Bảng cân đối kế toán
- Báo cáo kết quả kinh doanh  
- Báo cáo lưu chuyển tiền tệ
- Thuyết minh báo cáo tài chính

## 7. QUẢN LÝ THUẾ

### 7.1. Tính thuế tự động

**Thuế suất linh hoạt:**
- Thuế VAT 0%, 5%, 8%, 10% tùy theo sản phẩm
- Thuế nhập khẩu cho hàng hóa nhập khẩu
- Thuế tiêu thụ đặc biệt cho một số mặt hàng
- Miễn thuế cho hàng xuất khẩu

**Ví dụ tính thuế phức tạp:**
```
🧾 HÓA ĐƠN HỖN HỢP #HD003

📱 iPhone 15 Pro (hàng nhập khẩu):
   Giá gốc: 25.000.000đ
   Thuế nhập khẩu 10%: 2.500.000đ
   Giá sau thuế NK: 27.500.000đ
   Thuế VAT 10%: 2.750.000đ
   Giá bán: 30.250.000đ

🍺 Bia Heineken (hàng tiêu thụ đặc biệt):
   Giá gốc: 500.000đ
   Thuế TTĐB 65%: 325.000đ  
   Giá sau thuế TTĐB: 825.000đ
   Thuế VAT 10%: 82.500đ
   Giá bán: 907.500đ

📚 Sách giáo khoa (miễn thuế):
   Giá gốc: 100.000đ
   Thuế VAT 0%: 0đ
   Giá bán: 100.000đ
```

### 7.2. Khai báo thuế điện tử

**Tích hợp eTax:**
- Kết nối với hệ thống eTax của Tổng cục Thuế
- Tự động tạo tờ khai thuế từ dữ liệu hóa đơn
- Nộp tờ khai trực tuyến
- Theo dõi trạng thái xử lý

## 8. TỰ ĐỘNG HÓA QUY TRÌNH

### 8.1. Workflow tự động

**Quy trình hoàn toàn tự động:**
```
📦 Đơn hàng được xác nhận
⬇️ (Tự động sau 1 giờ)
🧾 Tạo hóa đơn và ký số
⬇️ (Tự động ngay lập tức)  
📧 Gửi email hóa đơn đến khách hàng
⬇️ (Tự động sau 7 ngày)
📨 Gửi email nhắc nhở thanh toán
⬇️ (Khi nhận được tiền)
✅ Cập nhật trạng thái đã thanh toán
⬇️ (Tự động ngay lập tức)
📊 Cập nhật báo cáo doanh thu
```

### 8.2. Cảnh báo thông minh

**Hệ thống cảnh báo:**
- Hóa đơn sắp đến hạn thanh toán (3 ngày trước)
- Hóa đơn quá hạn thanh toán
- Doanh thu tháng giảm so với cùng kỳ năm trước
- Khách hàng VIP chưa mua hàng trong 30 ngày
- Hết hạn chữ ký số (trước 30 ngày)

**Ví dụ cảnh báo:**
```
⚠️ CẢNH BÁO HỆ THỐNG
📅 Ngày: 27/10/2024 09:00

🔴 KHẨN CẤP:
- 5 hóa đơn quá hạn thanh toán (tổng: 150 triệu đồng)
- Chữ ký số sẽ hết hạn sau 15 ngày

🟡 QUAN TRỌNG:  
- 12 hóa đơn sắp đến hạn trong 3 ngày tới
- Khách hàng VIP "Công ty ABC" chưa mua hàng 25 ngày

🟢 THÔNG TIN:
- Doanh thu tháng 10 đạt 95% kế hoạch
- 3 khách hàng mới đăng ký trong tuần
```

---

**Cập nhật lần cuối**: 2024-01-15  
**Phiên bản**: 1.0.0  
**Tác giả**: NextFlow CRM Finance Team
