defmodule GitHue.GitHubAPI do
  @moduledoc false

  def get_latest_ci_run(github_owner_repo, github_personal_access_token, github_ci_job_name) do
    query_github_api(github_owner_repo, github_personal_access_token)
    |> extract_ci_runs(github_ci_job_name)
    |> List.first()
  end

  def query_github_api(github_owner_repo, github_personal_access_token) do
    req = Req.new(base_url: "https://api.github.com")

    Req.get!(req,
      url: "/repos/#{github_owner_repo}/actions/runs",
      headers: [
        {"Authorization", "Token #{github_personal_access_token}"},
        {"Accept", "application/vnd.github.v3+json"}
      ]
    ).body["workflow_runs"]
  end

  def extract_ci_runs(workflow_runs, name_of_ci_job) do
    workflow_runs
    |> Enum.filter(&(&1["name"] == name_of_ci_job))
    |> Enum.map(&Map.take(&1, ["id", "status", "conclusion"]))
    |> Enum.sort(&(&1["id"] > &2["id"]))
  end

  def light_color(%{"conclusion" => "failure"} = _run), do: :red
  def light_color(%{"conclusion" => nil, "status" => "in_progress"} = _run), do: :yellow
  def light_color(%{"conclusion" => "success", "status" => "completed"} = _run), do: :green
  def light_color(%{"conclusion" => nil, "status" => "queued"} = _run), do: :unchanged

  def light_color(run) do
    raise RuntimeError, "Unknown light color for #{inspect(run)}"
  end
end
