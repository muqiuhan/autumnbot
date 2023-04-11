(** The MIT License (MIT)
 ** 
 ** Copyright (c) 2022 Muqiu Han
 ** 
 ** Permission is hereby granted, free of charge, to any person obtaining a copy
 ** of this software and associated documentation files (the "Software"), to deal
 ** in the Software without restriction, including without limitation the rights
 ** to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 ** copies of the Software, and to permit persons to whom the Software is
 ** furnished to do so, subject to the following conditions:
 ** 
 ** The above copyright notice and this permission notice shall be included in all
 ** copies or substantial portions of the Software.
 ** 
 ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 ** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 ** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 ** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 ** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 ** OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 ** SOFTWARE. *)

open Domain.Dispatcher

let log_location : string = "Dispatcher"

let error : string -> string -> unit Lwt.t =
 fun msg self ->
  Lwt.(
    Instance.get self
    >>= fun self ->
    Result.iter
      (fun self -> Dream.send self (Message.build_error_message msg) |> ignore)
      self
    |> Lwt.return)
;;

let mount_instance : string -> Dream.websocket -> unit Lwt.t =
 fun name connection -> Instance.mount name connection
;;

let handle : Domain.Dispatcher.instruction * Dream.websocket -> unit Lwt.t =
 fun (instruction, connection) ->
  match instruction with
  | Reply { reply_self; reply_client = "core"; reply_body = "mount" } ->
    mount_instance reply_self connection
  | Request { request_self; request_service = "core"; request_body = "mount" } ->
    mount_instance request_self connection
  | Reply { reply_self; reply_client; reply_body } ->
    Lwt.(
      Instance.get reply_client
      >>= fun client ->
      (match client with
       | Ok client ->
         Dream.send
           client
           (Format.sprintf
              {|{ "header" : { "service": "%s" }, body : "%s" } |}
              reply_self
              reply_body)
       | Error msg -> error msg reply_self))
  | Request { request_self; request_service; request_body } ->
    Lwt.(
      Instance.get request_service
      >>= fun service ->
      (match service with
       | Ok service ->
         Dream.send
           service
           (Format.sprintf
              {| { "header" : { "client": "%s }, body : "%s" } |}
              request_self
              request_body)
       | Error msg -> error msg request_self))
;;

let dispatch : unit -> unit =
 fun _ ->
  Log.info log_location "start";
  let rec loop _ =
    Lwt.(Message.pop () >>= fun instruction -> handle instruction |> loop)
  in
  loop Lwt.return_unit |> ignore
;;
