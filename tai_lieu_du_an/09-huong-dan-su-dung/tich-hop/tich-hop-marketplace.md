# HƯỚNG DẪN TÍCH HỢP MARKETPLACE

## 1. GIỚI THIỆU

Tài liệu này hướng dẫn chi tiết cách tích hợp và quản lý các tài khoản marketplace (Shopee, Lazada, TikTok Shop) trong NextFlow CRM. Tính năng này cho phép bạn quản lý sản phẩm, đơn hàng và tồn kho trên nhiều nền tảng từ một giao diện duy nhất.

### 1.1. Lợi ích của tích hợp marketplace

- **Quản lý tập trung**: Quản lý nhiều tài khoản marketplace từ một giao diện duy nhất
- **Đồng bộ sản phẩm**: Tự động đồng bộ sản phẩm giữa NextFlow CRM và các marketplace
- **Quản lý đơn hàng**: Xử lý đơn hàng từ nhiều nền tảng trong một hệ thống
- **Quản lý tồn kho**: Tự động cập nhật tồn kho trên tất cả các kênh
- **Báo cáo tổng hợp**: Xem báo cáo bán hàng tổng hợp từ tất cả các kênh

### 1.2. Các nền tảng được hỗ trợ

- **Shopee**: Tích hợp đầy đủ với Shopee Open Platform API
- **Lazada**: Tích hợp đầy đủ với Lazada Open Platform API
- **TikTok Shop**: Tích hợp đầy đủ với TikTok Shop Open API
- **WordPress/WooCommerce**: Tích hợp thông qua WooCommerce REST API
- **Haravan**: Tích hợp thông qua Haravan Open API

## 2. THIẾT LẬP KẾT NỐI MARKETPLACE

### 2.1. Kết nối với Shopee

#### 2.1.1. Yêu cầu trước khi kết nối

- Có tài khoản Shopee bán hàng đang hoạt động
- Đã xác thực danh tính trên Shopee
- Có quyền truy cập vào tài khoản Shopee

#### 2.1.2. Các bước kết nối

1. **Đăng nhập vào NextFlow CRM**
   - Truy cập vào hệ thống NextFlow CRM
   - Đăng nhập bằng tài khoản của bạn

2. **Truy cập trang Tích hợp Marketplace**
   - Từ menu chính, chọn **Tích hợp > Marketplace**
   - Hoặc truy cập trực tiếp vào đường dẫn: `https://app.NextFlow.com/integrations/marketplace`

3. **Thêm kết nối Shopee mới**
   - Nhấp vào nút **Thêm kết nối mới**
   - Chọn **Shopee** từ danh sách các nền tảng

4. **Xác thực với Shopee**
   - Nhấp vào nút **Kết nối với Shopee**
   - Hệ thống sẽ chuyển hướng bạn đến trang đăng nhập Shopee
   - Đăng nhập vào tài khoản Shopee của bạn
   - Cấp quyền cho NextFlow CRM truy cập vào tài khoản Shopee của bạn
   - Sau khi xác thực thành công, bạn sẽ được chuyển hướng trở lại NextFlow CRM

5. **Cấu hình đồng bộ**
   - Cấu hình các tùy chọn đồng bộ:
     - **Đồng bộ sản phẩm**: Bật/tắt đồng bộ sản phẩm
     - **Đồng bộ đơn hàng**: Bật/tắt đồng bộ đơn hàng
     - **Đồng bộ tồn kho**: Bật/tắt đồng bộ tồn kho
     - **Tần suất đồng bộ**: Chọn tần suất đồng bộ (15 phút, 30 phút, 1 giờ, v.v.)
   - Nhấp vào nút **Lưu cấu hình**

6. **Kiểm tra kết nối**
   - Kiểm tra trạng thái kết nối trong danh sách các kết nối
   - Nếu trạng thái hiển thị **Đã kết nối**, quá trình kết nối đã thành công

### 2.2. Kết nối với Lazada

#### 2.2.1. Yêu cầu trước khi kết nối

- Có tài khoản Lazada bán hàng đang hoạt động
- Đã xác thực danh tính trên Lazada
- Có quyền truy cập vào tài khoản Lazada

