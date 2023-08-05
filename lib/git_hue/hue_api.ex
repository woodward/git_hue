defmodule GitHue.HueAPI do
  @moduledoc false

  def connect_to_hue_bridge(hue_bridge_ip_address, hue_unique_identifier, hue_light_name) do
    with {:ok, bridge} <- discover_hue_bridge(hue_bridge_ip_address),
         {:ok, bridge} <- authenticate_with_bridge(bridge, hue_unique_identifier),
         {:ok, light_id, light_info} <- find_hue_light(bridge, hue_light_name) do
      {:ok, bridge, light_id, light_info}
    else
      error -> error
    end
  end

  def discover_hue_bridge(nil = _hue_ip_address) do
    case HueSDK.Discovery.discover(HueSDK.Discovery.NUPNP) do
      {:nupnp, []} -> {:error, :no_bridges_found}
      {:nupnp, [bridge]} -> {:ok, bridge}
    end
  end

  def discover_hue_bridge(hue_ip_address) do
    {:manual_ip, [bridge]} = HueSDK.Discovery.discover(HueSDK.Discovery.ManualIP, ip_address: hue_ip_address)
    {:ok, bridge}
  end

  def authenticate_with_bridge(bridge, hue_unique_identifier) do
    case HueSDK.Bridge.authenticate(bridge, hue_unique_identifier) do
      %HueSDK.Bridge{username: nil} -> {:error, :unable_to_authenticate}
      %HueSDK.Bridge{} = bridge -> {:ok, bridge}
    end
  end

  def find_hue_light(bridge, hue_light_name) do
    {:ok, lights} = HueSDK.API.Lights.get_all_lights(bridge)

    case find_light_by_name(lights, hue_light_name) do
      nil -> {:error, :unable_to_locate_light}
      {light_id, light_info} -> {:ok, light_id, light_info}
    end
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

  def set_color(_bridge, _light_id, :unchanged), do: :ok

  def find_light_by_name(lights, name) do
    Enum.find(lights, fn {_, light_data} -> light_data["name"] == name end)
  end
end
