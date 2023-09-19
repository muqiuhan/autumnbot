let process (message: Message.Service_message.t) : unit = 
    match message with
    | {service_message_id; service_message_target; service_message_value} ->
        Log.info "[%s -> %s]: %s" service_message_id service_message_target
          service_message_value
