defmodule MarketWeb.Vendor.SessionControllerTest do
  use MarketWeb.ConnCase, async: true

  import Market.AccountsFixtures

  setup do
    %{vendor: vendor_fixture()}
  end

  describe "POST /vendors/log_in" do
    test "logs the vendor in", %{conn: conn, vendor: vendor} do
      conn =
        conn
        |> init_test_session([])
        |> post(~p"/vendors/log_in", %{
          "vendor" => %{"email" => vendor.email, "password" => valid_vendor_password()}
        })

      assert get_session(conn, :vendor_token)

      conn = get(conn, ~p"/vendors/show")
      response = json_response(conn, 200)
      assert %{"name" => vendor.name, "email" => vendor.email, "id" => vendor.id} == response
    end

    test "logs the vendor in with remember me", %{conn: conn, vendor: vendor} do
      conn = init_test_session(conn, [])

      conn =
        post(conn, ~p"/vendors/log_in", %{
          "vendor" => %{
            "email" => vendor.email,
            "password" => valid_vendor_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_market_web_vendor_remember_me"]
    end

    test "emits error message with invalid credentials", %{conn: conn, vendor: vendor} do
      conn =
        conn
        |> init_test_session([])
        |> post(~p"/vendors/log_in", %{
          "vendor" => %{"email" => vendor.email, "password" => "invalid_password"}
        })

      assert %{"errors" => _} = json_response(conn, 200)
    end
  end

  describe "DELETE /vendors/log_out" do
    test "logs the vendor out", %{conn: conn, vendor: vendor} do
      conn =
        conn |> init_test_session([]) |> log_in_vendor(vendor) |> delete(~p"/vendors/log_out")

      refute get_session(conn, :vendor_token)
    end

    test "succeeds even if the vendor is not logged in", %{conn: conn} do
      conn = conn |> init_test_session([]) |> delete(~p"/vendors/log_out")
      refute get_session(conn, :vendor_token)
    end
  end
end
