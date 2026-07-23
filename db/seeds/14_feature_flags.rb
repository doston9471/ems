# frozen_string_literal: true

[
  [ nil, "dark_mode", "Enable dark mode toggle", true ],
  [ nil, "org_chart", "Enable org chart UI", true ],
  [ nil, "performance_module", "Enable performance module", true ],
  [ Seeds.acme.id, "recruitment_beta", "Acme-only recruitment UI experiments", true ],
  [ Seeds.acme.id, "sms_notifications", "Send SMS notifications", false ]
].each do |company_id, key, description, enabled|
  flag = FeatureFlag.find_or_initialize_by(company_id: company_id, key: key)
  flag.description = description
  flag.enabled = enabled
  flag.save!
end
