require 'test_helper'

class ContractDocumentsControllerTest < ActionController::TestCase
  setup do
    @contract_document = contract_documents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contract_documents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contract_document" do
    assert_difference('ContractDocument.count') do
      post :create, contract_document: { contract_id: @contract_document.contract_id, link: @contract_document.link, name: @contract_document.name }
    end

    assert_redirected_to contract_document_path(assigns(:contract_document))
  end

  test "should show contract_document" do
    get :show, id: @contract_document
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contract_document
    assert_response :success
  end

  test "should update contract_document" do
    patch :update, id: @contract_document, contract_document: { contract_id: @contract_document.contract_id, link: @contract_document.link, name: @contract_document.name }
    assert_redirected_to contract_document_path(assigns(:contract_document))
  end

  test "should destroy contract_document" do
    assert_difference('ContractDocument.count', -1) do
      delete :destroy, id: @contract_document
    end

    assert_redirected_to contract_documents_path
  end
end
