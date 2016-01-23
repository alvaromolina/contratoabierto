class ContractReportsController < ApplicationController

  def index
    @grid = ContractReportsGrid.new(params[:contract_reports_grid])

	respond_to do |f|
	  f.html do
	    @grid.scope {|scope| scope.page(params[:page]) }
	  end
	  f.csv do
	    send_data @grid.to_csv, 
	      type: "text/csv", 
	      disposition: 'inline', 
	      filename: "grid-#{Time.now.to_s}.csv"
	  end
	end

  end

end

