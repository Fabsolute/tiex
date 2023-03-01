defmodule Tiex.Machina.Parse do
  require __MODULE__

  defmacro __using__(root: root_state) do
    quote do
      @rules []
      @action_counter 0
      @root_state unquote(root_state)
      import Kernel, except: [or: 2, and: 2]
      import unquote(__MODULE__)
      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def parse(tokens) do
        tokens
      end
    end
  end

  defmacro defrule(name, is_terminal, do: context) do
    :ok
  end

  defmacro defterm(name, do: context) do
    quote do
      defrule(unquote(name), true, do: unquote(context))
    end
  end

  defmacro defnterm(name, do: context) do
    quote do
      defrule(unquote(name), false, do: unquote(context))
    end
  end

  defmacro repeat(value) do
    quote bind_quoted: [value: value] do
      {:repeat, value}
    end
  end

  def left or right do
    left =
      case left do
        [content | _] when is_list(content) ->
          left

        _ ->
          [left]
      end

    right =
      if is_list(right) do
        right
      else
        [right]
      end

    [left, right]
  end

  def left and right do
    if is_list(left) do
      left ++ [right]
    else
      [left, right]
    end
  end
end
