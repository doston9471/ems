# frozen_string_literal: true

company = Seeds.acme
users = Seeds.users
employees = Seeds.employees

ActsAsTenant.with_tenant(company) do
  deliveries = [
    [ "email", "leave.approved", "sent", users[:employee], employees["E005"] ],
    [ "slack", "leave.approved", "skipped", users[:manager], employees["E003"] ],
    [ "teams", "employee.hired", "skipped", users[:hr], employees["E002"] ],
    [ "sms", "leave.submitted", "failed", users[:employee], employees["E005"] ],
    [ "telegram", "leave.approved", "skipped", users[:employee], employees["E005"] ],
    [ "in_app", "performance.review_due", "pending", users[:lead], employees["E004"] ]
  ]

  deliveries.each_with_index do |(channel, event_key, status, user, employee), index|
    NotificationDelivery.find_or_create_by!(
      company: company,
      channel: channel,
      event_key: event_key,
      user: user,
      employee: employee,
      status: status
    ) do |delivery|
      delivery.payload = {
        "seed" => true,
        "message" => "Demo #{event_key} via #{channel}",
        "index" => index
      }
      delivery.error_message =
        case status
        when "failed" then "SMS provider not configured"
        when "skipped"
          channel == "telegram" ? "Telegram bot token not configured" : "#{channel} webhook URL not configured"
        end
      delivery.sent_at = (status == "sent" ? 3.hours.ago : nil)
    end
  end
end
