defmodule Retrospector.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false
      add :name, :string
      add :color, :string
    end

    alter table(:cards) do
      remove :user_id
    end

    alter table(:cards) do
      add :user_id, references(:users, type: :uuid)
    end
  end

  def down do
    drop table(:users)
  end
end
