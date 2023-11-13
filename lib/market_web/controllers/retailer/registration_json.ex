defmodule MarketWeb.Retailer.RegistrationJSON do
  def show(%{retailer: retailer}) do
    %{id: retailer.id}
  end
end
