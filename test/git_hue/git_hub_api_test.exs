defmodule GitHue.GitHubAPITest do
  @moduledoc false
  use ExUnit.Case
  doctest GitHue

  alias GitHue.GitHubAPI
  use Patch

  describe "query_github_api/2" do
    setup do
      expose(GitHubAPI, query_github_api: 2)
      :ok
    end

    test "returns the GitHub runs if successful" do
      patch(Req, :get!, fn _req, _params ->
        response_body = File.read!("test/fixtures/github_response.json") |> Jason.decode!()

        %Req.Response{
          private: %{},
          status: 200,
          body: response_body,
          headers: [
            {"server", "GitHub.com"}
          ]
        }
      end)

      {:ok, workflow_runs} = private(GitHubAPI.query_github_api("my-org/my-repo", "my-personal-access-token"))
      assert length(workflow_runs) == 30
    end

    test "returns an error if unsuccessful" do
      patch(Req, :get!, fn _req, _params ->
        %Req.Response{
          private: %{},
          status: 404,
          headers: [
            {"server", "GitHub.com"}
          ]
        }
      end)

      {:error, error_response} =
        private(GitHubAPI.query_github_api("my-org/my-repo-DOES-NOT-EXIST", "my-personal-access-token"))

      assert error_response == %Req.Response{status: 404, headers: [{"server", "GitHub.com"}], body: "", private: %{}}
    end
  end

  describe "get_color_of_latest_ci_run/4" do
    test "returns the latest CI run as a map" do
      patch(Req, :get!, fn _req, _params ->
        response_body = File.read!("test/fixtures/github_response.json") |> Jason.decode!()

        %Req.Response{
          private: %{},
          status: 200,
          body: response_body,
          headers: [
            {"server", "GitHub.com"}
          ]
        }
      end)

      github_owner_repo = "mechanical-orchard/omni"
      github_personal_access_token = "some-valid-token"
      github_ci_job_name = "Omni CI"
      github_branch_name = "main"

      {:ok, color} =
        GitHubAPI.get_color_of_latest_ci_run(
          github_owner_repo,
          github_personal_access_token,
          github_ci_job_name,
          github_branch_name
        )

      assert color == :yellow
    end

    test "returns an error if unable to retrieve the latest CI runs" do
      patch(Req, :get!, fn _req, _params ->
        %Req.Response{
          private: %{},
          status: 404,
          headers: [
            {"server", "GitHub.com"}
          ]
        }
      end)

      github_owner_repo = "mechanical-orchard/omni"
      github_personal_access_token = "some-valid-token"
      github_ci_job_name = "Omni CI"
      github_branch_name = "main"

      {:error, reason} =
        GitHubAPI.get_color_of_latest_ci_run(
          github_owner_repo,
          github_personal_access_token,
          github_ci_job_name,
          github_branch_name
        )

      assert reason == %Req.Response{status: 404, headers: [{"server", "GitHub.com"}], body: "", private: %{}}
    end
  end

  describe "extract_ci_runs" do
    setup do
      expose(GitHubAPI, extract_ci_runs: 2)
      :ok
    end

    test "gets the ci runs from all of the workflow runs" do
      github_json = File.read!("test/fixtures/github_response.json") |> Jason.decode!()
      workflow_runs = Map.get(github_json, "workflow_runs")
      assert length(workflow_runs) == 30

      ci_runs = private(GitHubAPI.extract_ci_runs(workflow_runs, "Omni CI"))
      assert length(ci_runs) == 10

      expected_ci_runs = [
        %{"conclusion" => nil, "id" => 5_708_095_112, "status" => "in_progress", "head_branch" => "main"},
        %{"conclusion" => "success", "id" => 5_697_406_496, "status" => "completed", "head_branch" => "main"},
        %{"conclusion" => "success", "id" => 5_697_212_538, "status" => "completed", "head_branch" => "main"},
        %{"conclusion" => "success", "id" => 5_686_810_388, "status" => "completed", "head_branch" => "main"},
        %{"conclusion" => "success", "id" => 5_686_275_839, "status" => "completed", "head_branch" => "main"},
        %{
          "conclusion" => "success",
          "id" => 5_686_226_403,
          "status" => "completed",
          "head_branch" => "something-other-than-main"
        },
        %{"conclusion" => "success", "id" => 5_685_984_611, "status" => "completed", "head_branch" => "main"},
        %{"conclusion" => "success", "id" => 5_675_452_424, "status" => "completed", "head_branch" => "main"},
        %{"conclusion" => "success", "id" => 5_674_818_299, "status" => "completed", "head_branch" => "main"},
        %{"conclusion" => "success", "id" => 5_674_284_010, "status" => "completed", "head_branch" => "main"}
      ]

      assert ci_runs == expected_ci_runs
    end
  end

  describe "light_color" do
    setup do
      expose(GitHubAPI, light_color: 1)
      :ok
    end

    test "returns :green if a successful conclusion" do
      run = %{"conclusion" => "success", "id" => 5_697_406_496, "status" => "completed"}
      assert private(GitHubAPI.light_color(run)) == :green
    end

    test "returns :yellow if the job is still in progress" do
      run = %{"conclusion" => nil, "id" => 5_708_095_112, "status" => "in_progress"}
      assert private(GitHubAPI.light_color(run)) == :yellow
    end

    test "returns :red if the job has failed" do
      run = %{"conclusion" => "failure", "id" => 5_697_406_496, "status" => "completed"}
      assert private(GitHubAPI.light_color(run)) == :red
    end

    test "returns :unchanged if the job is queued" do
      run = %{"conclusion" => nil, "id" => 5_721_332_317, "status" => "queued"}
      assert private(GitHubAPI.light_color(run)) == :unchanged
    end
  end

  describe "extract_runs_for_branch" do
    setup do
      expose(GitHubAPI, extract_runs_for_branch: 2)
      :ok
    end

    test "by default gets the ci runs from all of the workflow runs" do
      filtered_ci_runs = private(GitHubAPI.extract_runs_for_branch(ci_runs(), ""))
      assert length(filtered_ci_runs) == 4
      expected_ci_runs = ci_runs()
      assert filtered_ci_runs == expected_ci_runs
    end

    test "by default gets the ci runs from all of the workflow runs - also works for nil" do
      filtered_ci_runs = private(GitHubAPI.extract_runs_for_branch(ci_runs(), nil))
      assert length(filtered_ci_runs) == 4
      expected_ci_runs = ci_runs()
      assert filtered_ci_runs == expected_ci_runs
      assert filtered_ci_runs == expected_ci_runs
    end

    test "gets only the results for a particular branch" do
      filtered_ci_runs = private(GitHubAPI.extract_runs_for_branch(ci_runs(), "main"))
      assert length(filtered_ci_runs) == 3

      expected_ci_runs = [
        %{"conclusion" => nil, "head_branch" => "main", "id" => 5_708_095_112, "status" => "in_progress"},
        %{"conclusion" => "success", "head_branch" => "main", "id" => 5_697_406_496, "status" => "completed"},
        %{"conclusion" => "success", "head_branch" => "main", "id" => 5_697_212_538, "status" => "completed"}
      ]

      assert filtered_ci_runs == expected_ci_runs
    end
  end

  def ci_runs do
    [
      %{"conclusion" => nil, "id" => 5_708_095_112, "status" => "in_progress", "head_branch" => "main"},
      %{"conclusion" => "success", "id" => 5_697_406_496, "status" => "completed", "head_branch" => "main"},
      %{
        "conclusion" => "success",
        "id" => 5_686_226_403,
        "status" => "completed",
        "head_branch" => "something-other-than-main"
      },
      %{"conclusion" => "success", "id" => 5_697_212_538, "status" => "completed", "head_branch" => "main"}
    ]
  end
end
