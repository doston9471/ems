# frozen_string_literal: true

module Api
  module V1
    module Scim
      class UsersController < BaseController
        skip_before_action :authenticate!
        skip_before_action :set_current_tenant
        skip_after_action :verify_authorized
        before_action :authenticate_scim!
        before_action :set_employee, only: %i[show update destroy]

        def index
          start_index = (params[:startIndex].presence || 1).to_i
          count = (params[:count].presence || 100).to_i
          scope = scim_scope
          employees = scope.order(:id).offset(start_index - 1).limit(count)

          render json: {
            schemas: [ "urn:ietf:params:scim:api:messages:2.0:ListResponse" ],
            totalResults: scope.count,
            startIndex: start_index,
            itemsPerPage: employees.size,
            Resources: employees.map { |e| scim_user(e) }
          }
        end

        def show
          render json: scim_user(@employee)
        end

        def create
          attrs = scim_attributes
          employee = Current.company.employees.create!(
            first_name: attrs[:first_name],
            last_name: attrs[:last_name],
            email: attrs[:email],
            employee_number: "S#{SecureRandom.random_number(10_000_000).to_s.rjust(7, '0')}",
            employment_status: :active,
            joining_date: Date.current,
            currency: Current.company.currency,
            salary_cents: 0
          )
          render json: scim_user(employee), status: :created
        rescue ActiveRecord::RecordInvalid => e
          render_scim_error(e.record.errors.full_messages.join(", "), status: :bad_request)
        end

        def update
          if patch_request?
            apply_patch!(@employee)
          else
            attrs = scim_attributes
            @employee.update!(
              first_name: attrs[:first_name],
              last_name: attrs[:last_name],
              email: attrs[:email]
            )
            apply_active_flag!(@employee) if params.key?(:active) || params.key?("active")
          end

          render json: scim_user(@employee.reload)
        rescue ActiveRecord::RecordInvalid => e
          render_scim_error(e.record.errors.full_messages.join(", "), status: :bad_request)
        end

        def destroy
          deactivate!(@employee)
          head :no_content
        end

        private

        def authenticate_scim!
          token = bearer_token
          scim_token = token.present? ? ScimToken.find_by_raw_token(token) : nil
          unless scim_token
            render json: { detail: "Unauthorized", status: "401" }, status: :unauthorized
            return
          end

          scim_token.touch_last_used!
          Current.company = scim_token.company
        end

        def set_employee
          @employee = Current.company.employees.with_discarded.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render_scim_error("User #{params[:id]} not found", status: :not_found)
        end

        def scim_scope
          if ActiveModel::Type::Boolean.new.cast(params[:includeInactive])
            Current.company.employees.with_discarded
          else
            Current.company.employees.kept
          end
        end

        def patch_request?
          request.patch? || params[:schemas].to_s.include?("PatchOp") || params[:Operations].present?
        end

        def apply_patch!(employee)
          Array(params[:Operations] || params[:operations]).each do |operation|
            op = (operation[:op] || operation["op"]).to_s.downcase
            path = (operation[:path] || operation["path"]).to_s
            value = operation[:value] || operation["value"]

            case op
            when "replace", "add"
              if path.blank? && value.is_a?(Hash)
                apply_active_value!(employee, value[:active] || value["active"]) if value.key?(:active) || value.key?("active")
                employee.first_name = value.dig(:name, :givenName) || value.dig("name", "givenName") || employee.first_name
                employee.last_name = value.dig(:name, :familyName) || value.dig("name", "familyName") || employee.last_name
                email = Array(value[:emails] || value["emails"]).first
                employee.email = email.is_a?(Hash) ? (email[:value] || email["value"]) : employee.email
              elsif path.match?(/active/i)
                apply_active_value!(employee, value)
              elsif path.match?(/name\.givenName/i)
                employee.first_name = value
              elsif path.match?(/name\.familyName/i)
                employee.last_name = value
              elsif path.match?(/userName|emails/i)
                employee.email = value.is_a?(Array) ? value.first&.dig("value") || value.first&.dig(:value) : value
              end
            when "remove"
              deactivate!(employee) if path.match?(/active/i)
            end
          end
          employee.save!
        end

        def apply_active_flag!(employee)
          apply_active_value!(employee, params[:active])
          employee.save! if employee.changed?
        end

        def apply_active_value!(employee, value)
          active = ActiveModel::Type::Boolean.new.cast(value)
          if active
            employee.undiscard if employee.discarded?
            employee.employment_status = :active if employee.terminated?
          else
            deactivate!(employee)
          end
        end

        def deactivate!(employee)
          employee.employment_status = :terminated
          employee.discard if employee.respond_to?(:discard) && !employee.discarded?
          employee.save!
        end

        def scim_attributes
          data = params.to_unsafe_h.with_indifferent_access
          name = (data[:name] || {}).with_indifferent_access
          emails = Array(data[:emails])
          first_email = emails.first
          email_value = first_email.is_a?(Hash) ? first_email.with_indifferent_access[:value] : nil

          {
            first_name: name[:givenName].presence || @employee&.first_name || "SCIM",
            last_name: name[:familyName].presence || @employee&.last_name || "User",
            email: email_value.presence || data[:userName].presence || @employee&.email
          }
        end

        def scim_user(employee)
          {
            schemas: [ "urn:ietf:params:scim:schemas:core:2.0:User" ],
            id: employee.id.to_s,
            userName: employee.email,
            name: {
              givenName: employee.first_name,
              familyName: employee.last_name
            },
            emails: [ { value: employee.email, primary: true } ],
            active: !employee.terminated? && employee.kept?,
            meta: {
              resourceType: "User",
              created: employee.created_at.iso8601,
              lastModified: employee.updated_at.iso8601
            }
          }
        end

        def render_scim_error(detail, status:)
          code = Rack::Utils::SYMBOL_TO_STATUS_CODE[status] || status
          render json: {
            schemas: [ "urn:ietf:params:scim:api:messages:2.0:Error" ],
            detail: detail,
            status: code.to_s
          }, status: status
        end
      end
    end
  end
end
