# frozen_string_literal: true

module CustomFields
  class SyncValuesService < ApplicationService
    def initialize(record:, values:)
      @record = record
      @values = values.to_h
    end

    def call
      definitions = CustomFieldDefinition.where(
        company_id: @record.company_id,
        resource_type: @record.class.name
      )

      definitions.find_each do |definition|
        raw = @values[definition.id.to_s] || @values[definition.id]
        next if raw.nil? && !@values.key?(definition.id.to_s) && !@values.key?(definition.id)

        value = @record.custom_field_values.find_or_initialize_by(custom_field_definition: definition)
        value.value = raw.to_s
        value.save!
      end

      success(@record)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end
  end
end
