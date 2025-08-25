# N8N - TỔNG QUAN

## 1. GIỚI THIỆU

n8n là một nền tảng tự động hóa quy trình làm việc (workflow automation) mã nguồn mở, cho phép kết nối các ứng dụng, dịch vụ và API khác nhau để tự động hóa các tác vụ mà không cần viết mã. Trong NextFlow CRM-AI, n8n được tích hợp để cung cấp khả năng tự động hóa mạnh mẽ, giúp doanh nghiệp tối ưu hóa quy trình kinh doanh và tiết kiệm thời gian.

## 2. VAI TRÒ CỦA N8N TRONG NextFlow CRM-AI

### 2.1. Tự động hóa quy trình kinh doanh

n8n cho phép tự động hóa các quy trình kinh doanh phức tạp trong NextFlow CRM-AI, như:

- Tự động gửi email chào mừng khi có khách hàng mới
- Tự động phân loại khách hàng tiềm năng dựa trên hành vi
- Tự động tạo nhiệm vụ cho nhân viên bán hàng khi có yêu cầu báo giá
- Tự động cập nhật thông tin khách hàng từ các nguồn bên ngoài

### 2.2. Tích hợp đa nền tảng

n8n giúp NextFlow CRM-AI kết nối với hàng trăm dịch vụ và ứng dụng bên ngoài, bao gồm:

- Nền tảng thương mại điện tử (Shopee, Lazada, TikTok Shop)
- Dịch vụ email marketing (Mailchimp, SendGrid)
- Mạng xã hội (Facebook, Instagram, LinkedIn)
- Công cụ giao tiếp (Slack, Telegram, Zalo)
- Dịch vụ lưu trữ đám mây (Google Drive, Dropbox)
- Công cụ quản lý dự án (Trello, Asana, Jira)

### 2.3. Xử lý dữ liệu thông minh

n8n cung cấp các công cụ mạnh mẽ để xử lý và biến đổi dữ liệu:

- Lọc và sắp xếp dữ liệu
- Biến đổi cấu trúc dữ liệu
- Tổng hợp dữ liệu từ nhiều nguồn
- Làm giàu dữ liệu với thông tin bổ sung

### 2.4. Tích hợp AI và Machine Learning

n8n cho phép tích hợp các dịch vụ AI và Machine Learning vào NextFlow CRM-AI:

- Phân tích cảm xúc từ phản hồi của khách hàng
- Dự đoán khả năng chuyển đổi của khách hàng tiềm năng
- Phân loại tự động các yêu cầu hỗ trợ
- Tạo nội dung tự động cho email marketing

## 3. KIẾN TRÚC N8N TRONG NextFlow CRM-AI

### 3.1. Mô hình triển khai

Trong NextFlow CRM-AI, n8n được triển khai theo hai mô hình:

1. **Mô hình dùng chung**: Một instance n8n dùng chung cho tất cả các tenant, phù hợp cho các gói Basic và Standard.
2. **Mô hình riêng biệt**: Mỗi tenant có một instance n8n riêng, phù hợp cho các gói Premium và Enterprise.

### 3.2. Kiến trúc kỹ thuật

