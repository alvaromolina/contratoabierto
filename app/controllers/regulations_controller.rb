class RegulationsController < ApplicationController
  before_action :set_regulation, only: [:show, :edit, :update, :destroy]

  # GET /regulations
  # GET /regulations.json
  def index
    @regulations = Regulation.all
  end

  # GET /regulations/1
  # GET /regulations/1.json
  def show
  end

  # GET /regulations/new
  def new
    @regulation = Regulation.new
  end

  # GET /regulations/1/edit
  def edit
  end

  # POST /regulations
  # POST /regulations.json
  def create
    @regulation = Regulation.new(regulation_params)

    respond_to do |format|
      if @regulation.save
        format.html { redirect_to @regulation, notice: 'Regulation was successfully created.' }
        format.json { render action: 'show', status: :created, location: @regulation }
      else
        format.html { render action: 'new' }
        format.json { render json: @regulation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /regulations/1
  # PATCH/PUT /regulations/1.json
  def update
    respond_to do |format|
      if @regulation.update(regulation_params)
        format.html { redirect_to @regulation, notice: 'Regulation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @regulation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /regulations/1
  # DELETE /regulations/1.json
  def destroy
    @regulation.destroy
    respond_to do |format|
      format.html { redirect_to regulations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_regulation
      @regulation = Regulation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def regulation_params
      params.require(:regulation).permit(:name)
    end
end
