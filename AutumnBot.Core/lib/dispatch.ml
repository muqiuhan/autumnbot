open Base
open Ws_ocaml
module Domain = Stdlib.Domain

module Client = struct
  let mount (client : Websocket.client) (header : string) : unit =
    Log.info ("Dispatch: A mount message from " ^ header);
    Instance.clients#contain (header, client)
  ;;

  let dispatch (client : Websocket.client) (message : Message.client_message) : unit =
    match message with
    | { client_message_header; client_message_service; client_message_body } ->
      Log.info
        ("Dispatch: Process a client message from "
        ^ client_message_header
        ^ " to "
        ^ client_message_service);
      if Message.is_mount_message (Message.Client (client, message))
      then mount client client_message_header
      else (
        match Instance.find_client client_message_header with
        | None -> Log.error ("Dispatch: Client not found : " ^ client_message_header)
        | Some client ->
          (* Check whether the client in Instances needs to be updated *)
          Instance.clients#contain (client_message_header, client);
          (match Instance.find_service client_message_service with
           | None ->
             Exception.raise
               client
               (Exception.Service_not_found_exn client_message_service)
           | Some service ->
             Connection.send
               service
               (Ocason.Basic.JsonObject
                  [ "header", Ocason.Basic.JsonString client_message_header
                  ; "body", Ocason.Basic.JsonString client_message_body
                  ])))
  ;;
end

module Service = struct
  let mount (client : Websocket.client) (header : string) : unit =
    Log.info ("Dispatch: A mount message from " ^ header);
    Instance.services#contain (header, client)
  ;;

  let dispatch (client : Websocket.client) (message : Message.service_message) : unit =
    match message with
    | { service_message_header; service_message_client; service_message_body } ->
      Log.info
        ("Dispatch: Process a service message from "
        ^ service_message_header
        ^ " to "
        ^ service_message_client);
      if Message.is_mount_message (Message.Service (client, message))
      then mount client service_message_header
      else (
        match Instance.find_service service_message_header with
        | None ->
          Exception.raise client (Exception.Service_not_found_exn service_message_client)
        | Some client ->
          Instance.services#contain (service_message_header, client);
          (match Instance.find_client service_message_client with
           | None ->
             Exception.raise
               client
               (Exception.Client_not_found_exn service_message_client)
           | Some service ->
             Connection.send
               service
               (Ocason.Basic.JsonObject
                  [ "header", Ocason.Basic.JsonString service_message_header
                  ; "body", Ocason.Basic.JsonString service_message_body
                  ])))
  ;;
end

let rec dispatch () : unit =
  try
    while true do
      match Message.get () with
      | Message.Client (client, message) -> Client.dispatch client message
      | Message.Service (client, message) -> Service.dispatch client message
    done
  with
  | e ->
    Log.error (Stdlib.Printexc.to_string e);
    dispatch ()
;;

let start () =
  Domain.spawn (fun _ ->
    Log.info "Dispatch: Start";
    dispatch ())
  |> ignore
;;
