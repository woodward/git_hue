defmodule GitHue.GitHubAPITest do
  use ExUnit.Case
  doctest GitHue

  alias GitHue.GitHubAPI

  describe "extract_ci_runs" do
    test "gets the ci runs from all of the workflow runs" do
      github_json = File.read!("test/fixtures/response.json") |> Jason.decode!()
      workflow_runs = Map.get(github_json, "workflow_runs")
      assert length(workflow_runs) == 30

      ci_runs = workflow_runs |> GitHubAPI.extract_ci_runs("Omni CI")
      assert length(ci_runs) == 10

      expected_ci_runs = [
        %{"conclusion" => nil, "id" => 5_708_095_112, "status" => "in_progress"},
        %{"conclusion" => "success", "id" => 5_697_406_496, "status" => "completed"},
        %{"conclusion" => "success", "id" => 5_697_212_538, "status" => "completed"},
        %{"conclusion" => "success", "id" => 5_686_810_388, "status" => "completed"},
        %{"conclusion" => "success", "id" => 5_686_275_839, "status" => "completed"},
        %{"conclusion" => "success", "id" => 5_686_226_403, "status" => "completed"},
        %{"conclusion" => "success", "id" => 5_685_984_611, "status" => "completed"},
        %{"conclusion" => "success", "id" => 5_675_452_424, "status" => "completed"},
        %{"conclusion" => "success", "id" => 5_674_818_299, "status" => "completed"},
        %{"conclusion" => "success", "id" => 5_674_284_010, "status" => "completed"}
      ]

      assert ci_runs == expected_ci_runs
    end
  end

  describe "light_color" do
    test "returns :green if a successful conclusion" do
      run = %{"conclusion" => "success", "id" => 5_697_406_496, "status" => "completed"}
      assert GitHubAPI.light_color(run) == :green
    end

    test "returns :yellow if the job is still in progress" do
      run = %{"conclusion" => nil, "id" => 5_708_095_112, "status" => "in_progress"}
      assert GitHubAPI.light_color(run) == :yellow
    end

    test "returns :red if the job has failed" do
      run = %{"conclusion" => "failure", "id" => 5_697_406_496, "status" => "completed"}
      assert GitHubAPI.light_color(run) == :red
    end
  end
end
