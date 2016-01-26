class ContractBudgetItemsController < ApplicationController
  before_action :set_contract_budget_item, only: [:show, :edit, :update, :destroy]

  # GET /contract_budget_items
  # GET /contract_budget_items.json
  def index
    @contract_budget_items = ContractBudgetItem.all
  end

  # GET /contract_budget_items/1
  # GET /contract_budget_items/1.json
  def show
  end

  # GET /contract_budget_items/new
  def new
    @contract_budget_item = ContractBudgetItem.new
  end

  # GET /contract_budget_items/1/edit
  def edit
    
  end

  # POST /contract_budget_items
  # POST /contract_budget_items.json
  def create
    @contract_budget_item = ContractBudgetItem.new(contract_budget_item_params)

    respond_to do |format|
      if @contract_budget_item.save
        format.html { redirect_to @contract_budget_item, notice: 'Contract budget item was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contract_budget_item }
      else
        format.html { render action: 'new' }
        format.json { render json: @contract_budget_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contract_budget_items/1
  # PATCH/PUT /contract_budget_items/1.json
  def update
    respond_to do |format|
      if @contract_budget_item.update(contract_budget_item_params)
        format.html { redirect_to @contract_budget_item, notice: 'Contract budget item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contract_budget_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contract_budget_items/1
  # DELETE /contract_budget_items/1.json
  def destroy
    @contract_budget_item.destroy
    respond_to do |format|
      format.html { redirect_to contract_budget_items_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract_budget_item
      @contract_budget_item = ContractBudgetItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contract_budget_item_params
      params.require(:contract_budget_item).permit(:contract_id, :budget_item_id, :description, :contract_number, :unit_price, :quantity_type, :quntity, :total, :origin)
    end
end
