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

let log_location : string = "Connection"

let on_message : Dream.websocket -> string -> unit Lwt.t =
 fun connection raw_message ->
  Lwt.(
    Message.push connection raw_message
    >>= fun raw_message ->
    match raw_message with
    | Ok () -> Lwt.return_unit
    | Error msg -> Dream.send connection (Message.build_error_message msg))
;;

let on_close : Dream.websocket -> unit Lwt.t =
 fun connection ->
  Lwt.(Instance.remove_with_connection connection <&> Dream.close_websocket connection)
;;

let handle : Dream.websocket -> unit Lwt.t =
 fun connection ->
  let rec loop (_ : unit Lwt.t) =
    match%lwt Dream.receive connection with
    | Some message -> Lwt.(on_message connection message <&> loop Lwt.return_unit)
    | None -> on_close connection
  in
  loop Lwt.return_unit
;;
