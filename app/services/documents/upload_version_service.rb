# frozen_string_literal: true

module Documents
  class UploadVersionService < ApplicationService
    def initialize(employee_document:, uploaded_by_user:, file:, change_note: nil)
      @employee_document = employee_document
      @uploaded_by_user = uploaded_by_user
      @file = file
      @change_note = change_note
    end

    def call
      return failure("A file is required") if @file.blank?

      version = nil
      ActiveRecord::Base.transaction do
        next_number = (@employee_document.document_versions.maximum(:version_number) || 0) + 1
        version = @employee_document.document_versions.build(
          version_number: next_number,
          uploaded_by_user: @uploaded_by_user,
          change_note: @change_note
        )
        version.file.attach(@file)
        version.save!
      end

      success(version)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end
  end
end
