class Contract < ActiveRecord::Base
  belongs_to :entity
  belongs_to :mode
  belongs_to :status
  belongs_to :region
  belongs_to :regulation

  validates :origin_id, uniqueness: true

  monetize :contracted_amount_cents, with_model_currency: :contracted_amount_currency, :allow_nil => true

end
