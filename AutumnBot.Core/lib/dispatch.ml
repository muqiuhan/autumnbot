open Base
open Ws_ocaml
module Domain = Stdlib.Domain

let dispatch () : unit =
  while true do
    match Message.get () with
    | Message.Client (header, { service; service_body }) ->
      Option.iter (Instance.find_client header) ~f:(fun client ->
        match Instance.find_service service with
        | None -> Exception.raise client (Exception.Service_not_found_exn service)
        | Some service ->
          Websocket.send_text service (Bytes.of_string service_body) |> ignore)
    | Message.Service (header, { client; client_body }) ->
      Option.iter (Instance.find_service header) ~f:(fun service ->
        match Instance.find_client client with
        | None -> Exception.raise service (Exception.Client_not_found_exn client)
        | Some client ->
          Websocket.send_text client (Bytes.of_string client_body) |> ignore)
  done
;;

let start () =
  Log.debug "Start Dispatch...";
  Domain.spawn dispatch |> ignore
;;
