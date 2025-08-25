# FLOWISE - TỔNG QUAN

## 1. GIỚI THIỆU

Flowise là một nền tảng mã nguồn mở cho phép xây dựng và triển khai các ứng dụng AI và chatbot dựa trên LangChain một cách trực quan thông qua giao diện kéo thả. Trong NextFlow CRM-AI, Flowise được tích hợp để cung cấp khả năng tạo chatbot thông minh, tự động hóa giao tiếp với khách hàng và xử lý ngôn ngữ tự nhiên (NLP) cho nhiều kênh giao tiếp.

## 2. VAI TRÒ CỦA FLOWISE TRONG NextFlow CRM-AI

### 2.1. Chatbot đa kênh thông minh

Flowise cho phép xây dựng chatbot thông minh có thể tương tác với khách hàng qua nhiều kênh:

- Website của doanh nghiệp
- Mạng xã hội (Facebook Messenger, Zalo, Telegram)
- Ứng dụng nhắn tin (WhatsApp, Viber)
- Sàn thương mại điện tử (Shopee, Lazada, TikTok Shop)
- Email và SMS

### 2.2. Tự động hóa giao tiếp khách hàng

Flowise giúp tự động hóa các quy trình giao tiếp với khách hàng:

- Trả lời tự động các câu hỏi thường gặp
- Hỗ trợ khách hàng 24/7
- Tư vấn sản phẩm và dịch vụ
- Thu thập thông tin khách hàng
- Xử lý yêu cầu hỗ trợ ban đầu

### 2.3. Xử lý ngôn ngữ tự nhiên

Flowise tích hợp các mô hình ngôn ngữ lớn (LLM) để cung cấp khả năng xử lý ngôn ngữ tự nhiên:

- Hiểu ý định của người dùng
- Trích xuất thông tin từ văn bản
- Phân tích cảm xúc
- Tạo nội dung tự động
- Dịch đa ngôn ngữ

### 2.4. Tích hợp với cơ sở kiến thức

Flowise cho phép tích hợp với cơ sở kiến thức của doanh nghiệp:

- Truy vấn tài liệu nội bộ
- Trả lời dựa trên sản phẩm và dịch vụ cụ thể
- Cập nhật thông tin tự động
- Học từ lịch sử tương tác

## 3. KIẾN TRÚC FLOWISE TRONG NextFlow CRM-AI

### 3.1. Mô hình triển khai

Trong NextFlow CRM-AI, Flowise được triển khai theo hai mô hình:

1. **Mô hình dùng chung**: Một instance Flowise dùng chung cho tất cả các tenant, phù hợp cho các gói Basic và Standard.
2. **Mô hình riêng biệt**: Mỗi tenant có một instance Flowise riêng, phù hợp cho các gói Premium và Enterprise.

### 3.2. Kiến trúc kỹ thuật

