# frozen_string_literal: true

module GraphqlHelpers
  def graphql_post(query, headers: {}, variables: {})
    post "/graphql",
         params: { query: query, variables: variables }.compact,
         headers: headers.merge("CONTENT_TYPE" => "application/json"),
         as: :json
  end

  def graphql_json
    JSON.parse(response.body)
  end

  def bearer_headers_for(user, company:)
    token = JwtService.encode({ user_id: user.id })
    {
      "Authorization" => "Bearer #{token}",
      "X-Company-Id" => company.id.to_s
    }
  end
end

RSpec.configure do |config|
  config.include GraphqlHelpers, type: :request
end
