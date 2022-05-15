defmodule RetrospectorWeb.ColumnForm do
  use RetrospectorWeb, :live_component

  import Phoenix.LiveView.Helpers

  alias Retrospector.Retro

  def render(assigns) do
    ~H"""
    <form id={"col-form-" <> assigns.column_id} phx-submit="add" phx-target={@myself}>
      <textarea id={"col-input-" <> assigns.column_id} phx-keyup="keyup" phx-target={@myself} name="content" phx-hook="ClearTextArea" class="flex grow rounded text-gray-600 w-full"><%= @content %></textarea>
      <input name="board_id" value={assigns.board_id} type="hidden"/>
      <input name="column_id" value={assigns.column_id} type="hidden"/>
      <div class="flex justify-center">
        <%= submit "Add", class: "primary-button" %>
      </div>
    </form>
    """
  end

  def handle_event("keyup", %{"key" => "Enter", "value" => value}, socket) do
    IO.inspect(socket.assigns, label: "column assigns")
    params=%{content: value, board_id: socket.assigns.board_id, column_id: socket.assigns.column_id}
    handle_event("add", params, socket)
  end
  def handle_event("keyup", %{"key" => _}, socket) do
    {:noreply, socket}
  end

  @spec mount(map) :: {:ok, map}
  def mount(socket) do
    {:ok, assign(socket, :content, "")}
  end

  def handle_event("add", card_params, socket) do
    IO.inspect(card_params, label: "Adding...")
    if card_params["content"] != "" do
      Retro.create_card(card_params)
      # Force update of value to trigger the update hook on the text area
      {:noreply, update(socket, :content, fn s -> s <> " " end)}
    else
      {:noreply, socket}
    end
  end
end
