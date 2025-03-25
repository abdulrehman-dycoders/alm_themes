defmodule AlmosquePortalThemesWeb.Hard.WhiteIqamahOnly do
  use AlmosquePortalThemesWeb, :live_view

  # Static data - no dynamic calculations
  @iqamah_data [
    %{name: "fajr", image: "/images/sunrise-morning-svgrepo-com.svg", times: ["06:00 AM"]},
    %{name: "zuhr", image: "/images/sun-svgrepo-com.svg", times: ["12:00 PM"]},
    %{name: "asr", image: "/images/sun-cloudy-svgrepo-com.svg", times: ["03:00 PM"]},
    %{name: "maghrib", image: "/images/sunset-4-svgrepo-com.svg", times: ["06:00 PM"]},
    %{name: "isha", image: "/images/moon-stars-svgrepo-com.svg", times: ["07:00 PM"]},
    %{
      name: "jumu'ah I/II",
      image: "/images/sun-svgrepo-com (1).svg",
      times: ["12:00 PM", "01:00 PM"]
    }
  ]

  # Hardcoded values
  @date "Friday, October 11, 2024"
  @time "03:45 PM"
  @next_prayer "asr"
  @countdown "00:15"

  @impl true
  def mount(_, _session, socket) do
    socket =
      socket
      |> assign(:iqamah_time, @iqamah_data)
      |> assign(:current_date, @date)
      |> assign(:current_time, @time)
      |> assign(:next_prayer, @next_prayer)
      |> assign(:countdown, @countdown)

    {:ok, socket}
  end
end
