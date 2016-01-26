class BudgetItemReportsController < ApplicationController

  def index
    @grid = BudgetItemReportsGrid.new(params[:budget_item_reports_grid]) do |scope|
      scope.page(params[:page])
    end
  end

end

