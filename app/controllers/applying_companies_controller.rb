class ApplyingCompaniesController < ApplicationController
  before_action :set_applying_company, only: [:show, :edit, :update, :destroy]

  # GET /applying_companies
  # GET /applying_companies.json
  def index
    @applying_companies = ApplyingCompany.all.first(50000)
  end

  # GET /applying_companies/1
  # GET /applying_companies/1.json
  def show
  end

  # GET /applying_companies/new
  def new
    @applying_company = ApplyingCompany.new
  end

  # GET /applying_companies/1/edit
  def edit
  end

  # POST /applying_companies
  # POST /applying_companies.json
  def create
    @applying_company = ApplyingCompany.new(applying_company_params)

    respond_to do |format|
      if @applying_company.save
        format.html { redirect_to @applying_company, notice: 'Applying company was successfully created.' }
        format.json { render action: 'show', status: :created, location: @applying_company }
      else
        format.html { render action: 'new' }
        format.json { render json: @applying_company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /applying_companies/1
  # PATCH/PUT /applying_companies/1.json
  def update
    respond_to do |format|
      if @applying_company.update(applying_company_params)
        format.html { redirect_to @applying_company, notice: 'Applying company was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @applying_company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /applying_companies/1
  # DELETE /applying_companies/1.json
  def destroy
    @applying_company.destroy
    respond_to do |format|
      format.html { redirect_to applying_companies_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_applying_company
      @applying_company = ApplyingCompany.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def applying_company_params
      params[:applying_company]
    end
end
