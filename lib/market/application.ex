defmodule Market.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MarketWeb.Telemetry,
      # Start the Ecto repository
      Market.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Market.PubSub},
      # Start Finch
      {Finch, name: Market.Finch},
      # Start the Endpoint (http/https)
      MarketWeb.Endpoint
      # Start a worker by calling: Market.Worker.start_link(arg)
      # {Market.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Market.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MarketWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
