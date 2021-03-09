require 'test_helper'

class ChangeEmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get change_emails_new_url
    assert_response :success
  end

  test "should get create" do
    get change_emails_create_url
    assert_response :success
  end

end
