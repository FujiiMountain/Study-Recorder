def log_in(user)
  visit login_url
  fill_in "メールアドレス", with: user.email
  fill_in "session_password", with: "password1"
  click_on "ログインする"
end
