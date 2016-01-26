class Contract < ActiveRecord::Base
  belongs_to :entity
  belongs_to :mode
  belongs_to :status
  belongs_to :region
  belongs_to :regulation
  has_many :contract_forms
  has_many :contract_documents
  has_many :contracted_companies
  has_many :applying_companies
  has_many :contract_budget_items

  validates :origin_id, uniqueness: true

  monetize :contracted_amount_cents, with_model_currency: :contracted_amount_currency, :allow_nil => true

end
