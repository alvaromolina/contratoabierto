class ContractedCompany < ActiveRecord::Base
  belongs_to :contracts
  belongs_to :companies
end
