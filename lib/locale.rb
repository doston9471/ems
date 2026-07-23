# frozen_string_literal: true

# Single source of truth for UI locales. Keep in sync with config/locales/*.yml
module Locale
  AVAILABLE = %w[en es ru uz ky].freeze

  LABELS = {
    "en" => "EN",
    "es" => "ES",
    "ru" => "RU",
    "uz" => "UZ",
    "ky" => "KY"
  }.freeze

  module_function

  def available
    AVAILABLE
  end

  def available_symbols
    AVAILABLE.map(&:to_sym)
  end

  def valid?(locale)
    AVAILABLE.include?(locale.to_s)
  end

  def label_for(locale)
    LABELS.fetch(locale.to_s, locale.to_s.upcase)
  end
end
