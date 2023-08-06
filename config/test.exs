import Config

# disable SSL for tests
config :hue_sdk, ssl: false

config :git_hue,
  hue_unique_identifier: "test-hue-identifier",
  # Note that :hue_bridge_ip_address can be nil if using Philip's NUPNP discovery service (the default behavior)
  hue_bridge_ip_address: nil,
  hue_light_name: "github",
  #
  github_polling_interval_sec: 30,
  github_personal_access_token: "github-personal-access-token",
  github_owner_repo: "my-owner/my-repo",
  github_ci_job_name: "CI Job",
  github_branch_name: "main",
  start_github_monitor_automatically?: false
