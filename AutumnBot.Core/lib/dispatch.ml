open Base
open Domain_impl
open Ws_ocaml

module Dispatch =
functor
  (M : sig
     val instances : Instance.t
     val client_not_found : string -> unit
     val dispatch : Message.t -> unit
   end)
  ->
  struct
    let mount (client : Websocket.client) (header : string) : unit =
      Log.info ("Dispatch: A mount message from " ^ header);
      M.instances#contain (header, client)
    ;;

    let umount (header : string) : unit =
      Log.info ("Dispatch: A umount message from " ^ header);
      M.instances#remove header
    ;;

    let dispatch (message : Message.t) : unit =
      let header = Message.get_message_header message
      and client : Websocket.client = Message.get_message_client message in
      if Message.is_mount_message message then
        mount client header
      else if Message.is_umount_message message then
        umount header
      else (
        match M.instances#get_client header with
        | None -> M.client_not_found header
        | Some client ->
          (* Check whether the client in Instances needs to be updated *)
          M.instances#contain (header, client);
          M.dispatch message)
    ;;
  end

module Client = Dispatch (struct
  let instances : Instance.t = Instance.clients

  let client_not_found (header : string) : unit =
    Log.error ("Dispatch: Service not found -> " ^ header)
  ;;

  let log (client_message_header : string) (client_message_service : string) : unit =
    Log.info
      ("Dispatch: Process a client message from "
      ^ client_message_header
      ^ " to "
      ^ client_message_service)
  ;;

  let dispatch (message : Message.t) : unit =
    let client : Websocket.client = Message.get_message_client message in
    match Message.to_client_message_exn message with
    | {client_message_header; client_message_service; client_message_body} -> (
      log client_message_header client_message_service;
      match Instance.find_service client_message_service with
      | None ->
        Exception.raise client (Exception.Service_not_found_exn client_message_service)
      | Some service ->
        Connection.send
          service
          (Ocason.Basic.JsonObject
             [ "header", Ocason.Basic.JsonString client_message_header;
               "body", Ocason.Basic.JsonString client_message_body ]))
  ;;
end)

module Service = Dispatch (struct
  let instances : Instance.t = Instance.services

  let client_not_found (header : string) : unit =
    Log.error ("Dispatch: Client not found -> " ^ header)
  ;;

  let log (service_message_header : string) (service_message_client : string) : unit =
    Log.info
      ("Dispatch: Process a service message from "
      ^ service_message_header
      ^ " to "
      ^ service_message_client)
  ;;

  let dispatch (message : Message.t) : unit =
    let client : Websocket.client = Message.get_message_client message in
    match Message.to_service_message_exn message with
    | {service_message_header; service_message_client; service_message_body} -> (
      log service_message_header service_message_client;
      match Instance.find_client service_message_client with
      | None ->
        Exception.raise client (Exception.Client_not_found_exn service_message_client)
      | Some service ->
        Connection.send
          service
          (Ocason.Basic.JsonObject
             [ "header", Ocason.Basic.JsonString service_message_header;
               "body", Ocason.Basic.JsonString service_message_body ]))
  ;;
end)

let rec dispatch () : unit =
  try
    while true do
      match Message.Pool.get () with
      | Message.Client message -> Client.dispatch (Message.Client message)
      | Message.Service message -> Service.dispatch (Message.Service message)
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
