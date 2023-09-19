let process (message : Message.Type.t) : unit =
    match message with
    | Message.Type.Client client_message ->
        Process_client_message.process client_message
    | Message.Type.Sevice service_message ->
        Process_service_message.process service_message
    | Message.Type.Log log_message -> Process_log_message.process log_message
    | Message.Type.Mount mount_message ->
        Process_mount_message.process mount_message
