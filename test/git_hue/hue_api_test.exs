defmodule GitHue.HueAPITest do
  use ExUnit.Case
  doctest GitHue

  alias GitHue.HueAPI
  use Patch

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
    test "returns when using discovery" do
      patch(HueSDK.Discovery, :discover, fn _type ->
        {:nupnp, [bridge()]}
      end)

      {:ok, bridge} = HueAPI.discover_hue_bridge(nil)

      assert bridge == bridge()
    end

    test "no bridges found" do
      patch(HueSDK.Discovery, :discover, fn _type ->
        {:nupnp, []}
      end)

      assert(HueAPI.discover_hue_bridge(nil) == {:error, :no_bridges_found})
    end
  end

  describe "authenticate_with_bridge" do
    test "returns the bridge with a username if successful" do
      patch(HueSDK.Bridge, :authenticate, fn bridge, _unique_identifier ->
        username = "KkRnlFmJiMVyLRU-4H2GjdtSQhWsOzYYNBA9VrWS"
        Map.put(bridge, :username, username)
      end)

      {:ok, bridge} = HueAPI.authenticate_with_bridge(bridge(), "some-unique-identifier#huesdk")

      assert bridge.username == username()
    end

    test "returns an error if unable to authenticate" do
      patch(HueSDK.Bridge, :authenticate, fn bridge, _unique_identifier ->
        bridge
      end)

      assert HueAPI.authenticate_with_bridge(bridge(), "some-unique-identifier#huesdk") == {:error, :unable_to_authenticate}
    end
  end

  describe "find_hue_light" do
    test "returns the light" do
      patch(HueSDK.API.Lights, :get_all_lights, fn _bridge ->
        {:ok, lights()}
      end)

      hue_light_name = "github"

      {:ok, light_id, light_info} = HueAPI.find_hue_light(authenticated_bridge(), hue_light_name)

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
      assert HueAPI.find_hue_light(authenticated_bridge(), hue_light_name) == {:error, :unable_to_locate_light}
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
    test "gets the ci runs from all of the workflow runs" do
      {light_id, light_info} = HueAPI.find_light_by_name(lights(), "github")
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

  defp bridge do
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

  defp username, do: "KkRnlFmJiMVyLRU-4H2GjdtSQhWsOzYYNBA9VrWS"

  defp authenticated_bridge do
    Map.put(bridge(), :username, username())
  end

  defp lights do
    %{
      "1" => %{
        "capabilities" => %{
          "certified" => true,
          "control" => %{
            "colorgamuttype" => "other",
            "ct" => %{"max" => 0, "min" => 0}
          },
          "streaming" => %{"proxy" => false, "renderer" => false}
        },
        "config" => %{
          "archetype" => "classicbulb",
          "direction" => "omnidirectional",
          "function" => "mixed"
        },
        "manufacturername" => "Signify Netherlands B.V.",
        "modelid" => "LCA005",
        "name" => "Hue color lamp 1",
        "productname" => "Hue color light",
        "state" => %{
          "alert" => "none",
          "bri" => 254,
          "colormode" => "xy",
          "ct" => 366,
          "effect" => "none",
          "hue" => 14988,
          "mode" => "homeautomation",
          "on" => true,
          "reachable" => false,
          "sat" => 141,
          "xy" => [0.4578, 0.4101]
        },
        "swupdate" => %{
          "lastinstall" => "2023-05-31T05:56:22",
          "state" => "notupdatable"
        },
        "swversion" => "1.76.11",
        "type" => "Extended color light",
        "uniqueid" => "00:17:88:01:0d:a2:1b:e9-0b"
      },
      "2" => %{
        "capabilities" => %{
          "certified" => true,
          "control" => %{
            "colorgamut" => [[0.6915, 0.3083], [0.17, 0.7], [0.1532, 0.0475]],
            "colorgamuttype" => "C",
            "ct" => %{"max" => 500, "min" => 153},
            "maxlumen" => 800,
            "mindimlevel" => 200
          },
          "streaming" => %{"proxy" => true, "renderer" => true}
        },
        "config" => %{
          "archetype" => "classicbulb",
          "direction" => "omnidirectional",
          "function" => "mixed",
          "startup" => %{"configured" => true, "mode" => "safety"}
        },
        "manufacturername" => "Signify Netherlands B.V.",
        "modelid" => "LCA005",
        "name" => "github",
        "productid" => "Philips-LCA005-1-A19ECLv7",
        "productname" => "Hue color lamp",
        "state" => %{
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
        },
        "swconfigid" => "5419E9E3",
        "swupdate" => %{
          "lastinstall" => "2023-07-31T00:29:37",
          "state" => "noupdates"
        },
        "swversion" => "1.104.2",
        "type" => "Extended color light",
        "uniqueid" => "00:17:88:01:0d:a2:17:e6-0b"
      }
    }
  end
end
