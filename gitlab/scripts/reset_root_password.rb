# Reset root user password
# Usage: gitlab-rails runner /path/to/reset_root_password.rb

puts "Resetting root user password..."

# Find root user
user = User.find_by(username: 'root')
unless user
  puts "Error: Root user not found!"
  exit 1
end

# Get new password from environment or use default
new_password = ENV['GITLAB_ROOT_PASSWORD'] || 'Nex!tFlow@2025!'

puts "Found root user: #{user.email}"

# Update password
begin
  user.password = new_password
  user.password_confirmation = new_password
  user.save!
  
  puts "Root password reset successfully!"
  puts "  Username: #{user.username}"
  puts "  Email: #{user.email}"
  puts "  New password: #{new_password}"
  
rescue => e
  puts "Failed to reset password:"
  puts "  Error: #{e.message}"
  exit 1
end
