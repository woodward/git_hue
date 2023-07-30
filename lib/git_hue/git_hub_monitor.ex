defmodule GitHue.GitHubMonitor do
  @moduledoc false
  use GenServer

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), :check_github, 1_000)
    {:ok, %{}}
  end

  @impl true
  def handle_info(:check_github, state) do
    Process.send_after(self(), :check_github, 1_000)
    {:noreply, state}
  end
end
