defmodule MarketWeb.VendorProductController do
  use MarketWeb, :controller

  def create(conn, _params) do
    conn |> send_resp(200, "create") |> halt()
  end

  def index(conn, _params) do
    conn |> send_resp(200, "index") |> halt()
  end

  def show(conn, _params) do
    conn |> send_resp(200, "show") |> halt()
  end

  def update(conn, _params) do
    conn |> send_resp(200, "update") |> halt()
  end

  def delete(conn, _params) do
    conn |> send_resp(200, "delete") |> halt()
  end
end
