defmodule RetrospectorWeb.BoardController do
  use RetrospectorWeb, :controller

  alias Retrospector.Retro
  alias Retrospector.Retro.Board

  def index(_conn, _params) do
  end

  def new(conn, _params) do
    changeset = Retro.change_board(%Board{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"board" => board_params}) do
    case Retro.create_board(board_params) do
      {:ok, board} ->
        conn
        |> redirect(to: Routes.board_path(conn, :show, board))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    board = Retro.get_board!(id)
    render(conn, "show.html", board: board)
  end

  def edit(conn, %{"id" => id}) do
    board = Retro.get_board!(id)
    changeset = Retro.change_board(board)
    render(conn, "edit.html", board: board, changeset: changeset)
  end

  def update(conn, %{"id" => id, "board" => board_params}) do
    board = Retro.get_board!(id)

    case Retro.update_board(board, board_params) do
      {:ok, board} ->
        conn
        |> redirect(to: Routes.board_path(conn, :show, board))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", board: board, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    board = Retro.get_board!(id)
    {:ok, _board} = Retro.delete_board(board)

    conn
    |> redirect(to: Routes.board_path(conn, :index))
  end
end
