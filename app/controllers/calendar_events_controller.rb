# frozen_string_literal: true

class CalendarEventsController < ApplicationController
  before_action :require_company!

  def index
    authorize CalendarEvent
    @events = policy_scope(CalendarEvent).recent.limit(100)
  end
end
