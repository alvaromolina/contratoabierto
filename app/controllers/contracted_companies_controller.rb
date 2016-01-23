class ContractedCompaniesController < ApplicationController

  def index
    @grid = ContractedCompaniesGrid.new(params[:contracted_companies_grid]) do |scope|
      scope.page(params[:page])
    end
  end

end

