require 'test_helper'

class ContractsControllerTest < ActionController::TestCase
  setup do
    @contract = contracts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contracts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contract" do
    assert_difference('Contract.count') do
      post :create, contract: { abandonment_date: @contract.abandonment_date, aclaration_date: @contract.aclaration_date, contact: @contract.contact, contracted_amount_cents: @contract.contracted_amount_cents, contracted_amount_currency: @contract.contracted_amount_currency, control_number: @contract.control_number, description: @contract.description, entity_id: @contract.entity_id, granted_date: @contract.granted_date, mode_id: @contract.mode_id, origin_id: @contract.origin_id, presentation_date: @contract.presentation_date, publication_date: @contract.publication_date, publication_number: @contract.publication_number, region_id: @contract.region_id, regulation_id: @contract.regulation_id, specification_price: @contract.specification_price, status_id: @contract.status_id, warranty: @contract.warranty }
    end

    assert_redirected_to contract_path(assigns(:contract))
  end

  test "should show contract" do
    get :show, id: @contract
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contract
    assert_response :success
  end

  test "should update contract" do
    patch :update, id: @contract, contract: { abandonment_date: @contract.abandonment_date, aclaration_date: @contract.aclaration_date, contact: @contract.contact, contracted_amount_cents: @contract.contracted_amount_cents, contracted_amount_currency: @contract.contracted_amount_currency, control_number: @contract.control_number, description: @contract.description, entity_id: @contract.entity_id, granted_date: @contract.granted_date, mode_id: @contract.mode_id, origin_id: @contract.origin_id, presentation_date: @contract.presentation_date, publication_date: @contract.publication_date, publication_number: @contract.publication_number, region_id: @contract.region_id, regulation_id: @contract.regulation_id, specification_price: @contract.specification_price, status_id: @contract.status_id, warranty: @contract.warranty }
    assert_redirected_to contract_path(assigns(:contract))
  end

  test "should destroy contract" do
    assert_difference('Contract.count', -1) do
      delete :destroy, id: @contract
    end

    assert_redirected_to contracts_path
  end
end
