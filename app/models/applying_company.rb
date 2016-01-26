class ApplyingCompany < ActiveRecord::Base
  belongs_to :contract
  belongs_to :company
end
