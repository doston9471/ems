# frozen_string_literal: true

company = Seeds.acme
employees = Seeds.employees

ActsAsTenant.with_tenant(company) do
  today = Date.current
  sample_people = employees.values_at("E003", "E004", "E005", "E006", "E007")

  sample_people.each_with_index do |employee, index|
    5.times do |offset|
      work_date = today - (offset + 1).days
      next if work_date.saturday? || work_date.sunday?

      day = AttendanceDay.find_or_initialize_by(company: company, employee: employee, work_date: work_date)
      clock_in = Time.zone.parse("#{work_date} 09:0#{index % 3}:00")
      clock_out = Time.zone.parse("#{work_date} 17:3#{index % 4}:00")
      day.assign_attributes(
        clock_in_at: clock_in,
        clock_out_at: clock_out,
        worked_minutes: ((clock_out - clock_in) / 60).to_i - 60,
        break_minutes: 60,
        overtime_minutes: index.even? ? 30 : 0,
        status: "complete",
        notes: offset.zero? ? "Seeded complete day" : nil
      )
      day.save!

      [
        [ "clock_in", clock_in ],
        [ "break_start", clock_in + 3.hours ],
        [ "break_end", clock_in + 4.hours ],
        [ "clock_out", clock_out ]
      ].each do |kind, occurred_at|
        AttendanceEvent.find_or_create_by!(
          company: company,
          employee: employee,
          attendance_day: day,
          kind: kind,
          occurred_at: occurred_at
        ) do |event|
          event.source = "web"
          event.metadata = { "seed" => true }
        end
      end
    end
  end

  open_day = AttendanceDay.find_or_initialize_by(
    company: company,
    employee: employees["E005"],
    work_date: today
  )
  open_day.assign_attributes(
    clock_in_at: Time.zone.parse("#{today} 09:12:00"),
    status: "open",
    worked_minutes: 0,
    break_minutes: 0,
    overtime_minutes: 0,
    notes: "Currently clocked in (seed)"
  )
  open_day.save!
  AttendanceEvent.find_or_create_by!(
    company: company,
    employee: employees["E005"],
    attendance_day: open_day,
    kind: "clock_in",
    occurred_at: open_day.clock_in_at
  ) do |event|
    event.source = "web"
    event.metadata = { "late" => true, "seed" => true }
  end

  missing = AttendanceDay.find_or_initialize_by(
    company: company,
    employee: employees["E006"],
    work_date: today - 3.days
  )
  missing.assign_attributes(
    clock_in_at: Time.zone.parse("#{missing.work_date} 09:00:00"),
    status: "missing_clock_out",
    worked_minutes: 0,
    notes: "Forgot to clock out"
  )
  missing.save!
  AttendanceEvent.find_or_create_by!(
    company: company,
    employee: employees["E006"],
    attendance_day: missing,
    kind: "clock_in",
    occurred_at: missing.clock_in_at
  ) { |e| e.source = "web" }
end
