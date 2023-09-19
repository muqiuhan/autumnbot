let process (message : Message.Client_message.t) : unit =
    match message with
    | {client_message_id; client_message_target; client_message_value} ->
        Log.info "[%s -> %s]: %s" client_message_id client_message_target
          client_message_value
