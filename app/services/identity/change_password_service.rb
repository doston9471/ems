# frozen_string_literal: true

module Identity
  class ChangePasswordService < ApplicationService
    HISTORY_LIMIT = 5

    def initialize(user:, password:, password_confirmation:)
      @user = user
      @password = password
      @password_confirmation = password_confirmation
    end

    def call
      return failure("User is required") if @user.blank?
      return failure("Password is required") if @password.blank?
      return failure("Passwords did not match") if @password != @password_confirmation
      return failure("Password is too short (minimum is 8 characters)") if @password.length < 8
      return failure("Password was used recently. Choose a different password.") if recently_used?

      previous_digest = @user.password_digest

      ActiveRecord::Base.transaction do
        @user.update!(password: @password, password_confirmation: @password_confirmation)
        record_history!(previous_digest) if previous_digest.present?
        prune_history!
      end

      success(@user.reload)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    def recently_used?
      digests = []
      digests << @user.password_digest if @user.password_digest.present?
      digests.concat(
        @user.password_histories.order(created_at: :desc).limit(HISTORY_LIMIT).pluck(:password_digest)
      )

      digests.uniq.any? do |digest|
        BCrypt::Password.new(digest) == @password
      rescue BCrypt::Errors::InvalidHash
        false
      end
    end

    def record_history!(digest)
      @user.password_histories.create!(password_digest: digest, created_at: Time.current)
    end

    def prune_history!
      keep_ids = @user.password_histories.order(created_at: :desc).limit(HISTORY_LIMIT).pluck(:id)
      @user.password_histories.where.not(id: keep_ids).delete_all if keep_ids.any?
    end
  end
end
