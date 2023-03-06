open Ws_ocaml
open Base
open Utils
module Domain = Stdlib.Domain

class virtual connection =
  object (self)
    val mutable pool : Websocket.client list = []
    method add (client : Websocket.client) : unit = pool <- client :: pool

    method remove (client : Websocket.client) : unit =
      pool <- List.remove pool ~f:(fun x -> phys_equal x client)

    method virtual on_message : Websocket.client -> Websocket.message -> unit
    method virtual on_close : Websocket.client -> unit
    method virtual on_connection : Websocket.client -> unit

    method make () : Websocket.app =
      let on_connection = self#on_connection in
      let on_message = self#on_message in
      let on_close = self#on_close in
      Websocket.make_app ~on_connection ~on_message ~on_close ()
  end

class core =
  object (self)
    inherit connection

    method on_message (client : Websocket.client) (message : Websocket.message) : unit =
      match message with
      | Websocket.Text message ->
        Domain.spawn (fun () ->
          Bytes.to_string message
          |> Message.parse
          |> (fun message ->
               (match message with
                | Message.Client (header, _) -> Instance.clients#put (header, client)
                | Message.Service (header, _) -> Instance.services#put (header, client));
               message)
          |> Message.message_pool#put)
        |> ignore
      | Websocket.Binary _ -> ()

    method on_close (client : Websocket.client) : unit =
      Log.info "Connection is disconnected";
      self#remove client

    method on_connection (client : Websocket.client) : unit =
      Log.info "New connection";
      self#add client
  end

let connection_pool : core = new core

let start () =
  Log.info "Start AutumnBot.Core on ws://127.0.0.1:3000";
  Domain.spawn (fun () ->
    Websocket.run ~addr:"127.0.0.1" ~port:"3000" (connection_pool#make ()))
  |> ignore
;;
