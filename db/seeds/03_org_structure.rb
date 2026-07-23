# frozen_string_literal: true

company = Seeds.acme

ActsAsTenant.with_tenant(company) do
  hq = Office.find_or_initialize_by(company: company, code: "HQ")
  hq.assign_attributes(
    name: "San Francisco HQ",
    address_line1: "100 Market St",
    city: "San Francisco",
    state: "CA",
    postal_code: "94105",
    country: "US",
    timezone: "America/Los_Angeles",
    active: true
  )
  hq.save!

  remote = Office.find_or_initialize_by(company: company, code: "REMOTE")
  remote.assign_attributes(
    name: "Remote Hub",
    city: "Austin",
    state: "TX",
    country: "US",
    timezone: "America/Chicago",
    active: true
  )
  remote.save!

  engineering = Department.find_or_initialize_by(company: company, code: "ENG")
  engineering.assign_attributes(name: "Engineering", active: true, parent: nil)
  engineering.save!

  people = Department.find_or_initialize_by(company: company, code: "PEOPLE")
  people.assign_attributes(name: "People Ops", active: true, parent: nil)
  people.save!

  product = Department.find_or_initialize_by(company: company, code: "PRODUCT")
  product.assign_attributes(name: "Product", active: true, parent: nil)
  product.save!

  children = {
    "BACKEND" => [ "Backend", engineering ],
    "FRONTEND" => [ "Frontend", engineering ],
    "QA" => [ "QA", engineering ],
    "DESIGN" => [ "Design", product ]
  }

  child_depts = children.to_h do |code, (name, parent)|
    dept = Department.find_or_initialize_by(company: company, code: code)
    dept.assign_attributes(name: name, parent: parent, active: true)
    dept.save!
    [ code.downcase.to_sym, dept ]
  end

  Seeds.offices = { hq: hq, remote: remote }
  Seeds.departments = {
    engineering: engineering,
    people: people,
    product: product
  }.merge(child_depts)
end

ActsAsTenant.with_tenant(Seeds.globex) do
  Office.find_or_create_by!(company: Seeds.globex, code: "LON") do |o|
    o.name = "London Office"
    o.city = "London"
    o.country = "GB"
    o.timezone = "Europe/London"
    o.active = true
  end

  Department.find_or_create_by!(company: Seeds.globex, code: "OPS") do |d|
    d.name = "Operations"
    d.active = true
  end
end
