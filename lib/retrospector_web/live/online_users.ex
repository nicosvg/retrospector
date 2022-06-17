defmodule RetrospectorWeb.Components.OnlineUsers do
  use RetrospectorWeb, :live_component

  import Phoenix.LiveView.Helpers
  alias RetrospectorWeb.Colors

  def render(assigns) do
    ~H"""
    <div class="mt-2">
    <h2 class="text-s">Users online:
      <span class="text-s bg-amber-800 rounded px-2 py-1">
        <%= Enum.count(@users) %>
      </span>
    </h2>
    <div>
      <%= for {user_id, user} <- @users do %>
        <%= if user_id == @current_user[:id] do %>
          <span class={"text-xs rounded px-2 py-1 " <> Colors.getColorClass(user[:color])}>me</span>
        <% else %>
          <span class={"text-xs rounded px-2 py-1 w-4 " <> Colors.getColorClass(user[:color])}>&nbsp</span>
        <% end %>
      <% end %>
    </div>

    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
