defmodule PasswordlessAuthenticationAppWeb.AuthController do
  use PasswordlessAuthenticationAppWeb, :controller

  plug(Ueberauth)
  require HTTPoison
  require Poison
  require Logger
  require IEx

  alias PasswordlessAuthenticationAppWeb.UserFromAuth

  def login(conn, params) do
    url = "https://dev-jirr7i9f.us.auth0.com/oauth/token"
    body = Poison.encode!(%{
      "grant_type": "http://auth0.com/oauth/grant-type/passwordless/otp",
      "client_id": "wBEDm8R20EP3xANQ4gqVvg7LXKOg0O9y",
      "client_secret": "dGODegR-_kNG_mcFRdcwKJMLSZkNRKnS8LKjwQDkqsWJi5Ci6i81lqPqu1471dER",
      "otp": params["verification_code"],
      "realm": "email",
      "username": params["email"]
    })
    headers = [{"Content-type", "application/json"}]
    case HTTPoison.post(url, body, headers, []) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        conn
        |> put_session(:current_user, body)
        |> redirect(to: "/user")
      {:ok, %HTTPoison.Response{body: body}} ->
        IO.inspect body
        conn
          |> put_flash(:error, "Failed to authenticate.")
          |> redirect(to: "/")
      {:error, %HTTPoison.Error{reason: reason}} ->
        conn
          |> put_flash(:error, reason)
          |> redirect(to: "/")
    end
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        # |> put_flash(:info, "Successfully authenticated as " <> user.name <> ".")
        |> put_session(:current_user, user)
        |> redirect(to: "/user")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
