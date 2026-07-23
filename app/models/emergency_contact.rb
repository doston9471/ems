# frozen_string_literal: true

class EmergencyContact < ApplicationRecord
  belongs_to :employee

  validates :name, presence: true
end
