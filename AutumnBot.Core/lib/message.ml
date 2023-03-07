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

module Parser = struct
  module Client = struct
    let parse (header : string) (message : Ocason.Basic.json) : message =
      Log.debug ("New message from" ^ header);
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
      Log.debug ("New message from" ^ header);
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
    val pool_mutex : Mutex.t = Mutex.create ()
    val pool_cond : Condition.t = Condition.create ()

    method get () : message =
      Mutex.lock pool_mutex;
      Condition.wait pool_cond pool_mutex;
      let message : message = Stack.pop_exn pool in
      Mutex.unlock pool_mutex;
      message

    method put (message : message) : unit =
      Mutex.lock pool_mutex;
      Stack.push pool message;
      Condition.broadcast pool_cond;
      Mutex.unlock pool_mutex
  end

let message_pool : message_pool = new message_pool
let get = message_pool#get
let put = message_pool#put
