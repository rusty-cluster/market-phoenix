defmodule MarketWeb.Vendor.SessionJSON do
  def show(%{vendor: vendor}) do
    %{id: vendor.id, email: vendor.email, name: vendor.name}
  end

  def error(_) do
    %{errors: "🐗"}
  end
end
