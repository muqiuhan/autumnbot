open Base
open Ws_ocaml
module Mutex = Stdlib.Mutex
module Condition = Stdlib.Condition

type message =
  | Client of (Websocket.client * client_message)
  | Service of (Websocket.client * service_message)

and client_message = {
  client_message_header : string;
  client_message_service : string;
  client_message_body : string;
}

and service_message = {
  service_message_header : string;
  service_message_client : string;
  service_message_body : string;
}

and t = message

let get_message_header = function
  | Client (_, {client_message_header; _}) -> client_message_header
  | Service (_, {service_message_header; _}) -> service_message_header

let is_mount_message = function
  | Client (_, {client_message_service; _}) ->
    String.equal client_message_service "mount"
  | Service (_, {service_message_client; _}) ->
    String.equal service_message_client "mount"

let is_umount_message = function
  | Client (_, {client_message_service; _}) ->
    String.equal client_message_service "umount"
  | Service (_, {service_message_client; _}) ->
    String.equal service_message_client "umount"

let header (message : Ocason.Basic.json) =
  message |> Ocason.Basic.Util.key "header" |> Ocason.Basic.Util.to_string

let is_service_message (message : Ocason.Basic.json) : bool =
  if String.is_prefix ~prefix:"AutumnBot.Service" (header message) then
    true
  else
    false

let is_client_message (message : Ocason.Basic.json) : bool =
  if String.is_prefix ~prefix:"AutumnBot.Client" (header message) then
    true
  else
    false

module Parser = struct
  module Client = struct
    let parse (message : Ocason.Basic.json) : client_message =
      let client_message_header = header message
      and client_message_service =
        message
        |> Ocason.Basic.Util.key "service"
        |> Ocason.Basic.Util.to_string
      and client_message_body =
        message |> Ocason.Basic.Util.key "body" |> Ocason.Basic.Util.to_string
      in
      {client_message_header; client_message_service; client_message_body}
  end

  module Service = struct
    let parse (message : Ocason.Basic.json) : service_message =
      let service_message_header = header message
      and service_message_client =
        message |> Ocason.Basic.Util.key "client" |> Ocason.Basic.Util.to_string
      and service_message_body =
        message |> Ocason.Basic.Util.key "body" |> Ocason.Basic.Util.to_string
      in
      {service_message_header; service_message_client; service_message_body}
  end

  let parse (message : string) (client : Websocket.client) : message option =
    Log.debug ("Message: Parsing" ^ message);
    try
      let message = Ocason.Basic.from_string message in
      if is_client_message message then
        Some (Client (client, Client.parse message))
      else if is_service_message message then
        Some (Service (client, Service.parse message))
      else
        raise
          (Exception.Core_exn
             (Exception.Unknown_message_type
                (Ocason.Basic.Util.to_string message)))
    with
    | Exception.Core_exn msg ->
      Log.error (Exception.to_string msg);
      None
    | e ->
      Log.error (Stdlib.Printexc.to_string e);
      None
end

let parse : string -> Websocket.client -> message option = Parser.parse

module Pool = struct
  class t =
    object
      val pool : message Stack.t = Stack.create ()
      val mutex : Mutex.t = Mutex.create ()
      val nonempty : Condition.t = Condition.create ()

      method get () : message =
        Mutex.lock mutex;
        while Stack.is_empty pool do
          Condition.wait nonempty mutex
        done;
        let v = Stack.pop_exn pool in
        Mutex.unlock mutex;
        v

      method put (message : message) : unit =
        Log.info ("Message: New from " ^ get_message_header message);
        Mutex.lock mutex;
        let was_empty = Stack.is_empty pool in
        Stack.push pool message;
        if was_empty then Condition.broadcast nonempty;
        Mutex.unlock mutex
    end

  let message_pool : t = new t
  let get = message_pool#get
  let put = message_pool#put
end
