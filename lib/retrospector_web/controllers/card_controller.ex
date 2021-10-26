defmodule RetrospectorWeb.CardController do
  use RetrospectorWeb, :controller

  alias Retrospector.Retro
  alias Retrospector.Retro.Card

  def new(conn, params) do
    board_id = params["board_id"]
    column_id = params["column_id"]
    IO.inspect(params, label: "params")
    changeset = Retro.change_card(%Card{}, %{board_id: board_id, column_id: column_id})
    IO.inspect(changeset, label: "changeset")
    render(conn, "new.html", changeset: changeset, board_id: board_id, column_id: column_id)
  end

  def create(conn, %{"card" => card_params}) do
    IO.puts("Creating card")
    send(self(), :create_card)

    case Retro.create_card(card_params) do
      {:ok, _card} ->
        conn
        |> redirect(to: Routes.board_path(conn, :show, card_params["board_id"]))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, board_id: "1")
    end
  end
end
