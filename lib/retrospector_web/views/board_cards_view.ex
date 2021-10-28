defmodule RetrospectorWeb.BoardCardsView do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="">
    The live view here!
      <div>
        <%= @cards %>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, cards: [])}
  end

end
