class ContractDocumentsController < ApplicationController
  before_action :set_contract_document, only: [:show, :edit, :update, :destroy]

  # GET /contract_documents
  # GET /contract_documents.json
  def index
    @contract_documents = ContractDocument.all
  end

  # GET /contract_documents/1
  # GET /contract_documents/1.json
  def show
  end

  # GET /contract_documents/new
  def new
    @contract_document = ContractDocument.new
  end

  # GET /contract_documents/1/edit
  def edit
  end

  # POST /contract_documents
  # POST /contract_documents.json
  def create
    @contract_document = ContractDocument.new(contract_document_params)

    respond_to do |format|
      if @contract_document.save
        format.html { redirect_to @contract_document, notice: 'Contract document was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contract_document }
      else
        format.html { render action: 'new' }
        format.json { render json: @contract_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contract_documents/1
  # PATCH/PUT /contract_documents/1.json
  def update
    respond_to do |format|
      if @contract_document.update(contract_document_params)
        format.html { redirect_to @contract_document, notice: 'Contract document was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contract_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contract_documents/1
  # DELETE /contract_documents/1.json
  def destroy
    @contract_document.destroy
    respond_to do |format|
      format.html { redirect_to contract_documents_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contract_document
      @contract_document = ContractDocument.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contract_document_params
      params.require(:contract_document).permit(:contract_id, :name, :link)
    end
end
