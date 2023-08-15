defmodule MarketWeb.Router do
  use MarketWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MarketWeb do
    pipe_through :api

    post "/vendors/register", VendorRegistrationController, :create
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:market, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes
  # scope "/", MarketWeb do
  #   pipe_through [:browser, :redirect_if_vendor_is_authenticated]
  #
  #   get "/vendors/register", VendorRegistrationController, :new
  #   post "/vendors/register", VendorRegistrationController, :create
  #   get "/vendors/log_in", VendorSessionController, :new
  #   post "/vendors/log_in", VendorSessionController, :create
  #   get "/vendors/reset_password", VendorResetPasswordController, :new
  #   post "/vendors/reset_password", VendorResetPasswordController, :create
  #   get "/vendors/reset_password/:token", VendorResetPasswordController, :edit
  #   put "/vendors/reset_password/:token", VendorResetPasswordController, :update
  # end
  #
  # scope "/", MarketWeb do
  #   pipe_through [:browser, :require_authenticated_vendor]
  #
  #   get "/vendors/settings", VendorSettingsController, :edit
  #   put "/vendors/settings", VendorSettingsController, :update
  #   get "/vendors/settings/confirm_email/:token", VendorSettingsController, :confirm_email
  # end
  #
  # scope "/", MarketWeb do
  #   pipe_through [:browser]
  #
  #   delete "/vendors/log_out", VendorSessionController, :delete
  #   get "/vendors/confirm", VendorConfirmationController, :new
  #   post "/vendors/confirm", VendorConfirmationController, :create
  #   get "/vendors/confirm/:token", VendorConfirmationController, :edit
  #   post "/vendors/confirm/:token", VendorConfirmationController, :update
  # end
end
