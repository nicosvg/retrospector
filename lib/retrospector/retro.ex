defmodule Retrospector.Retro do
  @moduledoc """
  The Retro context.
  """
  require Logger
  import Ecto.Query, warn: false
  alias Phoenix.PubSub

  alias Retrospector.Repo
  alias Retrospector.Retro.Board
  alias Retrospector.Retro.Column
  alias Retrospector.Retro.Card
  alias Retrospector.Retro.User

  @doc """
  Returns the list of boards.

  ## Examples

      iex> list_boards()
      [%Board{}, ...]

  """
  def list_boards do
    Repo.all(Board)
  end

  @doc """
  Gets a single board.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board!(123)
      %Board{}



      iex> get_board!(456)
      ** (Ecto.NoResultsError)

  """
  def get_board!(id) do
    Repo.one(
      from board in Board,
        where: board.id == ^id,
        preload: [:columns, columns: :cards]
    )
    |> IO.inspect(label: "loaded boads")
  end

  def get_column(id) do
    Repo.one(
      from column in Column,
        where: column.id == ^id,
        preload: [:cards]
    )
  end

  @doc """
  Creates a board.

  ## Examples

      iex> create_board(%{field: value})
      {:ok, %Board{}}

      iex> create_board(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
    |> IO.inspect()
    |> create_default_columns
  end

  @doc """
  Creates default columns for a board.
  """
  def create_default_columns({:ok, board}) do
    first = %Column{title: "Went well", position: 0, board_id: board.id}
    second = %Column{title: "To improve", position: 1, board_id: board.id}
    third = %Column{title: "Actions", position: 2, board_id: board.id}
    Enum.map([first, second, third], &Repo.insert/1)
    {:ok, board}
  end

  @doc """
  Updates a board.

  ## Examples

      iex> update_board(board, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board(board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  def start_timer(board_id) do
    Logger.info("Start timer for board: #{board_id}")

    # 5 minutes
    seconds = 300
    date = DateTime.now!("Etc/UTC")
    reveal_date = date |> DateTime.add(seconds, :second, Calendar.UTCOnlyTimeZoneDatabase)

    board =
      Repo.one(
        from board in Board,
          where: board.id == ^board_id
      )

    board
    |> Board.changeset(%{reveal_date: reveal_date})
    |> Repo.update()

    PubSub.broadcast(Retrospector.PubSub, "start:" <> board_id, {:start, reveal_date})

    :timer.apply_after(seconds * 1000, Retrospector.Retro, :reveal, [board_id])
  end

  def stop_timer(board_id) do
    Logger.debug("Stopping timer for board: #{board_id}")

    reveal_date = DateTime.now!("Etc/UTC")

    Repo.one(
      from board in Board,
        where: board.id == ^board_id
    )
    |> Board.changeset(%{reveal_date: reveal_date})
    |> Repo.update()

    reveal(board_id)
  end

  def reveal(board_id) do
    board =
      Repo.one(
        from board in Board,
          where: board.id == ^board_id
      )

    if DateTime.compare(board.reveal_date, DateTime.now!("Etc/UTC")) == :lt do
      Logger.debug("Revealing board: #{board_id}")
      PubSub.broadcast(Retrospector.PubSub, "reveal:" <> board_id, :reveal)
    else
      Logger.debug("Not revealing board, timer running")
    end
  end

  @doc """
  Deletes a board.

  ## Examples

      iex> delete_board(board)
      {:ok, %Board{}}

      iex> delete_board(board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_board(%Board{} = board) do
    Repo.delete(board)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board changes.

  ## Examples

      iex> change_board(board)
      %Ecto.Changeset{data: %Board{}}

  """
  def change_board(%Board{} = board, attrs \\ %{}) do
    Board.changeset(board, attrs)
  end

  def change_card(%Card{} = card, attrs \\ %{}) do
    Card.changeset(card, attrs)
  end

  def create_card(attrs \\ %{}) do
    Logger.debug("Creating card")

    %Card{}
    |> Card.changeset(attrs)
    |> IO.inspect
    |> Repo.insert()
    |> IO.inspect
    |> broadcast(:card_created)
  end
  
  def get_users(board_id) do
    Repo.all(
      from user in User,
        where: user.board_id == ^board_id
    )
    |> IO.inspect(label: "list users")
  end

  def create_user(attrs \\ %{}) do
    Logger.debug("Creating user")

    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> IO.inspect
  end

  def subscribe do
    PubSub.subscribe(Retrospector.PubSub, "cards")
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, card}, event) do
    PubSub.broadcast(Retrospector.PubSub, "cards", {event, card})
    {:ok, card}
  end
end
