defmodule MarketWeb.Router do
  use MarketWeb, :router

  import MarketWeb.VendorAuth

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MarketWeb do
    pipe_through :api

    post "/vendors/register", VendorRegistrationController, :create

    post "/vendors/log_in", VendorSessionController, :create
    delete "/vendors/log_out", VendorSessionController, :delete
  end

  scope "/", MarketWeb do
    pipe_through [:api, :require_authenticated_vendor]

    resources "/vendors/products", VendorProductController,
      only: [:index, :show, :create, :delete, :update]

    resources "/vendors/categories", VendorCategoryController,
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