![Kiến trúc Flowise trong NextFlow CRM-AI](https://assets.NextFlow.com/docs/flowise-architecture.png)

Kiến trúc Flowise trong NextFlow CRM-AI bao gồm các thành phần chính:

1. **Flowise UI**: Giao diện người dùng để thiết kế chatflow
2. **Flowise API**: API để tương tác với Flowise từ NextFlow CRM-AI
3. **Flowise Engine**: Động cơ xử lý chatflow
4. **LangChain**: Thư viện để xây dựng ứng dụng dựa trên LLM
5. **Vector Database**: Cơ sở dữ liệu vector để lưu trữ embeddings
6. **LLM Providers**: Các nhà cung cấp mô hình ngôn ngữ lớn (OpenAI, Google, Anthropic, v.v.)

### 3.3. Tích hợp với NextFlow CRM-AI

Flowise được tích hợp với NextFlow CRM-AI thông qua:

1. **API Integration**: NextFlow CRM-AI cung cấp API cho Flowise để truy cập dữ liệu và chức năng
2. **Webhook**: Flowise nhận và gửi sự kiện đến NextFlow CRM-AI thông qua webhook
3. **Embedded Chat Widget**: Widget chat của Flowise có thể được nhúng vào giao diện NextFlow CRM-AI
4. **Single Sign-On**: Người dùng có thể đăng nhập vào Flowise thông qua NextFlow CRM-AI

## 4. KHÁI NIỆM CƠ BẢN TRONG FLOWISE

### 4.1. Chatflow

Chatflow là một chuỗi các node được kết nối với nhau để xây dựng luồng hội thoại của chatbot. Mỗi chatflow định nghĩa cách chatbot xử lý đầu vào, tìm kiếm thông tin và tạo phản hồi.

### 4.2. Node

Node là đơn vị cơ bản trong chatflow, đại diện cho một chức năng hoặc xử lý cụ thể. Flowise cung cấp nhiều loại node cho các chức năng khác nhau.

Các loại node phổ biến:

- **Chat Models**: Mô hình chat (OpenAI, Google, Anthropic, v.v.)
- **Memory**: Lưu trữ và truy xuất lịch sử hội thoại
- **Document Loaders**: Tải tài liệu từ nhiều nguồn
- **Text Splitters**: Chia nhỏ văn bản thành các đoạn
- **Embeddings**: Tạo vector embeddings từ văn bản
- **Vector Stores**: Lưu trữ và truy vấn vector embeddings
- **Tools**: Công cụ bổ sung (tìm kiếm web, tính toán, v.v.)

### 4.3. Connection

Connection là liên kết giữa các node, xác định luồng dữ liệu từ node này sang node khác.

### 4.4. Credentials

Credentials là thông tin xác thực được sử dụng để kết nối với các dịch vụ bên ngoài như OpenAI, Google, Pinecone, v.v. Flowise lưu trữ credentials một cách an toàn và mã hóa.

### 4.5. API

Mỗi chatflow có thể được xuất bản dưới dạng API để tích hợp với các ứng dụng khác, bao gồm cả NextFlow CRM-AI.

## 5. TÍNH NĂNG CHÍNH CỦA FLOWISE

### 5.1. Thiết kế chatflow trực quan

Flowise cung cấp giao diện người dùng trực quan để thiết kế chatflow bằng cách kéo và thả, không cần kỹ năng lập trình phức tạp.

### 5.2. Hỗ trợ nhiều mô hình LLM

Flowise hỗ trợ nhiều mô hình ngôn ngữ lớn từ các nhà cung cấp khác nhau:

- OpenAI (GPT-3.5, GPT-4)
- Google (PaLM, Gemini)
- Anthropic (Claude)
- Hugging Face
- Mô hình mã nguồn mở (Llama, Mistral, v.v.)

### 5.3. Truy vấn cơ sở kiến thức

Flowise cho phép xây dựng chatbot có khả năng truy vấn cơ sở kiến thức của doanh nghiệp thông qua:

- Tải tài liệu từ nhiều nguồn (PDF, Word, Excel, HTML, v.v.)
- Tạo vector embeddings từ tài liệu
- Lưu trữ embeddings trong vector database
- Tìm kiếm ngữ nghĩa (semantic search)
- Trả lời dựa trên thông tin tìm thấy

### 5.4. Bộ nhớ hội thoại

Flowise cung cấp nhiều loại bộ nhớ hội thoại để chatbot có thể nhớ và tham chiếu đến các tương tác trước đó:

- Buffer Memory
- Window Memory
- Conversation Summary Memory
- Vector Store Memory

### 5.5. Công cụ và tích hợp

Flowise hỗ trợ nhiều công cụ và tích hợp để mở rộng khả năng của chatbot:

- Tìm kiếm web
- Truy cập API bên ngoài
- Thực hiện tính toán
- Truy cập cơ sở dữ liệu
- Tạo và chỉnh sửa hình ảnh

### 5.6. Đa ngôn ngữ

Flowise hỗ trợ xây dựng chatbot đa ngôn ngữ, bao gồm cả tiếng Việt, giúp doanh nghiệp phục vụ khách hàng toàn cầu.

### 5.7. Phân tích và đánh giá

Flowise cung cấp công cụ phân tích và đánh giá hiệu suất chatbot:

- Theo dõi lịch sử hội thoại
- Đánh giá chất lượng phản hồi
- Phân tích ý định người dùng
- Xác định khu vực cần cải thiện

## 6. CÁC TRƯỜNG HỢP SỬ DỤNG TRONG NextFlow CRM-AI

### 6.1. Hỗ trợ khách hàng tự động

- Trả lời câu hỏi thường gặp 24/7
- Hướng dẫn sử dụng sản phẩm và dịch vụ
- Xử lý yêu cầu hỗ trợ cơ bản
- Chuyển tiếp đến nhân viên khi cần thiết

### 6.2. Tư vấn sản phẩm thông minh

- Gợi ý sản phẩm dựa trên nhu cầu khách hàng
- So sánh các sản phẩm và dịch vụ
- Cung cấp thông tin chi tiết về sản phẩm
- Hỗ trợ quy trình mua hàng

### 6.3. Tự động hóa quy trình bán hàng

- Thu thập thông tin khách hàng tiềm năng
- Đánh giá mức độ quan tâm
- Lên lịch cuộc hẹn với nhân viên bán hàng
- Theo dõi và nhắc nhở khách hàng

### 6.4. Phân tích phản hồi khách hàng

- Thu thập phản hồi từ khách hàng
- Phân tích cảm xúc và ý kiến
- Xác định vấn đề phổ biến
- Tạo báo cáo tổng hợp

### 6.5. Trợ lý ảo cho nhân viên

- Truy xuất thông tin nội bộ nhanh chóng
- Hỗ trợ quy trình làm việc
- Tự động hóa tác vụ hành chính
- Đào tạo nhân viên mới

## 7. GIỚI HẠN VÀ KHUYẾN NGHỊ

### 7.1. Giới hạn kỹ thuật

- **Số lượng chatflow**: Tùy thuộc vào gói dịch vụ
  - Basic: 5 chatflow
  - Standard: 20 chatflow
  - Premium: 50 chatflow
  - Enterprise: Không giới hạn

- **Kích thước cơ sở kiến thức**: Tùy thuộc vào gói dịch vụ
  - Basic: 100 trang
  - Standard: 500 trang
  - Premium: 2000 trang
  - Enterprise: Không giới hạn

- **Số lượng tin nhắn**: Tùy thuộc vào gói dịch vụ và nhà cung cấp LLM

### 7.2. Khuyến nghị hiệu suất

- Chia nhỏ tài liệu thành các đoạn phù hợp (thường 500-1000 ký tự)
- Sử dụng mô hình embeddings phù hợp với ngôn ngữ của dữ liệu
- Tối ưu hóa prompt để có kết quả tốt nhất
- Sử dụng bộ nhớ hội thoại phù hợp với trường hợp sử dụng
- Thiết lập cơ chế chuyển tiếp đến nhân viên khi cần thiết

### 7.3. Khuyến nghị bảo mật

- Không chia sẻ API key của các dịch vụ LLM
- Không lưu trữ thông tin nhạy cảm trong chatflow
- Thiết lập chính sách lưu trữ và xóa dữ liệu hội thoại
- Thông báo cho người dùng khi họ đang tương tác với chatbot
- Tuân thủ các quy định về bảo vệ dữ liệu (GDPR, PDPA, v.v.)

## 8. SO SÁNH VỚI CÁC GIẢI PHÁP KHÁC

| Tính năng | Flowise | Botpress | Rasa | Dialogflow |
|-----------|---------|----------|------|------------|
| Mã nguồn | Mở | Mở/Đóng | Mở | Đóng |
| Triển khai | Self-hosted hoặc Cloud | Self-hosted hoặc Cloud | Self-hosted hoặc Cloud | Chỉ Cloud |
| Dựa trên LLM | Có | Một phần | Không | Một phần |
| Thiết kế trực quan | Cao | Cao | Thấp | Trung bình |
| Tùy biến | Cao | Trung bình | Cao | Thấp |
| Hỗ trợ tiếng Việt | Tốt | Trung bình | Trung bình | Tốt |
| Giá cả | Miễn phí (self-hosted) | Miễn phí/Trả phí | Miễn phí (self-hosted) | Trả phí |
| Phù hợp với | Doanh nghiệp cần chatbot dựa trên LLM và cơ sở kiến thức | Doanh nghiệp cần chatbot đa kênh | Doanh nghiệp cần tùy biến cao và kiểm soát hoàn toàn | Doanh nghiệp cần giải pháp đơn giản và sẵn sàng |

## 9. HƯỚNG DẪN TIẾP THEO

Để bắt đầu sử dụng Flowise trong NextFlow CRM-AI, hãy tham khảo các hướng dẫn sau:

1. [Cài đặt và cấu hình Flowise](./cai-dat.md)
2. [Tạo chatflow đầu tiên](./tao-chatflow.md)
3. [Tích hợp Flowise với NextFlow CRM-AI](./tich-hop.md)
4. [Xây dựng chatbot với cơ sở kiến thức](./co-so-kien-thuc.md)
5. [Triển khai chatbot đa kênh](./da-kenh.md)

## 10. TÀI LIỆU THAM KHẢO

1. [Tài liệu chính thức Flowise](https://docs.flowiseai.com/)
2. [GitHub Flowise](https://github.com/FlowiseAI/Flowise)
3. [Tài liệu LangChain](https://js.langchain.com/docs/)
4. [Hướng dẫn sử dụng OpenAI API](https://platform.openai.com/docs/api-reference)
5. [Cộng đồng Flowise Discord](https://discord.gg/flowiseai)
