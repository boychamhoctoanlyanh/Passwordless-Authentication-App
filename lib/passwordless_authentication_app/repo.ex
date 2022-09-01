defmodule PasswordlessAuthenticationApp.Repo do
  use Ecto.Repo,
    otp_app: :passwordless_authentication_app,
    adapter: Ecto.Adapters.Postgres
end
