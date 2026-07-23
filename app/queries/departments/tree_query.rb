# frozen_string_literal: true

module Departments
  class TreeQuery
    Node = Struct.new(:department, :children, keyword_init: true)

    def initialize(scope: Department.all)
      @scope = scope
    end

    def call
      departments = @scope.includes(:children).order(:name).to_a
      by_parent = departments.group_by(&:parent_id)

      build_nodes(by_parent[nil] || [], by_parent)
    end

    private

    def build_nodes(list, by_parent)
      list.map do |department|
        Node.new(
          department: department,
          children: build_nodes(by_parent[department.id] || [], by_parent)
        )
      end
    end
  end
end
