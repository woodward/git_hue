defmodule GitHue.HueAPITest do
  use ExUnit.Case
  doctest GitHue

  alias GitHue.HueAPI

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
