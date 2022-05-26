defmodule Retrospector.Retro.Card do
  use Ecto.Schema
  import Ecto.Changeset

  schema "cards" do
    field :board_id, Ecto.UUID
    field :column_id, Ecto.UUID
    field :user_id, Ecto.UUID
    field :content, :string
    timestamps()
  end

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(card, attrs) do
    card
    # |> cast(attrs, [:content, :board_id, :column_id])
    |> cast(attrs, [:content, :board_id, :column_id, :user_id])
    # |> cast_assoc(:user)
    |> validate_required([:board_id, :column_id, :user_id])
  end
end
