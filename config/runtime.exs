import Config

config :git_hue,
  unique_identifier: System.get_env("HUE_UNIQUE_IDENTIFIER"),
  github_polling_interval_sec: System.get_env("GITHUB_POLLING_INTERVAL_SEC"),
  github_personal_access_token: System.get_env("GITHUB_PERSONAL_ACCESS_TOKEN"),
  github_owner_repo: System.get_env("GITHUB_OWNER_REPO"),
  github_ci_job_name: System.get_env("GITHUB_CI_JOB_NAME")