#### 2.2.2. Các bước kết nối

1. **Truy cập trang Tích hợp Marketplace**
   - Từ menu chính, chọn **Tích hợp > Marketplace**

2. **Thêm kết nối Lazada mới**
   - Nhấp vào nút **Thêm kết nối mới**
   - Chọn **Lazada** từ danh sách các nền tảng

3. **Xác thực với Lazada**
   - Nhấp vào nút **Kết nối với Lazada**
   - Hệ thống sẽ chuyển hướng bạn đến trang đăng nhập Lazada
   - Đăng nhập vào tài khoản Lazada của bạn
   - Cấp quyền cho NextFlow CRM truy cập vào tài khoản Lazada của bạn
   - Sau khi xác thực thành công, bạn sẽ được chuyển hướng trở lại NextFlow CRM

4. **Cấu hình đồng bộ**
   - Cấu hình các tùy chọn đồng bộ tương tự như với Shopee
   - Nhấp vào nút **Lưu cấu hình**

5. **Kiểm tra kết nối**
   - Kiểm tra trạng thái kết nối trong danh sách các kết nối

### 2.3. Kết nối với TikTok Shop

#### 2.3.1. Yêu cầu trước khi kết nối

- Có tài khoản TikTok Shop đang hoạt động
- Đã xác thực danh tính trên TikTok Shop
- Có quyền truy cập vào tài khoản TikTok Shop

#### 2.3.2. Các bước kết nối

1. **Truy cập trang Tích hợp Marketplace**
   - Từ menu chính, chọn **Tích hợp > Marketplace**

2. **Thêm kết nối TikTok Shop mới**
   - Nhấp vào nút **Thêm kết nối mới**
   - Chọn **TikTok Shop** từ danh sách các nền tảng

3. **Xác thực với TikTok Shop**
   - Nhấp vào nút **Kết nối với TikTok Shop**
   - Hệ thống sẽ chuyển hướng bạn đến trang đăng nhập TikTok
   - Đăng nhập vào tài khoản TikTok của bạn
   - Cấp quyền cho NextFlow CRM truy cập vào tài khoản TikTok Shop của bạn
   - Sau khi xác thực thành công, bạn sẽ được chuyển hướng trở lại NextFlow CRM

4. **Cấu hình đồng bộ**
   - Cấu hình các tùy chọn đồng bộ tương tự như với Shopee và Lazada
   - Nhấp vào nút **Lưu cấu hình**

5. **Kiểm tra kết nối**
   - Kiểm tra trạng thái kết nối trong danh sách các kết nối

## 3. QUẢN LÝ SẢN PHẨM ĐA NỀN TẢNG

### 3.1. Đăng sản phẩm lên marketplace

#### 3.1.1. Đăng sản phẩm mới

1. **Tạo sản phẩm trong NextFlow CRM**
   - Từ menu chính, chọn **Sản phẩm > Tất cả sản phẩm**
   - Nhấp vào nút **Thêm sản phẩm mới**
   - Điền thông tin sản phẩm:
     - Tên sản phẩm
     - Mô tả
     - Giá
     - Danh mục
     - Thuộc tính (màu sắc, kích cỡ, v.v.)
     - Hình ảnh
   - Nhấp vào nút **Lưu sản phẩm**

2. **Đăng sản phẩm lên marketplace**
   - Từ trang chi tiết sản phẩm, nhấp vào tab **Marketplace**
   - Chọn các marketplace muốn đăng sản phẩm (Shopee, Lazada, TikTok Shop)
   - Cấu hình thông tin cho từng marketplace:
     - Danh mục trên marketplace
     - Thuộc tính đặc thù của marketplace
     - Giá bán (có thể khác với giá trên NextFlow CRM)
   - Nhấp vào nút **Đăng sản phẩm**

3. **Kiểm tra trạng thái đăng sản phẩm**
   - Hệ thống sẽ hiển thị tiến trình đăng sản phẩm
   - Sau khi hoàn tất, bạn sẽ thấy trạng thái đăng sản phẩm trên từng marketplace
   - Nếu có lỗi, hệ thống sẽ hiển thị thông báo lỗi và hướng dẫn khắc phục

