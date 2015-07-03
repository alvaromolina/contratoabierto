class ApplyingCompany < ActiveRecord::Base
  belongs_to :contracts
  belongs_to :Company
end
