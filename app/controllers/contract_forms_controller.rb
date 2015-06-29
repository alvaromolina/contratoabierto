class ContractFormsController < ApplicationController
  before_action :set_contract_form, only: [:show, :edit, :update, :destroy]

  # GET /contract_forms
  # GET /contract_forms.json
  def index
    @contract_forms = ContractForm.all
  end

  # GET /contract_forms/1
  # GET /contract_forms/1.json
  def show
  end

  # GET /contract_forms/new
  def new
    @contract_form = ContractForm.new
  end

  # GET /contract_forms/1/edit
  def edit
  end

  # POST /contract_forms
  # POST /contract_forms.json
  def create
    @contract_form = ContractForm.new(contract_form_params)

    respond_to do |format|
      if @contract_form.save
        format.html { redirect_to @contract_form, notice: 'Contract form was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contract_form }
      else
        format.html { render action: 'new' }
        format.json { render json: @contract_form.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contract_forms/1
  # PATCH/PUT /contract_forms/1.json
  def update
    respond_to do |format|
      if @contract_form.update(contract_form_params)
        format.html { redirect_to @contract_form, notice: 'Contract form was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contract_form.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contract_forms/1
  # DELETE /contract_forms/1.json
  def destroy
    @contract_form.destroy
    respond_to do |format|
      format.html { redirect_to contract_forms_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract_form
      @contract_form = ContractForm.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contract_form_params
      params.require(:contract_form).permit(:contract_id, :name, :link)
    end
end
