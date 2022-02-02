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
       revealed: isRevealed(board.reveal_date),
       seconds: 3000
     )}
  end

  def isRevealed(reveal_date) do
    reveal_date == nil || DateTime.compare(reveal_date, DateTime.now!("Etc/UTC")) == :lt
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
  def handle_info(:start, socket) do
    Process.send_after(self(), :update_timer, 1000)
    {:noreply, update(socket, :revealed, fn _r -> false end)}
  end

  def handle_info(:update_timer, socket) do
    # Process.send_after(self(), :update_timer, 1000)
    IO.inspect("coucou here")
    {:noreply, assign(socket, :seconds, fn _s -> 1 end)}
  end

  @impl true
  def handle_event("save", %{"card" => card_params}, socket) do
    Retro.create_card(card_params)
    {:noreply, socket}
  end

  def handle_event("start_timer", _value, socket) do
    Retro.start_timer(socket.assigns.board.id)
    {:noreply, socket}
  end
end
