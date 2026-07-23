# frozen_string_literal: true

class DepartmentSerializer
  include JSONAPI::Serializer

  attributes :name, :code, :active, :parent_id
end
