# frozen_string_literal: true

# Registers domain event listeners on boot.
Rails.application.config.to_prepare do
  EventBus.reset!
  EventBus.subscribe(Leave::ApprovedEvent, LeaveApprovedListener)
  EventBus.subscribe(Employees::HiredEvent, EmployeeHiredListener)
end
