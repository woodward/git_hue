defmodule GitHue.GitHubMonitor do
  @moduledoc false
  use GenServer

  alias GitHue.Hue

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    # Process.send_after(self(), :check_github, 1_000)
    # bridge = Hue.get_bridge()

    # {:ok, lights} = HueSDK.API.Lights.get_all_lights(bridge)
    # light = Enum.find(lights, fn {_, light_data} -> light_data["name"] == "github" end)

    # {:ok, %{bridge: bridge, light: light}}
    {:ok, %{}}
  end

  @impl true
  def handle_info(:check_github, state) do
    Process.send_after(self(), :check_github, 1_000)
    {:noreply, state}
  end
end
