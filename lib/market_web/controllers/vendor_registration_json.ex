defmodule MarketWeb.VendorRegistrationJSON do
  def show(%{vendor: vendor}) do
    %{id: vendor.id}
  end
end
