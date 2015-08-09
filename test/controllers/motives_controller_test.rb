require 'test_helper'

class MotivesControllerTest < ActionController::TestCase
  setup do
    @motive = motives(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:motives)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create motive" do
    assert_difference('Motive.count') do
      post :create, motive: { name: @motive.name }
    end

    assert_redirected_to motive_path(assigns(:motive))
  end

  test "should show motive" do
    get :show, id: @motive
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @motive
    assert_response :success
  end

  test "should update motive" do
    patch :update, id: @motive, motive: { name: @motive.name }
    assert_redirected_to motive_path(assigns(:motive))
  end

  test "should destroy motive" do
    assert_difference('Motive.count', -1) do
      delete :destroy, id: @motive
    end

    assert_redirected_to motives_path
  end
end
