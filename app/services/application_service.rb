# frozen_string_literal: true

class ApplicationService
  Result = Struct.new(:success, :value, :errors, keyword_init: true) do
    def success?
      success
    end

    def failure?
      !success
    end
  end

  def self.call(...)
    new(...).call
  end

  private

  def success(value = nil)
    Result.new(success: true, value: value, errors: [])
  end

  def failure(errors)
    Result.new(success: false, value: nil, errors: Array(errors))
  end
end
