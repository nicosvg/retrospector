defmodule Retrospector.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :content, :string
      add :board_id, :uuid
      add :column_id, :uuid
      add :user_id, :uuid

      timestamps()
    end
  end
end
