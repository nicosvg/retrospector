defmodule RetrospectorWeb.Components.Card do
  use RetrospectorWeb, :live_component

  import Phoenix.LiveView.Helpers

  def render(assigns) do
    colors = %{"sky" => "bg-sky-800",
    "amber" => "bg-amber-800",
    "teal" => "bg-teal-800",
    "gray" => "bg-gray-800"
    }

    ~H"""
    <div class="rounded p-4 mb-4 bg-gray-700 text-gray-200 whitespace-normal w-full">
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
