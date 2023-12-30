defmodule MarketWeb.Retailer.RegistrationJSON do
  def show(%{retailer: retailer}) do
    %{id: retailer.id, email: retailer.email, name: retailer.name}
  end
end
