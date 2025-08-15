# ============================================================================
# SCRIPT ĐẶT LẠI MẬT KHẨU ROOT GITLAB
# ============================================================================
# Mục đích: Đặt lại mật khẩu cho tài khoản quản trị viên (root)
# Sử dụng: gitlab-rails runner /path/to/reset_root_password.rb
# Biến môi trường:
#   GITLAB_ROOT_PASSWORD - Mật khẩu mới (mặc định: Nex!tFlow@2025!)
# ============================================================================

puts "Đang đặt lại mật khẩu tài khoản root..."

# Tìm kiếm tài khoản root trong database
user = User.find_by(username: 'root')
unless user
  puts "✗ Lỗi: Không tìm thấy tài khoản root!"
  exit 1
end

# Lấy mật khẩu mới từ biến môi trường hoặc dùng giá trị mặc định
new_password = ENV['GITLAB_ROOT_PASSWORD'] || 'Nex!tFlow@2025!'

puts "✓ Tìm thấy tài khoản root: #{user.email}"

# Cập nhật mật khẩu mới
begin
  user.password = new_password
  user.password_confirmation = new_password
  user.save!

  puts "✓ Đặt lại mật khẩu root thành công!"
  puts "  Tên đăng nhập: #{user.username}"
  puts "  Email: #{user.email}"
  puts "  Mật khẩu mới: #{new_password}"

rescue => e
  puts "✗ Lỗi khi đặt lại mật khẩu:"
  puts "  Chi tiết lỗi: #{e.message}"
  exit 1
end
