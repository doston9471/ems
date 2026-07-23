# frozen_string_literal: true

class FeatureFlag < ApplicationRecord
  belongs_to :company, optional: true

  validates :key, presence: true, uniqueness: { scope: :company_id }

  def self.enabled?(key, company: nil)
    return false unless table_exists?

    company_id = company&.id || Current.company&.id
    flag = find_by(company_id: company_id, key: key.to_s) if company_id
    flag ||= find_by(company_id: nil, key: key.to_s)
    flag&.enabled? || false
  rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError
    false
  end

  def self.enable!(key, company: nil, description: nil)
    flag = find_or_initialize_by(company_id: company&.id, key: key.to_s)
    flag.description = description if description.present?
    flag.enabled = true
    flag.save!
    flag
  end
end
