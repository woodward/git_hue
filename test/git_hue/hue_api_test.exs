defmodule GitHue.HueAPITest do
  @moduledoc false
  use ExUnit.Case
  doctest GitHue

  alias GitHue.HueAPI
  use Patch
  import GitHue.GitHueFixtures

  describe "connect_to_hue_bridge/3" do
    test "returns the bridge, light id, and light_info" do
      patch(HueSDK.Discovery, :discover, fn _type ->
        {:nupnp, [bridge()]}
      end)

      patch(HueSDK.Bridge, :authenticate, fn bridge, _unique_identifier ->
        username = "KkRnlFmJiMVyLRU-4H2GjdtSQhWsOzYYNBA9VrWS"
        Map.put(bridge, :username, username)
      end)

      patch(HueSDK.API.Lights, :get_all_lights, fn _bridge ->
        {:ok, lights()}
      end)

      {:ok, bridge, light_id, light_info} = HueAPI.connect_to_hue_bridge(nil, "hue-identifier#huesdk", "github")

      assert bridge == authenticated_bridge()

      assert light_id == "2"

      assert light_info["state"] == %{
               "alert" => "lselect",
               "bri" => 254,
               "colormode" => "hs",
               "ct" => 153,
               "effect" => "none",
               "hue" => 27306,
               "mode" => "homeautomation",
               "on" => true,
               "reachable" => false,
               "sat" => 254,
               "xy" => [0.1687, 0.6482]
             }
    end

    test "error - no bridges found" do
      patch(HueSDK.Discovery, :discover, fn _type ->
        {:nupnp, []}
      end)

      assert HueAPI.connect_to_hue_bridge(nil, "not-relevant", "not relevant") == {:error, :no_bridges_found}
    end
  end

  describe "discover_hue_bridge" do
    setup do
      expose(HueAPI, discover_hue_bridge: 1)
      :ok
    end

    test "returns when using discovery" do
      patch(HueSDK.Discovery, :discover, fn _type ->
        {:nupnp, [bridge()]}
      end)

      {:ok, bridge} = private(HueAPI.discover_hue_bridge(nil))

      assert bridge == bridge()
    end

    test "no bridges found using discovery" do
      patch(HueSDK.Discovery, :discover, fn _type ->
        {:nupnp, []}
      end)

      assert private(HueAPI.discover_hue_bridge(nil)) == {:error, :no_bridges_found}
    end

    test "returns when using ip address" do
      patch(HueSDK.Discovery, :discover, fn HueSDK.Discovery.ManualIP, _ip_address ->
        {:manual_ip, [bridge()]}
      end)

      {:ok, bridge} = private(HueAPI.discover_hue_bridge("10.0.1.16"))

      assert bridge == bridge()
    end

    test "returns an error when using ip address and not found" do
      patch(HueSDK.Discovery, :discover, fn HueSDK.Discovery.ManualIP, _ip_address ->
        {:error, %Mint.TransportError{reason: :timeout}}
      end)

      assert private(HueAPI.discover_hue_bridge("10.0.1.16")) == {:error, %Mint.TransportError{reason: :timeout}}
    end
  end

  describe "authenticate_with_bridge" do
    setup do
      expose(HueAPI, authenticate_with_bridge: 2)
      :ok
    end

    test "returns the bridge with a username if successful" do
      patch(HueSDK.Bridge, :authenticate, fn bridge, _unique_identifier ->
        username = "KkRnlFmJiMVyLRU-4H2GjdtSQhWsOzYYNBA9VrWS"
        Map.put(bridge, :username, username)
      end)

      {:ok, bridge} = private(HueAPI.authenticate_with_bridge(bridge(), "some-unique-identifier#huesdk"))

      assert bridge.username == username()
    end

    test "returns an error if unable to authenticate" do
      patch(HueSDK.Bridge, :authenticate, fn bridge, _unique_identifier ->
        bridge
      end)

      assert private(HueAPI.authenticate_with_bridge(bridge(), "some-unique-identifier#huesdk")) ==
               {:error, :unable_to_authenticate}
    end
  end

  describe "find_hue_light" do
    setup do
      expose(HueAPI, find_hue_light: 2)
      :ok
    end

    test "returns the light" do
      patch(HueSDK.API.Lights, :get_all_lights, fn _bridge ->
        {:ok, lights()}
      end)

      hue_light_name = "github"

      {:ok, light_id, light_info} = private(HueAPI.find_hue_light(authenticated_bridge(), hue_light_name))

      assert light_id == "2"

      assert light_info["state"] == %{
               "alert" => "lselect",
               "bri" => 254,
               "colormode" => "hs",
               "ct" => 153,
               "effect" => "none",
               "hue" => 27306,
               "mode" => "homeautomation",
               "on" => true,
               "reachable" => false,
               "sat" => 254,
               "xy" => [0.1687, 0.6482]
             }
    end

    test "returns an error if unable to find the light" do
      patch(HueSDK.API.Lights, :get_all_lights, fn _bridge ->
        {:ok, lights()}
      end)

      hue_light_name = "not-in-light-data"
      assert private(HueAPI.find_hue_light(authenticated_bridge(), hue_light_name)) == {:error, :unable_to_locate_light}
    end
  end

  describe "set_color" do
    test "returns success when able to set the light's color" do
      patch(HueSDK.API.Lights, :set_light_state, fn _bridge, _light_id, state ->
        assert state == %{on: true, hue: 27306, sat: 254, bri: 254}

        {:ok,
         [
           %{"success" => %{"/lights/2/state/on" => true}},
           %{"success" => %{"/lights/2/state/hue" => 27306}},
           %{"success" => %{"/lights/2/state/sat" => 254}},
           %{"success" => %{"/lights/2/state/bri" => 254}}
         ]}
      end)

      response = HueAPI.set_color(authenticated_bridge(), "2", :green)

      assert response ==
               {:ok,
                [
                  %{"success" => %{"/lights/2/state/on" => true}},
                  %{"success" => %{"/lights/2/state/hue" => 27306}},
                  %{"success" => %{"/lights/2/state/sat" => 254}},
                  %{"success" => %{"/lights/2/state/bri" => 254}}
                ]}
    end

    test "returns an error when unable to set the color of the light" do
      patch(HueSDK.API.Lights, :set_light_state, fn _bridge, _light_id, _state ->
        {:error, %Mint.TransportError{reason: :timeout}}
      end)

      response = HueAPI.set_color(authenticated_bridge(), "2", :green)
      assert response == {:error, %Mint.TransportError{reason: :timeout}}
    end
  end

  describe "find_light_by_name" do
    setup do
      expose(HueAPI, find_light_by_name: 2)
      :ok
    end

    test "gets the ci runs from all of the workflow runs" do
      {light_id, light_info} = private(HueAPI.find_light_by_name(lights(), "github"))
      assert light_id == "2"

      assert light_info["state"] == %{
               "alert" => "lselect",
               "bri" => 254,
               "colormode" => "hs",
               "ct" => 153,
               "effect" => "none",
               "hue" => 27306,
               "mode" => "homeautomation",
               "on" => true,
               "reachable" => false,
               "sat" => 254,
               "xy" => [0.1687, 0.6482]
             }
    end
  end
end
