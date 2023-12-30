defmodule MarketWeb.Retailer.RegistrationControllerTest do
  use MarketWeb.ConnCase, async: true

  import Market.AccountsFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "POST /retailers/register" do
    @tag :capture_log
    test "creates account and logs the retailer in", %{conn: conn} do
      email = unique_retailer_email()

      conn =
        conn
        |> init_test_session([])
        |> post(~p"/retailers/register", %{
          "retailer" => valid_retailer_attributes(email: email, name: "Company")
        })

      assert get_session(conn, :retailer_token)
      assert %{"id" => _id, "email" => ^email, "name" => "Company"} = json_response(conn, 201)
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/retailers/register", %{
          "retailer" => %{"email" => "with spaces", "password" => "too short"}
        })

      assert json_response(conn, 422)["errors"] != %{}
    end
  end
end
