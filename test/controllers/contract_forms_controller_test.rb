require 'test_helper'

class ContractFormsControllerTest < ActionController::TestCase
  setup do
    @contract_form = contract_forms(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contract_forms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contract_form" do
    assert_difference('ContractForm.count') do
      post :create, contract_form: { contract_id: @contract_form.contract_id, link: @contract_form.link, name: @contract_form.name }
    end

    assert_redirected_to contract_form_path(assigns(:contract_form))
  end

  test "should show contract_form" do
    get :show, id: @contract_form
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contract_form
    assert_response :success
  end

  test "should update contract_form" do
    patch :update, id: @contract_form, contract_form: { contract_id: @contract_form.contract_id, link: @contract_form.link, name: @contract_form.name }
    assert_redirected_to contract_form_path(assigns(:contract_form))
  end

  test "should destroy contract_form" do
    assert_difference('ContractForm.count', -1) do
      delete :destroy, id: @contract_form
    end

    assert_redirected_to contract_forms_path
  end
end
