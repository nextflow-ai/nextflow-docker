# ============================================================================
# SCRIPT KIỂM TRA TÀI KHOẢN ROOT GITLAB
# ============================================================================
# Mục đích: Kiểm tra xem tài khoản quản trị viên (root) đã tồn tại chưa
# Sử dụng: gitlab-rails runner /path/to/check_root_user.rb
# ============================================================================

puts "Đang kiểm tra tài khoản root..."

# Tìm kiếm user có username là 'root' trong database
user = User.find_by(username: 'root')

if user
  puts "✓ Tìm thấy tài khoản root:"
  puts "  Tên đăng nhập: #{user.username}"
  puts "  Email: #{user.email}"
  puts "  Quyền quản trị: #{user.admin ? 'Có' : 'Không'}"
  puts "  Trạng thái: #{user.state}"
  puts "  Ngày tạo: #{user.created_at}"
else
  puts "✗ Không tìm thấy tài khoản root"
  puts "  Cần tạo tài khoản root để đăng nhập GitLab"
end
