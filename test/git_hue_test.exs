defmodule GitHueTest do
  use ExUnit.Case
  doctest GitHue

  test "greets the world" do
    assert GitHue.hello() == :world
  end
end
