defmodule RetrospectorWeb.Components.Card do
  use RetrospectorWeb, :live_component

  import Phoenix.LiveView.Helpers
  alias RetrospectorWeb.Colors

  def render(assigns) do
    card_user = Enum.find(assigns.users, fn u -> u.id == assigns.card.user_id end)

    ~H"""
    <div class={"rounded p-4 mb-4 text-gray-200 whitespace-normal w-full " <> Colors.getColorClass(card_user.color)}>
      <%= if @revealed || @card.user_id == @current_user.id do %>
        <%= @card.content %>
      <% else %>
      ...
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
