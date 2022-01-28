defmodule ProdealElixir.Repo do
  use Ecto.Repo,
    otp_app: :prodeal_elixir,
    adapter: Ecto.Adapters.Postgres
end
