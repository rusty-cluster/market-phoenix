defmodule MarketWeb.Vendor.SessionController do
  use MarketWeb, :controller

  alias Market.Accounts
  alias MarketWeb.VendorAuth

  action_fallback MarketWeb.FallbackController

  def create(conn, %{"vendor" => vendor_params}) do
    %{"email" => email, "password" => password} = vendor_params

    if vendor = Accounts.get_vendor_by_email_and_password(email, password) do
      conn
      |> VendorAuth.log_in_vendor(vendor, vendor_params)
      |> put_status(:created)
      |> render(:show, vendor: vendor)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, :error, error_message: "Invalid email or password")
    end
  end

  def show(conn, _params) do
    conn = VendorAuth.fetch_current_vendor(conn, [])

    if conn.assigns.current_vendor do
      render(conn, :show, vendor: conn.assigns.current_vendor)
    else
      send_resp(conn, :not_found, "")
    end
  end

  def delete(conn, _params) do
    conn
    |> VendorAuth.log_out_vendor()
    |> send_resp(:no_content, "")
  end
end
