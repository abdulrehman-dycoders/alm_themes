defmodule AlmosquePortalThemesWeb.WhiteIqamahOnly do
  use AlmosquePortalThemesWeb, :live_view

  @iqamah_data [
    %{name: "fajr", image: "/images/sunrise-morning-svgrepo-com.svg", times: ["06:00 AM"]},
    %{name: "zuhr", image: "/images/sun-svgrepo-com.svg", times: ["12:00 PM"]},
    %{name: "asr", image: "/images/sun-cloudy-svgrepo-com.svg", times: ["03:00 PM"]},
    %{name: "maghrib", image: "/images/sunset-4-svgrepo-com.svg", times: ["06:00 PM"]},
    %{name: "isha", image: "/images/moon-stars-svgrepo-com.svg", times: ["07:00 PM"]},
    %{name: "jumu'ah I/II", image: "/images/sun-svgrepo-com (1).svg", times: ["12:00 PM", "01:00 PM"]}
  ]

  @timer_interval 1000 # Update every second

  @impl true
  def mount(_, _session, socket) do
    if connected?(socket) do
      # Start timer when client connects
      Process.send_after(self(), :tick, @timer_interval)
    end

    socket =
      socket
      |> assign(:iqamah_time, @iqamah_data)
      |> assign_datetime_and_countdown()

    {:ok, socket}
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
    next_prayer_info = get_next_prayer(now, @iqamah_data)

    socket
    |> assign(:current_date, date)
    |> assign(:current_time, time)
    |> assign(:next_prayer, next_prayer_info.name)
    |> assign(:countdown, next_prayer_info.countdown)
  end

  defp get_next_prayer(now, iqamah_data) do
    current_hour = now.hour
    current_minute = now.minute
    current_weekday = Date.day_of_week(now)

    # Convert current time to minutes for easier comparison
    current_time_in_minutes = current_hour * 60 + current_minute

    # Create list of prayer times with their time in minutes
    prayer_times_with_minutes =
      Enum.flat_map(iqamah_data, fn prayer ->
        # Special case for Jumu'ah - only on Friday (day 5)
        if prayer.name =~ "jumu'ah" and current_weekday != 5 do
          []
        else
          Enum.map(prayer.times, fn time_str ->
            # Parse time string like "06:00 AM"
            [time, am_pm] = String.split(time_str, " ")
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
              time: time_str,
              minutes_from_midnight: minutes_from_midnight
            }
          end)
        end
      end)

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
        next_prayer.minutes_from_midnight + (24 * 60) - current_time_in_minutes
      else
        next_prayer.minutes_from_midnight - current_time_in_minutes
      end

    hours = div(minutes_until_prayer, 60)
    minutes = rem(minutes_until_prayer, 60)

    countdown = "#{String.pad_leading("#{hours}", 2, "0")}:#{String.pad_leading("#{minutes}", 2, "0")}"

    %{
      name: next_prayer.name,
      time: next_prayer.time,
      countdown: countdown
    }
  end
end
