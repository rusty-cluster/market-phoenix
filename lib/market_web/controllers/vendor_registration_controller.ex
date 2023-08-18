defmodule MarketWeb.VendorRegistrationController do
  use MarketWeb, :controller

  alias Market.Accounts
  alias MarketWeb.VendorAuth

  action_fallback MarketWeb.FallbackController

  def create(conn, %{"vendor" => vendor_params}) do
    with {:ok, vendor} <- Accounts.register_vendor(vendor_params) do
      conn
      |> VendorAuth.log_in_vendor(vendor)
      |> put_status(:created)
      |> render(:show, vendor: vendor)
    end
  end
end
