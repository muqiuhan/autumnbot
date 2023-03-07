open Ws_ocaml
open Base
open Utils
module Domain = Stdlib.Domain

class core =
  object (self)
    val mutable pool : Websocket.client list = []
    method add (client : Websocket.client) : unit = pool <- client :: pool

    method remove (client : Websocket.client) : unit =
      pool <- List.remove pool ~f:(fun x -> phys_equal x client)

    method make () : Websocket.app =
      let on_connection = self#on_connection in
      let on_message = self#on_message in
      let on_close = self#on_close in
      Websocket.make_app ~on_connection ~on_message ~on_close ()

    method on_message (client : Websocket.client) (message : Websocket.message) : unit =
      Domain.spawn (fun () ->
        match message with
        | Websocket.Text message ->
          Bytes.to_string message
          |> Message.parse
          |> Option.bind ~f:(fun message ->
               (match message with
                | Message.Client (header, _) -> Instance.clients#contain (header, client)
                | Message.Service (header, _) -> Instance.services#contain (header, client));
               Some message)
          |> Option.iter ~f:Message.message_pool#put
        | Websocket.Binary _ -> ())
      |> ignore

    method on_close (client : Websocket.client) : unit = self#remove client
    method on_connection (client : Websocket.client) : unit = self#add client
  end

let connection_pool : core = new core

let start () =
  Domain.spawn (fun () ->
    let rec start () =
      try
        Log.info "Try to start AutumnBot.Core Websocket server at ws://127.0.0.1:3000";
        Websocket.run ~addr:"127.0.0.1" ~port:"3000" (connection_pool#make ())
      with
      | e ->
        Unix.sleep 1;
        Log.error
          ("Unable to start AutumnBot.Core Websocket server at ws://127.0.0.1:3000 -> "
          ^ Stdlib.Printexc.to_string e)
        |> start
    in
    start ())
  |> ignore
;;
