let process (message : Message.Log_message.t) : unit =
    match message with
    | {log_message_level; log_message_id; log_message_value} ->
        let log =
            match log_message_level with
            | INFO -> Log.info
            | DEBUG -> Log.debug
            | WARN -> Log.warn
            | ERROR -> Log.error
        in
            log "[%s]: %s" log_message_id log_message_value
