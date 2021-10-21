defmodule Retrospector.Retro.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :board_id, Ecto.UUID
    field :column_id, Ecto.UUID
    field :content, :string

    timestamps()
  end

  @doc false
  def changeset(card, attrs) do
    card
    |> cast(attrs, [:content, :board_id, :column_id])
    |> validate_required([:board_id, :column_id])
  end
end
