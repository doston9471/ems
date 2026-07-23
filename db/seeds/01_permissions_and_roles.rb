# frozen_string_literal: true

permission_by_key = Seeds::PERMISSIONS.to_h do |key, name, category|
  [
    key,
    Permission.find_or_create_by!(key: key) do |p|
      p.name = name
      p.category = category
      p.description = name
    end
  ]
end

Seeds::PERMISSIONS.each do |key, name, category|
  permission_by_key[key].update!(name: name, category: category, description: name)
end

all_permissions = permission_by_key.values

Seeds::SYSTEM_ROLES.each do |key, config|
  role = Role.find_or_initialize_by(company_id: nil, key: key)
  role.name = config[:name]
  role.system = true
  role.save!

  desired =
    if config[:permissions] == :all
      all_permissions
    else
      config[:permissions].map { |k| permission_by_key.fetch(k) }
    end
  role.permissions = desired
end
