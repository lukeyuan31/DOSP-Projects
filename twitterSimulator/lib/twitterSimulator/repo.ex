defmodule TwitterSimulator.Repo do
  use Ecto.Repo,
    otp_app: :twitterSimulator,
    adapter: Ecto.Adapters.Postgres
end
