defmodule Retrospector.Repo.Migrations.AddRevealDate do
  use Ecto.Migration

  def change do
    alter table(:boards) do
      add :reveal_date, :utc_datetime
    end
  end
end
