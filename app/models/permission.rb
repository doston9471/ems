# frozen_string_literal: true

class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  validates :key, :name, :category, presence: true
  validates :key, uniqueness: true, format: { with: /\A[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*\z/ }
end
