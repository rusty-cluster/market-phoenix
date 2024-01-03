defmodule MarketWeb.Retailer.SessionController do
  use MarketWeb, :controller

  alias Market.Accounts
  alias MarketWeb.RetailerAuth

  action_fallback MarketWeb.FallbackController

  def create(conn, %{"retailer" => retailer_params}) do
    %{"email" => email, "password" => password} = retailer_params

    if retailer = Accounts.get_retailer_by_email_and_password(email, password) do
      conn
      |> RetailerAuth.log_in_retailer(retailer, retailer_params)
      |> put_status(:created)
      |> render(:show, retailer: retailer)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, :error, error_message: "Invalid email or password")
    end
  end

  def show(conn, _params) do
    conn = RetailerAuth.fetch_current_retailer(conn, [])

    if conn.assigns.current_retailer do
      render(conn, :show, retailer: conn.assigns.current_retailer)
    else
      send_resp(conn, :not_found, "")
    end
  end

  def delete(conn, _params) do
    conn
    |> RetailerAuth.log_out_retailer()
    |> send_resp(:no_content, "")
  end
end
