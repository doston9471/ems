# frozen_string_literal: true

# Ensure locales stick after boot (application.rb alone can be missed by a
# long-running process that was started before new locale files existed).
Rails.application.config.to_prepare do
  I18n.available_locales = Locale.available_symbols
  I18n.default_locale = :en
  I18n.fallbacks = [ :en ]
end

I18n.available_locales = Locale.available_symbols
I18n.default_locale = :en
