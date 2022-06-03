defmodule RetrospectorWeb.Components.OnlineUsers do
  use RetrospectorWeb, :live_component

  import Phoenix.LiveView.Helpers

  def render(assigns) do
    colors = %{"sky" => "bg-sky-800",
    "amber" => "bg-amber-800",
    "teal" => "bg-teal-800",
    "gray" => "bg-gray-800"
    }

    ~H"""
    <div class="mt-2">
    <h2 class="text-s">Users online:
      <span class="text-s bg-amber-800 rounded px-2 py-1">
        <%= Enum.count(@current_user) %>
      </span>
    </h2>
    <div>
      <%= for {user_id, user} <- @users do %>
        <%= if user_id == @current_user[:id] do %>
          <span class={"text-xs rounded px-2 py-1 " <> colors[user[:color]]}>me</span>
        <% else %>
          <span class={"text-xs rounded px-2 py-1 w-4 " <> colors[user[:color]]}>&nbsp</span>
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
