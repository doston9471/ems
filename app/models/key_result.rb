# frozen_string_literal: true

class KeyResult < ApplicationRecord
  belongs_to :okr

  validates :title, presence: true
  validates :target_value, :current_value, numericality: true
end
