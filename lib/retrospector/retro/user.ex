defmodule Retrospector.Retro.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "users" do
    field :name, :string
    field :color, :string
    field :board_id, Ecto.UUID
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:id, :name, :color, :board_id])
    |> validate_required([:color, :board_id])
  end
end
