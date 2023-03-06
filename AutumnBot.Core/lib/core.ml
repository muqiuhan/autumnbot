open Ws_ocaml

let start () =
  let message_pool : Connection.core = new Connection.core in
  Websocket.run ~addr:"127.0.0.1" ~port:"3000" (message_pool#make ())
;;
