# frozen_string_literal: true

class CompanyAsset < ApplicationRecord
  include Tenantable
  include Auditable

  has_many :asset_assignments, dependent: :restrict_with_exception
  has_one :current_assignment, -> { where(returned_on: nil) }, class_name: "AssetAssignment", inverse_of: :company_asset

  enum :asset_type, {
    laptop: "laptop",
    keyboard: "keyboard",
    phone: "phone",
    monitor: "monitor",
    chair: "chair",
    badge: "badge",
    other: "other"
  }, validate: true

  enum :status, {
    purchased: "purchased",
    assigned: "assigned",
    returned: "returned",
    lost: "lost",
    damaged: "damaged"
  }, validate: true

  validates :name, presence: true
end
