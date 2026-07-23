# frozen_string_literal: true

class OrgChartQuery
  Node = Struct.new(:employee, :children, keyword_init: true)

  def initialize(company:)
    @company = company
  end

  def call
    employees = @company.employees.kept
      .where(employment_status: %w[active on_leave probation])
      .includes(:department)
      .order(:last_name, :first_name)
      .to_a

    by_manager = employees.group_by(&:manager_id)
    roots = by_manager[nil].to_a + employees.select { |e| e.manager_id.present? && employees.none? { |m| m.id == e.manager_id } }.uniq
    roots = roots.uniq

    roots.map { |root| build_node(root, by_manager) }
  end

  private

  def build_node(employee, by_manager)
    children = by_manager[employee.id].to_a.map { |child| build_node(child, by_manager) }
    Node.new(employee: employee, children: children)
  end
end
