defmodule Retrospector.Retro.Board do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "boards" do
    field :name, :string
    field :reveal_date, :utc_datetime

    has_many :columns, Retrospector.Retro.Column

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:name, :reveal_date])
    |> validate_required([:name])
  end
end
