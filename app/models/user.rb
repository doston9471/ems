# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model
  include Auditable

  has_secure_password validations: false

  has_many :sessions, dependent: :destroy
  has_many :oauth_identities, dependent: :destroy, autosave: true
  has_many :password_histories, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :companies, through: :memberships
  has_many :employees, dependent: :nullify
  has_many :leave_approvals, foreign_key: :approver_id, inverse_of: :approver, dependent: :restrict_with_exception

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :preferred_locale, inclusion: { in: Locale::AVAILABLE, allow_nil: true }
  validate :password_or_oauth_identity

  def full_name
    [ first_name, last_name ].compact_blank.join(" ").presence || email_address
  end

  def email_verified?
    email_verified_at.present?
  end

  def email_verification_token
    signed_id(purpose: :email_verification, expires_in: 2.days)
  end

  NOTIFICATION_PREF_CHANNELS = %w[email slack telegram in_app].freeze

  def notification_channel_enabled?(channel)
    prefs = notification_preferences.is_a?(Hash) ? notification_preferences : {}
    value = prefs[channel.to_s]
    value.nil? ? true : ActiveModel::Type::Boolean.new.cast(value)
  end

  def update_notification_preferences!(attrs)
    merged = NOTIFICATION_PREF_CHANNELS.index_with { |ch| notification_channel_enabled?(ch) }
    attrs.to_h.each do |key, value|
      next unless NOTIFICATION_PREF_CHANNELS.include?(key.to_s)

      merged[key.to_s] = ActiveModel::Type::Boolean.new.cast(value)
    end
    update!(notification_preferences: merged)
  end

  private

  def password_or_oauth_identity
    return if password_digest.present? || password.present? || oauth_identities.any?

    errors.add(:base, "must have a password or linked OAuth identity")
  end
end
