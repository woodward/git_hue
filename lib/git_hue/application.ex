defmodule GitHue.Application do
  @moduledoc false
  require Config

  use Application

  @impl true
  def start(_type, _args) do
    children = if start_github_monitor_automicatically?(), do: [GitHue.GitHubMonitor], else: []

    opts = [strategy: :one_for_one, name: GitHue.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_github_monitor_automicatically?, do: Application.get_env(:git_hue, :start_github_monitor_automatically?)
end
