defmodule Retrospector.Retro.Column do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "columns" do
    field :board_id, Ecto.UUID
    field :position, :integer
    field :title, :string

    has_many :cards, Retrospector.Retro.Card

    timestamps()
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:title, :position, :board_id])
    |> validate_required([:title, :position, :board_id])
  end
end
