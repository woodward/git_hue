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
    Process.send_after(self(), :check_github, 100)
    bridge = HueAPI.get_bridge(hue_unique_identifier(), hue_bridge_ip_address())
    Logger.info("bridge: #{inspect(bridge)}")

    {:ok, lights} = HueSDK.API.Lights.get_all_lights(bridge)
    {light_id, light_info} = Enum.find(lights, fn {_, light_data} -> light_data["name"] == hue_light_name() end)
    Logger.info("light_id: #{inspect(light_id)}")
    Logger.info("light_info: #{inspect(light_info)}")

    {:ok, %{bridge: bridge, light_id: light_id}}
    # {:ok, %{}}
  end

  @impl true
  def handle_info(:check_github, %{light_id: light_id, bridge: bridge} = state) do
    Process.send_after(self(), :check_github, github_polling_interval_sec() * 1000)

    latest_ci_run = GitHubAPI.get_latest_ci_run(github_owner_repo(), github_personal_access_token(), github_ci_job_name())
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
end
