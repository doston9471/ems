# frozen_string_literal: true

module Recruitment
  class HireApplicantService < ApplicationService
    def initialize(applicant:, attributes: {})
      @applicant = applicant
      @attributes = attributes
    end

    def call
      return failure("Applicant is already hired") if @applicant.hired?
      return failure("Applicant was rejected") if @applicant.rejected?

      employee = nil

      ActiveRecord::Base.transaction do
        employee = @applicant.company.employees.create!(employee_attributes)
        @applicant.update!(stage: :hired, hired_employee: employee)
      end

      Employees::HiredEvent.publish(
        employee_id: employee.id,
        company_id: employee.company_id,
        applicant_id: @applicant.id,
        email: employee.email,
        full_name: employee.full_name
      )

      success(employee)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    end

    private

    def employee_attributes
      {
        first_name: @applicant.first_name,
        last_name: @applicant.last_name,
        email: @applicant.email,
        phone: @applicant.phone,
        job_title: @applicant.job_title,
        department_id: @applicant.department_id,
        employee_number: next_employee_number,
        employment_status: :active,
        joining_date: Date.current,
        currency: @applicant.company.currency
      }.merge(@attributes.symbolize_keys)
    end

    def next_employee_number
      loop do
        number = "H#{SecureRandom.random_number(10_000_000).to_s.rjust(7, '0')}"
        break number unless @applicant.company.employees.exists?(employee_number: number)
      end
    end
  end
end
