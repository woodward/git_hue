# GitHue

## Description

GitHue uses the Elixir [HueSDK](https://github.com/connorlay/hue_sdk) and the 
[GitHub API](https://docs.github.com/en/rest?apiVersion=2022-11-28) to change the color of a Philips Hue
light based on the status of a GitHub actions continuous integration build (or CI).  The light will 
be set to green if the build is succsessful, yellow if the build is running, and red if the build fails.


## Installation and Usage

There are a number of environment variables to configure; see `.envrc` for a description.

* `git clone git@github.com:woodward/git_hue.git`
* `cd git_hue`
* `mix deps.get`
* In the Hue app on your phone, you'll need to give the light a recognizable name (which goes into the
  environment variable HUE_LIGHT_NAME)
* You'll need to get a [GitHub personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)
  which will be set in the environment variable GITHUB_PERSONAL_ACCESS_TOKEN
* Configure the rest of the environment variables in `.envrc`` (adding private values to `.local/envrc`)
* **IMPORTANT** Press the "link" button on top of the Hue Bridge (i.e., the big button on top)
* `iex -S mix`
  
The light should change based on the status of your GitHub action  
