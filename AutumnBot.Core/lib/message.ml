open Base
open Utils
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
      Client
        ( header
        , { service =
              message |> Ocason.Basic.Util.key "service" |> Ocason.Basic.Util.to_string
          ; service_body =
              message |> Ocason.Basic.Util.key "service" |> Ocason.Basic.Util.to_string
          } )
    ;;
  end

  module Service = struct
    let parse (header : string) (message : Ocason.Basic.json) : message =
      Service
        ( header
        , { client =
              message |> Ocason.Basic.Util.key "service" |> Ocason.Basic.Util.to_string
          ; client_body =
              message |> Ocason.Basic.Util.key "service" |> Ocason.Basic.Util.to_string
          } )
    ;;
  end

  let parse (message : string) : message =
    let message = Ocason.Basic.from_string message in
    let header : string =
      message |> Ocason.Basic.Util.key "header" |> Ocason.Basic.Util.to_string
    in
    Log.info ("New message from : " ^ header);
    if String.contains header "AutumnBot.Client"
    then Client.parse header message
    else if String.contains header "AutumnBot.Service"
    then Service.parse header message
    else failwith "Unknown message"
  ;;
end

let parse : string -> message = Parser.parse

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
