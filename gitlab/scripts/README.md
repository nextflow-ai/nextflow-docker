# GitLab Ruby Scripts

Thư mục này chứa các script Ruby để quản lý GitLab.

## Danh sách Scripts

### 1. `check_root_user.rb`
**Mục đích:** Kiểm tra thông tin root user

**Sử dụng:**
```bash
docker exec gitlab gitlab-rails runner /opt/gitlab/embedded/service/gitlab-rails/gitlab/scripts/check_root_user.rb
```

**Output:**
- Thông tin root user (username, email, admin status)
- Thông báo nếu root user không tồn tại

### 2. `create_root_user.rb`
**Mục đích:** Tạo root user mới

**Environment Variables:**
- `GITLAB_ROOT_PASSWORD` - Password cho root user (default: Nex!tFlow@2025!)
- `GITLAB_ROOT_EMAIL` - Email cho root user (default: nextflow.vn@gmail.com)

**Sử dụng:**
```bash
docker exec gitlab bash -c "GITLAB_ROOT_PASSWORD='your_password' GITLAB_ROOT_EMAIL='your_email' gitlab-rails runner /path/to/create_root_user.rb"
```

**Tính năng:**
- Kiểm tra root user đã tồn tại chưa
- Tạo namespace cho root user
- Tạo root user với quyền admin
- Error handling đầy đủ

### 3. `reset_root_password.rb`
**Mục đích:** Reset password cho root user

**Environment Variables:**
- `GITLAB_ROOT_PASSWORD` - Password mới (default: Nex!tFlow@2025!)

**Sử dụng:**
```bash
docker exec gitlab bash -c "GITLAB_ROOT_PASSWORD='new_password' gitlab-rails runner /path/to/reset_root_password.rb"
```

### 4. `gitlab_status.rb`
**Mục đích:** Hiển thị báo cáo trạng thái tổng thể GitLab

**Sử dụng:**
```bash
docker exec gitlab gitlab-rails runner /path/to/gitlab_status.rb
```

**Thông tin hiển thị:**
- Database connection status
- Users information (total, admin, active)
- Projects information (total, public, private)
- GitLab version và revision
- Application settings

## Cách sử dụng với gitlab-manager.sh

Các script này được tích hợp vào `gitlab-manager.sh`:

```bash
# Kiểm tra trạng thái tổng thể
./scripts/gitlab-manager.sh status

# Tạo root user
./scripts/gitlab-manager.sh create-root

# Reset root password (cần cập nhật script)
./scripts/gitlab-manager.sh reset-root
```

## Lưu ý

1. **Permissions:** Các script cần được copy vào container trước khi chạy
2. **Environment:** Sử dụng environment variables để truyền thông tin nhạy cảm
3. **Error Handling:** Tất cả script đều có error handling và exit codes
4. **Cleanup:** Script sẽ tự động xóa file tạm sau khi chạy

## Troubleshooting

### Script không chạy được
```bash
# Kiểm tra file tồn tại
ls -la gitlab/scripts/

# Kiểm tra syntax
docker exec gitlab ruby -c "require '/tmp/script_name.rb'"

# Kiểm tra logs
docker logs gitlab --tail 20
```

### Permission denied
```bash
# Đảm bảo file có quyền đọc
chmod +r gitlab/scripts/*.rb
```

### Database connection error
```bash
# Kiểm tra GitLab container
docker ps | grep gitlab

# Kiểm tra database connection
docker exec gitlab gitlab-rails runner "puts ActiveRecord::Base.connection.current_database"
```
