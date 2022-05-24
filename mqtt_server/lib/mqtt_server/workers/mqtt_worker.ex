defmodule MQTTServer.Workers.MQTTWorker do

  use GenServer

  #
  # SETUP
  #

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    state = %{
      mdb_conn: setup_mongodb(),
      emqtt_conn: setup_emqtt()
    }

    IO.puts("Everything started")

    {:ok, state}
  end

  defp setup_emqtt() do
    config = Application.get_env(:mqtt_server, :emqtt)

    {:ok, conn} = :emqtt.start_link(config)

    :emqtt.connect(conn)

    :emqtt.subscribe(conn, "/g/+/")
    :emqtt.subscribe(conn, "/g/+/status", [qos: 1])

    conn
  end

  defp setup_mongodb() do
    config = Application.get_env(:mqtt_server, :mongodb)
    {:ok, conn} = Mongo.start_link(config)

    conn
  end


  #
  # HANDLE PUBLISH RESPONSE ON SUBSCRIBED TOPIC
  #

  def handle_info({:publish, packet}, state) do
    topic = String.split(packet.topic, "/", trim: true)

    case topic do
      ["g", gateway_id] -> create_dots(gateway_id, packet.payload, state.mdb_conn)
      ["g", gateway_id, "status"] ->
        IO.inspect(packet)
        update_gateway_status(gateway_id, packet.payload, state.mdb_conn)
    end

    {:noreply, state}
  end

  defp create_dots(gateway_id, payload, conn) do
    data = Jason.decode!(payload)
      |> Map.to_list
      |> Enum.map(&map_multi_reading_payload/1)

    if length(data) > 0 do
      # Insert Dots
      Mongo.insert_many!(conn, "dots", data)

      # time of last_contact
      now = System.system_time(:second)

      # update gateway last contact
      update_gateway_last_contact(conn, gateway_id, now)

      # get updated reading ids
      reading_ids = Enum.map(data, fn dot ->
        Map.get(dot, :reading_id)
        |> BSON.ObjectId.decode!()
      end)

      # update readings last contact
      update_readings_last_contact(conn, reading_ids, now)
    end
  end

  defp map_multi_reading_payload({key, data}) when is_map(data) do
    Map.put(data, :reading_id, key)
  end

  defp map_multi_reading_payload({key, data}) when is_number(data) do
    %{
      value: data,
      timestamp: System.system_time(:second),
      reading_id: key,
    }
  end

  defp update_gateway_status(gateway_id, payload, conn) do
    Mongo.update_one!(conn, "gateways",
      %{_id: BSON.ObjectId.decode!(gateway_id)},
      %{ "$set": %{ status: payload } }
    )
  end

  defp update_gateway_last_contact(conn, gateway_id, time) do
    Mongo.update_one!(conn, "gateways",
      %{ _id: BSON.ObjectId.decode!(gateway_id) },
      %{ "$set": %{ last_contact: time } }
    )
  end

  defp update_readings_last_contact(conn, reading_ids, time) do
    Mongo.update_many!(conn, "readings",
      %{ _id: %{ "$in": reading_ids } },
      %{ "$set": %{ last_contact: time } }
    )
  end

end
