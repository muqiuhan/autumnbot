type client = Dream.websocket

open Core

let send_msg client msg =
    match Dream.send client msg |> Lwt.state with
    | Lwt.Fail exn -> Log.error "[Kernel]: %s" (Exn.to_string exn)
    | Lwt.Return unit -> unit
    | Lwt.Sleep -> ()

let close client =
    send_msg client "close";
    match Dream.close_websocket client |> Lwt.state with
    | Lwt.Fail exn -> Log.error "[Kernel]: %s" (Exn.to_string exn)
    | Lwt.Return unit -> unit
    | Lwt.Sleep -> ()

type t = client
