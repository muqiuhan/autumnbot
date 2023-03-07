open Base
module Mutex = Stdlib.Mutex
module Condition = Stdlib.Condition

type message =
  | Client of (header * client_message)
  | Service of (header * service_message)

and header = string

and client_message =
  { service : string
  ; service_body : string
  }

and service_message =
  { client : string
  ; client_body : string
  }

let get_message_header = function
  | Client (header, _) | Service (header, _) -> header
;;

let is_mount_message = function
  | Client (_, { service; _ }) -> String.is_empty service
  | Service (_, { client; _ }) -> String.is_empty client
;;

module Parser = struct
  module Client = struct
    let parse (header : string) (message : Ocason.Basic.json) : message =
      Client
        ( header
        , { service =
              message |> Ocason.Basic.Util.key "service" |> Ocason.Basic.Util.to_string
          ; service_body =
              message |> Ocason.Basic.Util.key "body" |> Ocason.Basic.Util.to_string
          } )
    ;;
  end

  module Service = struct
    let parse (header : string) (message : Ocason.Basic.json) : message =
      Service
        ( header
        , { client =
              message |> Ocason.Basic.Util.key "client" |> Ocason.Basic.Util.to_string
          ; client_body =
              message |> Ocason.Basic.Util.key "body" |> Ocason.Basic.Util.to_string
          } )
    ;;
  end

  let parse (message : string) : message option =
    Log.debug ("Parsing message : " ^ message);
    try
      let message : Ocason.Basic.json = Ocason.Basic.from_string message in
      let header : string =
        message |> Ocason.Basic.Util.key "header" |> Ocason.Basic.Util.to_string
      in
      if String.is_prefix ~prefix:"AutumnBot.Client" header
      then Some (Client.parse header message)
      else if String.is_prefix ~prefix:"AutumnBot.Service" header
      then Some (Service.parse header message)
      else
        raise
          (Exception.Core_exn
             (Exception.Unknown_message_type (Ocason.Basic.Util.to_string message)))
    with
    | Exception.Core_exn msg ->
      Log.error (Exception.to_string msg);
      None
    | e ->
      Log.error (Stdlib.Printexc.to_string e);
      None
  ;;
end

let parse : string -> message option = Parser.parse

class message_pool =
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
      if is_mount_message message
      then Log.info ("New mount message from " ^ get_message_header message)
      else (
        Log.info ("New message from " ^ get_message_header message);
        Mutex.lock mutex;
        let was_empty = Stack.is_empty pool in
        Stack.push pool message;
        if was_empty then Condition.broadcast nonempty;
        Mutex.unlock mutex)
  end

let message_pool : message_pool = new message_pool
let get = message_pool#get
let put = message_pool#put
