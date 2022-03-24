defmodule RetrospectorWeb.BoardLive do
  use RetrospectorWeb, :live_view

  alias Phoenix.PubSub
  alias Retrospector.Retro
  alias Retrospector.Retro.Card

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Retro.subscribe()
    board = Retro.get_board!(session["board_id"])
    changeset = Retro.change_card(%Card{}, %{board_id: board.id})

    if connected?(socket), do: PubSub.subscribe(Retrospector.PubSub, "reveal:" <> board.id)
    if connected?(socket), do: PubSub.subscribe(Retrospector.PubSub, "start:" <> board.id)

    {:ok,
     assign(socket,
       changeset: changeset,
       columns: board.columns,
       board: board,
       cards: Enum.flat_map(board.columns, fn c -> c.cards end),
       revealed: is_revealed(board.reveal_date),
       seconds: nil,
       form_params: %{}
     )}
  end

  def is_revealed(reveal_date) do
    reveal_date != nil && DateTime.compare(reveal_date, DateTime.now!("Etc/UTC")) == :lt
  end

  @impl true
  def handle_info({:card_created, card}, socket) do
    {:noreply, update(socket, :cards, fn cards -> [card | cards] end)}
  end

  @impl true
  def handle_info(:reveal, socket) do
    {:noreply, update(socket, :revealed, fn _r -> true end)}
  end

  @impl true
  def handle_info({:start, reveal_date}, socket) do
    Process.send_after(self(), :update_timer, 0)
    socket = update(socket, :revealed, fn _r -> false end)
    socket = update(socket, :board, fn b -> %{b | :reveal_date => reveal_date} end)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:update_timer, socket) do
    date = socket.assigns.board.reveal_date
    remaining = Time.diff(date, Time.utc_now())

    if remaining < 0 do
      {:noreply, update(socket, :revealed, fn _ -> true end)}
    else
      Process.send_after(self(), :update_timer, 3000)
      {:noreply, update(socket, :seconds, fn _s -> remaining end)}
    end
  end

  @impl true
  def handle_event("save", %{"card" => card_params}, socket) do
    Retro.create_card(card_params)
    {:noreply, socket}
  end

  # Handle click on "start timer" button
  def handle_event("start_timer", _value, socket) do
    Retro.start_timer(socket.assigns.board.id)
    {:noreply, socket}
  end

  def handle_event("validate", %{"card" => _params}, socket) do
    IO.inspect("validate")

    {:noreply, socket}
  end

  def format_seconds(seconds) when seconds == nil, do: "?"

  def format_seconds(seconds) do
    minutes = div(seconds, 60)
    sec = rem(seconds, 60)
    Integer.to_string(minutes) <> ":" <> String.pad_leading(Integer.to_string(sec), 2, "0")
  end

  def get_reveal(reveal_date) do
    Time.diff(reveal_date, Time.utc_now())
  end
end
