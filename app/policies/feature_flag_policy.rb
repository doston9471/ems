# frozen_string_literal: true

class FeatureFlagPolicy < ApplicationPolicy
  def index?
    allowed?("feature_flags.manage")
  end

  def update?
    allowed?("feature_flags.manage")
  end
end
