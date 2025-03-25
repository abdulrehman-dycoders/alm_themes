defmodule AlmosquePortalThemesWeb.Hard.Gray do
  use AlmosquePortalThemesWeb, :live_view

  # Static data - no dynamic calculations
  @iqamah_data [
    %{
      name: "fajr",
      image: "/images/sunrise-morning-svgrepo-com.svg",
      start_time: "06:00 AM",
      adhan_time: "06:30 AM"
    },
    %{
      name: "zuhr",
      image: "/images/sun-svgrepo-com.svg",
      start_time: "12:00 PM",
      adhan_time: "12:30 PM"
    },
    %{
      name: "asr",
      image: "/images/sun-cloudy-svgrepo-com.svg",
      start_time: "03:00 PM",
      adhan_time: "03:30 PM"
    },
    %{
      name: "maghrib",
      image: "/images/sunset-4-svgrepo-com.svg",
      start_time: "06:00 PM",
      adhan_time: "06:30 PM"
    },
    %{
      name: "isha",
      image: "/images/moon-stars-svgrepo-com.svg",
      start_time: "07:00 PM",
      adhan_time: "07:30 PM"
    }
  ]

  @jumuah_data [
    %{
      name: "jumu'ah I",
      image: "/images/sun-svgrepo-com (1).svg",
      start_time: "12:00 PM",
      jumuah_time: "01:00 PM"
    },
    %{
      name: "jumu'ah II",
      image: "/images/sun-svgrepo-com (1).svg",
      start_time: "01:00 PM",
      jumuah_time: "02:00 PM"
    }
  ]

  # Hardcoded values
  @date "Friday, October 11, 2024"
  @time "03:45 PM"
  @next_prayer "asr"
  @countdown "00:15"
  @ads "https://quran.com/"
  @active_col "2"  # Index 2 corresponds to "asr"

  @impl true
  def mount(_, _session, socket) do
    socket =
      socket
      |> assign(:iqamah_data, @iqamah_data)
      |> assign(:jumuah_data, @jumuah_data)
      # Default to first Jumu'ah
      |> assign(:active_jumuah, 0)
      |> assign(:current_date, @date)
      |> assign(:current_time, @time)
      |> assign(:next_prayer, @next_prayer)
      |> assign(:countdown, @countdown)
      |> assign(:active_ads, @ads)
      |> assign(:active_col, @active_col)  # Explicitly set active column to "asr" (index 2)

    {:ok, socket}
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
end
