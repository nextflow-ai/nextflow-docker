# HƯỚNG DẪN QUẢN LÝ NGƯỜI DÙNG CHO QUẢN TRỊ VIÊN - PHẦN 1

## 1. GIỚI THIỆU

Tài liệu này cung cấp hướng dẫn chi tiết về cách quản lý người dùng trong NextFlow CRM-AI dành cho quản trị viên hệ thống. Phần 1 tập trung vào tổng quan, tạo và quản lý tài khoản người dùng.

### 1.1. Mục đích tài liệu

- Hướng dẫn quản trị viên cách tạo và quản lý tài khoản người dùng
- Giải thích cách phân quyền và phân nhóm người dùng
- Cung cấp thông tin về cách thiết lập chính sách bảo mật
- Hướng dẫn giám sát và quản lý hoạt động người dùng

### 1.2. Vai trò quản trị viên

Quản trị viên trong NextFlow CRM-AI có các trách nhiệm chính:

- Quản lý tài khoản người dùng (tạo, chỉnh sửa, vô hiệu hóa)
- Phân quyền và phân nhóm người dùng
- Thiết lập chính sách bảo mật
- Giám sát hoạt động người dùng
- Hỗ trợ người dùng về vấn đề tài khoản

## 2. TRUY CẬP QUẢN LÝ NGƯỜI DÙNG

### 2.1. Đăng nhập với quyền quản trị

1. Truy cập vào URL của NextFlow CRM-AI: `https://[tenant-name].NextFlow.com`
2. Đăng nhập bằng tài khoản có quyền quản trị
3. Sau khi đăng nhập, truy cập vào phần quản trị bằng cách:
   - Nhấn vào avatar ở góc trên bên phải
   - Chọn "Quản trị hệ thống" hoặc
   - Truy cập trực tiếp từ sidebar, mục "Cài đặt" > "Quản lý người dùng"

### 2.2. Giao diện quản lý người dùng

Giao diện quản lý người dùng bao gồm các phần chính:

- **Danh sách người dùng**: Hiển thị tất cả người dùng trong hệ thống
- **Nhóm người dùng**: Quản lý các nhóm người dùng
- **Vai trò**: Quản lý các vai trò và quyền
- **Chính sách bảo mật**: Thiết lập các chính sách bảo mật
- **Nhật ký hoạt động**: Xem lịch sử hoạt động của người dùng

### 2.3. Tìm kiếm và lọc người dùng

Để tìm kiếm và lọc người dùng:

1. Sử dụng ô tìm kiếm ở phía trên danh sách người dùng
2. Nhập tên, email hoặc thông tin khác của người dùng
3. Sử dụng bộ lọc nâng cao:
   - Lọc theo trạng thái (Hoạt động, Vô hiệu hóa)
   - Lọc theo vai trò
   - Lọc theo nhóm
   - Lọc theo ngày tạo
   - Lọc theo ngày đăng nhập cuối

## 3. TẠO VÀ QUẢN LÝ TÀI KHOẢN NGƯỜI DÙNG

### 3.1. Tạo người dùng mới

#### 3.1.1. Tạo người dùng đơn lẻ

1. Trong giao diện Quản lý người dùng, nhấn nút "+ Thêm người dùng"
2. Điền thông tin cơ bản:
   - Họ và tên
   - Email (sẽ được sử dụng làm tên đăng nhập)
   - Số điện thoại
   - Chức danh
   - Phòng ban
3. Thiết lập tài khoản:
   - Chọn vai trò
   - Chọn nhóm người dùng
   - Thiết lập mật khẩu hoặc chọn "Gửi email thiết lập mật khẩu"
4. Cấu hình bổ sung:
   - Thiết lập ngày hết hạn tài khoản (nếu cần)
   - Yêu cầu đổi mật khẩu khi đăng nhập lần đầu
   - Yêu cầu xác thực hai yếu tố
5. Nhấn "Lưu" để tạo người dùng

#### 3.1.2. Import người dùng hàng loạt

1. Trong giao diện Quản lý người dùng, nhấn nút "Import"
2. Tải xuống template mẫu
3. Điền thông tin người dùng vào template
4. Tải lên file đã điền thông tin
5. Ánh xạ các cột trong file với trường trong hệ thống
6. Xem trước dữ liệu import
7. Nhấn "Import" để tạo người dùng hàng loạt
8. Xem báo cáo kết quả import

