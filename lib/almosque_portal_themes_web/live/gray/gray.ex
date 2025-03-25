defmodule AlmosquePortalThemesWeb.Gray do
  use AlmosquePortalThemesWeb, :live_view

  @iqamah_data [
    %{name: "fajr", image: "/images/sunrise-morning-svgrepo-com.svg", start_time: "06:00 AM", adhan_time: "06:30 AM"},
    %{name: "zuhr", image: "/images/sun-svgrepo-com.svg", start_time: "12:00 PM", adhan_time: "12:30 PM"},
    %{name: "asr", image: "/images/sun-cloudy-svgrepo-com.svg", start_time: "03:00 PM", adhan_time: "03:30 PM"},
    %{name: "maghrib", image: "/images/sunset-4-svgrepo-com.svg", start_time: "06:00 PM", adhan_time: "06:30 PM"},
    %{name: "isha", image: "/images/moon-stars-svgrepo-com.svg", start_time: "07:00 PM", adhan_time: "07:30 PM"}
  ]

  @jumuah_data [
    %{name: "jumu'ah I", image: "/images/sun-svgrepo-com (1).svg", start_time: "12:00 PM", jumuah_time: "01:00 PM"},
    %{name: "jumu'ah II", image: "/images/sun-svgrepo-com (1).svg", start_time: "01:00 PM", jumuah_time: "02:00 PM"}
  ]

  # Map prayer names to their index in the table
  @prayer_indices %{
    "fajr" => "0",
    "zuhr" => "1",
    "asr" => "2",
    "maghrib" => "3",
    "isha" => "4",
    "jumu'ah I" => "1",  # Jumu'ah I happens at Zuhr time
    "jumu'ah II" => "1"  # Jumu'ah II also mapped to Zuhr column
  }

  # Update every second
  @timer_interval 1000

  @impl true
  def mount(_, _session, socket) do
    if connected?(socket) do
      # Start timer when client connects
      Process.send_after(self(), :tick, @timer_interval)
    end

    # Set up initial socket state
    socket_with_data =
      socket
      |> assign(:iqamah_data, @iqamah_data)
      |> assign(:jumuah_data, @jumuah_data)
      # Default to first Jumu'ah
      |> assign(:active_jumuah, 0)
      |> assign(:active_ads, "/images/mosque-d5.jpg")
      |> assign_datetime_and_countdown()

    # Get the next prayer from the updated socket
    next_prayer = socket_with_data.assigns.next_prayer
    # Get column index for that prayer (default to "0" if not found)
    active_col = Map.get(@prayer_indices, next_prayer, "0")

    {:ok, assign(socket_with_data, active_col: active_col)}
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
    updated_socket = assign_datetime_and_countdown(socket)

    # Get the next prayer and update active column if needed
    next_prayer = updated_socket.assigns.next_prayer
    active_col = Map.get(@prayer_indices, next_prayer, "0")

    # Only update active_col if it's different to avoid unnecessary re-renders
    if socket.assigns.active_col != active_col do
      {:noreply, assign(updated_socket, active_col: active_col)}
    else
      {:noreply, updated_socket}
    end
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
