class MotivesController < ApplicationController
  before_action :set_motive, only: [:show, :edit, :update, :destroy]

  # GET /motives
  # GET /motives.json
  def index
    @motives = Motive.all
  end

  # GET /motives/1
  # GET /motives/1.json
  def show
  end

  # GET /motives/new
  def new
    @motive = Motive.new
  end

  # GET /motives/1/edit
  def edit
  end

  # POST /motives
  # POST /motives.json
  def create
    @motive = Motive.new(motive_params)

    respond_to do |format|
      if @motive.save
        format.html { redirect_to @motive, notice: 'Motive was successfully created.' }
        format.json { render action: 'show', status: :created, location: @motive }
      else
        format.html { render action: 'new' }
        format.json { render json: @motive.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /motives/1
  # PATCH/PUT /motives/1.json
  def update
    respond_to do |format|
      if @motive.update(motive_params)
        format.html { redirect_to @motive, notice: 'Motive was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @motive.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /motives/1
  # DELETE /motives/1.json
  def destroy
    @motive.destroy
    respond_to do |format|
      format.html { redirect_to motives_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_motive
      @motive = Motive.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def motive_params
      params.require(:motive).permit(:name)
    end
end
