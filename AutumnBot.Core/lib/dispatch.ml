open Base
open Ws_ocaml
module Domain = Stdlib.Domain

let check_send_status = function
  | true -> Log.info "Processed successfully"
  | false -> Log.error "Processing failed"
;;

let rec dispatch () : unit =
  try
    while true do
      match Message.get () with
      | Message.Client (header, { service; service_body }) ->
        Option.iter (Instance.find_client header) ~f:(fun client ->
          Log.debug ("Dispatch process a client message from " ^ header ^ " to " ^ service);
          match Instance.find_service service with
          | None -> Exception.raise client (Exception.Service_not_found_exn service)
          | Some service ->
            Websocket.send_text
              service
              (Ocason.Basic.JsonObject
                 [ "header", Ocason.Basic.JsonString header
                 ; "body", Ocason.Basic.JsonString service_body
                 ]
              |> Ocason.Basic.to_string
              |> Bytes.of_string)
            |> check_send_status)
      | Message.Service (header, { client; client_body }) ->
        Option.iter (Instance.find_service header) ~f:(fun service ->
          Log.debug ("Dispatch process a service message from " ^ header ^ " to " ^ client);
          match Instance.find_client client with
          | None -> Exception.raise service (Exception.Client_not_found_exn client)
          | Some client ->
            Websocket.send_text
              client
              (Ocason.Basic.JsonObject
                 [ "header", Ocason.Basic.JsonString header
                 ; "body", Ocason.Basic.JsonString client_body
                 ]
              |> Ocason.Basic.to_string
              |> Bytes.of_string)
            |> check_send_status)
    done
  with
  | e ->
    Log.error (Stdlib.Printexc.to_string e);
    dispatch ()
;;

let start () =
  Domain.spawn (fun _ ->
    Log.info "Start Dispatch";
    dispatch ())
  |> ignore
;;
