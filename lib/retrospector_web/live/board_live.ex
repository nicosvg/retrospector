defmodule RetrospectorWeb.BoardLive do
  use RetrospectorWeb, :live_view

  alias Phoenix.PubSub
  alias Retrospector.Retro
  alias Retrospector.Retro.Card
  alias RetrospectorWeb.Presence

  @presence "retrospector:presence"

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Retro.subscribe()
    board = Retro.get_board!(session["board_id"])
    changeset = Retro.change_card(%Card{}, %{board_id: board.id})

    if connected?(socket), do: PubSub.subscribe(Retrospector.PubSub, "reveal:" <> board.id)
    if connected?(socket), do: PubSub.subscribe(Retrospector.PubSub, "start:" <> board.id)

    reveal_in_seconds = get_reveal(board.reveal_date)

    if reveal_in_seconds > 0 do
      Process.send_after(self(), :update_timer, 0)
    end

    # Generate random name for users to test display, this is currently not used
    # Later, users may be able to enter their name
    name = for _ <- 1..5, into: "", do: <<Enum.random('abcdefghijklmnopqrstuvwxyz')>>
    # Get user color
    # current_users = Enum.count(Presence.list(@presence))
    board_users = Retro.get_users(board.id)
    IO.inspect(board_users, label: "board users")
    colors = ["sky", "amber", "teal"]
    user = %{id: Ecto.UUID.generate, name: name, color: Enum.at(colors, Enum.count(board_users), "gray"), board_id: board.id}
    session = Map.put(session, "current_user", user)

    if connected?(socket) do
      user = session["current_user"]

      {:ok, _} =
        Presence.track(self(), @presence, user[:id], %{
          board_id: board.id,
          name: user[:name],
          color: user[:color],
          joined_at: :os.system_time(:seconds)
        })

      PubSub.subscribe(Retrospector.PubSub, @presence)
      Retro.create_user(user)
    end

    {:ok,
     socket
     |> assign(
       changeset: changeset,
       current_user: session["current_user"],
       users: %{},
       board_users: [user | board_users],
       columns: board.columns,
       board: board,
       cards: Enum.flat_map(board.columns, fn c -> c.cards end),
       revealed: is_revealed(board.reveal_date),
       seconds: reveal_in_seconds,
       form_params: %{}
     )
     |> handle_joins(Presence.list(@presence))}
  end

  def is_revealed(reveal_date) do
    reveal_date != nil && DateTime.compare(reveal_date, DateTime.now!("Etc/UTC")) == :lt
  end

  @impl true
  def handle_info({:card_created, card}, socket) do
    {:noreply, update(socket, :cards, fn cards -> [card | cards] end)}
  end

  @impl true
  def handle_info(:reveal, socket) do
    {:noreply,
    socket
    |> update(:revealed, fn _r -> true end)
    |> update(:seconds, fn _r -> 0 end)
    |> update(:board, fn b -> %{b | reveal_date: DateTime.now!("Etc/UTC")} end)
  }
  end

  @impl true
  def handle_info({:start, reveal_date}, socket) do
    Process.send_after(self(), :update_timer, 0)
    socket = update(socket, :revealed, fn _r -> false end)
    socket = update(socket, :board, fn b -> %{b | :reveal_date => reveal_date} end)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:update_timer, socket) do
    date = socket.assigns.board.reveal_date
    remaining = Time.diff(date, Time.utc_now())

    if remaining < 0 do
      {:noreply, update(socket, :revealed, fn _ -> true end)}
    else
      Process.send_after(self(), :update_timer, 1000)
      {:noreply, update(socket, :seconds, fn _s -> remaining end)}
    end
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {
      :noreply,
      socket
      |> handle_leaves(diff.leaves)
      |> handle_joins(diff.joins)
    }
  end

  @impl true
  # Handle click on "start timer" button
  def handle_event("start_timer", _value, socket) do
    Retro.start_timer(socket.assigns.board.id)
    {:noreply, socket}
  end
  @impl true
  # Handle click on "start timer" button
  def handle_event("stop_timer", _value, socket) do
    Retro.stop_timer(socket.assigns.board.id)
    {:noreply, socket}
  end

  def format_seconds(seconds) when seconds == nil, do: "?"

  def format_seconds(seconds) do
    minutes = div(seconds, 60)
    sec = rem(seconds, 60)
    Integer.to_string(minutes) <> ":" <> String.pad_leading(Integer.to_string(sec), 2, "0")
  end

  def get_reveal(reveal_date) do
    case reveal_date do
      nil -> -1
      _ -> Time.diff(reveal_date, Time.utc_now())
    end
  end

  defp handle_joins(socket, joins) do
    Enum.reduce(joins, socket, fn {user, %{metas: [meta | _]}}, socket ->
      IO.inspect socket, label: "socket"
      if socket.assigns.board != nil && meta.board_id == socket.assigns.board.id do
        assign(socket, :users, Map.put(socket.assigns.users, user, meta))
        else
        socket
      end
    end)
  end

  defp handle_leaves(socket, leaves ) do
    Enum.reduce(leaves, socket, fn {user, _}, socket ->
      assign(socket, :users, Map.delete(socket.assigns.users, user))
    end)
  end
end
