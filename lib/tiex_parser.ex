defmodule Tiex.Parser do
  use Tiex.Machina.Parse, root: :module

  defterm :module do
    {:keyword, :module} and
      {:token, :identifier} and
      {:punctuation, :left_brace} and
      :functions and
      {:punctuation, :right_brace}
  end

  defnterm :functions do
    (:function and :functions) or
      :function
  end

  defterm :function do
    {:keyword, :function} and
      {:token, :identifier} and
      {:punctuation, :left_parenthesis} and
      :arguments and
      {:punctuation, :right_parenthesis} and
      {:punctuation, :left_brace} and
      :expression and
      {:punctuation, :right_brace}
  end

  defnterm :arguments do
    (:argument and :comma and :arguments) or
      :argument or
      :empty
  end

  defterm :argument do
    {:token, :identifier}
  end

  defterm :expression do
    (:function_call and {:operator, :pipe} and :expression) or
      :function_call or
      :inline_function or
      :tuple or
      {:token, :string} or
      {:token, :bit_string} or
      {:token, :integer} or
      {:token, :float} or
      :empty
  end

  defterm :inline_function do
    {:punctuation, :left_parenthesis} and
      :arguments and
      {:punctuation, :right_parenthesis} and
      {:punctuation, :right_arrow} and
      (({:punctuation, :left_brace} and :expression and {:punctuation, :right_brace}) or
         :expression)
  end

  defterm :function_call do
    :function_name and
      {:punctuation, :left_parenthesis} and
      :parameters and
      {:punctuation, :right_parenthesis}
  end

  defnterm :function_name do
    ({:token, :identifier} and {:punctuation, :dot} and {:token, :identifier}) or
      {:token, :identifier}
  end

  defnterm :parameters do
    (:expression and :comma and :parameters) or :expression
  end

  defterm :tuple do
    {:punctuation, :left_brace} and
      :parameters and
      {:punctuation, :right_brace}
  end
end
