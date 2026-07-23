# frozen_string_literal: true

class JwtService
  ALGORITHM = "HS256"

  def self.encode(payload, exp: 24.hours.from_now)
    data = payload.dup
    data[:exp] = exp.to_i
    JWT.encode(data, secret, ALGORITHM)
  end

  def self.decode(token)
    body, = JWT.decode(token, secret, true, algorithm: ALGORITHM)
    ActiveSupport::HashWithIndifferentAccess.new(body)
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def self.secret
    Rails.application.secret_key_base
  end
  private_class_method :secret
end
