open Base
open Utils
open Log
module Mutex = Stdlib.Mutex

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

let parse (message : string) : message =
  let message = Ocason.Basic.from_string message in
  let header : string =
    message |> Ocason.Basic.Util.key "header" |> Ocason.Basic.Util.to_string
  in
  if String.contains header "AutumnBot.Client"
  then
    Client
      ( header
      , { service =
            message |> Ocason.Basic.Util.key "service" |> Ocason.Basic.Util.to_string
        ; service_body =
            message |> Ocason.Basic.Util.key "service" |> Ocason.Basic.Util.to_string
        } )
  else if message
          |> Ocason.Basic.Util.key "header"
          |> Ocason.Basic.Util.to_string
          |> String.contains "AutumnBot.Service"
  then
    Service
      ( header
      , { client =
            message |> Ocason.Basic.Util.key "service" |> Ocason.Basic.Util.to_string
        ; client_body =
            message |> Ocason.Basic.Util.key "service" |> Ocason.Basic.Util.to_string
        } )
  else failwith "Unknown message"
;;

class message_pool =
  object
    val pool : message Stack.t = Stack.create ()
    val pool_mutex : Mutex.t = Mutex.create ()

    method get () : message =
      info "";
      Mutex.lock pool_mutex;
      let message : message = Stack.pop_exn pool in
      Mutex.unlock pool_mutex;
      message

    method put (message : message) : unit =
      Mutex.lock pool_mutex;
      Stack.push pool message;
      Mutex.unlock pool_mutex
  end

let message_pool : message_pool = new message_pool
