open Base
open Ws_ocaml

type core_exn =
  | Service_not_found_exn of string
  | Client_not_found_exn of string
  | Unknown_message_type of string

exception Core_exn of core_exn

let to_string = function
  | Service_not_found_exn service -> "Service not found -> " ^ service
  | Client_not_found_exn client -> "Client not found -> " ^ client
  | Unknown_message_type message -> "Unknown message type -> " ^ message
;;

let generate_error_msg (exn : core_exn) : string =
  Ocason.Basic.JsonObject
    [ "succeed", Ocason.Basic.JsonBool false;
      "body", Ocason.Basic.JsonString (to_string exn) ]
  |> Ocason.Basic.to_string
;;

let raise (client : Websocket.client) (exn : core_exn) : unit =
  let err_msg = generate_error_msg exn in
  Log.error (to_string exn);
  Websocket.send_text client (Bytes.of_string err_msg) |> ignore
;;
