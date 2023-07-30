defmodule GitHue.Application do
  @moduledoc false
  require Config

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GitHue.GitHubMonitor
    ]

    opts = [strategy: :one_for_one, name: GitHue.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
