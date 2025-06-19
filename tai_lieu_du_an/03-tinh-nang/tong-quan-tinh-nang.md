# TỔNG QUAN TÍNH NĂNG CHUNG

## Mục lục

1. [GIỚI THIỆU](#1-giới-thiệu)
   - [1.1. Đặc điểm chính](#11-đặc-điểm-chính)
   - [1.2. Lợi ích](#12-lợi-ích)
2. [QUẢN LÝ KHÁCH HÀNG](#2-quản-lý-khách-hàng)
   - [2.1. Hồ sơ khách hàng 360 độ](#21-hồ-sơ-khách-hàng-360-độ)
   - [2.2. Phân khúc khách hàng](#22-phân-khúc-khách-hàng)
   - [2.3. Quản lý lead](#23-quản-lý-lead)
3. [QUẢN LÝ BÁN HÀNG](#3-quản-lý-bán-hàng)
   - [3.1. Pipeline bán hàng](#31-pipeline-bán-hàng)
   - [3.2. Quản lý đơn hàng đa kênh](#32-quản-lý-đơn-hàng-đa-kênh)
   - [3.3. Quản lý báo giá và hợp đồng](#33-quản-lý-báo-giá-và-hợp-đồng)
4. [MARKETING VÀ TRUYỀN THÔNG](#4-marketing-và-truyền-thông)
   - [4.1. Email marketing](#41-email-marketing)
   - [4.2. Marketing đa kênh](#42-marketing-đa-kênh)
   - [4.3. Quản lý mạng xã hội](#43-quản-lý-mạng-xã-hội)
5. [CHĂM SÓC KHÁCH HÀNG](#5-chăm-sóc-khách-hàng)
   - [5.1. Hỗ trợ đa kênh](#51-hỗ-trợ-đa-kênh)
   - [5.2. Cơ sở kiến thức](#52-cơ-sở-kiến-thức)
   - [5.3. Quản lý phản hồi và đánh giá](#53-quản-lý-phản-hồi-và-đánh-giá)
6. [PHÂN TÍCH VÀ BÁO CÁO](#6-phân-tích-và-báo-cáo)
   - [6.1. Dashboard tùy chỉnh](#61-dashboard-tùy-chỉnh)
   - [6.2. Báo cáo nâng cao](#62-báo-cáo-nâng-cao)
   - [6.3. Business Intelligence](#63-business-intelligence)
7. [QUẢN LÝ HỆ THỐNG](#7-quản-lý-hệ-thống)
   - [7.1. Quản lý người dùng và phân quyền](#71-quản-lý-người-dùng-và-phân-quyền)
   - [7.2. Cấu hình và tùy chỉnh](#72-cấu-hình-và-tùy-chỉnh)
   - [7.3. Tích hợp và API](#73-tích-hợp-và-api)
8. [KẾT LUẬN](#8-kết-luận)
9. [TÀI LIỆU LIÊN QUAN](#9-tài-liệu-liên-quan)

## 1. GIỚI THIỆU

NextFlow CRM là hệ thống quản lý quan hệ khách hàng (CRM) đa nền tảng tích hợp trí tuệ nhân tạo (AI), được thiết kế để đáp ứng nhu cầu của nhiều đối tượng người dùng, từ doanh nghiệp vừa và nhỏ đến cá nhân kinh doanh và người sáng tạo nội dung. Tài liệu này mô tả tổng quan về các tính năng chung của hệ thống, áp dụng cho tất cả các lĩnh vực kinh doanh.

### 1.1. Đặc điểm chính

NextFlow CRM có ba đặc điểm chính tạo nên sự khác biệt:

1. **Đăng sản phẩm đa nền tảng**
   - Sản phẩm khi đăng trên hệ thống CRM sẽ tự động được đồng bộ lên các nền tảng được đăng ký quản lý như Shopee, Lazada, TikTok Shop, WordPress, v.v.
   - Quản lý tập trung nhiều tài khoản marketplace (50 tài khoản Shopee, 50 tài khoản TikTok Shop, v.v.)

2. **Tích hợp AI hỗ trợ bán hàng và chăm sóc khách hàng**
   - Tích hợp n8n và Flowise để tự động hóa các quy trình bán hàng, chăm sóc khách hàng
   - AI chatbot đa kênh để giao tiếp và chốt đơn tự động cho nhiều tài khoản marketplace
   - Phân tích dữ liệu khách hàng và đề xuất chiến lược bán hàng

3. **Kiến trúc Multi-tenant**
   - Hỗ trợ nhiều tổ chức trên cùng một hệ thống
   - Phân chia dữ liệu và cấu hình riêng biệt cho từng tenant
   - Khả năng mở rộng theo chiều ngang khi số lượng tenant tăng lên

### 1.2. Lợi ích

NextFlow CRM mang lại nhiều lợi ích cho người dùng:

1. **Tiết kiệm thời gian và công sức**
   - Tự động hóa các tác vụ lặp lại
   - Quản lý tập trung thay vì phải đăng nhập nhiều nền tảng
   - Giảm thời gian xử lý đơn hàng và chăm sóc khách hàng

2. **Tăng hiệu quả bán hàng**
   - AI chatbot tự động tư vấn và chốt đơn 24/7
   - Phân tích dữ liệu để đề xuất chiến lược bán hàng tối ưu
   - Tự động hóa quy trình bán hàng và marketing

3. **Cải thiện trải nghiệm khách hàng**
   - Phản hồi nhanh chóng và nhất quán trên tất cả các kênh
   - Cá nhân hóa tương tác dựa trên dữ liệu khách hàng
   - Theo dõi và quản lý toàn bộ hành trình khách hàng

4. **Tối ưu hóa chi phí**
   - Giảm chi phí nhân sự cho bán hàng và CSKH
   - Tối ưu hóa chiến dịch marketing dựa trên dữ liệu
   - Mô hình định giá linh hoạt theo nhu cầu sử dụng

## 2. QUẢN LÝ KHÁCH HÀNG

### 2.1. Hồ sơ khách hàng 360 độ

NextFlow CRM cung cấp góc nhìn toàn diện 360 độ về khách hàng:

1. **Thông tin cơ bản**
   - Thông tin liên hệ: tên, email, số điện thoại, địa chỉ
   - Thông tin cá nhân: ngày sinh, giới tính, nghề nghiệp
   - Thông tin mạng xã hội: Facebook, Instagram, TikTok, v.v.

2. **Lịch sử tương tác**
   - Lịch sử mua hàng trên tất cả các nền tảng
   - Lịch sử tương tác qua email, chat, cuộc gọi
   - Lịch sử xem sản phẩm và giỏ hàng bỏ dở

3. **Phân tích khách hàng**
   - Giá trị vòng đời khách hàng (CLV)
   - Tần suất mua hàng và giá trị trung bình đơn hàng
   - Sở thích và hành vi mua hàng
   - Điểm số khách hàng tiềm năng (lead scoring)

4. **Ghi chú và tài liệu**
   - Ghi chú về khách hàng
   - Tài liệu liên quan (hợp đồng, báo giá, v.v.)
   - Nhắc nhở và công việc liên quan đến khách hàng

### 2.2. Phân khúc khách hàng

NextFlow CRM cho phép phân khúc khách hàng một cách thông minh:

1. **Phân khúc tự động**
   - Phân khúc dựa trên giá trị khách hàng (VIP, thường xuyên, thỉnh thoảng)
   - Phân khúc dựa trên hành vi (mới, hoạt động, không hoạt động, có nguy cơ rời bỏ)
   - Phân khúc dựa trên nhân khẩu học (độ tuổi, giới tính, vị trí địa lý)

2. **Phân khúc tùy chỉnh**
   - Tạo phân khúc dựa trên các tiêu chí tùy chỉnh
   - Kết hợp nhiều tiêu chí để tạo phân khúc phức tạp
   - Lưu và quản lý các phân khúc đã tạo

3. **Phân tích phân khúc**
   - Phân tích hiệu suất của từng phân khúc
   - So sánh giữa các phân khúc
   - Đề xuất chiến lược cho từng phân khúc

4. **Chiến dịch theo phân khúc**
   - Tạo chiến dịch marketing cho từng phân khúc
   - Tự động hóa chiến dịch dựa trên phân khúc
   - Đo lường hiệu quả chiến dịch theo phân khúc

### 2.3. Quản lý lead

NextFlow CRM cung cấp công cụ quản lý lead hiệu quả:

1. **Thu thập lead**
   - Thu thập lead từ nhiều nguồn (website, mạng xã hội, marketplace)
   - Form thu thập lead tùy chỉnh
   - Landing page tích hợp với CRM

2. **Đánh giá lead**
   - Đánh giá lead tự động dựa trên AI
   - Tính điểm lead (lead scoring) dựa trên nhiều tiêu chí
   - Phân loại lead theo mức độ tiềm năng

3. **Nuôi dưỡng lead**
   - Tự động hóa quy trình nuôi dưỡng lead
   - Email marketing tự động theo từng giai đoạn
   - Theo dõi và đánh giá hiệu quả nuôi dưỡng lead

4. **Chuyển đổi lead**
   - Quy trình chuyển đổi lead thành khách hàng
   - Tự động phân công lead cho nhân viên bán hàng
   - Theo dõi tỷ lệ chuyển đổi và thời gian chuyển đổi

## 3. QUẢN LÝ BÁN HÀNG

### 3.1. Pipeline bán hàng

NextFlow CRM cung cấp pipeline bán hàng linh hoạt:

1. **Thiết kế pipeline**
   - Tạo và tùy chỉnh các giai đoạn bán hàng
   - Thiết lập quy trình làm việc cho từng giai đoạn
   - Tự động hóa chuyển đổi giữa các giai đoạn

2. **Quản lý cơ hội**
   - Tạo và quản lý cơ hội bán hàng
   - Theo dõi tiến độ của từng cơ hội
   - Dự báo doanh số dựa trên pipeline

3. **Phân tích pipeline**
   - Phân tích hiệu suất của từng giai đoạn
   - Xác định điểm nghẽn trong quy trình bán hàng
   - Đề xuất cải thiện quy trình

4. **Dự báo doanh số**
   - Dự báo doanh số dựa trên dữ liệu lịch sử
   - Dự báo doanh số theo nhân viên, sản phẩm, khu vực
   - Cập nhật dự báo theo thời gian thực

### 3.2. Quản lý đơn hàng đa kênh

NextFlow CRM cho phép quản lý đơn hàng từ nhiều kênh bán hàng:

1. **Đồng bộ đơn hàng**
   - Đồng bộ đơn hàng từ tất cả các nền tảng (Shopee, Lazada, TikTok Shop, v.v.)
   - Cập nhật trạng thái đơn hàng theo thời gian thực
   - Thông báo khi có đơn hàng mới

2. **Xử lý đơn hàng**
   - Quy trình xử lý đơn hàng tự động
   - Phân công đơn hàng cho nhân viên
   - Theo dõi tiến độ xử lý đơn hàng

3. **Quản lý vận chuyển**
   - Tích hợp với các đơn vị vận chuyển
   - Tạo và in vận đơn tự động
   - Theo dõi trạng thái vận chuyển

4. **Báo cáo đơn hàng**
   - Báo cáo doanh số theo kênh bán hàng
   - Phân tích hiệu suất bán hàng
   - Đề xuất tối ưu hóa kênh bán hàng

### 3.3. Quản lý báo giá và hợp đồng

NextFlow CRM cung cấp công cụ quản lý báo giá và hợp đồng:

1. **Tạo báo giá**
   - Tạo báo giá nhanh chóng từ template
   - Tùy chỉnh báo giá theo khách hàng
   - Gửi báo giá qua email hoặc link

2. **Quản lý hợp đồng**
   - Tạo hợp đồng từ báo giá đã được chấp nhận
   - Theo dõi trạng thái hợp đồng
   - Nhắc nhở gia hạn hợp đồng

3. **Chữ ký điện tử**
   - Tích hợp chữ ký điện tử
   - Theo dõi trạng thái ký hợp đồng
   - Lưu trữ hợp đồng đã ký

4. **Quản lý thanh toán**
   - Tạo hóa đơn từ hợp đồng
   - Theo dõi trạng thái thanh toán
   - Nhắc nhở thanh toán tự động

## 4. MARKETING VÀ TRUYỀN THÔNG

### 4.1. Email marketing

NextFlow CRM cung cấp công cụ email marketing mạnh mẽ:

1. **Tạo chiến dịch email**
   - Tạo email từ template hoặc từ đầu
   - Tùy chỉnh nội dung email với AI
   - Lên lịch gửi email tự động

2. **Phân khúc người nhận**
   - Phân khúc người nhận dựa trên nhiều tiêu chí
   - Cá nhân hóa nội dung email cho từng phân khúc
   - Tối ưu hóa thời gian gửi email

3. **Tự động hóa email**
   - Tạo chuỗi email tự động
   - Kích hoạt email dựa trên hành vi khách hàng
   - Tự động hóa quy trình nuôi dưỡng lead

4. **Phân tích hiệu quả**
   - Theo dõi tỷ lệ mở email, click, chuyển đổi
   - A/B testing để tối ưu hóa chiến dịch
   - Báo cáo ROI của chiến dịch email

### 4.2. Marketing đa kênh

NextFlow CRM cho phép quản lý marketing đa kênh:

1. **Quản lý kênh**
   - Quản lý tất cả các kênh marketing (email, SMS, mạng xã hội, v.v.)
   - Lên lịch nội dung cho từng kênh
   - Đồng bộ hóa chiến dịch giữa các kênh

2. **Tạo nội dung**
   - Tạo nội dung với sự hỗ trợ của AI
   - Tùy chỉnh nội dung cho từng kênh
   - Lưu trữ và quản lý thư viện nội dung

3. **Tự động hóa marketing**
   - Tạo quy trình marketing tự động
   - Kích hoạt chiến dịch dựa trên hành vi khách hàng
   - Tối ưu hóa chiến dịch dựa trên kết quả

4. **Phân tích hiệu quả**
   - Theo dõi hiệu quả của từng kênh
   - So sánh ROI giữa các kênh
   - Đề xuất phân bổ ngân sách marketing

### 4.3. Quản lý mạng xã hội

NextFlow CRM cung cấp công cụ quản lý mạng xã hội:

1. **Đăng bài**
   - Đăng bài lên nhiều nền tảng mạng xã hội
   - Lên lịch đăng bài tự động
   - Tạo nội dung với sự hỗ trợ của AI

2. **Tương tác**
   - Quản lý bình luận và tin nhắn từ nhiều nền tảng
   - Phản hồi tự động với sự hỗ trợ của AI
   - Phân công tương tác cho nhân viên

3. **Theo dõi đối thủ**
   - Theo dõi hoạt động của đối thủ trên mạng xã hội
   - Phân tích nội dung và tương tác của đối thủ
   - Đề xuất chiến lược cạnh tranh

4. **Phân tích hiệu quả**
   - Theo dõi tương tác, tiếp cận, chuyển đổi
   - Phân tích xu hướng và chủ đề hot
   - Đề xuất tối ưu hóa nội dung

## 5. CHĂM SÓC KHÁCH HÀNG

### 5.1. Hỗ trợ đa kênh

NextFlow CRM cung cấp hệ thống hỗ trợ khách hàng đa kênh:

1. **Tích hợp đa kênh**
   - Tích hợp với email, chat, điện thoại, mạng xã hội
   - Hộp thư đến thống nhất cho tất cả các kênh
   - Lịch sử tương tác xuyên kênh

2. **Chatbot AI**
   - Chatbot AI tự động trả lời câu hỏi thường gặp
   - Chuyển giao cho nhân viên khi cần thiết
   - Học hỏi và cải thiện theo thời gian

3. **Quản lý ticket**
   - Tạo ticket từ tất cả các kênh
   - Phân loại và ưu tiên ticket tự động
   - Phân công ticket cho nhân viên phù hợp

4. **Đánh giá chất lượng**
   - Thu thập phản hồi của khách hàng
   - Đánh giá hiệu suất của nhân viên
   - Cải thiện quy trình dựa trên phản hồi

### 5.2. Cơ sở kiến thức

NextFlow CRM cung cấp cơ sở kiến thức toàn diện:

1. **Quản lý nội dung**
   - Tạo và quản lý bài viết, hướng dẫn, FAQ
   - Phân loại nội dung theo chủ đề
   - Tìm kiếm nội dung nhanh chóng

2. **Cơ sở kiến thức nội bộ**
   - Cơ sở kiến thức cho nhân viên
   - Quy trình và hướng dẫn nội bộ
   - Chia sẻ kiến thức giữa các nhân viên

3. **Cơ sở kiến thức khách hàng**
   - Portal kiến thức cho khách hàng
   - Tự phục vụ với FAQ và hướng dẫn
   - Tìm kiếm thông minh với AI

4. **Phân tích sử dụng**
   - Theo dõi nội dung được xem nhiều nhất
   - Xác định khoảng trống trong cơ sở kiến thức
   - Cải thiện nội dung dựa trên phản hồi

### 5.3. Quản lý phản hồi và đánh giá

NextFlow CRM cho phép quản lý phản hồi và đánh giá của khách hàng:

1. **Thu thập phản hồi**
   - Khảo sát tự động sau tương tác
   - Thu thập đánh giá từ nhiều kênh
   - Phân tích cảm xúc trong phản hồi

2. **Phân tích phản hồi**
   - Phân tích xu hướng và chủ đề trong phản hồi
   - Xác định điểm mạnh và điểm yếu
   - Đề xuất cải thiện dựa trên phản hồi

3. **Quản lý đánh giá**
   - Theo dõi đánh giá trên các nền tảng
   - Phản hồi đánh giá tự động hoặc thủ công
   - Phân tích xu hướng đánh giá

4. **Cải thiện liên tục**
   - Quy trình cải thiện dựa trên phản hồi
   - Theo dõi tiến độ cải thiện
   - Đo lường tác động của cải thiện

## 6. PHÂN TÍCH VÀ BÁO CÁO

### 6.1. Dashboard tùy chỉnh

NextFlow CRM cung cấp dashboard tùy chỉnh cho từng vai trò:

1. **Dashboard cho lãnh đạo**
   - Tổng quan về doanh số, khách hàng, marketing
   - KPI và chỉ số hiệu suất chính
   - Dự báo và xu hướng

2. **Dashboard cho nhân viên bán hàng**
   - Pipeline bán hàng cá nhân
   - Mục tiêu và tiến độ
   - Khách hàng tiềm năng và cơ hội

3. **Dashboard cho marketing**
   - Hiệu quả chiến dịch marketing
   - Phân tích kênh và nội dung
   - ROI marketing

4. **Dashboard cho CSKH**
   - Ticket và thời gian phản hồi
   - Mức độ hài lòng của khách hàng
   - Hiệu suất nhân viên CSKH

### 6.2. Báo cáo nâng cao

NextFlow CRM cung cấp báo cáo nâng cao với AI:

1. **Báo cáo tự động**
   - Tạo báo cáo tự động theo lịch
   - Gửi báo cáo qua email
   - Xuất báo cáo nhiều định dạng

2. **Báo cáo tùy chỉnh**
   - Tạo báo cáo tùy chỉnh với trình tạo báo cáo
   - Kết hợp dữ liệu từ nhiều nguồn
   - Lưu và chia sẻ báo cáo

3. **Phân tích dự đoán**
   - Dự đoán xu hướng và kết quả
   - Phân tích "what-if" cho các kịch bản
   - Đề xuất hành động dựa trên dự đoán

4. **Phân tích AI**
   - Phát hiện mẫu và xu hướng với AI
   - Đề xuất cải thiện dựa trên dữ liệu
   - Tự động tạo insights từ dữ liệu

### 6.3. Business Intelligence

NextFlow CRM cung cấp công cụ Business Intelligence:

1. **Kho dữ liệu**
   - Tích hợp dữ liệu từ nhiều nguồn
   - Làm sạch và chuẩn hóa dữ liệu
   - Lưu trữ dữ liệu lịch sử

2. **Phân tích dữ liệu**
   - Phân tích dữ liệu với công cụ BI
   - Tạo biểu đồ và trực quan hóa dữ liệu
   - Khám phá insights từ dữ liệu

3. **Chia sẻ insights**
   - Chia sẻ dashboard và báo cáo
   - Cộng tác trên phân tích dữ liệu
   - Xuất và nhúng báo cáo

4. **Quyết định dựa trên dữ liệu**
   - Đề xuất quyết định dựa trên dữ liệu
   - Theo dõi tác động của quyết định
   - Cải thiện quy trình dựa trên kết quả

## 7. QUẢN LÝ HỆ THỐNG

### 7.1. Quản lý người dùng và phân quyền

NextFlow CRM cung cấp hệ thống quản lý người dùng và phân quyền mạnh mẽ:

1. **Quản lý người dùng**
   - Tạo và quản lý tài khoản người dùng
   - Phân nhóm người dùng
   - Quản lý trạng thái người dùng

2. **Phân quyền**
   - Phân quyền dựa trên vai trò (RBAC)
   - Phân quyền dựa trên thuộc tính (ABAC)
   - Phân quyền chi tiết đến cấp độ trường dữ liệu

3. **Quản lý vai trò**
   - Tạo và quản lý vai trò
   - Định nghĩa quyền cho từng vai trò
   - Gán vai trò cho người dùng

4. **Kiểm toán và tuân thủ**
   - Ghi nhật ký hoạt động người dùng
   - Báo cáo kiểm toán
   - Đảm bảo tuân thủ quy định

### 7.2. Cấu hình và tùy chỉnh

NextFlow CRM cho phép cấu hình và tùy chỉnh theo nhu cầu:

1. **Cấu hình hệ thống**
   - Cấu hình thông tin doanh nghiệp
   - Cấu hình email và thông báo
   - Cấu hình tích hợp bên ngoài

2. **Tùy chỉnh giao diện**
   - Tùy chỉnh logo và thương hiệu
   - Tùy chỉnh giao diện người dùng
   - Tùy chỉnh theme và màu sắc

3. **Tùy chỉnh đối tượng**
   - Tạo và tùy chỉnh trường tùy chỉnh
   - Tùy chỉnh bố cục và form
   - Tùy chỉnh quy trình làm việc

4. **Tùy chỉnh báo cáo**
   - Tạo báo cáo tùy chỉnh
   - Tùy chỉnh dashboard
   - Tùy chỉnh biểu đồ và trực quan hóa

### 7.3. Tích hợp và API

NextFlow CRM cung cấp khả năng tích hợp mạnh mẽ:

1. **Tích hợp sẵn có**
   - Tích hợp với các nền tảng marketplace
   - Tích hợp với email, SMS, mạng xã hội
   - Tích hợp với công cụ thanh toán và kế toán

2. **API**
   - RESTful API đầy đủ
   - Tài liệu API chi tiết
   - Quản lý API key và quyền truy cập

3. **Webhook**
   - Tạo và quản lý webhook
   - Kích hoạt webhook dựa trên sự kiện
   - Theo dõi lịch sử webhook

4. **Tích hợp tùy chỉnh**
   - Công cụ tích hợp không code
   - Tích hợp với n8n và Flowise
   - Hỗ trợ tích hợp tùy chỉnh

## 8. KẾT LUẬN

NextFlow CRM là hệ thống quản lý quan hệ khách hàng toàn diện với các tính năng chung mạnh mẽ, phù hợp với nhiều lĩnh vực kinh doanh. Với ba đặc điểm chính là đăng sản phẩm đa nền tảng, tích hợp AI hỗ trợ bán hàng và chăm sóc khách hàng, và kiến trúc multi-tenant, NextFlow CRM mang lại giải pháp hiệu quả và tiết kiệm chi phí cho doanh nghiệp vừa và nhỏ, hộ kinh doanh cá thể và người sáng tạo nội dung.

Các tính năng chung của NextFlow CRM bao gồm quản lý khách hàng, quản lý bán hàng, marketing và truyền thông, chăm sóc khách hàng, phân tích và báo cáo, và quản lý hệ thống. Mỗi nhóm tính năng đều được thiết kế để tối ưu hóa quy trình kinh doanh, tăng hiệu quả bán hàng, và cải thiện trải nghiệm khách hàng.

Ngoài các tính năng chung, NextFlow CRM còn cung cấp các tính năng đặc thù cho từng lĩnh vực kinh doanh, được mô tả chi tiết trong các tài liệu riêng:

- [Tính năng cho thương mại điện tử](./thuong-mai-dien-tu/tong-quan.md)
- [Tính năng cho người sáng tạo nội dung](./nguoi-sang-tao/tong-quan.md)
- [Tính năng cho lĩnh vực dịch vụ](./dich-vu/tong-quan.md)
- [Tính năng cho lĩnh vực giáo dục](./giao-duc/tong-quan.md)
- [Tính năng cho tổng đài](./tong-dai/tong-quan.md)

## 9. TÀI LIỆU LIÊN QUAN

- [Kiến trúc tổng thể](../02-kien-truc/kien-truc-tong-the.md) - Mô tả tổng quan về kiến trúc hệ thống NextFlow CRM
- [Kiến trúc microservices](../02-kien-truc/kien-truc-microservices.md) - Chi tiết về kiến trúc microservices của NextFlow CRM
- [Tổng quan tích hợp AI](../04-ai-integration/tong-quan-ai.md) - Mô tả cách NextFlow CRM tích hợp AI
- [Tổng quan schema](../05-schema/tong-quan-schema.md) - Chi tiết về schema cơ sở dữ liệu của NextFlow CRM

---

*Cập nhật lần cuối: Tháng 7/2024*
