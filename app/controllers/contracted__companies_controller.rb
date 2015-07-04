class ContractedCompaniesController < ApplicationController
  before_action :set_contracted__company, only: [:show, :edit, :update, :destroy]

  # GET /contracted__companies
  # GET /contracted__companies.json
  def index
    @contracted__companies = ContractedCompany.all.first(50000)
  end

  # GET /contracted__companies/1
  # GET /contracted__companies/1.json
  def show
  end

  # GET /contracted__companies/new
  def new
    @contracted__company = ContractedCompany.new
  end

  # GET /contracted__companies/1/edit
  def edit
  end

  # POST /contracted__companies
  # POST /contracted__companies.json
  def create
    @contracted__company = ContractedCompany.new(contracted__company_params)

    respond_to do |format|
      if @contracted__company.save
        format.html { redirect_to @contracted__company, notice: 'Contracted  company was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contracted__company }
      else
        format.html { render action: 'new' }
        format.json { render json: @contracted__company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contracted__companies/1
  # PATCH/PUT /contracted__companies/1.json
  def update
    respond_to do |format|
      if @contracted__company.update(contracted__company_params)
        format.html { redirect_to @contracted__company, notice: 'Contracted  company was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contracted__company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contracted__companies/1
  # DELETE /contracted__companies/1.json
  def destroy
    @contracted__company.destroy
    respond_to do |format|
      format.html { redirect_to contracted__companies_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contracted__company
      @contracted__company = ContractedCompany.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contracted__company_params
      params[:contracted__company]
    end
end
