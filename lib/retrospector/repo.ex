defmodule Retrospector.Repo do
  use Ecto.Repo,
    otp_app: :retrospector,
    adapter: Ecto.Adapters.Postgres
end
