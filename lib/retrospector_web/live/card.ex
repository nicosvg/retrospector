defmodule RetrospectorWeb.Components.Card do
  use RetrospectorWeb, :live_component

  import Phoenix.LiveView.Helpers

  def render(assigns) do
    colors = %{"sky" => "bg-sky-800",
    "amber" => "bg-amber-800",
    "teal" => "bg-teal-800",
    "gray" => "bg-gray-800"
    }
    card_user = Enum.find(assigns.users, fn u -> u.id == assigns.card.user_id end)
    card_user_color = case card_user do
    nil -> "gray"
    u -> u.color
    end

    ~H"""
    <div class={"rounded p-4 mb-4 text-gray-200 whitespace-normal w-full " <> colors[card_user_color]}>
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
