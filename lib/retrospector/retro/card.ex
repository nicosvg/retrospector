defmodule Retrospector.Retro.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :board_id, Ecto.UUID
    field :column_id, Ecto.UUID
    field :content, :string
    field :user_id, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:content, :board_id, :column_id, :user_id])
    |> validate_required([:content, :board_id, :column_id, :user_id])
  end
end