#### 3.1.2. Đăng nhiều sản phẩm cùng lúc

1. **Chọn nhiều sản phẩm**
   - Từ trang **Sản phẩm > Tất cả sản phẩm**
   - Đánh dấu chọn các sản phẩm muốn đăng
   - Nhấp vào nút **Hành động hàng loạt**
   - Chọn **Đăng lên marketplace**

2. **Chọn marketplace và cấu hình**
   - Chọn các marketplace muốn đăng sản phẩm
   - Cấu hình các tùy chọn chung:
     - Cập nhật giá
     - Cập nhật tồn kho
     - Cập nhật hình ảnh
     - Cập nhật mô tả
   - Nhấp vào nút **Đăng sản phẩm**

3. **Kiểm tra trạng thái**
   - Hệ thống sẽ hiển thị tiến trình đăng sản phẩm hàng loạt
   - Bạn có thể xem chi tiết kết quả đăng từng sản phẩm

### 3.2. Cập nhật sản phẩm đa nền tảng

#### 3.2.1. Cập nhật thông tin sản phẩm

1. **Chỉnh sửa sản phẩm trong NextFlow CRM**
   - Từ trang chi tiết sản phẩm, nhấp vào nút **Chỉnh sửa**
   - Cập nhật thông tin sản phẩm
   - Nhấp vào nút **Lưu thay đổi**

2. **Đồng bộ thay đổi lên marketplace**
   - Sau khi lưu thay đổi, hệ thống sẽ hiển thị thông báo hỏi bạn có muốn đồng bộ thay đổi lên các marketplace không
   - Chọn **Có** để đồng bộ ngay
   - Hoặc chọn **Không** nếu bạn muốn đồng bộ sau

#### 3.2.2. Cập nhật giá và tồn kho

1. **Cập nhật giá và tồn kho trong NextFlow CRM**
   - Từ trang chi tiết sản phẩm, nhấp vào tab **Giá & Tồn kho**
   - Cập nhật giá và tồn kho
   - Nhấp vào nút **Lưu thay đổi**

2. **Đồng bộ giá và tồn kho lên marketplace**
   - Hệ thống sẽ tự động đồng bộ giá và tồn kho lên các marketplace theo cấu hình đồng bộ
   - Bạn cũng có thể đồng bộ thủ công bằng cách nhấp vào nút **Đồng bộ ngay**

### 3.3. Nhập sản phẩm từ marketplace

1. **Truy cập tính năng nhập sản phẩm**
   - Từ menu chính, chọn **Sản phẩm > Nhập từ marketplace**

2. **Chọn marketplace và cấu hình**
   - Chọn marketplace muốn nhập sản phẩm
   - Cấu hình các tùy chọn nhập:
     - Nhập sản phẩm mới
     - Cập nhật sản phẩm hiện có
     - Nhập hình ảnh
     - Nhập biến thể

3. **Chọn sản phẩm để nhập**
   - Hệ thống sẽ hiển thị danh sách sản phẩm từ marketplace
   - Đánh dấu chọn các sản phẩm muốn nhập
   - Nhấp vào nút **Nhập sản phẩm**

4. **Kiểm tra kết quả nhập**
   - Hệ thống sẽ hiển thị tiến trình nhập sản phẩm
   - Sau khi hoàn tất, bạn có thể xem danh sách sản phẩm đã nhập

## 4. QUẢN LÝ ĐƠN HÀNG ĐA NỀN TẢNG

### 4.1. Đồng bộ đơn hàng từ marketplace

#### 4.1.1. Đồng bộ tự động

- Hệ thống sẽ tự động đồng bộ đơn hàng từ các marketplace theo tần suất đã cấu hình
- Bạn có thể xem lịch sử đồng bộ trong tab **Lịch sử đồng bộ**

#### 4.1.2. Đồng bộ thủ công

1. **Truy cập trang Đơn hàng**
   - Từ menu chính, chọn **Đơn hàng > Tất cả đơn hàng**

