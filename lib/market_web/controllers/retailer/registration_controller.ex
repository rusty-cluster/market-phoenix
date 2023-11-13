defmodule MarketWeb.Retailer.RegistrationController do
  use MarketWeb, :controller

  alias Market.Accounts
  alias MarketWeb.RetailerAuth

  action_fallback MarketWeb.FallbackController

  def create(conn, %{"retailer" => retailer_params}) do
    with {:ok, retailer} <- Accounts.register_retailer(retailer_params) do
      conn
      |> RetailerAuth.log_in_retailer(retailer)
      |> put_status(:created)
      |> render(:show, retailer: retailer)
    end
  end
end
