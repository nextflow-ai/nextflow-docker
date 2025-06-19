# Hướng Dẫn Tạo User Root GitLab

## Tổng Quan

Tài liệu này hướng dẫn cách tạo user root thủ công cho GitLab trong dự án NextFlow Docker với mật khẩu tùy chỉnh `Nex!tFlow@2025!`.

## Thông Tin User Root

- **Username**: `root`
- **Password**: `Nex!tFlow@2025!`
- **Email**: `nextflow.vn@gmail.com`
- **Name**: `NextFlow Administrator`
- **Role**: Admin
- **URL truy cập**: http://localhost:8088

## Cách Sử Dụng

### 1. Sử dụng Script GitLab Chính

```bash
# Tạo user root thủ công
./scripts/gitlab.sh --create-root

# Hoặc sử dụng chế độ tương tác
./scripts/gitlab.sh
# Chọn option "9. Tạo user root thủ công"
```

### 2. Sử dụng Script Test Chuyên Dụng

```bash
# Chạy test tạo user root
./scripts/test-gitlab-root-user.sh --create

# Hoặc chạy full test
./scripts/test-gitlab-root-user.sh --all

# Chế độ tương tác
./scripts/test-gitlab-root-user.sh
```

### 3. Các Lệnh Hữu Ích Khác

```bash
# Kiểm tra trạng thái GitLab
./scripts/gitlab.sh --status

# Xem logs GitLab
./scripts/gitlab.sh --logs --follow

# Hiển thị thông tin truy cập
./scripts/test-gitlab-root-user.sh --info

# Kiểm tra users hiện tại
./scripts/test-gitlab-root-user.sh --users
```

## Quy Trình Tạo User Root

### Bước 1: Kiểm tra GitLab
- Script sẽ kiểm tra GitLab container có đang chạy không
- Kiểm tra health status của GitLab (phải là "healthy")
- Nếu GitLab chưa sẵn sàng, script sẽ thông báo đợi

### Bước 2: Xác nhận thông tin
- Script hiển thị thông tin user root sẽ tạo
- Người dùng xác nhận có muốn tiếp tục không

### Bước 3: Tạo/Cập nhật user
- Kiểm tra user root có tồn tại không
- Nếu chưa có: tạo user root mới
- Nếu đã có: cập nhật thông tin và mật khẩu

### Bước 4: Xác nhận kết quả
- Hiển thị thông tin user root đã tạo/cập nhật
- Cung cấp thông tin đăng nhập

## Xử Lý Lỗi

### GitLab chưa sẵn sàng
```
⚠️ GitLab chưa sẵn sàng (trạng thái: starting)
Vui lòng đợi GitLab khởi động hoàn toàn trước khi tạo user root
```

**Giải pháp**: Đợi 3-5 phút để GitLab khởi động hoàn toàn, sau đó thử lại.

### GitLab không chạy
```
❌ GitLab không chạy
```

**Giải pháp**: 
```bash
./scripts/gitlab.sh --start
```

### Lỗi tạo user
Nếu có lỗi khi tạo user, script sẽ thử phương pháp khác (tạo với namespace).

## Cấu Hình Environment Variables

Các biến môi trường trong file `.env`:

```bash
# === CẤU HÌNH GITLAB ===
GITLAB_ROOT_USERNAME=root
GITLAB_ROOT_PASSWORD=Nex!tFlow@2025!
GITLAB_ROOT_EMAIL=nextflow.vn@gmail.com
GITLAB_ROOT_NAME="NextFlow Administrator"
```

## Kiểm Tra Kết Quả

### 1. Truy cập GitLab Web UI
```
URL: http://localhost:8088
Username: root
Password: Nex!tFlow@2025!
```

### 2. Kiểm tra qua script
```bash
./scripts/test-gitlab-root-user.sh --users
```

### 3. Kiểm tra trực tiếp trong container
```bash
docker exec gitlab gitlab-rails runner "
user = User.find_by(username: 'root')
puts user ? 'User root tồn tại' : 'User root không tồn tại'
"
```

## Troubleshooting

### 1. Không đăng nhập được
- Kiểm tra GitLab đã khởi động hoàn toàn chưa
- Thử tạo lại user root: `./scripts/gitlab.sh --create-root`
- Kiểm tra logs: `./scripts/gitlab.sh --logs`

### 2. Mật khẩu không đúng
- Chạy lại script tạo user root để cập nhật mật khẩu
- Kiểm tra biến môi trường `GITLAB_ROOT_PASSWORD` trong `.env`

### 3. GitLab không khởi động
- Kiểm tra logs: `./scripts/gitlab.sh --logs --follow`
- Khởi động lại: `./scripts/gitlab.sh --restart`
- Kiểm tra PostgreSQL và Redis: `./scripts/gitlab.sh --status`

## Lưu Ý Quan Trọng

1. **Thời gian khởi động**: GitLab cần 3-5 phút để khởi động hoàn toàn
2. **Health check**: Chỉ tạo user root khi GitLab có trạng thái "healthy"
3. **Mật khẩu mạnh**: `Nex!tFlow@2025!` đã được thiết kế để đảm bảo bảo mật
4. **Backup**: User root có quyền admin, có thể tạo backup và quản lý toàn bộ hệ thống
5. **Shared infrastructure**: GitLab sử dụng PostgreSQL và Redis chung với các service khác

## Tích Hợp với CI/CD

User root có thể được sử dụng để:
- Tạo projects và repositories
- Cấu hình CI/CD pipelines
- Quản lý Container Registry
- Thiết lập webhooks và integrations

## Bảo Mật

- Mật khẩu được lưu trong environment variables
- User root có quyền admin đầy đủ
- Nên thay đổi mật khẩu sau lần đăng nhập đầu tiên trong môi trường production
- Có thể tạo thêm users khác với quyền hạn thấp hơn cho các mục đích cụ thể

---

**Tác giả**: NextFlow Team  
**Phiên bản**: 1.0  
**Cập nhật**: 2025-06-16