![Kiến trúc n8n trong NextFlow CRM-AI](https://assets.NextFlow.com/docs/n8n-architecture.png)

Kiến trúc n8n trong NextFlow CRM-AI bao gồm các thành phần chính:

1. **n8n Core**: Động cơ xử lý workflow
2. **n8n Editor**: Giao diện người dùng để thiết kế workflow
3. **n8n API**: API để tương tác với n8n từ NextFlow CRM-AI
4. **n8n Database**: Cơ sở dữ liệu lưu trữ workflow và thực thi lịch sử
5. **n8n Queue**: Hàng đợi xử lý các workflow bất đồng bộ
6. **n8n Credentials**: Quản lý thông tin xác thực cho các dịch vụ bên ngoài

### 3.3. Tích hợp với NextFlow CRM-AI

n8n được tích hợp với NextFlow CRM-AI thông qua:

1. **API Integration**: NextFlow CRM-AI cung cấp API cho n8n để truy cập dữ liệu và chức năng
2. **Webhook**: n8n nhận sự kiện từ NextFlow CRM-AI thông qua webhook
3. **Database Connection**: n8n có thể truy cập trực tiếp vào cơ sở dữ liệu của NextFlow CRM-AI (chỉ trong môi trường on-premise)
4. **Single Sign-On**: Người dùng có thể đăng nhập vào n8n thông qua NextFlow CRM-AI

## 4. KHÁI NIỆM CƠ BẢN TRONG N8N

### 4.1. Workflow

Workflow là một chuỗi các node được kết nối với nhau để thực hiện một quy trình tự động. Mỗi workflow có thể được kích hoạt bởi một sự kiện (trigger) hoặc chạy theo lịch trình.

### 4.2. Node

Node là đơn vị cơ bản trong workflow, đại diện cho một hành động, kết nối, hoặc xử lý dữ liệu. n8n cung cấp hàng trăm node cho các dịch vụ và chức năng khác nhau.

Các loại node phổ biến:

- **Trigger Node**: Kích hoạt workflow (Webhook, Schedule, Event)
- **Action Node**: Thực hiện hành động (HTTP Request, Email, Database)
- **Transform Node**: Biến đổi dữ liệu (Function, Set, Split)
- **Flow Control Node**: Điều khiển luồng (IF, Switch, Merge)

### 4.3. Connection

Connection là liên kết giữa các node, xác định luồng dữ liệu từ node này sang node khác.

### 4.4. Credentials

Credentials là thông tin xác thực được sử dụng để kết nối với các dịch vụ bên ngoài. n8n lưu trữ credentials một cách an toàn và mã hóa.

### 4.5. Expression

Expression là biểu thức động được sử dụng để truy cập và xử lý dữ liệu trong workflow. n8n sử dụng cú pháp dựa trên JavaScript cho expressions.

Ví dụ:

```
{{ $json.customer.firstName + ' ' + $json.customer.lastName }}
```

## 5. TÍNH NĂNG CHÍNH CỦA N8N

### 5.1. Thiết kế workflow trực quan

n8n cung cấp giao diện người dùng trực quan để thiết kế workflow bằng cách kéo và thả, không cần kỹ năng lập trình.

### 5.2. Hơn 200 tích hợp có sẵn

n8n hỗ trợ hơn 200 tích hợp với các dịch vụ và ứng dụng phổ biến, giúp kết nối NextFlow CRM-AI với hệ sinh thái rộng lớn.

### 5.3. Xử lý lỗi và thử lại

n8n cung cấp cơ chế xử lý lỗi mạnh mẽ, cho phép định nghĩa hành động khi gặp lỗi và tự động thử lại các node thất bại.

### 5.4. Lập lịch và kích hoạt

Workflow có thể được kích hoạt theo nhiều cách:

- Lập lịch định kỳ (cron expression)
- Webhook
- Sự kiện từ NextFlow CRM-AI
- Thủ công

### 5.5. Biến và context

n8n hỗ trợ biến và context để lưu trữ và truy cập dữ liệu giữa các lần thực thi workflow.

### 5.6. Phân quyền và bảo mật

n8n trong NextFlow CRM-AI được tích hợp với hệ thống phân quyền, đảm bảo chỉ người dùng được ủy quyền mới có thể xem và chỉnh sửa workflow.

### 5.7. Theo dõi và gỡ lỗi

n8n cung cấp công cụ theo dõi và gỡ lỗi workflow, cho phép xem lịch sử thực thi và kiểm tra dữ liệu tại mỗi bước.

## 6. CÁC TRƯỜNG HỢP SỬ DỤNG TRONG NextFlow CRM-AI

### 6.1. Tự động hóa quy trình bán hàng

- Tự động phân loại khách hàng tiềm năng
- Tự động gửi email theo dõi
- Tự động tạo nhiệm vụ cho nhân viên bán hàng
- Tự động cập nhật trạng thái cơ hội bán hàng

### 6.2. Tự động hóa marketing

- Tự động gửi email marketing dựa trên hành vi khách hàng
- Tự động đăng bài lên mạng xã hội
- Tự động phân loại và gắn thẻ khách hàng
- Tự động tạo và cập nhật danh sách khách hàng

### 6.3. Tự động hóa hỗ trợ khách hàng

- Tự động phân loại và chuyển tiếp yêu cầu hỗ trợ
- Tự động gửi email xác nhận khi nhận yêu cầu
- Tự động cập nhật trạng thái yêu cầu
- Tự động tạo báo cáo hiệu suất hỗ trợ

### 6.4. Tự động hóa quản lý sản phẩm

- Tự động đồng bộ sản phẩm với các sàn thương mại điện tử
- Tự động cập nhật giá và tồn kho
- Tự động thông báo khi tồn kho thấp
- Tự động tạo báo cáo bán hàng theo sản phẩm

### 6.5. Tự động hóa quản lý đơn hàng

- Tự động xử lý đơn hàng từ nhiều kênh
- Tự động gửi email xác nhận đơn hàng
- Tự động cập nhật trạng thái vận chuyển
- Tự động tạo hóa đơn và phiếu giao hàng

## 7. GIỚI HẠN VÀ KHUYẾN NGHỊ

### 7.1. Giới hạn kỹ thuật

- **Số lượng workflow**: Tùy thuộc vào gói dịch vụ

  - Basic: 10 workflow
  - Standard: 50 workflow
  - Premium: 200 workflow
  - Enterprise: Không giới hạn

- **Tần suất thực thi**: Tùy thuộc vào gói dịch vụ

  - Basic: Tối thiểu 5 phút/lần
  - Standard: Tối thiểu 1 phút/lần
  - Premium: Tối thiểu 10 giây/lần
  - Enterprise: Không giới hạn

- **Số lượng node trong workflow**: Tối đa 100 node/workflow

### 7.2. Khuyến nghị hiệu suất

- Chia nhỏ workflow phức tạp thành nhiều workflow đơn giản
- Sử dụng caching để giảm số lượng yêu cầu API
- Tối ưu hóa xử lý dữ liệu lớn bằng cách phân trang hoặc xử lý theo batch
- Sử dụng webhook thay vì polling khi có thể
- Lập lịch workflow vào thời điểm ít tải

### 7.3. Khuyến nghị bảo mật

- Sử dụng tài khoản dịch vụ với quyền hạn chế cho các kết nối
- Không lưu trữ dữ liệu nhạy cảm trong workflow
- Kiểm soát quyền truy cập vào n8n
- Thường xuyên kiểm tra và cập nhật credentials
- Sử dụng webhook với xác thực

## 8. SO SÁNH VỚI CÁC GIẢI PHÁP KHÁC

| Tính năng         | n8n                                                | Zapier                                 | Make (Integromat)                    | Microsoft Power Automate           |
| ----------------- | -------------------------------------------------- | -------------------------------------- | ------------------------------------ | ---------------------------------- |
| Mã nguồn          | Mở                                                 | Đóng                                   | Đóng                                 | Đóng                               |
| Triển khai        | Self-hosted hoặc Cloud                             | Chỉ Cloud                              | Chỉ Cloud                            | Chỉ Cloud                          |
| Số lượng tích hợp | 200+                                               | 3000+                                  | 1000+                                | 500+                               |
| Tùy biến          | Cao                                                | Trung bình                             | Cao                                  | Trung bình                         |
| Giá cả            | Miễn phí (self-hosted)                             | Trả phí                                | Trả phí                              | Trả phí                            |
| Phù hợp với       | Doanh nghiệp cần tùy biến cao và kiểm soát dữ liệu | Doanh nghiệp cần nhiều tích hợp có sẵn | Doanh nghiệp cần giao diện trực quan | Doanh nghiệp sử dụng Microsoft 365 |

## 9. HƯỚNG DẪN TIẾP THEO

Để bắt đầu sử dụng n8n trong NextFlow CRM-AI, hãy tham khảo các hướng dẫn sau:

1. [Cài đặt và cấu hình n8n](./cai-dat.md)
2. [Tạo workflow đầu tiên](./tao-workflow.md)
3. [Tích hợp n8n với NextFlow CRM-AI](./tich-hop.md)
4. [Xử lý lỗi và tối ưu hóa](./xu-ly-loi.md)
5. [Các mẫu workflow phổ biến](./mau-workflow.md)

## 10. TÀI LIỆU THAM KHẢO

1. [Tài liệu chính thức n8n](https://docs.n8n.io/)
2. [Cộng đồng n8n](https://community.n8n.io/)
3. [GitHub n8n](https://github.com/n8n-io/n8n)
4. [Thư viện workflow n8n](https://n8n.io/workflows)
5. [Blog n8n](https://n8n.io/blog/)
