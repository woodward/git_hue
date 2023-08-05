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
    case HueAPI.connect_to_hue_bridge(hue_bridge_ip_address(), hue_unique_identifier(), hue_light_name()) do
      {:ok, bridge, light_id, _light_info} ->
        Logger.info("Connected to Hue bridge: #{inspect(bridge)}")
        Logger.info("Found Hue light: #{inspect(light_id)}")
        state = state |> Map.put(:bridge, bridge) |> Map.put(:light_id, light_id)
        Process.send_after(self(), :check_github, 1)
        {:noreply, state}

      {:error, error} ->
        Logger.error("Unable to initialize Hue bridge. Terminating. Reason: #{error}")
        {:stop, :normal, state}
    end
  end

  @impl true
  def handle_info(:check_github, %{light_id: light_id, bridge: bridge} = state) do
    latest_ci_run =
      GitHubAPI.get_latest_ci_run(
        github_owner_repo(),
        github_personal_access_token(),
        github_ci_job_name(),
        github_branch_name()
      )

    color = GitHubAPI.light_color(latest_ci_run)
    Logger.info("Setting Hue color to #{inspect(color)}")

    case HueAPI.set_color(bridge, light_id, color) do
      {:ok, _message} ->
        Process.send_after(self(), :check_github, github_polling_interval_sec() * 1000)
        {:noreply, state}

      {:error, error_message} ->
        Logger.error("Unable to set the color of the light. Error: #{inspect(error_message)}.  Terminating.")
        {:stop, :normal, state}
    end
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
