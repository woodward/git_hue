defmodule GitHue.GitHubAPI do
  @moduledoc false

  def get_latest_ci_run(github_owner_repo, github_personal_access_token, github_ci_job_name, github_branch_name) do
    case query_github_api(github_owner_repo, github_personal_access_token) do
      {:ok, workflow_runs} ->
        latest_ci_run =
          workflow_runs
          |> extract_ci_runs(github_ci_job_name)
          |> extract_runs_for_branch(github_branch_name)
          |> List.first()

        {:ok, latest_ci_run}

      {:error, error_reason} ->
        {:error, error_reason}
    end
  end

  def query_github_api(github_owner_repo, github_personal_access_token) do
    req = Req.new(base_url: "https://api.github.com")

    case Req.get!(req,
           url: "/repos/#{github_owner_repo}/actions/runs",
           headers: [
             {"Authorization", "Token #{github_personal_access_token}"},
             {"Accept", "application/vnd.github.v3+json"}
           ]
         ) do
      %Req.Response{status: 200, body: body} -> {:ok, body["workflow_runs"]}
      %Req.Response{} = error_response -> {:error, error_response}
    end
  end

  def extract_ci_runs(workflow_runs, name_of_ci_job) do
    workflow_runs
    |> Enum.filter(&(&1["name"] == name_of_ci_job))
    |> Enum.map(&Map.take(&1, ["id", "status", "conclusion", "head_branch"]))
    |> Enum.sort(&(&1["id"] > &2["id"]))
  end

  def extract_runs_for_branch(workflow_runs, ""), do: workflow_runs
  def extract_runs_for_branch(workflow_runs, nil), do: workflow_runs

  def extract_runs_for_branch(workflow_runs, github_branch_name) do
    workflow_runs
    |> Enum.filter(&(Map.get(&1, "head_branch") == github_branch_name))
  end

  def light_color(%{"conclusion" => "failure"} = _run), do: :red
  def light_color(%{"conclusion" => nil, "status" => "in_progress"} = _run), do: :yellow
  def light_color(%{"conclusion" => "success", "status" => "completed"} = _run), do: :green
  def light_color(%{"conclusion" => nil, "status" => "queued"} = _run), do: :unchanged

  def light_color(run) do
    raise RuntimeError, "Unknown light color for #{inspect(run)}"
  end
end
