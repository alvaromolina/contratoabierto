class Company < ActiveRecord::Base

	has_many :applying_companies
	has_many :contracted_companies

end
