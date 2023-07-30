defmodule GitHue.Hue do
  @moduledoc false

  def get_bridge do
    # {:manual_ip, [bridge]} = HueSDK.Discovery.discover(HueSDK.Discovery.ManualIP, ip_address: "10.0.1.16")
    {:nupnp, [bridge]} = HueSDK.Discovery.discover(HueSDK.Discovery.NUPNP)
    HueSDK.Bridge.authenticate(bridge, git_hue_unique_identifier())
  end

  def set_color(bridge, light_id, :green) do
    HueSDK.API.Lights.set_light_state(bridge, light_id, %{on: true, hue: 27306, sat: 254, bri: 254})
  end

  def set_color(bridge, light_id, :red) do
    HueSDK.API.Lights.set_light_state(bridge, light_id, %{on: true, hue: 0, sat: 254, bri: 254})
  end

  def set_color(bridge, light_id, :yellow) do
    # HueSDK.API.Lights.set_light_state(bridge, light_id, %{on: true, hue: 10761, sat: 254, bri: 254, effect: "colorloop"})
    HueSDK.API.Lights.set_light_state(bridge, light_id, %{on: true, hue: 10761, sat: 254, bri: 254, alert: "lselect"})
    # HueSDK.API.Lights.set_light_state(bridge, light_id, %{on: true, hue: 10761, sat: 254, bri: 254})
  end

  defp git_hue_unique_identifier do
    Application.get_env(:git_hue, :unique_identifier)
  end
end
