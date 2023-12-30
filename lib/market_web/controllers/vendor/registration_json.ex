defmodule MarketWeb.Vendor.RegistrationJSON do
  def show(%{vendor: vendor}) do
    %{id: vendor.id, email: vendor.email, name: vendor.name}
  end
end
