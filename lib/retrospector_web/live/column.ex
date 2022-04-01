defmodule RetrospectorWeb.ColumnForm do
  use RetrospectorWeb, :live_component

  import Phoenix.LiveView.Helpers

  alias Retrospector.Retro
  alias Retrospector.Retro.Card

  # def columnForm(assigns) do
  #   IO.inspect(assigns, label: "assigns")
  #   board_id = assigns.board_id
  #   column_id = assigns.column_id
  #   changeset = Retro.change_card(%Card{}, %{board_id: board_id, column_id: column_id})
  #   IO.inspect(changeset, label: "changeset")

  #   ~H"""
  #     <div>
  #       <button class="primary-button" phx-click="click">
  #         bouton
  #       </button>
  #     </div>
  #   """
  # end

  def render(assigns) do
    ~H"""
    <form phx-submit="add" phx-target={@myself}>
      <textarea name="content" class="flex grow rounded text-gray-600 w-full" />
      <input name="board_id" value={assigns.board_id} type="hidden"/>
      <input name="column_id" value={assigns.column_id} type="hidden"/>
      <div class="flex justify-center">
        <%= submit "Add", class: "primary-button" %>
      </div>
    </form>
    """
  end

  def handle_event("add", card_params, socket) do
    IO.inspect(card_params, label: "card params")

    if card_params["content"] != "" do
      Retro.create_card(card_params)
    end

    {:noreply, socket}
  end
end
