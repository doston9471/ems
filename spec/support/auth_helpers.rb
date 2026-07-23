# frozen_string_literal: true

module AuthHelpers
  def sign_in(user, password: "Password1!")
    post session_path, params: { email_address: user.email_address, password: password }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
