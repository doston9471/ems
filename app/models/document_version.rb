# frozen_string_literal: true

class DocumentVersion < ApplicationRecord
  belongs_to :employee_document
  belongs_to :uploaded_by_user, class_name: "User"

  has_one_attached :file

  validates :version_number, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :version_number, uniqueness: { scope: :employee_document_id }
  validate :acceptable_file

  private

  def acceptable_file
    return unless file.attached?

    allowed_types = %w[
      application/pdf
      image/jpeg
      image/png
      image/gif
      image/webp
      application/msword
      application/vnd.openxmlformats-officedocument.wordprocessingml.document
    ]

    unless allowed_types.include?(file.content_type)
      errors.add(:file, "must be a PDF, image, or Word document")
    end
  end
end
