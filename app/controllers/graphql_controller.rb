# frozen_string_literal: true

class GraphqlController < ActionController::Base
  include ActionController::Cookies

  protect_from_forgery with: :null_session

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    result = EmployeeManagementSystemSchema.execute(
      query,
      variables: variables,
      context: graphql_context,
      operation_name: operation_name
    )
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?

    handle_error_in_development(e)
  end

  private

  def graphql_context
    authenticate_for_graphql!

    {
      current_user: Current.user,
      current_company: Current.company,
      current_membership: Current.membership,
      current_employee: Current.employee,
      request: request
    }
  end

  def authenticate_for_graphql!
    if bearer_token.present?
      authenticate_jwt!
    else
      authenticate_session!
    end

    set_tenant_from_user! if Current.user
  end

  def authenticate_session!
    session_record = Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    Current.session = session_record if session_record
  end

  def authenticate_jwt!
    payload = JwtService.decode(bearer_token)
    user = User.find_by(id: payload&.dig("user_id") || payload&.dig(:user_id))
    return unless user

    Current.session = user.sessions.order(created_at: :desc).first ||
                      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip)
  end

  def set_tenant_from_user!
    company_id = request.headers["X-Company-Id"].presence || params[:company_id].presence
    scope = Current.user.memberships.active.includes(:company, role: :permissions)
    membership = company_id ? scope.find_by(company_id: company_id) : scope.order(:id).first
    membership ||= scope.order(:id).first
    return unless membership

    Current.membership = membership
    Current.company = membership.company
    Current.employee = Employee.find_by(company_id: membership.company_id, user_id: Current.user.id)
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    header.start_with?("Bearer ") ? header.split(" ", 2).last : nil
  end

  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_h
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(error)
    logger.error error.message
    logger.error error.backtrace.join("\n")

    render json: { errors: [ { message: error.message, backtrace: error.backtrace } ], data: {} }, status: :internal_server_error
  end
end
