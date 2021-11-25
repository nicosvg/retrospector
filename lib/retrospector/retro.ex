defmodule Retrospector.Retro do
  @moduledoc """
  The Retro context.
  """

  import Ecto.Query, warn: false
  alias Phoenix.PubSub

  alias Retrospector.Repo
  alias Retrospector.Retro.Board
  alias Retrospector.Retro.Column
  alias Retrospector.Retro.Card

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

  def start_timer(id) do
    seconds = 300
    date = DateTime.now!("Etc/UTC")
    reveal_date = date |> DateTime.add(seconds, :second, Calendar.UTCOnlyTimeZoneDatabase)
    board = Repo.one(
      from board in Board,
        where: board.id == ^id
    )
    board
    |> Board.changeset(%{reveal_date: reveal_date})
    |> Repo.update()

    :timer.apply_after(seconds * 1000, Retrospector.Retro, :reveal, [id])
  end

  def reveal(id) do
    PubSub.broadcast(Retrospector.PubSub, "reveal:" <> id, :reveal)
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
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:card_created)
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
