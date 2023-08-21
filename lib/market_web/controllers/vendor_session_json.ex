defmodule MarketWeb.VendorSessionJSON do
  def show(%{vendor: vendor}) do
    %{id: vendor.id}
  end

  def error(_) do
    %{errors: "🐗"}
  end
end
