defmodule MarketWeb.Retailer.SessionControllerTest do
  use MarketWeb.ConnCase, async: true

  import Market.AccountsFixtures

  setup do
    %{retailer: retailer_fixture()}
  end

  describe "POST /retailers/log_in" do
    test "logs the retailer in", %{conn: conn, retailer: retailer} do
      conn =
        conn
        |> init_test_session([])
        |> post(~p"/retailers/log_in", %{
          "retailer" => %{"email" => retailer.email, "password" => valid_retailer_password()}
        })

      assert get_session(conn, :retailer_token)

      # Now do a logged in request and assert on the menu
      # conn = get(conn, ~p"/")
      # response = html_response(conn, 200)
      # assert response =~ retailer.email
      # assert response =~ ~p"/retailers/settings"
      # assert response =~ ~p"/retailers/log_out"
    end

    test "logs the retailer in with remember me", %{conn: conn, retailer: retailer} do
      conn = init_test_session(conn, [])

      conn =
        post(conn, ~p"/retailers/log_in", %{
          "retailer" => %{
            "email" => retailer.email,
            "password" => valid_retailer_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_market_web_retailer_remember_me"]
    end

    test "emits error message with invalid credentials", %{conn: conn, retailer: retailer} do
      conn =
        conn
        |> init_test_session([])
        |> post(~p"/retailers/log_in", %{
          "retailer" => %{"email" => retailer.email, "password" => "invalid_password"}
        })

      assert %{"errors" => _} = json_response(conn, 200)
    end
  end

  describe "DELETE /retailers/log_out" do
    test "logs the retailer out", %{conn: conn, retailer: retailer} do
      conn =
        conn |> init_test_session([]) |> log_in_retailer(retailer) |> delete(~p"/retailers/log_out")

      refute get_session(conn, :retailer_token)
    end

    test "succeeds even if the retailer is not logged in", %{conn: conn} do
      conn = conn |> init_test_session([]) |> delete(~p"/retailers/log_out")
      refute get_session(conn, :retailer_token)
    end
  end
end