2. **Đồng bộ đơn hàng**
   - Nhấp vào nút **Đồng bộ đơn hàng**
   - Chọn marketplace muốn đồng bộ
   - Cấu hình thời gian đồng bộ (từ ngày, đến ngày)
   - Chọn trạng thái đơn hàng muốn đồng bộ
   - Nhấp vào nút **Đồng bộ ngay**

3. **Kiểm tra kết quả đồng bộ**
   - Hệ thống sẽ hiển thị tiến trình đồng bộ
   - Sau khi hoàn tất, bạn có thể xem danh sách đơn hàng đã đồng bộ

### 4.2. Xử lý đơn hàng marketplace

#### 4.2.1. Xem danh sách đơn hàng

1. **Truy cập trang Đơn hàng**
   - Từ menu chính, chọn **Đơn hàng > Tất cả đơn hàng**

2. **Lọc đơn hàng**
   - Sử dụng bộ lọc để tìm đơn hàng:
     - Theo marketplace (Shopee, Lazada, TikTok Shop)
     - Theo trạng thái (Chờ xử lý, Đang xử lý, Đã giao, Đã hủy)
     - Theo thời gian (Hôm nay, Tuần này, Tháng này)
     - Theo khách hàng

#### 4.2.2. Cập nhật trạng thái đơn hàng

1. **Xem chi tiết đơn hàng**
   - Nhấp vào mã đơn hàng để xem chi tiết

2. **Cập nhật trạng thái**
   - Từ trang chi tiết đơn hàng, nhấp vào nút **Cập nhật trạng thái**
   - Chọn trạng thái mới (Đang xử lý, Đã giao hàng, Đã hủy)
   - Nhập thông tin bổ sung (nếu cần)
   - Nhấp vào nút **Lưu thay đổi**

3. **Đồng bộ trạng thái lên marketplace**
   - Hệ thống sẽ tự động đồng bộ trạng thái mới lên marketplace
   - Bạn có thể xem kết quả đồng bộ trong tab **Lịch sử đồng bộ**

#### 4.2.3. Cập nhật thông tin vận chuyển

1. **Xem chi tiết đơn hàng**
   - Nhấp vào mã đơn hàng để xem chi tiết

2. **Cập nhật thông tin vận chuyển**
   - Từ trang chi tiết đơn hàng, nhấp vào tab **Vận chuyển**
   - Nhấp vào nút **Cập nhật thông tin vận chuyển**
   - Nhập thông tin vận chuyển:
     - Đơn vị vận chuyển
     - Mã vận đơn
     - Ngày giao hàng dự kiến
   - Nhấp vào nút **Lưu thay đổi**

3. **Đồng bộ thông tin vận chuyển lên marketplace**
   - Hệ thống sẽ tự động đồng bộ thông tin vận chuyển lên marketplace
   - Bạn có thể xem kết quả đồng bộ trong tab **Lịch sử đồng bộ**

## 5. BÁO CÁO VÀ PHÂN TÍCH

### 5.1. Báo cáo bán hàng tổng hợp

1. **Truy cập trang Báo cáo**
   - Từ menu chính, chọn **Báo cáo > Báo cáo bán hàng**

2. **Xem báo cáo tổng hợp**
   - Hệ thống sẽ hiển thị báo cáo bán hàng tổng hợp từ tất cả các kênh
   - Bạn có thể xem các chỉ số:
     - Doanh thu
     - Số lượng đơn hàng
     - Giá trị đơn hàng trung bình
     - Tỷ lệ chuyển đổi

3. **Lọc và phân tích báo cáo**
   - Sử dụng bộ lọc để phân tích dữ liệu:
     - Theo marketplace
     - Theo thời gian
     - Theo danh mục sản phẩm
     - Theo khu vực

### 5.2. Báo cáo hiệu suất sản phẩm

1. **Truy cập trang Báo cáo sản phẩm**
   - Từ menu chính, chọn **Báo cáo > Hiệu suất sản phẩm**

2. **Xem báo cáo hiệu suất sản phẩm**
   - Hệ thống sẽ hiển thị báo cáo hiệu suất của từng sản phẩm trên các marketplace
   - Bạn có thể xem các chỉ số:
     - Doanh số bán hàng
     - Số lượng bán
     - Lượt xem
     - Tỷ lệ chuyển đổi

