defmodule Tiex.Machina.Lex do
  alias __MODULE__.Sigils
  alias __MODULE__.Lexer

  defmacro __using__(_opts) do
    quote do
      @rules []
      @action_counter 0
      import unquote(__MODULE__)
      use unquote(__MODULE__).Sigils

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def lex(text) do
        Lexer.lex(__MODULE__, @rules, text)
      end
    end
  end

  defmacro defnamed(names) do
    quote do
      Enum.each(unquote(names), fn {name, value} ->
        Sigils.put(name, value)
      end)
    end
  end

  defmacro defrule(regex, state, do: context) when is_atom(regex) do
    value = Atom.to_string(regex)

    quote do
      defrule unquote(value), unquote(state), do: unquote(context)
    end
  end

  defmacro defrule(regex, state, do: context) when is_bitstring(regex) do
    value = Regex.escape(regex)

    quote do
      defrule ~l/#{unquote(value)}/r, unquote(state), do: unquote(context)
    end
  end

  defmacro defrule(regex, state, do: context) do
    quote do
      regex = Macro.escape(unquote(regex))
      @action_counter @action_counter + 1
      action_name = "_action_#{@action_counter}" |> String.to_atom()

      context = unquote(Macro.escape(context))

      [val_name, len_name, line_name] =
        Enum.map(["val", "len", "line"], fn v ->
          if String.contains?(Macro.to_string(context), "token_#{v}") do
            "token_#{v}"
          else
            "_token_#{v}"
          end
        end)

      action =
        quote do
          def unquote(:"#{action_name}")(token_val, token_len, token_line) do
            unquote(context)
          end
        end
        |> Macro.to_string()
        |> String.replace("token_val", val_name)
        |> String.replace("token_len", len_name)
        |> String.replace("token_line", line_name)
        |> Code.string_to_quoted!()

      Module.eval_quoted(__MODULE__, action)

      @rules @rules ++ [{unquote(state), regex, action_name}]

      :ok
    end
  end

  defmacro defrule(regex, do: context) do
    quote do
      defrule(unquote(regex), :default, do: unquote(context))
    end
  end
end
