defmodule GitHue.GitHubMonitor do
  @moduledoc false
  use GenServer
  require Logger

  alias GitHue.{GitHubAPI, HueAPI}

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok, %{bridge: nil, light_id: nil}, {:continue, :initialize_bridge}}
  end

  @impl true
  def handle_continue(:initialize_bridge, state) do
    IO.puts("-------------------------")
    Logger.info("Locating Hue bridge...")

    case HueAPI.discover_hue_bridge(hue_bridge_ip_address()) do
      {:ok, bridge} ->
        Logger.info("bridge: #{inspect(bridge)}")
        {:noreply, Map.put(state, :bridge, bridge), {:continue, :authenticate_bridge}}

      {:error, :no_bridges_found} ->
        Logger.error("Unable to initialize Hue bridge. Terminating")
        {:stop, :normal, state}
    end
  end

  def handle_continue(:authenticate_bridge, %{bridge: bridge} = state) do
    IO.puts("-------------------------")
    Logger.info("Authenticating bridge...")

    case HueAPI.temp_authenticate(:bad) do
      # case HueSDK.Bridge.authenticate(bridge, hue_unique_identifier()) do
      %{username: nil} ->
        Logger.error("Unable to authenticate Hue bridge. Terminating")
        # {:stop, :normal, state}
        {:noreply, state, {:continue, :find_hue_light}}

      %{username: _} = bridge ->
        IO.puts("is bridge actually set to something here????")
        IO.inspect(bridge, label: "bbbbbbbbbbbbbbbbbbbridge")
        {:noreply, Map.put(state, :bridge, bridge), {:continue, :find_hue_light}}
    end

    # ==================================
    # bridge = HueSDK.Bridge.authenticate(bridge, hue_unique_identifier())

    # if bridge && bridge.username != nil do
    #   {:noreply, Map.put(state, :bridge, bridge), {:continue, :find_hue_light}}
    # else
    #   Logger.error("Unable to authenticate Hue bridge. Terminating")
    #   # {:stop, :normal, state}
    #   {:noreply, state, {:continue, :find_hue_light}}
    # end
  end

  def handle_continue(:find_hue_light, %{bridge: bridge} = state) do
    IO.puts("-------------------------")
    Logger.info("Finding Hue light with name \"#{hue_light_name()}\"...")

    {:ok, lights} = HueSDK.API.Lights.get_all_lights(bridge)
    {light_id, light_info} = HueAPI.find_light_by_name(lights, hue_light_name())

    if light_id do
      Logger.info("light_id: #{inspect(light_id)}")
      Logger.info("light_info: #{inspect(light_info)}")
      {:noreply, Map.put(state, :light_id, light_id), {:continue, :check_github}}
    else
      Logger.error("Unable to find Hue light with name \"#{hue_light_name()}\". Terminating")
      {:stop, :normal, state}
    end
  end

  @impl true
  def handle_info(:check_github, %{light_id: light_id, bridge: bridge} = state) do
    Process.send_after(self(), :check_github, github_polling_interval_sec() * 1000)

    latest_ci_run =
      GitHubAPI.get_latest_ci_run(
        github_owner_repo(),
        github_personal_access_token(),
        github_ci_job_name(),
        github_branch_name()
      )

    color = GitHubAPI.light_color(latest_ci_run)
    Logger.info("Setting Hue color to #{inspect(color)}")
    HueAPI.set_color(bridge, light_id, color)

    {:noreply, state}
  end

  defp hue_unique_identifier, do: Application.get_env(:git_hue, :hue_unique_identifier)
  defp hue_bridge_ip_address, do: Application.get_env(:git_hue, :hue_bridge_ip_address)
  defp hue_light_name, do: Application.get_env(:git_hue, :hue_light_name)

  defp github_owner_repo, do: Application.get_env(:git_hue, :github_owner_repo)
  defp github_personal_access_token, do: Application.get_env(:git_hue, :github_personal_access_token)
  defp github_ci_job_name, do: Application.get_env(:git_hue, :github_ci_job_name)
  defp github_polling_interval_sec, do: Application.get_env(:git_hue, :github_polling_interval_sec)
  defp github_branch_name, do: Application.get_env(:git_hue, :github_branch_name)
end
