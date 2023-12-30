defmodule MarketWeb.Retailer.SessionJSON do
  def show(%{retailer: retailer}) do
    %{id: retailer.id, email: retailer.email, name: retailer.name}
  end

  def error(_) do
    %{errors: "🐗"}
  end
end
