# frozen_string_literal: true

company = Seeds.acme
hq = Seeds.offices.fetch(:hq)
remote = Seeds.offices.fetch(:remote)
depts = Seeds.departments
users = Seeds.users

ActsAsTenant.with_tenant(company) do
  roster = [
    {
      number: "E001", first_name: "Ada", last_name: "Owner", email: "owner@acme.example",
      title: "Chief Executive Officer", dept: depts[:engineering], office: hq, user: users[:owner],
      salary_cents: 220_000_00, gender: "female", birthday: Date.new(1988, 4, 12),
      nationality: "US", phone: "+1-415-555-0101", joining_date: Date.new(2020, 1, 6)
    },
    {
      number: "E002", first_name: "Helen", last_name: "Resources", email: "hr@acme.example",
      title: "HR Director", dept: depts[:people], office: hq, user: users[:hr],
      salary_cents: 140_000_00, gender: "female", birthday: Date.new(1990, 7, 22),
      phone: "+1-415-555-0102", joining_date: Date.new(2021, 2, 1)
    },
    {
      number: "E003", first_name: "Morgan", last_name: "Manager", email: "manager@acme.example",
      title: "Engineering Manager", dept: depts[:engineering], office: hq, user: users[:manager],
      salary_cents: 175_000_00, gender: "non_binary", birthday: Date.new(1987, 11, 3),
      phone: "+1-415-555-0103", joining_date: Date.new(2021, 5, 17)
    },
    {
      number: "E004", first_name: "Taylor", last_name: "Lead", email: "lead@acme.example",
      title: "Backend Team Lead", dept: depts[:backend], office: hq, user: users[:lead],
      salary_cents: 155_000_00, gender: "male", birthday: Date.new(1992, 1, 30),
      phone: "+1-415-555-0104", joining_date: Date.new(2022, 3, 14)
    },
    {
      number: "E005", first_name: "Eddie", last_name: "Employee", email: "employee@acme.example",
      title: "Backend Engineer", dept: depts[:backend], office: remote, user: users[:employee],
      salary_cents: 120_000_00, gender: "male", birthday: Date.new(1995, 9, 8),
      phone: "+1-512-555-0105", joining_date: Date.new(2023, 6, 1)
    },
    {
      number: "E006", first_name: "Fay", last_name: "Frontend", email: "fay@acme.example",
      title: "Frontend Engineer", dept: depts[:frontend], office: hq,
      salary_cents: 118_000_00, gender: "female", birthday: Date.new(1994, 5, 19),
      joining_date: Date.new(2023, 1, 9)
    },
    {
      number: "E007", first_name: "Quinn", last_name: "Tester", email: "quinn@acme.example",
      title: "QA Engineer", dept: depts[:qa], office: remote,
      salary_cents: 105_000_00, gender: "prefer_not_to_say", birthday: Date.new(1993, 12, 1),
      joining_date: Date.new(2022, 9, 12)
    },
    {
      number: "E008", first_name: "Dana", last_name: "Designer", email: "dana@acme.example",
      title: "Product Designer", dept: depts[:design], office: hq,
      salary_cents: 112_000_00, gender: "female", birthday: Date.new(1991, 8, 25),
      joining_date: Date.new(2024, 2, 5)
    },
    {
      number: "E009", first_name: "Sam", last_name: "Intern", email: "sam@acme.example",
      title: "Software Intern", dept: depts[:frontend], office: hq,
      salary_cents: 55_000_00, gender: "other", employment_status: "probation",
      joining_date: Date.new(2026, 1, 12)
    },
    {
      number: "E010", first_name: "Pat", last_name: "Alumni", email: "pat@acme.example",
      title: "Former Engineer", dept: depts[:backend], office: hq,
      salary_cents: 110_000_00, employment_status: "terminated",
      joining_date: Date.new(2021, 4, 1)
    }
  ]

  employees = roster.to_h do |row|
    attrs = row.except(:number, :first_name, :last_name, :email, :title, :dept, :office, :user)
    employee = Seeds.ensure_employee!(
      company: company,
      number: row[:number],
      first_name: row[:first_name],
      last_name: row[:last_name],
      email: row[:email],
      job_title: row[:title],
      department: row[:dept],
      office: row[:office],
      user: row[:user],
      address_line1: "1 Acme Way",
      city: row[:office] == remote ? "Austin" : "San Francisco",
      state: row[:office] == remote ? "TX" : "CA",
      country: "US",
      **attrs
    )
    [ row[:number], employee ]
  end

  ceo = employees["E001"]
  eng_manager = employees["E003"]
  team_lead = employees["E004"]

  employees["E002"].update!(manager: ceo)
  employees["E003"].update!(manager: ceo)
  employees["E004"].update!(manager: eng_manager)
  employees["E005"].update!(manager: team_lead)
  employees["E006"].update!(manager: eng_manager)
  employees["E007"].update!(manager: eng_manager)
  employees["E008"].update!(manager: eng_manager)
  employees["E009"].update!(manager: eng_manager)
  employees["E010"].update!(manager: team_lead)

  platform = Team.find_or_initialize_by(company: company, name: "Platform")
  platform.assign_attributes(department: depts[:engineering], lead_employee: team_lead)
  platform.save!

  design_team = Team.find_or_initialize_by(company: company, name: "Design Systems")
  design_team.assign_attributes(department: depts[:design], lead_employee: employees["E008"])
  design_team.save!

  [ ceo, eng_manager, team_lead, employees["E005"], employees["E006"], employees["E007"] ].each do |member|
    TeamMembership.find_or_create_by!(team: platform, employee: member)
  end
  TeamMembership.find_or_create_by!(team: design_team, employee: employees["E008"])

  {
    "E001" => [ "Alex Owner-Spouse", "Spouse", "+1-415-555-0199" ],
    "E005" => [ "Casey Employee", "Partner", "+1-512-555-0198" ],
    "E003" => [ "Riley Manager", "Sibling", "+1-415-555-0197" ]
  }.each do |number, (name, relationship, phone)|
    EmergencyContact.find_or_create_by!(employee: employees[number], name: name) do |contact|
      contact.relationship = relationship
      contact.phone = phone
      contact.email = "#{name.parameterize}@example.com"
      contact.primary = true
    end
  end

  Seeds.employees = employees
  Seeds.teams = { platform: platform, design: design_team }
end

ActsAsTenant.with_tenant(Seeds.globex) do
  office = Office.find_by!(company: Seeds.globex, code: "LON")
  dept = Department.find_by!(company: Seeds.globex, code: "OPS")
  Seeds.ensure_employee!(
    company: Seeds.globex,
    number: "G001",
    first_name: "Greg",
    last_name: "Globex",
    email: "owner@globex.example",
    job_title: "Managing Director",
    department: dept,
    office: office,
    user: Seeds.users[:globex_owner],
    salary_cents: 150_000_00,
    currency: "GBP",
    joining_date: Date.new(2019, 8, 1)
  )
end
