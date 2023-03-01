defmodule TIEX do
  alias Tiex.{Lexer, Parser}

  def init do
    File.read!("/Users/fabsolutely/dev/elixir/tiex/lib/file.tiex")
    |> Lexer.lex()
    |> IO.inspect()
    |> Parser.parse
    |> IO.inspect()

    # |> TIEX.Parser.parse()
    # |> IO.inspect()
  end
end
