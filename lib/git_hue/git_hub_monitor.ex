defmodule GitHue.GitHubMonitor do
  @moduledoc false
  use GenServer

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    {:ok, %{}}
  end
end
