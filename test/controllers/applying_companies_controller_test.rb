require 'test_helper'

class ApplyingCompaniesControllerTest < ActionController::TestCase
  setup do
    @applying_company = applying_companies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:applying_companies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create applying_company" do
    assert_difference('ApplyingCompany.count') do
      post :create, applying_company: {  }
    end

    assert_redirected_to applying_company_path(assigns(:applying_company))
  end

  test "should show applying_company" do
    get :show, id: @applying_company
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @applying_company
    assert_response :success
  end

  test "should update applying_company" do
    patch :update, id: @applying_company, applying_company: {  }
    assert_redirected_to applying_company_path(assigns(:applying_company))
  end

  test "should destroy applying_company" do
    assert_difference('ApplyingCompany.count', -1) do
      delete :destroy, id: @applying_company
    end

    assert_redirected_to applying_companies_path
  end
end
