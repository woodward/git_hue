defmodule GitHue.GitHubAPI do
  @moduledoc false

  def extract_ci_runs(workflow_runs, name_of_ci_job) do
    workflow_runs
    |> Enum.filter(&(&1["name"] == name_of_ci_job))
    |> Enum.map(&Map.take(&1, ["id", "status", "conclusion"]))
    |> Enum.sort(&(&1["id"] > &2["id"]))
  end

  def light_color(%{"conclusion" => "failure"} = _run), do: :red
  def light_color(%{"conclusion" => nil, "status" => "in_progress"} = _run), do: :yellow
  def light_color(%{"conclusion" => "success", "status" => "completed"} = _run), do: :green

  def light_color(run) do
    raise RuntimeError, "Unknown light color for #{inspect(run)}"
  end
end
