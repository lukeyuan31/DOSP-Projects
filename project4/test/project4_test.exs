defmodule Project4Test do
  use ExUnit.Case
  doctest Project4

  test "greets the world" do
    assert Project4.hello() == :world
  end
end
