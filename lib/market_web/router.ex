defmodule MarketWeb.Router do
  use MarketWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MarketWeb do
    pipe_through :api

    post "/vendors/register", VendorRegistrationController, :create

    post "/vendors/log_in", VendorSessionController, :create
    delete "/vendors/log_out", VendorSessionController, :delete
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:market, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
