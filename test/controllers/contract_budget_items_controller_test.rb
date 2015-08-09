require 'test_helper'

class ContractBudgetItemsControllerTest < ActionController::TestCase
  setup do
    @contract_budget_item = contract_budget_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contract_budget_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contract_budget_item" do
    assert_difference('ContractBudgetItem.count') do
      post :create, contract_budget_item: { budget_item_id: @contract_budget_item.budget_item_id, contract_id: @contract_budget_item.contract_id, contract_number: @contract_budget_item.contract_number, description: @contract_budget_item.description, origin: @contract_budget_item.origin, quantity_type: @contract_budget_item.quantity_type, quntity: @contract_budget_item.quntity, total: @contract_budget_item.total, unit_price: @contract_budget_item.unit_price }
    end

    assert_redirected_to contract_budget_item_path(assigns(:contract_budget_item))
  end

  test "should show contract_budget_item" do
    get :show, id: @contract_budget_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contract_budget_item
    assert_response :success
  end

  test "should update contract_budget_item" do
    patch :update, id: @contract_budget_item, contract_budget_item: { budget_item_id: @contract_budget_item.budget_item_id, contract_id: @contract_budget_item.contract_id, contract_number: @contract_budget_item.contract_number, description: @contract_budget_item.description, origin: @contract_budget_item.origin, quantity_type: @contract_budget_item.quantity_type, quntity: @contract_budget_item.quntity, total: @contract_budget_item.total, unit_price: @contract_budget_item.unit_price }
    assert_redirected_to contract_budget_item_path(assigns(:contract_budget_item))
  end

  test "should destroy contract_budget_item" do
    assert_difference('ContractBudgetItem.count', -1) do
      delete :destroy, id: @contract_budget_item
    end

    assert_redirected_to contract_budget_items_path
  end
end
