defmodule Tiex.Machina.Lex.Lexer do
  defmodule State, do: defstruct(pos: 0, line: 1, column: 0, tokens: [])
  defmodule Token, do: defstruct(pos: 0, line: 1, column: 0, name: nil, value: nil)

  def lex(module, rules, text), do: lex(module, rules, text, %State{})

  def clear_ignored_tokens(tokens, ignored_tokens),
    do: Enum.filter(tokens, fn %Token{name: name} -> name not in ignored_tokens end)

  defp lex(module, rules, text, state) do
    rules
    |> matching_rules(text)
    |> apply_matches(text)
    |> longest_match()
    |> process_match(module, rules, text, state)
  end

  defp process_match(nil, _, _, text, _),
    do: {:error, "Text not in language: #{inspect(text)}"}

  defp process_match({content, fun}, module, rules, text, state) do
    len = content |> String.length()

    apply(module, fun, [content])
    |> process_result(state)
    |> case do
      {:error, _} ->
        state

      state ->
        fragment = String.slice(text, 0, len)
        line = state.line + line_number_incrementor(fragment)
        column = column_number(state, fragment)

        state = Map.merge(state, %{pos: state.pos + len, line: line, column: column})

        case String.split_at(text, len) do
          {_, ""} -> {:ok, Enum.reverse(state.tokens)}
          {_, new_text} -> lex(module, rules, new_text, state)
        end
    end
  end

  defp column_number(state, match) do
    if Regex.match?(~r/[\r\n]/, match) do
      len = match |> split_on_newlines() |> List.last() |> String.length()

      case len do
        0 -> 1
        _ -> len
      end
    else
      state.column + String.length(match)
    end
  end

  defp line_number_incrementor(match), do: (match |> split_on_newlines() |> Enum.count()) - 1

  defp split_on_newlines(text), do: String.split(text, ~r{(\r|\n|\r\n)})

  defp process_result(result, state) when is_tuple(result), do: push_token(state, result)

  defp process_result(result, _), do: {:error, "Invalid result from action: #{inspect(result)}"}

  defp push_token(state, {name, value} = _token) do
    token = %Token{
      pos: state.pos,
      line: state.line,
      column: state.column,
      name: name,
      value: value
    }

    Map.merge(state, %{tokens: [token | state.tokens]})
  end

  defp matching_rules(rules, text),
    do:
      Enum.filter(rules, fn {_, regex, _} ->
        Regex.match?(regex, text)
      end)

  defp apply_matches(rules, text),
    do:
      Enum.map(rules, fn {_, regex, fun} ->
        [match] = Regex.run(regex, text, capture: :first)
        {match, fun}
      end)

  defp longest_match(matches),
    do: Enum.sort_by(matches, fn {match, _} -> String.length(match) end, :desc) |> Enum.at(0)
end
