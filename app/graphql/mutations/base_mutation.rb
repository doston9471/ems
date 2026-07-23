# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    private

    def current_user
      context[:current_user]
    end

    def current_company
      context[:current_company]
    end

    def current_employee
      context[:current_employee]
    end

    def current_membership
      context[:current_membership]
    end

    def require_authentication!
      raise GraphQL::ExecutionError, "Authentication required" unless current_user
      raise GraphQL::ExecutionError, "No active company membership" unless current_company
    end

    def require_employee!
      require_authentication!
      raise GraphQL::ExecutionError, "No employee profile linked to your account" unless current_employee
    end
  end
end
