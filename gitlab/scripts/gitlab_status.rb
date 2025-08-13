# Check GitLab status and information
# Usage: gitlab-rails runner /path/to/gitlab_status.rb

puts "=" * 50
puts "GITLAB STATUS REPORT"
puts "=" * 50

# 1. Database information
puts "\n1. DATABASE INFORMATION:"
begin
  db_name = ActiveRecord::Base.connection.current_database
  puts "  ✓ Connected to database: #{db_name}"
rescue => e
  puts "  ✗ Database connection error: #{e.message}"
end

# 2. Users information
puts "\n2. USERS INFORMATION:"
begin
  total_users = User.count
  admin_users = User.where(admin: true).count
  active_users = User.where(state: 'active').count
  
  puts "  Total users: #{total_users}"
  puts "  Admin users: #{admin_users}"
  puts "  Active users: #{active_users}"
  
  # List admin users
  if admin_users > 0
    puts "  Admin users list:"
    User.where(admin: true).each do |user|
      puts "    - #{user.username} (#{user.email})"
    end
  end
rescue => e
  puts "  ✗ Error getting user info: #{e.message}"
end

# 3. Projects information
puts "\n3. PROJECTS INFORMATION:"
begin
  total_projects = Project.count
  public_projects = Project.where(visibility_level: 20).count
  private_projects = Project.where(visibility_level: 0).count
  
  puts "  Total projects: #{total_projects}"
  puts "  Public projects: #{public_projects}"
  puts "  Private projects: #{private_projects}"
rescue => e
  puts "  ✗ Error getting project info: #{e.message}"
end

# 4. GitLab version
puts "\n4. GITLAB VERSION:"
begin
  puts "  GitLab version: #{Gitlab::VERSION}"
  puts "  GitLab revision: #{Gitlab::REVISION}"
rescue => e
  puts "  ✗ Error getting version info: #{e.message}"
end

# 5. Application settings
puts "\n5. APPLICATION SETTINGS:"
begin
  settings = ApplicationSetting.current
  puts "  Sign-up enabled: #{settings.signup_enabled?}"
  puts "  Default branch protection: #{settings.default_branch_protection}"
  puts "  Max attachment size: #{settings.max_attachment_size} MB"
rescue => e
  puts "  ✗ Error getting settings: #{e.message}"
end

puts "\n" + "=" * 50
puts "END OF REPORT"
puts "=" * 50
