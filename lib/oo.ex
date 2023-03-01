defmodule Oo do
  def ee([:oo,:lol|tail]) when length(tail) == 0 do
    :ok
  end

  def ee(x) do
    {:no,x}
  end
end
