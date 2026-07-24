# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Locale files" do
  def locale_hash(locale)
    dir = Rails.root.join("config/locales/#{locale}")
    files = Dir.glob(dir.join("*.yml")).sort
    raise "No locale files for #{locale} in #{dir}" if files.empty?

    files.each_with_object({}) do |path, memo|
      loaded = YAML.safe_load_file(path)
      raise "Missing root key #{locale} in #{path}" unless loaded.is_a?(Hash) && loaded.key?(locale.to_s)

      memo.deep_merge!(loaded.fetch(locale.to_s))
    end
  end

  def flatten_keys(hash, prefix = nil)
    hash.flat_map do |key, value|
      full = [ prefix, key ].compact.join(".")
      value.is_a?(Hash) ? flatten_keys(value, full) : full
    end
  end

  let(:reference_keys) { flatten_keys(locale_hash(:en)).sort }

  %i[es ru uz ky].each do |locale|
    it "keeps the same translation keys as en for #{locale}" do
      expect(flatten_keys(locale_hash(locale)).sort).to eq(reference_keys)
    end
  end

  it "registers ru, uz, and ky as available locales" do
    expect(Locale.available).to include("ru", "uz", "ky")
    expect(I18n.available_locales).to include(:ru, :uz, :ky)
  end

  it "translates nav.employees for each supported locale" do
    expect(I18n.t("nav.employees", locale: :ru)).to eq("Сотрудники")
    expect(I18n.t("nav.employees", locale: :uz)).to eq("Xodimlar")
    expect(I18n.t("nav.employees", locale: :ky)).to eq("Кызматкерлер")
  end

  it "loads nested locale folders for sessions and my workspace" do
    expect(I18n.t("sessions.title", locale: :en)).to eq("Sign in")
    expect(I18n.t("my.nav.overview", locale: :es)).to eq("Resumen")
    expect(I18n.t("dashboard.present_today", locale: :ru)).to eq("На месте сегодня")
  end
end
