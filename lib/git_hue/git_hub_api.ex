defmodule GitHue.GitHubAPI do
  @moduledoc false

  def get_color_of_latest_ci_run(github_owner_repo, github_personal_access_token, github_ci_job_name, github_branch_name) do
    with {:ok, workflow_runs} <- query_github_api(github_owner_repo, github_personal_access_token),
         {:ok, ci_runs} <- workflow_runs |> extract_ci_runs(github_ci_job_name),
         color <- ci_runs |> extract_runs_for_branch(github_branch_name) |> List.first() |> light_color() do
      {:ok, color}
    else
      {:error, error_reason} ->
        {:error, error_reason}
    end
  end

  defp query_github_api(github_owner_repo, github_personal_access_token) do
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

  defp extract_ci_runs(workflow_runs, name_of_ci_job) do
    case workflow_runs |> Enum.filter(&(&1["name"] == name_of_ci_job)) do
      [] ->
        {:error, "No GitHub workflow runs for job name \"#{name_of_ci_job}\""}

      ci_job_workflow_runs ->
        transformed_runs =
          ci_job_workflow_runs
          |> Enum.map(&Map.take(&1, ["id", "status", "conclusion", "head_branch"]))
          |> Enum.sort(&(&1["id"] > &2["id"]))

        {:ok, transformed_runs}
    end
  end

  defp extract_runs_for_branch(workflow_runs, ""), do: workflow_runs
  defp extract_runs_for_branch(workflow_runs, nil), do: workflow_runs

  defp extract_runs_for_branch(workflow_runs, github_branch_name) do
    workflow_runs
    |> Enum.filter(&(Map.get(&1, "head_branch") == github_branch_name))
  end

  defp light_color(%{"conclusion" => "failure"} = _run), do: :red
  defp light_color(%{"conclusion" => nil, "status" => "in_progress"} = _run), do: :yellow
  defp light_color(%{"conclusion" => "success", "status" => "completed"} = _run), do: :green
  defp light_color(%{"conclusion" => nil, "status" => "queued"} = _run), do: :unchanged

  defp light_color(run) do
    raise RuntimeError, "Unknown light color for #{inspect(run)}"
  end
end
