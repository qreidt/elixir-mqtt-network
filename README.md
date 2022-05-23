# Elixir MQTT Network Example

>MQTT network example for reading multiple values from multiple sensors for each device.

## MQTT Broker

Broker in use is [EMQX MQTT Broker](https://hub.docker.com/r/emqx/emqx). ([Docs](https://www.emqx.io/docs/en/v4.4/))

Also, can use [Broker Dashboard](https://www.emqx.io/docs/en/v4.4/getting-started/dashboard.html) if you allow the port 18083 to be open.

## Server

[Elixir Phoenix Framework](https://github.com/phoenixframework/phoenix) API with a GenServer for subscribing to devices (gateways) status and new published sensor data.

Server than communicates to a MongoDB database to store data and update information about registered devices/sensors


## Tools

- [MQTT X Desktop Client](https://mqttx.app/)