defmodule GitHue.GitHubMonitorTest do
  @moduledoc false
  use ExUnit.Case
  doctest GitHue

  alias GitHue.GitHubMonitor
  use Patch
  import GitHue.GitHueFixtures

  describe "successfully starts up" do
    setup do
      patch(HueSDK.Discovery, :discover, fn _type -> {:nupnp, [bridge()]} end)
      patch(HueSDK.Bridge, :authenticate, fn bridge, _unique_identifier -> Map.put(bridge, :username, username()) end)
      patch(HueSDK.API.Lights, :get_all_lights, fn _bridge -> {:ok, lights()} end)

      patch(Req, :get!, fn _req, _params ->
        response_body = File.read!("test/fixtures/github_response.json") |> Jason.decode!()
        %Req.Response{private: %{}, status: 200, body: response_body, headers: [{"server", "GitHub.com"}]}
      end)

      :ok
    end

    @tag capture_log: true
    test "starts the genserver and polls GitHub" do
      {:ok, github_monitor_pid} = start_supervised(GitHubMonitor)

      # Instead of Process.sleep() do a wait_until for the state.color to become :yellow?
      Process.sleep(10)

      state = :sys.get_state(github_monitor_pid)
      assert state == %{bridge: authenticated_bridge(), light_id: "2", color: :yellow}
    end
  end
end
