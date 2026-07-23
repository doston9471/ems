# frozen_string_literal: true

module ApplicationHelper
  def my_nav_class(active)
    base = "rounded-md px-2.5 py-1.5 whitespace-nowrap"
    active ? "#{base} bg-teal-50 text-teal-800" : "#{base} text-slate-600 hover:bg-slate-100"
  end

  def attendance_spark_tone(day)
    return "bg-slate-200" if day.blank?

    case day.status
    when "complete" then "bg-teal-600"
    when "open" then "bg-amber-400"
    when "missing_clock_out" then "bg-rose-500"
    when "absent" then "bg-slate-400"
    else "bg-slate-300"
    end
  end
end
