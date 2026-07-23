# frozen_string_literal: true

company = Seeds.acme
depts = Seeds.departments
employees = Seeds.employees

ActsAsTenant.with_tenant(company) do
  applicants = [
    {
      email: "nina@candidates.example", first_name: "Nina", last_name: "Applicant",
      stage: "applied", job_title: "Backend Engineer", department: depts[:backend],
      phone: "+1-415-555-0201", notes: "Referral from Eddie"
    },
    {
      email: "omar@candidates.example", first_name: "Omar", last_name: "Interview",
      stage: "interview", job_title: "Frontend Engineer", department: depts[:frontend],
      phone: "+1-415-555-0202", notes: "Strong portfolio"
    },
    {
      email: "priya@candidates.example", first_name: "Priya", last_name: "Offer",
      stage: "offer", job_title: "QA Engineer", department: depts[:qa],
      phone: "+1-415-555-0203", notes: "Offer sent"
    },
    {
      email: "rico@candidates.example", first_name: "Rico", last_name: "Rejected",
      stage: "rejected", job_title: "Product Designer", department: depts[:design],
      notes: "Role filled"
    },
    {
      email: "hired@candidates.example", first_name: "Harper", last_name: "Hired",
      stage: "hired", job_title: "Backend Engineer", department: depts[:backend],
      hired_employee: employees["E005"], notes: "Converted in prior cycle (demo link)"
    }
  ]

  created = applicants.map do |attrs|
    applicant = Applicant.find_or_initialize_by(company: company, email: attrs[:email])
    applicant.assign_attributes(attrs)
    applicant.save!
    applicant
  end

  interview_candidate = created.find { |a| a.email == "omar@candidates.example" }
  Interview.find_or_create_by!(applicant: interview_candidate, scheduled_at: 2.days.from_now.change(hour: 15)) do |interview|
    interview.interviewer = employees["E003"]
    interview.mode = "video"
    interview.status = "scheduled"
    interview.feedback = nil
  end

  offer_candidate = created.find { |a| a.email == "priya@candidates.example" }
  Interview.find_or_create_by!(applicant: offer_candidate, scheduled_at: 5.days.ago.change(hour: 11)) do |interview|
    interview.interviewer = employees["E007"]
    interview.mode = "in_person"
    interview.status = "completed"
    interview.feedback = "Excellent test design instincts."
  end
end
