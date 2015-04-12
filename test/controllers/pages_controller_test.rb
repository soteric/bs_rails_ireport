require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get backlog" do
    get :backlog
    assert_response :success
  end

  test "should get defect" do
    get :defect
    assert_response :success
  end

  test "should get support" do
    get :support
    assert_response :success
  end

end
