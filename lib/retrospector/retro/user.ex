defmodule Retrospector.Retro.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "users" do
    field :name, :string
    field :color, :string
  end

  @doc false
  def changeset(column, attrs) do
    column
    |> cast(attrs, [:id, :name, :color])
    |> validate_required([:color])
    |> IO.inspect
  end
end
