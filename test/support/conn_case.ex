defmodule MarketWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use MarketWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint MarketWeb.Endpoint

      use MarketWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import MarketWeb.ConnCase
    end
  end

  setup tags do
    Market.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def register_and_log_in_vendor(%{conn: conn}) do
    vendor = Market.AccountsFixtures.vendor_fixture()
    %{conn: log_in_vendor(conn, vendor), vendor: vendor}
  end

  def log_in_vendor(conn, vendor) do
    token = Market.Accounts.generate_vendor_session_token(vendor)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:vendor_token, token)
  end

  def register_and_log_in_retailer(%{conn: conn}) do
    retailer = Market.AccountsFixtures.retailer_fixture()
    %{conn: log_in_retailer(conn, retailer), retailer: retailer}
  end

  def log_in_retailer(conn, retailer) do
    token = Market.Accounts.generate_retailer_session_token(retailer)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:retailer_token, token)
  end
end
