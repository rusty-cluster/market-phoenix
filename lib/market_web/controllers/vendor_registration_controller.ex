defmodule MarketWeb.VendorRegistrationController do
  use MarketWeb, :controller

  alias Market.Accounts
  alias Market.Accounts.Vendor
  alias MarketWeb.VendorAuth

  # def new(conn, _params) do
  #   changeset = Accounts.change_vendor_registration(%Vendor{})
  #   render(conn, :new, changeset: changeset)
  # end

  def create(conn, %{"vendor" => vendor_params}) do
    case Accounts.register_vendor(vendor_params) do
      {:ok, vendor} ->
        {:ok, _} =
          Accounts.deliver_vendor_confirmation_instructions(
            vendor,
            &url(~p"/vendors/confirm/#{&1}")
          )

        conn
        |> put_flash(:info, "Vendor created successfully.")
        |> VendorAuth.log_in_vendor(vendor)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
