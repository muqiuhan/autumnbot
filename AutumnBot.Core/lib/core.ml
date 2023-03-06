open Ws_ocaml
module Client = struct
  type t =
    { service : string [@key "service"]
    ; body : string [@key "body"]
    }
  [@@deriving yojson]
end

let start () = 
  Websocket.run