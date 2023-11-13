defmodule MarketWeb.RetailerAuth do
  use MarketWeb, :verified_routes

  import Plug.Conn

  alias Market.Accounts

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in RetailerToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_market_web_retailer_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  def log_in_retailer(conn, retailer, params \\ %{}) do
    token = Accounts.generate_retailer_session_token(retailer)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> maybe_write_remember_me_cookie(token, params)
  end

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    put_resp_cookie(conn, @remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params) do
    conn
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  def log_out_retailer(conn) do
    retailer_token = get_session(conn, :retailer_token)
    retailer_token && Accounts.delete_retailer_session_token(retailer_token)

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
  end

  @doc """
  Authenticates the retailer by looking into the session
  and remember me token.
  """
  def fetch_current_retailer(conn, _opts) do
    {retailer_token, conn} = ensure_retailer_token(conn)
    retailer = retailer_token && Accounts.get_retailer_by_session_token(retailer_token)
    assign(conn, :current_retailer, retailer)
  end

  defp ensure_retailer_token(conn) do
    if token = get_session(conn, :retailer_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_token_in_session(conn, token)}
      else
        {nil, conn}
      end
    end
  end

  defp put_token_in_session(conn, token) do
    put_session(conn, :retailer_token, token)
  end

  def require_authenticated_retailer(conn, _opts) do
    if conn.assigns[:current_retailer] do
      conn
    else
      conn |> send_resp(401, "Unauthorized") |> halt()
    end
  end
end
