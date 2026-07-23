# frozen_string_literal: true

module Performance
  class AssignReviewsService < ApplicationService
    def initialize(review_cycle:, employee_ids: [], include_self: true, include_manager: true, peer_assignments: [])
      @review_cycle = review_cycle
      @employee_ids = Array(employee_ids).map(&:presence).compact.map(&:to_i).uniq
      @include_self = ActiveModel::Type::Boolean.new.cast(include_self)
      @include_manager = ActiveModel::Type::Boolean.new.cast(include_manager)
      @peer_assignments = Array(peer_assignments)
    end

    def call
      return failure("Review cycle must be open") unless @review_cycle.open?
      return failure("Select at least one employee or peer assignment") if @employee_ids.empty? && @peer_assignments.empty?
      return failure("Choose self and/or manager reviews") if @employee_ids.any? && !@include_self && !@include_manager

      created = []
      warnings = []

      ActiveRecord::Base.transaction do
        employees.each do |employee|
          if @include_self
            created << create_review!(employee: employee, reviewer: employee, review_type: :self)
          end

          next unless @include_manager

          if employee.manager.blank?
            warnings << "#{employee.full_name} has no manager"
            next
          end

          created << create_review!(employee: employee, reviewer: employee.manager, review_type: :manager)
        end

        @peer_assignments.each do |assignment|
          employee_id = assignment[:employee_id] || assignment["employee_id"]
          reviewer_id = assignment[:reviewer_id] || assignment["reviewer_id"]
          next if employee_id.blank? || reviewer_id.blank?

          employee = employees_by_id.fetch(employee_id.to_i) do
            raise ActiveRecord::RecordNotFound, "Employee #{employee_id} not found"
          end
          reviewer = employees_by_id.fetch(reviewer_id.to_i) do
            raise ActiveRecord::RecordNotFound, "Reviewer #{reviewer_id} not found"
          end

          if employee.id == reviewer.id
            warnings << "#{employee.full_name} cannot peer-review themselves"
            next
          end

          created << create_review!(employee: employee, reviewer: reviewer, review_type: :peer_360)
        end
      end

      success({ reviews: created.compact, warnings: warnings })
    rescue ActiveRecord::RecordNotFound => e
      failure(e.message)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    rescue ActiveRecord::RecordNotUnique
      failure("A matching review assignment already exists")
    end

    private

    def employees
      @employees ||= @review_cycle.company.employees.kept.where(id: @employee_ids).includes(:manager).to_a
    end

    def employees_by_id
      @employees_by_id ||= begin
        ids = @employee_ids + @peer_assignments.flat_map { |a| [ a[:employee_id] || a["employee_id"], a[:reviewer_id] || a["reviewer_id"] ] }
        @review_cycle.company.employees.kept.where(id: ids.map(&:to_i)).index_by(&:id)
      end
    end

    def create_review!(employee:, reviewer:, review_type:)
      existing = @review_cycle.performance_reviews.find_by(
        employee_id: employee.id,
        reviewer_id: reviewer.id,
        review_type: review_type
      )
      return if existing

      @review_cycle.performance_reviews.create!(
        company: @review_cycle.company,
        employee: employee,
        reviewer: reviewer,
        review_type: review_type,
        status: :pending
      )
    end
  end
end
