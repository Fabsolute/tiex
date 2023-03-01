defmodule Tiex.Lexer do
  use Tiex.Machina.Lex

  defnamed DIGIT: ~n/0-9/,
           # positive digit
           PDIGIT: ~n/1-9/,
           HEX: ~n/0-9a-fA-F/,
           BINARY: ~n/01/,
           WORD: ~n/A-Za-z_/,
           DIGIT_WORD: ~n/{DIGIT}{WORD}/

  defnamed WS: ~n/\t\s/,
           NL: ~n/\r\n/

  # keywords
  defrule :module, do: {:token, :module}
  defrule :function, do: {:token, :function}

  # punctions
  defrule "}", do: {:token, :right_brace}
  defrule "{", do: {:token, :left_brace}
  defrule "(", do: {:token, :left_parenthesis}
  defrule ")", do: {:token, :right_parenthesis}
  defrule ",", do: {:token, :comma}
  defrule ".", do: {:token, :dot}
  defrule "->", do: {:token, :right_arrow}

  # operators
  defrule "~>", do: {:token, :pipe}

  # string
  defrule ~l/''/, do: {:string, ""}
  defrule ~l/'/, do: :single_quote
  defrule ~l/(\\'|[^'])+/, :single_quote, do: {:string, String.replace(token_val, "\\\'", "'")}
  defrule ~l/'/, :single_quote, do: nil

  defrule ~l/""/, do: {:bit_string, ""}
  defrule ~l/"/, do: :double_quote

  defrule ~l/(\\"|[^"])+/, :double_quote, do: {:bit_string, String.replace(token_val, "\\\"", "\"")}

  defrule ~l/"/, :double_quote, do: nil

  # float
  defrule ~l/[{DIGIT}]+\\.[{DIGIT}]+/, do: {:float, String.to_float(token_val)}

  # integer
  defrule ~l/0x[{HEX}]+/ do
    [_, i] = String.split(token_val, "x")
    {:integer, String.to_integer(i, 16)}
  end

  defrule ~l/0b[{BINARY}]+/ do
    [_, i] = String.split(token_val, "b")
    {:integer, String.to_integer(i, 2)}
  end

  defrule ~l/[{PDIGIT}][{DIGIT}]*/, do: {:integer, String.to_integer(token_val)}
  defrule ~l/0/, do: {:integer, 0}

  # whitespace and new_line
  defrule ~l/[{WS}]+/, do: :skip_token
  defrule ~l/[{NL}]+/, do: :skip_token

  # comments
  defrule ~l/\/\//, do: :comment
  defrule ~l/[^{NL}]+/, :comment, do: {:comment, token_val}
  defrule ~l/[{NL}]+/, :comment, do: nil

  # identifier
  defrule ~l/[{WORD}][{DIGIT_WORD}]*[\?|\!]?/, do: {:identifier, token_val}
end
