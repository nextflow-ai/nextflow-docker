# ============================================================================
# SCRIPT KIỂM TRA TRẠNG THÁI GITLAB
# ============================================================================
# Mục đích: Kiểm tra tình trạng hoạt động và thông tin chi tiết của GitLab
# Sử dụng: gitlab-rails runner /path/to/gitlab_status.rb
# ============================================================================

puts "=" * 60
puts "BÁO CÁO TRẠNG THÁI GITLAB - NEXTFLOW CRM-AI"
puts "=" * 60

# 1. Thông tin cơ sở dữ liệu
puts "\n1. THÔNG TIN CƠ SỞ DỮ LIỆU:"
begin
  db_name = ActiveRecord::Base.connection.current_database
  puts "  ✓ Đã kết nối database: #{db_name}"
rescue => e
  puts "  ✗ Lỗi kết nối database: #{e.message}"
end

# 2. Thông tin người dùng
puts "\n2. THÔNG TIN NGƯỜI DÙNG:"
begin
  total_users = User.count
  admin_users = User.where(admin: true).count
  active_users = User.where(state: 'active').count

  puts "  Tổng số người dùng: #{total_users}"
  puts "  Số quản trị viên: #{admin_users}"
  puts "  Người dùng đang hoạt động: #{active_users}"

  # Danh sách quản trị viên
  if admin_users > 0
    puts "  Danh sách quản trị viên:"
    User.where(admin: true).each do |user|
      puts "    - #{user.username} (#{user.email})"
    end
  end
rescue => e
  puts "  ✗ Lỗi lấy thông tin người dùng: #{e.message}"
end

# 3. Thông tin dự án
puts "\n3. THÔNG TIN DỰ ÁN:"
begin
  total_projects = Project.count
  public_projects = Project.where(visibility_level: 20).count
  private_projects = Project.where(visibility_level: 0).count

  puts "  Tổng số dự án: #{total_projects}"
  puts "  Dự án công khai: #{public_projects}"
  puts "  Dự án riêng tư: #{private_projects}"
rescue => e
  puts "  ✗ Lỗi lấy thông tin dự án: #{e.message}"
end

# 4. Phiên bản GitLab
puts "\n4. PHIÊN BẢN GITLAB:"
begin
  puts "  Phiên bản GitLab: #{Gitlab::VERSION}"
  puts "  Revision GitLab: #{Gitlab::REVISION}"
rescue => e
  puts "  ✗ Lỗi lấy thông tin phiên bản: #{e.message}"
end

# 5. Cài đặt ứng dụng
puts "\n5. CÀI ĐẶT ỨNG DỤNG:"
begin
  settings = ApplicationSetting.current
  puts "  Cho phép đăng ký: #{settings.signup_enabled? ? 'Có' : 'Không'}"
  puts "  Bảo vệ nhánh mặc định: #{settings.default_branch_protection}"
  puts "  Kích thước file tối đa: #{settings.max_attachment_size} MB"
rescue => e
  puts "  ✗ Lỗi lấy cài đặt: #{e.message}"
end

puts "\n" + "=" * 60
puts "KẾT THÚC BÁO CÁO"
puts "=" * 60
