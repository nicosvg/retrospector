defmodule RetrospectorWeb.CardController do
  use RetrospectorWeb, :controller

  alias Retrospector.Retro
  alias Retrospector.Retro.Card

  def new(conn, _params) do
    changeset = Retro.change_card(%Card{})
    render(conn, "new.html", changeset: changeset)
  end

#  def create(conn, %{"board" => board_params}) do
#    case Retro.create_board(board_params) do
#      {:ok, board} ->
#        conn
#        |> put_flash(:info, "Board created successfully.")
#        |> redirect(to: Routes.board_path(conn, :show, board))
#
#      {:error, %Ecto.Changeset{} = changeset} ->
#        render(conn, "new.html", changeset: changeset)
#    end
#  end

end
