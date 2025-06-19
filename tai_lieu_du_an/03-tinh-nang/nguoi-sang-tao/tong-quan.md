# TỔNG QUAN TÍNH NĂNG CHO NGƯỜI SÁNG TẠO NỘI DUNG

## Mục lục

1. [GIỚI THIỆU](#1-giới-thiệu)
   - [1.1. Đối tượng sử dụng](#11-đối-tượng-sử-dụng)
   - [1.2. Lợi ích chính](#12-lợi-ích-chính)
2. [QUẢN LÝ ĐA NỀN TẢNG](#2-quản-lý-đa-nền-tảng)
   - [2.1. Tích hợp nền tảng](#21-tích-hợp-nền-tảng)
   - [2.2. Quản lý người theo dõi](#22-quản-lý-người-theo-dõi)
   - [2.3. Quản lý tương tác](#23-quản-lý-tương-tác)
   - [2.4. Lập lịch đăng tải](#24-lập-lịch-đăng-tải)
3. [QUẢN LÝ NỘI DUNG](#3-quản-lý-nội-dung)
   - [3.1. Kế hoạch nội dung](#31-kế-hoạch-nội-dung)
   - [3.2. Quản lý tài sản số](#32-quản-lý-tài-sản-số)
   - [3.3. Biên tập nội dung](#33-biên-tập-nội-dung)
   - [3.4. Tối ưu hóa nội dung](#34-tối-ưu-hóa-nội-dung)
4. [QUẢN LÝ HỢP TÁC THƯƠNG HIỆU](#4-quản-lý-hợp-tác-thương-hiệu)
   - [4.1. Quản lý thương hiệu và đối tác](#41-quản-lý-thương-hiệu-và-đối-tác)
   - [4.2. Quản lý cơ hội hợp tác](#42-quản-lý-cơ-hội-hợp-tác)
   - [4.3. Quản lý hợp đồng](#43-quản-lý-hợp-đồng)
   - [4.4. Quản lý chiến dịch](#44-quản-lý-chiến-dịch)
5. [QUẢN LÝ TÀI CHÍNH](#5-quản-lý-tài-chính)
   - [5.1. Quản lý doanh thu](#51-quản-lý-doanh-thu)
   - [5.2. Quản lý chi phí](#52-quản-lý-chi-phí)
   - [5.3. Quản lý thuế](#53-quản-lý-thuế)
   - [5.4. Quản lý sản phẩm](#54-quản-lý-sản-phẩm)
6. [PHÂN TÍCH HIỆU SUẤT](#6-phân-tích-hiệu-suất)
   - [6.1. Analytics tổng hợp](#61-analytics-tổng-hợp)
   - [6.2. Phân tích nội dung](#62-phân-tích-nội-dung)
   - [6.3. Phân tích người theo dõi](#63-phân-tích-người-theo-dõi)
   - [6.4. Phân tích thị trường](#64-phân-tích-thị-trường)
7. [TÍCH HỢP AI VÀ TỰ ĐỘNG HÓA](#7-tích-hợp-ai-và-tự-động-hóa)
   - [7.1. Sáng tạo nội dung với AI](#71-sáng-tạo-nội-dung-với-ai)
   - [7.2. Tự động hóa quy trình](#72-tự-động-hóa-quy-trình)
   - [7.3. Phân tích dự đoán](#73-phân-tích-dự-đoán)
   - [7.4. Chatbot và trợ lý ảo](#74-chatbot-và-trợ-lý-ảo)
8. [QUẢN LÝ CỘNG ĐỒNG](#8-quản-lý-cộng-đồng)
   - [8.1. Tương tác với người theo dõi](#81-tương-tác-với-người-theo-dõi)
   - [8.2. Quản lý sự kiện](#82-quản-lý-sự-kiện)
   - [8.3. Quản lý nội dung người dùng tạo](#83-quản-lý-nội-dung-người-dùng-tạo)
   - [8.4. Chương trình khách hàng thân thiết](#84-chương-trình-khách-hàng-thân-thiết)
9. [TÍCH HỢP VÀ MỞ RỘNG](#9-tích-hợp-và-mở-rộng)
   - [9.1. Tích hợp với công cụ sáng tạo](#91-tích-hợp-với-công-cụ-sáng-tạo)
   - [9.2. Tích hợp với công cụ marketing](#92-tích-hợp-với-công-cụ-marketing)
   - [9.3. API và Webhook](#93-api-và-webhook)
   - [9.4. Mobile App](#94-mobile-app)
10. [BẢO MẬT VÀ QUYỀN RIÊNG TƯ](#10-bảo-mật-và-quyền-riêng-tư)
    - [10.1. Bảo mật tài khoản](#101-bảo-mật-tài-khoản)
    - [10.2. Bảo vệ nội dung](#102-bảo-vệ-nội-dung)
    - [10.3. Tuân thủ quy định](#103-tuân-thủ-quy-định)
11. [TỔNG KẾT](#11-tổng-kết)
12. [TÀI LIỆU LIÊN QUAN](#12-tài-liệu-liên-quan)

## 1. GIỚI THIỆU

NextFlow CRM cung cấp các tính năng đặc thù cho người sáng tạo nội dung (content creator) và KOLs, giúp họ quản lý người theo dõi, nội dung, hợp tác thương hiệu và phân tích hiệu suất một cách hiệu quả. Tài liệu này mô tả chi tiết về các tính năng của NextFlow CRM dành riêng cho người sáng tạo nội dung.

### 1.1. Đối tượng sử dụng

- **Influencer và KOLs**: Người có ảnh hưởng trên mạng xã hội
- **Content Creator**: Người sáng tạo nội dung trên YouTube, TikTok, Facebook, v.v.
- **Blogger và Vlogger**: Người viết blog, quay vlog
- **Podcaster**: Người sản xuất podcast
- **Nghệ sĩ số**: Nghệ sĩ hoạt động trên nền tảng số

### 1.2. Lợi ích chính

- **Quản lý đa nền tảng**: Quản lý tài khoản trên nhiều nền tảng từ một giao diện
- **Tối ưu hóa nội dung**: Phân tích và cải thiện hiệu suất nội dung
- **Quản lý hợp tác**: Theo dõi và quản lý hợp tác với thương hiệu
- **Tự động hóa**: Tự động hóa các nhiệm vụ lặp lại
- **Phân tích dữ liệu**: Báo cáo, dashboard, phân tích xu hướng

## 2. QUẢN LÝ ĐA NỀN TẢNG

### 2.1. Tích hợp nền tảng

- **Kết nối đa nền tảng**: Tích hợp với YouTube, TikTok, Instagram, Facebook, Twitter, LinkedIn, v.v.
- **Đồng bộ hóa dữ liệu**: Đồng bộ thông tin từ các nền tảng
- **Quản lý tài khoản**: Quản lý nhiều tài khoản trên cùng một nền tảng
- **Xác thực an toàn**: Kết nối an toàn với API của nền tảng
- **Cập nhật tự động**: Tự động cập nhật dữ liệu từ nền tảng
- **Trạng thái kết nối**: Theo dõi trạng thái kết nối với các nền tảng

### 2.2. Quản lý người theo dõi

- **Thống kê người theo dõi**: Số lượng, tăng trưởng, phân bố
- **Phân tích nhân khẩu học**: Độ tuổi, giới tính, vị trí địa lý
- **Phân loại người theo dõi**: Theo mức độ tương tác, trung thành
- **Người theo dõi chung**: Xác định người theo dõi trên nhiều nền tảng
- **Người theo dõi có ảnh hưởng**: Xác định người theo dõi là influencer
- **Xu hướng người theo dõi**: Phân tích xu hướng tăng/giảm

### 2.3. Quản lý tương tác

- **Theo dõi tương tác**: Like, comment, share, save
- **Phản hồi comment**: Quản lý và phản hồi comment từ một giao diện
- **Lọc comment**: Lọc comment theo từ khóa, sentiment
- **Tự động trả lời**: Thiết lập trả lời tự động cho comment phổ biến
- **Thông báo**: Cảnh báo khi có tương tác quan trọng
- **Phân tích sentiment**: Phân tích cảm xúc trong comment

### 2.4. Lập lịch đăng tải

- **Lịch đăng tải**: Lập lịch đăng nội dung trên nhiều nền tảng
- **Đăng tải tự động**: Tự động đăng nội dung theo lịch
- **Tối ưu thời gian**: Gợi ý thời gian đăng tải tối ưu
- **Xem trước**: Xem trước nội dung trước khi đăng
- **Quản lý hàng đợi**: Quản lý nội dung chờ đăng
- **Lặp lại**: Lập lịch đăng tải lặp lại

## 3. QUẢN LÝ NỘI DUNG

### 3.1. Kế hoạch nội dung

- **Lịch nội dung**: Lập kế hoạch nội dung theo tuần, tháng
- **Ý tưởng nội dung**: Lưu trữ và quản lý ý tưởng
- **Chủ đề và series**: Tổ chức nội dung theo chủ đề, series
- **Mục tiêu**: Thiết lập mục tiêu cho nội dung
- **Workflow**: Quy trình sản xuất nội dung
- **Nhắc nhở**: Thông báo deadline, nhiệm vụ

### 3.2. Quản lý tài sản số

- **Kho media**: Lưu trữ và quản lý hình ảnh, video, âm thanh
- **Phân loại**: Phân loại tài sản theo thẻ, thư mục
- **Tìm kiếm**: Tìm kiếm nhanh chóng bằng từ khóa, thẻ
- **Phiên bản**: Quản lý phiên bản của tài sản
- **Metadata**: Quản lý metadata của tài sản
- **Chia sẻ**: Chia sẻ tài sản với cộng tác viên

### 3.3. Biên tập nội dung

- **Soạn thảo văn bản**: Soạn thảo caption, bài viết
- **Chỉnh sửa hình ảnh**: Công cụ chỉnh sửa hình ảnh cơ bản
- **Cắt ghép video**: Công cụ cắt ghép video đơn giản
- **Template**: Sử dụng template có sẵn
- **Hashtag suggestion**: Gợi ý hashtag phù hợp
- **Kiểm tra chính tả**: Kiểm tra lỗi chính tả, ngữ pháp

### 3.4. Tối ưu hóa nội dung

- **SEO**: Gợi ý tối ưu hóa cho công cụ tìm kiếm
- **Phân tích từ khóa**: Nghiên cứu và gợi ý từ khóa
- **A/B Testing**: So sánh hiệu suất của các phiên bản nội dung
- **Readability**: Đánh giá độ dễ đọc của nội dung
- **Engagement prediction**: Dự đoán mức độ tương tác
- **Content recycling**: Gợi ý tái sử dụng nội dung

## 4. QUẢN LÝ HỢP TÁC THƯƠNG HIỆU

### 4.1. Quản lý thương hiệu và đối tác

- **Danh sách thương hiệu**: Quản lý thông tin thương hiệu đã hợp tác
- **Phân loại**: Phân loại thương hiệu theo ngành, quy mô
- **Lịch sử hợp tác**: Theo dõi lịch sử hợp tác với thương hiệu
- **Người liên hệ**: Quản lý thông tin người liên hệ của thương hiệu
- **Ghi chú**: Lưu trữ ghi chú về thương hiệu
- **Đánh giá**: Đánh giá mức độ hài lòng khi làm việc với thương hiệu

### 4.2. Quản lý cơ hội hợp tác

- **Pipeline hợp tác**: Theo dõi cơ hội hợp tác từ lead đến ký kết
- **Quy trình hợp tác**: Thiết lập quy trình hợp tác tùy chỉnh
- **Báo giá**: Tạo và quản lý báo giá
- **Đàm phán**: Ghi nhận quá trình đàm phán
- **Phê duyệt**: Quy trình phê duyệt nội dung
- **Theo dõi tiến độ**: Cập nhật trạng thái hợp tác

### 4.3. Quản lý hợp đồng

- **Tạo hợp đồng**: Tạo hợp đồng từ mẫu có sẵn
- **Quản lý phiên bản**: Theo dõi các phiên bản hợp đồng
- **Ký điện tử**: Tích hợp ký điện tử
- **Nhắc nhở**: Cảnh báo hợp đồng sắp hết hạn
- **Điều khoản**: Quản lý thư viện điều khoản
- **Tuân thủ**: Đảm bảo tuân thủ quy định về quảng cáo

### 4.4. Quản lý chiến dịch

- **Lập kế hoạch**: Thiết kế chiến dịch hợp tác
- **Brief**: Quản lý brief từ thương hiệu
- **Nội dung**: Quản lý nội dung cho chiến dịch
- **Lịch trình**: Lập lịch đăng tải nội dung
- **Báo cáo**: Tạo báo cáo hiệu suất chiến dịch
- **ROI**: Đánh giá hiệu quả đầu tư của chiến dịch

## 5. QUẢN LÝ TÀI CHÍNH

### 5.1. Quản lý doanh thu

- **Nguồn doanh thu**: Theo dõi doanh thu từ nhiều nguồn (quảng cáo, hợp tác, sản phẩm)
- **Hóa đơn**: Tạo và quản lý hóa đơn
- **Thanh toán**: Theo dõi trạng thái thanh toán
- **Dự báo**: Dự báo doanh thu trong tương lai
- **Phân tích**: Phân tích doanh thu theo nguồn, thời gian
- **Báo cáo**: Báo cáo doanh thu theo kỳ

### 5.2. Quản lý chi phí

- **Danh mục chi phí**: Phân loại chi phí theo danh mục
- **Hóa đơn chi phí**: Lưu trữ hóa đơn, chứng từ
- **Phân bổ**: Phân bổ chi phí cho dự án, chiến dịch
- **Ngân sách**: Lập và theo dõi ngân sách
- **Hoàn thuế**: Quản lý chi phí được hoàn thuế
- **Báo cáo**: Phân tích chi phí theo nhiều chiều

### 5.3. Quản lý thuế

- **Tính toán thuế**: Hỗ trợ tính toán thuế thu nhập
- **Kê khai**: Chuẩn bị thông tin cho kê khai thuế
- **Nhắc nhở**: Thông báo deadline nộp thuế
- **Khấu trừ**: Quản lý các khoản khấu trừ thuế
- **Hóa đơn VAT**: Quản lý hóa đơn VAT
- **Tuân thủ**: Đảm bảo tuân thủ quy định thuế

### 5.4. Quản lý sản phẩm

- **Danh mục sản phẩm**: Quản lý sản phẩm, dịch vụ cung cấp
- **Giá bán**: Thiết lập giá bán, chiết khấu
- **Tồn kho**: Theo dõi tồn kho sản phẩm
- **Đơn hàng**: Quản lý đơn hàng từ khách hàng
- **Vận chuyển**: Theo dõi trạng thái vận chuyển
- **Báo cáo**: Phân tích doanh số bán hàng

## 6. PHÂN TÍCH HIỆU SUẤT

### 6.1. Analytics tổng hợp

- **Dashboard tổng quan**: Tổng hợp dữ liệu từ nhiều nền tảng
- **KPIs chính**: Theo dõi các chỉ số hiệu suất quan trọng
- **So sánh nền tảng**: So sánh hiệu suất giữa các nền tảng
- **Xu hướng**: Phân tích xu hướng theo thời gian
- **Báo cáo tùy chỉnh**: Tạo báo cáo theo nhu cầu
- **Xuất báo cáo**: Xuất báo cáo dưới nhiều định dạng

### 6.2. Phân tích nội dung

- **Hiệu suất nội dung**: Đánh giá hiệu suất từng nội dung
- **So sánh**: So sánh hiệu suất giữa các nội dung
- **Phân tích thời gian**: Phân tích thời điểm tương tác
- **Retention**: Phân tích thời gian xem, đọc
- **Conversion**: Theo dõi tỷ lệ chuyển đổi
- **Content ROI**: Đánh giá ROI của nội dung

### 6.3. Phân tích người theo dõi

- **Growth analysis**: Phân tích tăng trưởng người theo dõi
- **Demographic**: Phân tích nhân khẩu học
- **Behavior**: Phân tích hành vi người theo dõi
- **Engagement**: Phân tích mức độ tương tác
- **Loyalty**: Phân tích độ trung thành
- **Churn**: Phân tích tỷ lệ mất người theo dõi

### 6.4. Phân tích thị trường

- **Competitor analysis**: Phân tích đối thủ cạnh tranh
- **Trend analysis**: Phân tích xu hướng thị trường
- **Benchmark**: So sánh với tiêu chuẩn ngành
- **Audience insights**: Phân tích insight về đối tượng
- **Content gap**: Phân tích khoảng trống nội dung
- **Opportunity identification**: Xác định cơ hội mới

## 7. TÍCH HỢP AI VÀ TỰ ĐỘNG HÓA

### 7.1. Sáng tạo nội dung với AI

- **Gợi ý ý tưởng**: AI gợi ý ý tưởng nội dung
- **Viết caption**: Hỗ trợ viết caption, bài viết
- **Tạo thumbnail**: Gợi ý thiết kế thumbnail
- **Biên tập video**: Hỗ trợ biên tập video tự động
- **Tạo hashtag**: Gợi ý hashtag phù hợp
- **Tối ưu SEO**: Gợi ý tối ưu hóa nội dung

### 7.2. Tự động hóa quy trình

- **Workflow tự động**: Tự động hóa quy trình sản xuất nội dung
- **Đăng tải tự động**: Tự động đăng nội dung theo lịch
- **Tương tác tự động**: Tự động like, comment, follow
- **Báo cáo tự động**: Tự động tạo và gửi báo cáo
- **Nhắc nhở**: Tự động nhắc nhở deadline, nhiệm vụ
- **Cập nhật dữ liệu**: Tự động cập nhật dữ liệu từ các nền tảng

### 7.3. Phân tích dự đoán

- **Dự đoán hiệu suất**: Dự đoán hiệu suất nội dung
- **Dự báo xu hướng**: Dự đoán xu hướng sắp tới
- **Gợi ý tối ưu**: Đề xuất cách tối ưu hóa nội dung
- **Phân tích sentiment**: Phân tích cảm xúc của người theo dõi
- **Dự đoán churn**: Dự đoán nguy cơ mất người theo dõi
- **Opportunity scoring**: Chấm điểm cơ hội hợp tác

### 7.4. Chatbot và trợ lý ảo

- **Trợ lý cá nhân**: Hỗ trợ lập kế hoạch, nhắc nhở
- **Chatbot tương tác**: Tự động trả lời tin nhắn, comment
- **Phân tích dữ liệu**: Hỗ trợ phân tích dữ liệu
- **Gợi ý hành động**: Đề xuất hành động dựa trên dữ liệu
- **Hỗ trợ quyết định**: Cung cấp thông tin để ra quyết định
- **Học hỏi**: Cải thiện dựa trên phản hồi

## 8. QUẢN LÝ CỘNG ĐỒNG

### 8.1. Tương tác với người theo dõi

- **Inbox tập trung**: Quản lý tin nhắn từ nhiều nền tảng
- **Comment management**: Quản lý comment từ một giao diện
- **Phản hồi mẫu**: Sử dụng mẫu phản hồi có sẵn
- **Ưu tiên**: Ưu tiên phản hồi dựa trên mức độ quan trọng
- **Lịch sử tương tác**: Xem lịch sử tương tác với người theo dõi
- **Ghi chú**: Thêm ghi chú về người theo dõi

### 8.2. Quản lý sự kiện

- **Lập kế hoạch**: Thiết kế sự kiện trực tuyến, offline
- **Đăng ký**: Quản lý đăng ký tham dự
- **Nhắc nhở**: Gửi nhắc nhở tự động
- **Live streaming**: Quản lý sự kiện live stream
- **Tương tác**: Theo dõi tương tác trong sự kiện
- **Phân tích**: Đánh giá hiệu quả sự kiện

### 8.3. Quản lý nội dung người dùng tạo

- **Thu thập**: Thu thập nội dung từ người dùng
- **Phê duyệt**: Quy trình phê duyệt nội dung
- **Tái sử dụng**: Sử dụng lại nội dung người dùng
- **Ghi nhận**: Ghi nhận người tạo nội dung
- **Phân tích**: Đánh giá hiệu quả nội dung người dùng
- **Quyền sở hữu**: Quản lý quyền sở hữu nội dung

### 8.4. Chương trình khách hàng thân thiết

- **Thiết kế chương trình**: Tạo chương trình thành viên
- **Cấp độ**: Thiết lập các cấp độ thành viên
- **Phần thưởng**: Quản lý phần thưởng, ưu đãi
- **Tích điểm**: Hệ thống tích điểm
- **Đổi thưởng**: Quản lý đổi thưởng
- **Phân tích**: Đánh giá hiệu quả chương trình

## 9. TÍCH HỢP VÀ MỞ RỘNG

### 9.1. Tích hợp với công cụ sáng tạo

- **Adobe Creative Cloud**: Tích hợp với Photoshop, Premiere, v.v.
- **Canva**: Tích hợp với công cụ thiết kế Canva
- **Video editing**: Tích hợp với công cụ biên tập video
- **Audio editing**: Tích hợp với công cụ biên tập âm thanh
- **Stock media**: Tích hợp với thư viện stock media
- **Design tools**: Tích hợp với công cụ thiết kế khác

### 9.2. Tích hợp với công cụ marketing

- **Email marketing**: Tích hợp với công cụ email marketing
- **SMS marketing**: Tích hợp với công cụ SMS marketing
- **Landing page**: Tích hợp với công cụ tạo landing page
- **Affiliate marketing**: Tích hợp với hệ thống tiếp thị liên kết
- **Ad platforms**: Tích hợp với nền tảng quảng cáo
- **SEO tools**: Tích hợp với công cụ SEO

### 9.3. API và Webhook

- **REST API**: Cung cấp API để tích hợp với hệ thống khác
- **Webhook**: Gửi thông báo khi có sự kiện xảy ra
- **OAuth 2.0**: Xác thực an toàn
- **API Documentation**: Tài liệu API đầy đủ
- **Rate Limiting**: Giới hạn tốc độ truy cập API
- **Sandbox**: Môi trường thử nghiệm

### 9.4. Mobile App

- **App cho người sáng tạo**: Quản lý nội dung, tương tác, phân tích
- **Push notification**: Thông báo quan trọng
- **Offline mode**: Hoạt động khi không có kết nối internet
- **Content creation**: Tạo nội dung đơn giản trên mobile
- **Quick response**: Phản hồi nhanh comment, tin nhắn
- **Analytics on-the-go**: Xem phân tích hiệu suất mọi lúc

## 10. BẢO MẬT VÀ QUYỀN RIÊNG TƯ

### 10.1. Bảo mật tài khoản

- **Multi-factor authentication**: Xác thực đa yếu tố
- **Login alerts**: Cảnh báo đăng nhập lạ
- **Session management**: Quản lý phiên đăng nhập
- **Password policy**: Chính sách mật khẩu mạnh
- **Access log**: Nhật ký truy cập
- **Device management**: Quản lý thiết bị đăng nhập

### 10.2. Bảo vệ nội dung

- **Watermark**: Đánh dấu bản quyền nội dung
- **Copyright protection**: Bảo vệ bản quyền
- **Content backup**: Sao lưu nội dung tự động
- **Version control**: Kiểm soát phiên bản
- **Access control**: Kiểm soát quyền truy cập nội dung
- **Takedown request**: Quản lý yêu cầu gỡ bỏ nội dung

### 10.3. Tuân thủ quy định

- **GDPR**: Tuân thủ quy định bảo vệ dữ liệu
- **CCPA**: Tuân thủ đạo luật bảo vệ quyền riêng tư
- **FTC guidelines**: Tuân thủ hướng dẫn về quảng cáo
- **Platform policies**: Tuân thủ chính sách nền tảng
- **Disclosure**: Công khai hợp tác thương hiệu
- **Children's privacy**: Bảo vệ quyền riêng tư trẻ em

## 11. TỔNG KẾT

NextFlow CRM cung cấp giải pháp toàn diện cho người sáng tạo nội dung và KOLs, giúp họ quản lý người theo dõi, nội dung, hợp tác thương hiệu và phân tích hiệu suất một cách hiệu quả. Với các tính năng đặc thù cho người sáng tạo nội dung, tích hợp AI và tự động hóa, NextFlow CRM giúp tối ưu hóa quy trình, nâng cao hiệu suất nội dung và tăng doanh thu.

Các tính năng của NextFlow CRM được thiết kế dựa trên hiểu biết sâu sắc về nhu cầu và thách thức của người sáng tạo nội dung, đồng thời tận dụng công nghệ tiên tiến để mang lại giải pháp hiệu quả và dễ sử dụng. Với NextFlow CRM, người sáng tạo nội dung có thể tập trung vào việc sáng tạo nội dung chất lượng, trong khi vẫn quản lý hiệu quả hoạt động kinh doanh và phát triển thương hiệu cá nhân.

## 12. TÀI LIỆU LIÊN QUAN

- [Tổng quan tính năng](../tong-quan-tinh-nang.md) - Mô tả tổng quan về các tính năng chung của NextFlow CRM
- [Tính năng cho thương mại điện tử](../thuong-mai-dien-tu/tong-quan.md) - Mô tả chi tiết về các tính năng đặc thù cho thương mại điện tử
- [Kiến trúc tổng thể](../../02-kien-truc/kien-truc-tong-the.md) - Mô tả tổng quan về kiến trúc hệ thống NextFlow CRM
- [Tổng quan tích hợp AI](../../04-ai-integration/tong-quan-ai.md) - Mô tả cách NextFlow CRM tích hợp AI

---

*Cập nhật lần cuối: Tháng 7/2024*