### 3.2. Chỉnh sửa thông tin người dùng

1. Trong danh sách người dùng, nhấn vào tên người dùng cần chỉnh sửa
2. Nhấn nút "Chỉnh sửa"
3. Cập nhật thông tin cần thiết
4. Nhấn "Lưu" để áp dụng thay đổi

### 3.3. Vô hiệu hóa và kích hoạt tài khoản

#### 3.3.1. Vô hiệu hóa tài khoản

1. Trong danh sách người dùng, chọn người dùng cần vô hiệu hóa
2. Nhấn nút "Vô hiệu hóa" hoặc
3. Mở chi tiết người dùng, nhấn "Vô hiệu hóa tài khoản"
4. Xác nhận hành động trong hộp thoại hiện ra

#### 3.3.2. Kích hoạt lại tài khoản

1. Trong danh sách người dùng, lọc để hiển thị người dùng bị vô hiệu hóa
2. Chọn người dùng cần kích hoạt lại
3. Nhấn nút "Kích hoạt" hoặc
4. Mở chi tiết người dùng, nhấn "Kích hoạt tài khoản"
5. Xác nhận hành động trong hộp thoại hiện ra

### 3.4. Đặt lại mật khẩu

#### 3.4.1. Đặt lại mật khẩu cho người dùng

1. Trong danh sách người dùng, chọn người dùng cần đặt lại mật khẩu
2. Nhấn nút "Đặt lại mật khẩu" hoặc
3. Mở chi tiết người dùng, nhấn "Đặt lại mật khẩu"
4. Chọn phương thức đặt lại:
   - Tạo mật khẩu mới và thông báo cho người dùng
   - Gửi email đặt lại mật khẩu cho người dùng
5. Xác nhận hành động

#### 3.4.2. Cưỡng chế đổi mật khẩu

1. Trong danh sách người dùng, chọn người dùng cần cưỡng chế đổi mật khẩu
2. Mở chi tiết người dùng, chuyển đến tab "Bảo mật"
3. Bật tùy chọn "Yêu cầu đổi mật khẩu khi đăng nhập tiếp theo"
4. Nhấn "Lưu" để áp dụng thay đổi

## 4. QUẢN LÝ NHÓM NGƯỜI DÙNG

### 4.1. Tạo nhóm người dùng

1. Trong giao diện Quản lý người dùng, chuyển đến tab "Nhóm người dùng"
2. Nhấn nút "+ Thêm nhóm"
3. Điền thông tin nhóm:
   - Tên nhóm
   - Mô tả
   - Nhóm cha (nếu có)
4. Nhấn "Lưu" để tạo nhóm

### 4.2. Thêm người dùng vào nhóm

#### 4.2.1. Thêm từ danh sách người dùng

1. Trong danh sách người dùng, chọn một hoặc nhiều người dùng
2. Nhấn nút "Thêm vào nhóm"
3. Chọn nhóm từ danh sách
4. Nhấn "Thêm" để xác nhận

#### 4.2.2. Thêm từ chi tiết nhóm

1. Trong tab "Nhóm người dùng", nhấn vào tên nhóm
2. Chuyển đến tab "Thành viên"
3. Nhấn nút "+ Thêm thành viên"
4. Chọn người dùng từ danh sách
5. Nhấn "Thêm" để xác nhận

### 4.3. Xóa người dùng khỏi nhóm

1. Trong tab "Nhóm người dùng", nhấn vào tên nhóm
2. Chuyển đến tab "Thành viên"
3. Chọn người dùng cần xóa khỏi nhóm
4. Nhấn nút "Xóa khỏi nhóm"
5. Xác nhận hành động

### 4.4. Chỉnh sửa và xóa nhóm

#### 4.4.1. Chỉnh sửa nhóm

1. Trong tab "Nhóm người dùng", nhấn vào tên nhóm
2. Nhấn nút "Chỉnh sửa"
3. Cập nhật thông tin nhóm
4. Nhấn "Lưu" để áp dụng thay đổi

#### 4.4.2. Xóa nhóm

1. Trong tab "Nhóm người dùng", chọn nhóm cần xóa
2. Nhấn nút "Xóa" hoặc
3. Mở chi tiết nhóm, nhấn "Xóa nhóm"
4. Xác nhận hành động

**Lưu ý**: Khi xóa nhóm, người dùng trong nhóm sẽ không bị xóa, chỉ bị xóa khỏi nhóm.
