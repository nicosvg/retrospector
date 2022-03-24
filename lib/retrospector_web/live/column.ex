defmodule RetrospectorWeb.ColumnForm do
  use Phoenix.Component

  # Optionally also bring the HTML helpers
  # use Phoenix.HTML

  def columnForm(assigns) do
    ~H"""
      <div>
        <.form let={f} for={@changeset} phx-submit="save" class="card-form">
        <%= textarea f, :content, class: "flex grow rounded text-gray-600 w-full" %>
        <%= hidden_input f, :board_id, value: @board.id %>
        <%= hidden_input f, :column_id, value: c.id %>
        <div class="flex justify-center">
          <%= submit "Add", class: "primary-button" %>
        </div>
        </.form>
      </div>
    """
  end
end
