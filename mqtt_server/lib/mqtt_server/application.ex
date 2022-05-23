defmodule MQTTServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MQTTServerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MQTTServer.PubSub},
      # Start the Endpoint (http/https)
      MQTTServerWeb.Endpoint,
      # Start a worker by calling: MQTTServer.Worker.start_link(arg)
      # {MQTTServer.Worker, arg}
      {MQTTServer.Workers.MQTTWorker, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MQTTServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MQTTServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
