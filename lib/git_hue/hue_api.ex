defmodule GitHue.HueAPI do
  @moduledoc false

  def discover_hue_bridge(nil = _hue_ip_address) do
    # case HueSDK.Discovery.discover(HueSDK.Discovery.NUPNP) do
    #   {:nupnp, []} -> {:error, :no_bridges_found}
    #   {:nupnp, [bridge]} -> {:ok, bridge}
    # end

    {:ok,
     %HueSDK.Bridge{
       api_version: "1.59.0",
       bridge_id: "ECB5FAFFFEA11E49",
       datastore_version: "159",
       host: "10.0.1.16",
       mac: "ec:b5:fa:a1:1e:49",
       model_id: "BSB002",
       name: "Philips hue",
       sw_version: "1959097030",
       username: nil
     }}
  end

  def discover_hue_bridge(hue_ip_address) do
    {:manual_ip, [bridge]} = HueSDK.Discovery.discover(HueSDK.Discovery.ManualIP, ip_address: hue_ip_address)
    {:ok, bridge}
  end

  def temp_authenticate(:good) do
    %HueSDK.Bridge{
      api_version: "1.59.0",
      bridge_id: "ECB5FAFFFEA11E49",
      datastore_version: "159",
      host: "10.0.1.16",
      mac: "ec:b5:fa:a1:1e:49",
      model_id: "BSB002",
      name: "Philips hue",
      sw_version: "1959097030",
      username: "KkRnlFmJiMVyLRU-4H2GjdtSQhWsOzYYNBA9VrWS"
    }
  end

  def temp_authenticate(:bad) do
    %HueSDK.Bridge{
      api_version: "1.59.0",
      bridge_id: "ECB5FAFFFEA11E49",
      datastore_version: "159",
      host: "10.0.1.16",
      mac: "ec:b5:fa:a1:1e:49",
      model_id: "BSB002",
      name: "Philips hue",
      sw_version: "1959097030",
      username: nil
    }
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
