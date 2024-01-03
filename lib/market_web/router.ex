defmodule MarketWeb.Router do
  use MarketWeb, :router

  import MarketWeb.VendorAuth
  import MarketWeb.RetailerAuth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :vendor_api do
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_vendor
    plug :require_authenticated_vendor
  end

  pipeline :retailer_api do
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_retailer
    plug :require_authenticated_retailer
  end

  scope "/", MarketWeb do
    pipe_through :api

    post "/vendors/register", Vendor.RegistrationController, :create
    post "/vendors/log_in", Vendor.SessionController, :create
    delete "/vendors/log_out", Vendor.SessionController, :delete
    get "/vendors/show", Vendor.SessionController, :show

    post "/retailers/register", Retailer.RegistrationController, :create
    post "/retailers/log_in", Retailer.SessionController, :create
    delete "/retailers/log_out", Retailer.SessionController, :delete
    get "/retailers/show", Retailer.SessionController, :show
  end

  scope "/vendors", MarketWeb.Vendor do
    pipe_through [:api, :vendor_api]

    resources "/products", ProductController, only: [:index, :show, :create, :delete, :update]
    resources "/categories", CategoryController, only: [:index, :show, :create, :delete, :update]
    resources "/orders", OrderController, only: [:index, :show, :update]
  end

  scope "/retailers", MarketWeb.Retailer do
    pipe_through [:api, :retailer_api]

    resources "/products", ProductController, only: [:index, :show]
    resources "/orders", OrderController, only: [:index, :show, :update, :create, :delete]
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:market, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
