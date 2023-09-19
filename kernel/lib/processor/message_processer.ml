module Message_processer =
functor
  (M : sig
     type t

     val process : t -> unit
   end)
  ->
  struct
    let process (message : M.t) (pool : Pool.Thread.t) =
        pool#async (fun () -> M.process message)
  end

module Client = Message_processer (struct
  type t = Message.Client_message.t

  let process (message : Message.Client_message.t) : unit =
      match message with
      | {client_message_id; client_message_target; client_message_value} ->
          Log.info "[%s -> %s]: %s" client_message_id client_message_target
            client_message_value
end)

module Mount = Message_processer (struct
  type t = Message.Mount_message.t

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
end)

module Service = Message_processer (struct
  type t = Message.Service_message.t

  let process (message : Message.Service_message.t) : unit =
      match message with
      | {service_message_id; service_message_target; service_message_value} ->
          Log.info "[%s -> %s]: %s" service_message_id service_message_target
            service_message_value
end)

module Log = Message_processer (struct
  type t = Message.Log_message.t

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
end)
