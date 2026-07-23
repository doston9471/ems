# frozen_string_literal: true

class InterviewsController < ApplicationController
  before_action :require_company!
  before_action :set_applicant

  def create
    @interview = @applicant.interviews.new(interview_params)
    authorize @interview

    if @interview.save
      CalendarSyncJob.perform_later(
        event_key: "interview.scheduled",
        company_id: Current.company.id,
        interview_id: @interview.id
      )
      redirect_to applicant_path(@applicant), notice: "Interview scheduled."
    else
      redirect_to applicant_path(@applicant), alert: @interview.errors.full_messages.to_sentence
    end
  end

  private

  def set_applicant
    @applicant = policy_scope(Applicant).find(params[:applicant_id])
  end

  def interview_params
    params.require(:interview).permit(:interviewer_id, :scheduled_at, :mode, :status, :feedback)
  end
end
