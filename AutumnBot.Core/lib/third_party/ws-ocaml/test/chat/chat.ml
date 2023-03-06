open Ws_ocaml

class virtual client =
  object (self)
    val mutable pool : Websocket.client list = []
    method add (client : Websocket.client) : unit = pool <- client :: pool

    method remove (client : Websocket.client) : unit =
      pool <- List.filter (fun x -> x = client) pool

    method virtual on_message : Websocket.client -> Websocket.message -> unit
    method virtual on_close : Websocket.client -> unit
    method virtual on_connection : Websocket.client -> unit

    method make () : Websocket.app =
      let on_connection = self#on_connection in
      let on_message = self#on_message in
      let on_close = self#on_close in
      Websocket.make_app ~on_connection ~on_message ~on_close ()
  end

class app1 =
  object (self)
    inherit client

    method private broadcast (message : bytes) : unit =
      List.iter (fun client -> ignore (Websocket.send_text client message)) pool

    method on_message (_ : Websocket.client) (message : Websocket.message) : unit =
      match message with
      | Websocket.Text message -> self#broadcast message
      | Websocket.Binary _ -> ()

    method on_close (client : Websocket.client) : unit =
      print_endline "app1: a client disconnected";
      self#remove client

    method on_connection (client : Websocket.client) : unit =
      print_endline "app1: a new client connected";
      self#add client
  end

let () =
  let app1 = new app1 in
  Websocket.run ~addr:"127.0.0.1" ~port:"3000" (app1#make ())
;;
