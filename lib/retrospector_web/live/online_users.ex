defmodule RetrospectorWeb.Components.OnlineUsers do
  use RetrospectorWeb, :live_component

  import Phoenix.LiveView.Helpers

  def render(assigns) do
    ~H"""
    <div class="mt-2">
    <h2 class="text-s">Users online:
      <span class="text-s bg-purple-800 rounded px-2 py-1">
        <%= Enum.count(@users) %>
      </span>
    </h2>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
