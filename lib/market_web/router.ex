defmodule MarketWeb.Router do
  use MarketWeb, :router

  import MarketWeb.VendorAuth

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :vendor_api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_vendor
  end

  scope "/", MarketWeb do
    pipe_through :api

    post "/vendors/register", VendorRegistrationController, :create

    post "/vendors/log_in", VendorSessionController, :create
    delete "/vendors/log_out", VendorSessionController, :delete
  end

  scope "/", MarketWeb do
    pipe_through [:vendor_api, :require_authenticated_vendor]

    resources "/vendors/products", VendorProductController,
      only: [:index, :show, :create, :delete, :update]

    resources "/categories", CategoryController,
      only: [:index, :show, :create, :delete, :update]

    resources "/vendors/orders", VendorOrderController, only: [:index, :show, :update]
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:market, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
