# frozen_string_literal: true

class EmployeeDocumentsController < ApplicationController
  before_action :require_company!
  before_action :set_employee_document, only: %i[show upload_version]

  def index
    authorize EmployeeDocument
    @employee_documents = policy_scope(EmployeeDocument).includes(:employee).order(updated_at: :desc)
  end

  def show
    authorize @employee_document
    @document_versions = @employee_document.document_versions.includes(:uploaded_by_user).order(version_number: :desc)
  end

  def new
    @employee_document = Current.company.employee_documents.new(doc_type: :other, status: :active)
    authorize @employee_document
    load_form_collections
  end

  def create
    @employee_document = Current.company.employee_documents.new(employee_document_params)
    authorize @employee_document

    if @employee_document.save
      if params.dig(:employee_document, :file).present?
        result = Documents::UploadVersionService.call(
          employee_document: @employee_document,
          uploaded_by_user: Current.user,
          file: params[:employee_document][:file],
          change_note: "Initial upload"
        )
        unless result.success?
          redirect_to @employee_document, alert: "Document created, but file upload failed: #{result.errors.join(', ')}"
          return
        end
      end
      redirect_to @employee_document, notice: "Document created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def upload_version
    authorize @employee_document, :upload_version?

    result = Documents::UploadVersionService.call(
      employee_document: @employee_document,
      uploaded_by_user: Current.user,
      file: params.require(:file),
      change_note: params[:change_note]
    )

    if result.success?
      redirect_to @employee_document, notice: "Version uploaded."
    else
      redirect_to @employee_document, alert: result.errors.join(", ")
    end
  end

  private

  def set_employee_document
    @employee_document = policy_scope(EmployeeDocument).find(params[:id])
  end

  def employee_document_params
    params.require(:employee_document).permit(:employee_id, :doc_type, :title, :status)
  end

  def load_form_collections
    @employees = Employee.kept.order(:last_name, :first_name)
  end
end
