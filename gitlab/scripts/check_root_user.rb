# Check root user
user = User.find_by(username: 'root')
if user
  puts "Root user found:"
  puts "Username: #{user.username}"
  puts "Email: #{user.email}"
  puts "Admin: #{user.admin}"
else
  puts "Root user not found"
end