3. **So sánh hiệu suất giữa các marketplace**
   - Sử dụng tính năng so sánh để đánh giá hiệu suất của sản phẩm trên các marketplace khác nhau
   - Xác định marketplace nào mang lại hiệu quả tốt nhất cho từng sản phẩm

## 6. XỬ LÝ SỰ CỐ

### 6.1. Các vấn đề thường gặp khi kết nối

| Vấn đề | Nguyên nhân | Giải pháp |
|--------|------------|-----------|
| Không thể kết nối với marketplace | Token xác thực hết hạn | Thực hiện lại quá trình xác thực |
| | Tài khoản marketplace bị khóa | Kiểm tra trạng thái tài khoản trên marketplace |
| | Lỗi API | Thử lại sau vài phút |
| Kết nối bị ngắt | Token xác thực hết hạn | Làm mới token xác thực |
| | Thay đổi mật khẩu marketplace | Thực hiện lại quá trình xác thực |

### 6.2. Các vấn đề thường gặp khi đồng bộ sản phẩm

| Vấn đề | Nguyên nhân | Giải pháp |
|--------|------------|-----------|
| Không thể đăng sản phẩm | Thiếu thông tin bắt buộc | Bổ sung thông tin còn thiếu |
| | Sản phẩm vi phạm quy định | Kiểm tra và điều chỉnh thông tin sản phẩm |
| | Lỗi API | Thử lại sau vài phút |
| Sản phẩm không hiển thị trên marketplace | Sản phẩm đang chờ duyệt | Chờ marketplace duyệt sản phẩm |
| | Sản phẩm bị từ chối | Kiểm tra lý do từ chối và điều chỉnh |

### 6.3. Các vấn đề thường gặp khi đồng bộ đơn hàng

| Vấn đề | Nguyên nhân | Giải pháp |
|--------|------------|-----------|
| Không thể đồng bộ đơn hàng | Lỗi kết nối | Kiểm tra kết nối marketplace |
| | Lỗi API | Thử lại sau vài phút |
| | Quyền truy cập không đủ | Kiểm tra quyền truy cập API |
| Trạng thái đơn hàng không đồng bộ | Lỗi đồng bộ | Thử đồng bộ lại thủ công |
| | Trạng thái không hợp lệ | Kiểm tra trạng thái đơn hàng trên marketplace |

## 7. CÂU HỎI THƯỜNG GẶP

### 7.1. Câu hỏi chung

**Hỏi**: NextFlow CRM hỗ trợ bao nhiêu tài khoản marketplace?
**Trả lời**: NextFlow CRM hỗ trợ không giới hạn số lượng tài khoản marketplace, tùy thuộc vào gói dịch vụ của bạn.

**Hỏi**: Tôi có thể kết nối nhiều tài khoản từ cùng một marketplace không?
**Trả lời**: Có, bạn có thể kết nối nhiều tài khoản Shopee, Lazada hoặc TikTok Shop với NextFlow CRM.

### 7.2. Câu hỏi về đồng bộ sản phẩm

**Hỏi**: Tần suất đồng bộ sản phẩm tối đa là bao nhiêu?
**Trả lời**: Tần suất đồng bộ tối đa là 15 phút cho sản phẩm và 5 phút cho tồn kho.

**Hỏi**: Có thể đồng bộ sản phẩm có biến thể phức tạp không?
**Trả lời**: Có, NextFlow CRM hỗ trợ đồng bộ sản phẩm có nhiều biến thể (màu sắc, kích cỡ, v.v.).

### 7.3. Câu hỏi về đồng bộ đơn hàng

**Hỏi**: Đơn hàng từ marketplace có được tự động cập nhật trong NextFlow CRM không?
**Trả lời**: Có, đơn hàng sẽ được tự động đồng bộ theo tần suất bạn đã cấu hình.

**Hỏi**: Tôi có thể cập nhật trạng thái đơn hàng trên marketplace từ NextFlow CRM không?
**Trả lời**: Có, bạn có thể cập nhật trạng thái đơn hàng từ NextFlow CRM và thay đổi sẽ được đồng bộ lên marketplace.
