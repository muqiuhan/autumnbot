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

class connection_pool =
  object
    val pool : (string, Dream.websocket) Hashtbl.t = Hashtbl.create 10

    val log_location : string = Format.sprintf "connection_pool"

    method add_connection : string -> Dream.websocket -> unit =
      fun name websocket -> Hashtbl.add pool name websocket

    method remove_connection : string -> unit =
      fun name -> Hashtbl.remove pool name

    method get_connection : string -> Dream.websocket option =
      fun name ->
        try Some (Hashtbl.find pool name)
        with Not_found ->
          Log.error log_location
            (Format.sprintf "Connection not found: %s" name) ;
          None

    method broadcast : string -> unit =
      fun message ->
        Log.info log_location "Broadcasting message to all connections..." ;
        Hashtbl.iter
          (fun name websocket ->
            Log.info log_location (Format.sprintf "Broadcast to %s" name) ;
            Dream.send websocket message |> ignore )
          pool
  end

let clients : (int, Dream.websocket) Hashtbl.t = Hashtbl.create 5

let track =
  let last_client_id = ref 0 in
  fun websocket ->
    last_client_id := !last_client_id + 1 ;
    Hashtbl.replace clients !last_client_id websocket ;
    !last_client_id

let forget client_id =
  Dream.log "%d disconnect" client_id ;
  Hashtbl.remove clients client_id

let send message =
  Hashtbl.to_seq_values clients
  |> List.of_seq
  |> Lwt_list.iter_p (fun client -> Dream.send client message)

let handle_client : Dream.websocket -> unit Lwt.t =
 fun client ->
  let client_id = track client in
  let rec loop () =
    match%lwt Dream.receive client with
    | Some message ->
      let%lwt () = send message in
      loop ()
    | None ->
      forget client_id ;
      Dream.close_websocket client
  in
  loop ()

let start : interface:string -> port:int -> unit =
 fun ~interface ~port ->
  Dream.run ~interface ~port
  @@ Dream.logger
  @@ Dream.router [Dream.get "/" (fun _ -> Dream.websocket handle_client)]
