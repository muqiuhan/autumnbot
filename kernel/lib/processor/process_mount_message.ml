let process (message : Message.Mount_message.t) : unit =
    match message with
    | {mount_message_client_type; mount_message_id; mount_message_address} ->
        let mount_message_address =
            match mount_message_address with
            | Some (address, port) -> Format.sprintf ", at %s:%d" address port
            | None -> ""
        in
            Log.info "[Kernel]: Mount %s %s %s"
              (Message.Mount_message.string_of_client_type
                 mount_message_client_type)
              mount_message_id mount_message_address
