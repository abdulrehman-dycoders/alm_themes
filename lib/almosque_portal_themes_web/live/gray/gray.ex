defmodule AlmosquePortalThemesWeb.Gray do
  use AlmosquePortalThemesWeb, :live_view

  @iqamah_data [
    %{name: "fajr", start_time: "06:00 AM", adhan_time: "06:30 AM"},
    %{name: "zuhr", start_time: "12:00 PM", adhan_time: "12:30 PM"},
    %{name: "asr", start_time: "03:00 PM", adhan_time: "03:30 PM"},
    %{name: "maghrib", start_time: "06:00 PM", adhan_time: "06:30 PM"},
    %{name: "isha", start_time: "07:00 PM", adhan_time: "07:30 PM"}
  ]

  @jumuah_data [
    %{name: "jumu'ah I", start_time: "12:00 PM", jumuah_time: "01:00 PM"},
    %{name: "jumu'ah II", start_time: "01:00 PM", jumuah_time: "02:00 PM"}
  ]

  # Update every second
  @timer_interval 1000

  @impl true
  def mount(_, _session, socket) do
    if connected?(socket) do
      # Start timer when client connects
      Process.send_after(self(), :tick, @timer_interval)
    end

    socket =
      socket
      |> assign(:iqamah_time, @iqamah_data)
      |> assign(:jumuah_data, @jumuah_data)
      # Default to first Jumu'ah
      |> assign(:active_jumuah, 0)
      |> assign(:active_ads, "https://quran.com/")
      |> assign_datetime_and_countdown()

    {:ok, assign(socket, active_col: "2", iqamah_data: @iqamah_data)}
  end

  @impl true
  def handle_event("select_col", %{"col" => col}, socket) do
    {:noreply, assign(socket, active_col: col)}
  end

  @impl true
  def handle_event("select_jumuah", %{"index" => index}, socket) do
    index = String.to_integer(index)
    {:noreply, assign(socket, active_jumuah: index)}
  end

  @impl true
  def handle_info(:tick, socket) do
    # Schedule the next tick
    Process.send_after(self(), :tick, @timer_interval)

    # Update time and countdown
    {:noreply, assign_datetime_and_countdown(socket)}
  end

  defp assign_datetime_and_countdown(socket) do
    now = DateTime.now!("Etc/UTC")
    date = Calendar.strftime(now, "%A, %B %d, %Y")
    time = Calendar.strftime(now, "%I:%M:%S %p")

    # Find the next prayer time for countdown
    next_prayer_info = get_next_prayer(now, @iqamah_data, @jumuah_data)

    socket
    |> assign(:current_date, date)
    |> assign(:current_time, time)
    |> assign(:next_prayer, next_prayer_info.name)
    |> assign(:countdown, next_prayer_info.countdown)
  end

  defp get_next_prayer(now, iqamah_data, jumuah_data) do
    current_hour = now.hour
    current_minute = now.minute
    current_weekday = Date.day_of_week(now)

    # Convert current time to minutes for easier comparison
    current_time_in_minutes = current_hour * 60 + current_minute

    # Create list of prayer times with their time in minutes
    prayer_times_with_minutes =
      Enum.map(iqamah_data, fn prayer ->
        # Parse time string like "06:00 AM"
        [time, am_pm] = String.split(prayer.start_time, " ")
        [hour_str, minute_str] = String.split(time, ":")

        hour = String.to_integer(hour_str)
        minute = String.to_integer(minute_str)

        # Adjust for AM/PM
        hour =
          case {hour, am_pm} do
            {12, "AM"} -> 0
            {12, "PM"} -> 12
            {h, "AM"} -> h
            {h, "PM"} -> h + 12
          end

        minutes_from_midnight = hour * 60 + minute

        %{
          name: prayer.name,
          time: prayer.start_time,
          minutes_from_midnight: minutes_from_midnight
        }
      end)

    # Add Jumuah times if it's Friday
    prayer_times_with_minutes =
      if current_weekday == 5 do
        jumuah_times =
          Enum.map(jumuah_data, fn prayer ->
            # Parse time string like "12:00 PM"
            [time, am_pm] = String.split(prayer.start_time, " ")
            [hour_str, minute_str] = String.split(time, ":")

            hour = String.to_integer(hour_str)
            minute = String.to_integer(minute_str)

            # Adjust for AM/PM
            hour =
              case {hour, am_pm} do
                {12, "AM"} -> 0
                {12, "PM"} -> 12
                {h, "AM"} -> h
                {h, "PM"} -> h + 12
              end

            minutes_from_midnight = hour * 60 + minute

            %{
              name: prayer.name,
              time: prayer.start_time,
              minutes_from_midnight: minutes_from_midnight
            }
          end)

        prayer_times_with_minutes ++ jumuah_times
      else
        prayer_times_with_minutes
      end

    # Find the next prayer time
    next_prayer =
      Enum.find(prayer_times_with_minutes, fn prayer ->
        prayer.minutes_from_midnight > current_time_in_minutes
      end)

    # If no prayer found today, use the first prayer of tomorrow
    next_prayer = next_prayer || List.first(prayer_times_with_minutes)

    # Calculate countdown
    minutes_until_prayer =
      if next_prayer.minutes_from_midnight <= current_time_in_minutes do
        # If it's tomorrow's prayer, add 24 hours worth of minutes
        next_prayer.minutes_from_midnight + 24 * 60 - current_time_in_minutes
      else
        next_prayer.minutes_from_midnight - current_time_in_minutes
      end

    hours = div(minutes_until_prayer, 60)
    minutes = rem(minutes_until_prayer, 60)

    countdown =
      "#{String.pad_leading("#{hours}", 2, "0")}:#{String.pad_leading("#{minutes}", 2, "0")}"

    %{
      name: next_prayer.name,
      time: next_prayer.time,
      countdown: countdown
    }
  end
end
