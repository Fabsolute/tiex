defmodule Tiex.Machina.Lex.Sigils do
  use GenServer

  @name :tiex_sigil

  defmacro __using__(_opts) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def start() do
    pid = Process.get(@name)

    if pid == nil or !Process.alive?(pid) do
      GenServer.start_link(__MODULE__, [], name: @name)
    end
  end

  def put(key, value) do
    GenServer.cast(@name, {:put, {key, value}})
  end

  def replace(value) do
    GenServer.call(@name, {:replace, value})
  end

  @impl true
  def init([]) do
    {:ok, []}
  end

  @impl true
  def handle_call({:replace, value}, _from, state) do
    replaced =
      String.replace(
        value,
        Enum.map(
          state,
          fn {key, _} -> "{#{key}}" end
        ),
        fn "{" <> key ->
          Keyword.get(state, String.to_existing_atom(String.replace(key, "}", "")))
        end
      )
    {:reply, replaced, state}
  end

  @impl true
  def handle_cast({:put, {name, value}}, state) do
    {:noreply, Keyword.put(state, name, value)}
  end

  def sigil_l(term, []) do
    start()
    ~r/#{replace(term)}/
  end

  def sigil_l(term, [?r]) do
    ~l/^#{term}/
  end

  def sigil_n(term, []) do
    start()
    replace(term)
  end
end
