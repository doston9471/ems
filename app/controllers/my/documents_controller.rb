# frozen_string_literal: true

module My
  class DocumentsController < BaseController
    skip_after_action :verify_authorized
    before_action :set_document, only: :show

    def index
      @documents = Current.employee.employee_documents.includes(:document_versions).order(updated_at: :desc)
    end

    def show
    end

    private

    def set_document
      @document = Current.employee.employee_documents.includes(:document_versions).find(params[:id])
    end
  end
end
