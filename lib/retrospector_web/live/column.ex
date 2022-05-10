defmodule RetrospectorWeb.ColumnForm do
  use RetrospectorWeb, :live_component

  import Phoenix.LiveView.Helpers

  alias Retrospector.Retro

  def render(assigns) do
    ~H"""
    <form phx-submit="add" phx-target={@myself}>
      <textarea name="content" class="flex grow rounded text-gray-600 w-full" ><%= assigns.content %></textarea>
      <input name="board_id" value={assigns.board_id} type="hidden"/>
      <input name="column_id" value={assigns.column_id} type="hidden"/>
      <div class="flex justify-center">
        <%= submit "Add", class: "primary-button" %>
      </div>
    </form>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, :content, "")}
  end

  def handle_event("add", card_params, socket) do
    IO.inspect(card_params, label: "card params")

    if card_params["content"] != "" do
      Retro.create_card(card_params)
    end

    {:noreply, update(socket, :content, fn _s -> "" end)}
  end
end
