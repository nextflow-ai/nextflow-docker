# ============================================================================
# SCRIPT TẠO TÀI KHOẢN ROOT GITLAB
# ============================================================================
# Mục đích: Tạo tài khoản quản trị viên (root) cho GitLab
# Sử dụng: gitlab-rails runner /path/to/create_root_user.rb
# Biến môi trường:
#   GITLAB_ROOT_PASSWORD - Mật khẩu root (mặc định: Nex!tFlow@2025!)
#   GITLAB_ROOT_EMAIL - Email root (mặc định: nextflow.vn@gmail.com)
# ============================================================================

puts "Đang tạo tài khoản root..."

# Kiểm tra xem tài khoản root đã tồn tại chưa
existing_user = User.find_by(username: 'root')
if existing_user
  puts "✓ Tài khoản root đã tồn tại:"
  puts "  Tên đăng nhập: #{existing_user.username}"
  puts "  Email: #{existing_user.email}"
  puts "  Quyền quản trị: #{existing_user.admin ? 'Có' : 'Không'}"
  exit 0
end

# Lấy mật khẩu và email từ biến môi trường hoặc dùng giá trị mặc định
password = ENV['GITLAB_ROOT_PASSWORD'] || 'Nex!tFlow@2025!'
email = ENV['GITLAB_ROOT_EMAIL'] || 'nextflow.vn@gmail.com'

puts "Tạo tài khoản root với email: #{email}"

# Tạo namespace : không gian tên cho user trước
namespace = Namespace.new(
  name: 'root',
  path: 'root'
)

if namespace.save
  puts "✓ Đã tạo namespace: #{namespace.path}"
else
  puts "✗ Lỗi tạo namespace:"
  namespace.errors.full_messages.each { |msg| puts "  - #{msg}" }
  exit 1
end

# Tạo tài khoản root mới
begin
  user = User.create!(
    username: 'root',
    email: email,
    name: 'Administrator',
    password: password,
    password_confirmation: password,
    admin: true,
    confirmed_at: Time.current,
    namespace: namespace,
    skip_confirmation: true
  )

  # Cập nhật chủ sở hữu namespace
  namespace.update!(owner: user)

  puts "✓ Tạo tài khoản root thành công!"
  puts "  Tên đăng nhập: #{user.username}"
  puts "  Email: #{user.email}"
  puts "  Quyền quản trị: #{user.admin ? 'Có' : 'Không'}"
  puts "  Namespace: #{user.namespace.path}"

rescue ActiveRecord::RecordInvalid => e
  puts "✗ Lỗi tạo tài khoản:"
  e.record.errors.full_messages.each { |msg| puts "  - #{msg}" }
  exit 1
end
