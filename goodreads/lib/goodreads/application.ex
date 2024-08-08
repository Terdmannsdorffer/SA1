defmodule Goodreads.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      GoodreadsWeb.Telemetry,
      Goodreads.Repo,
      {DNSCluster, query: Application.get_env(:goodreads, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Goodreads.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Goodreads.Finch},
      # Start a worker by calling: Goodreads.Worker.start_link(arg)
      # {Goodreads.Worker, arg},
      # Start to serve requests, typically the last entry
      GoodreadsWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Goodreads.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GoodreadsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
