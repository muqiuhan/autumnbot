open Base
open Domain_impl
open Ws_ocaml
open Utils

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
          Message.parse (Bytes.to_string message) client
          |> Option.iter ~f:Message.Pool.message_pool#put
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
        Log.info
          ("Connection: Try to start AutumnBot.Core Websocket server at ws://"
          ^ Config.websocket_hostname
          ^ ":"
          ^ Config.websocket_port);
        Websocket.run
          ~addr:Config.websocket_hostname
          ~port:Config.websocket_port
          (connection_pool#make ())
      with
      | e ->
        Unix.sleep 3;
        Log.error
          ("Connection: Unable to start AutumnBot.Core Websocket server at ws://"
          ^ Config.websocket_hostname
          ^ ":"
          ^ Config.websocket_port
          ^ " -> "
          ^ Stdlib.Printexc.to_string e)
        |> start
    in
    start ())
  |> ignore
;;

let send (client : Websocket.client) (data : Ocason.Basic.json) : unit =
  Websocket.send_text client (data |> Ocason.Basic.to_string |> Bytes.of_string)
  |> check_send_status
;;
