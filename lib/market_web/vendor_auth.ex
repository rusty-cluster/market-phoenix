defmodule MarketWeb.VendorAuth do
  use MarketWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  alias Market.Accounts

  # Make the remember me cookie valid for 60 days.
  # If you want bump or reduce this value, also change
  # the token expiry itself in VendorToken.
  @max_age 60 * 60 * 24 * 60
  @remember_me_cookie "_market_web_vendor_remember_me"
  @remember_me_options [sign: true, max_age: @max_age, same_site: "Lax"]

  @doc """
  Logs the vendor in.

  It renews the session ID and clears the whole session
  to avoid fixation attacks. See the renew_session
  function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session,
  so LiveView sessions are identified and automatically
  disconnected on log out. The line can be safely removed
  if you are not using LiveView.
  """
  def log_in_vendor(conn, vendor, params \\ %{}) do
    token = Accounts.generate_vendor_session_token(vendor)

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

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  @doc """
  Logs the vendor out.

  It clears all session data for safety. See renew_session.
  """
  def log_out_vendor(conn) do
    vendor_token = get_session(conn, :vendor_token)
    vendor_token && Accounts.delete_vendor_session_token(vendor_token)

    if live_socket_id = get_session(conn, :live_socket_id) do
      MarketWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie)
  end

  @doc """
  Authenticates the vendor by looking into the session
  and remember me token.
  """
  def fetch_current_vendor(conn, _opts) do
    {vendor_token, conn} = ensure_vendor_token(conn)
    vendor = vendor_token && Accounts.get_vendor_by_session_token(vendor_token)
    assign(conn, :current_vendor, vendor)
  end

  defp ensure_vendor_token(conn) do
    if token = get_session(conn, :vendor_token) do
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

  @doc """
  Used for routes that require the vendor to be authenticated.

  If you want to enforce the vendor email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_vendor(conn, _opts) do
    if conn.assigns[:current_vendor] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:vendor_token, token)
    |> put_session(:live_socket_id, "vendors_sessions:#{Base.url_encode64(token)}")
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :vendor_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/"
end
