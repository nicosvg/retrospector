defmodule RetrospectorWeb.BoardCardsLive do
  use RetrospectorWeb, :live_view

  alias Phoenix.PubSub
  alias Retrospector.Retro
  alias Retrospector.Retro.Card

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Retro.subscribe()
    column = Retro.get_column(session["column_id"])
    changeset = Retro.change_card(%Card{}, %{board_id: column.board_id, column_id: column.id})

    if connected?(socket), do: PubSub.subscribe(Retrospector.PubSub, "reveal:" <> column.board_id)

    {:ok,
     assign(socket,
       changeset: changeset,
       cards: column.cards,
       column_id: column.id,
       board_id: column.board_id,
       revealed: DateTime.compare(session["reveal_date"], DateTime.now!("Etc/UTC")) == :lt
     )}
  end

  @impl true
  def handle_info({:card_created, card}, socket) do
    if card.column_id == socket.assigns.column_id do
      {:noreply, update(socket, :cards, fn cards -> [card | cards] end)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:reveal, socket) do
    {:noreply, update(socket, :revealed, fn _r -> :true end)}
  end

  @impl true
  def handle_event("save", %{"card" => card_params}, socket) do
    Retro.create_card(card_params)
    {:noreply, socket}
  end
end
