# frozen_string_literal: true

class EmployeeManagementSystemSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader

  max_complexity 300
  max_depth 15

  rescue_from(Pundit::NotAuthorizedError) do |_err, _obj, _args, _ctx, _field|
    raise GraphQL::ExecutionError, "Not authorized"
  end

  rescue_from(ActiveRecord::RecordNotFound) do |_err, _obj, _args, _ctx, _field|
    raise GraphQL::ExecutionError, "Record not found"
  end
end
