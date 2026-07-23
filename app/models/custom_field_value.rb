# frozen_string_literal: true

class CustomFieldValue < ApplicationRecord
  belongs_to :custom_field_definition
  belongs_to :record, polymorphic: true

  validates :custom_field_definition_id, uniqueness: { scope: [ :record_type, :record_id ] }
  validate :definition_matches_record_company

  private

  def definition_matches_record_company
    return if custom_field_definition.blank? || record.blank?
    return unless record.respond_to?(:company_id)
    return if custom_field_definition.company_id == record.company_id

    errors.add(:base, "custom field must belong to the same company as the record")
  end
end
