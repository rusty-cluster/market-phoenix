defmodule MarketWeb.Vendor.RegistrationJSON do
  def show(%{vendor: vendor}) do
    %{id: vendor.id}
  end
end
