# frozen_string_literal: true

class Office < ApplicationRecord
  include Tenantable
  include Auditable

  has_many :employees, dependent: :nullify

  validates :name, presence: true
  validates :code, uniqueness: { scope: :company_id }, allow_nil: true
end
