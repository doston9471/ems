# frozen_string_literal: true

class PasswordHistory < ApplicationRecord
  self.record_timestamps = false

  belongs_to :user

  validates :password_digest, presence: true
  validates :created_at, presence: true
end
