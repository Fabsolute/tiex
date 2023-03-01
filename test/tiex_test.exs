defmodule TIEXTest do
  use ExUnit.Case
  doctest TIEX

  test "greets the world" do
    assert TIEX.hello() == :world
  end
end
