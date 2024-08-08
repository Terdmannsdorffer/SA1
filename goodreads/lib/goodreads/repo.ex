defmodule Goodreads.Repo do
  use Ecto.Repo,
    otp_app: :goodreads,
    adapter: Ecto.Adapters.Postgres
end
