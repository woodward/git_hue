import Config

config :git_hue,
  hue_unique_identifier: System.get_env("HUE_UNIQUE_IDENTIFIER"),
  # Note that :hue_bridge_ip_address can be nil if using Philip's NUPNP discovery service (the default behavior)
  hue_bridge_ip_address: System.get_env("HUE_BRIDGE_IP_ADDRESS"),
  hue_light_name: System.get_env("HUE_LIGHT_NAME"),
  #
  github_polling_interval_sec: System.get_env("GITHUB_POLLING_INTERVAL_SEC") |> String.to_integer(),
  github_personal_access_token: System.get_env("GITHUB_PERSONAL_ACCESS_TOKEN"),
  github_owner_repo: System.get_env("GITHUB_OWNER_REPO"),
  github_ci_job_name: System.get_env("GITHUB_CI_JOB_NAME"),
  github_branch_name: System.get_env("GITHUB_BRANCH_NAME", nil),
  start_github_monitor_automatically?: config_env() != :test
