defmodule MarketWeb.Retailer.SessionJSON do
  def show(%{retailer: retailer}) do
    %{id: retailer.id}
  end

  def error(_) do
    %{errors: "🐗"}
  end
end
