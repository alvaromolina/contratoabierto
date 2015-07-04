require 'test_helper'

class ContractedCompaniesControllerTest < ActionController::TestCase
  setup do
    @contracted__company = contracted__companies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contracted__companies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contracted__company" do
    assert_difference('ContractedCompany.count') do
      post :create, contracted__company: {  }
    end

    assert_redirected_to contracted__company_path(assigns(:contracted__company))
  end

  test "should show contracted__company" do
    get :show, id: @contracted__company
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contracted__company
    assert_response :success
  end

  test "should update contracted__company" do
    patch :update, id: @contracted__company, contracted__company: {  }
    assert_redirected_to contracted__company_path(assigns(:contracted__company))
  end

  test "should destroy contracted__company" do
    assert_difference('ContractedCompany.count', -1) do
      delete :destroy, id: @contracted__company
    end

    assert_redirected_to contracted__companies_path
  end
end
