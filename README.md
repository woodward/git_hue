# GitHue

** Description

GitHue uses the Elixir [HueSDK](https://github.com/connorlay/hue_sdk) and the 
[GitHub API](https://docs.github.com/en/rest?apiVersion=2022-11-28) to change the color of a Philips Hue
light based on the status of continuous integration (or CI).  The light will be set to green if the build
was succsessful, yellow if the build is running, and red if the build fails.


## Installation and Usage

There are a number of environment variables to configure; see `.envrc` for a description.

* `git clone git@github.com:woodward/git_hue.git`
* `cd git_hue`
* `mix deps.get`
* Configure the environment variables in `.envrc`` (adding private values to `.local/envrc`)
* Press the "link" button on top of the Hue Bridge (i.e., the big button on top)
* `iex -S mix`
  
The light should change based on the status of your GitHub action  
