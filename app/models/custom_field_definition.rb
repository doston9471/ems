# frozen_string_literal: true

class CustomFieldDefinition < ApplicationRecord
  include Tenantable

  FIELD_TYPES = %w[text number date boolean select].freeze

  has_many :custom_field_values, dependent: :destroy

  validates :key, :label, :resource_type, :field_type, presence: true
  validates :key, uniqueness: { scope: [ :company_id, :resource_type ] },
                  format: { with: /\A[a-z][a-z0-9_]*\z/, message: "must be snake_case" }
  validates :field_type, inclusion: { in: FIELD_TYPES }
  validates :resource_type, inclusion: { in: %w[Employee] }
end
