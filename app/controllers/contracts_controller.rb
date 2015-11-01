class ContractsController < ApplicationController
  before_action :set_contract, only: [:show, :edit, :update, :destroy]
  autocomplete :entity, :name, :full => true


  def subscriptions


  end

  def home

    @objeto = ""
    first = request.fullpath.split("?")[0]
    @excel_path = "/home.xls"


    if params[:objeto]
      second = request.fullpath.split("?")[1]
      @excel_path = @excel_path+"?"+second


      @contracts = Contract.all

      @status_id = params[:status][:id]
      if params[:status] and params[:status][:id] != ""
        @contracts= @contracts.where('status_id = ?',@status_id)
      end

      if params[:entity] and params[:entity] != ""
        @entity = Entity.where("name like ?", params[:entity].upcase + "%").first
        @contracts= @contracts.where('entity_id = ?',@entity.id)
      end

      if params[:objeto] and params[:objeto] != ""
        @objeto = params[:objeto]
        @contracts= @contracts.where('upper(description) like ?',"%"+params[:objeto].upcase+ "%")
      end


      if params[:motive] and params[:motive][:id] != ""
        @motive_id = params[:motive][:id]
        @contracts= @contracts.where('motive_id = ?', @motive_id)
      end


      @contracts = @contracts.order(:publication_date).paginate(:per_page => 10, :page => params[:page])    
    else
      @status_id = 11
      # @contracts = Contract.where('publication_date >= ?','2015-07-01').paginate(:per_page => 10, :page => params[:page])
      @contracts = Contract.where('status_id = ?',@status_id).order(:publication_date).paginate(:per_page => 10, :page => params[:page])
    end
    respond_to do |format|
      format.html
      #format.csv { send_data @products.to_csv } #
      format.xls
    end
  end

  def about
    
  end

  def mobile

  end


  # GET /contracts
  # GET /contracts.json
  def index
    @contracts = Contract.all.first(50000)
  end

  # GET /contracts/1
  # GET /contracts/1.json
  def show
  end

  # GET /contracts/new
  def new
    @contract = Contract.new
  end

  # GET /contracts/1/edit
  def edit
  end

  # POST /contracts
  # POST /contracts.json
  def create
    @contract = Contract.new(contract_params)
    respond_to do |format|
      if @contract.save
        format.html { redirect_to @contract, notice: 'Contract was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contract }
      else
        format.html { render action: 'new' }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contracts/1
  # PATCH/PUT /contracts/1.json
  def update
    respond_to do |format|
      if @contract.update(contract_params)
        format.html { redirect_to @contract, notice: 'Contract was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contracts/1
  # DELETE /contracts/1.json
  def destroy
    @contract.destroy
    respond_to do |format|
      format.html { redirect_to contracts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract
      @contract = Contract.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contract_params
      params.require(:contract).permit(:origin_id, :entity_id, :mode_id, :control_number, :publication_number, :description, :status_id, :contracted_amount_cents, :contracted_amount_currency, :publication_date, :presentation_date, :contact, :warranty, :specification_price, :aclaration_date, :granted_date, :abandonment_date, :region_id, :regulation_id)
    end
end
