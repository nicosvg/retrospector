defmodule Retrospector.Repo.Migrations.CreateColumns do
  use Ecto.Migration

  def change do
    create table(:columns, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :position, :integer
      add :board_id, :binary_id

      timestamps()
    end
  end
end
