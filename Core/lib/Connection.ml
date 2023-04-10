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

let on_message : Dream.websocket -> string -> unit =
 fun connection raw_message ->
  match Message.push raw_message with
  | Ok () -> ()
  | Error msg -> Dream.send connection (Message.build_error_message msg) |> ignore
;;

let on_close : Dream.websocket -> unit =
 fun connection ->
  Instance.remove_with_connection connection;
  Dream.close_websocket connection |> ignore
;;

let handle : Dream.websocket -> unit Lwt.t =
 fun connection ->
  let rec loop () =
    match%lwt Dream.receive connection with
    | Some message -> on_message connection message |> loop
    | None ->
      on_close connection;
      Lwt.return_unit
  in
  loop ()
;;
