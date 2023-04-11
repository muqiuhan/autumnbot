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

let log_location : string = "Instance"

module Pool : Domain.Instance.Pool = struct
  class pool =
    object (self)
      val pool : (string, Dream.websocket) Hashtbl.t = Hashtbl.create 10
      val log_location : string = Log.combine_location log_location "instance_pool"

      method add : string -> Dream.websocket -> unit Lwt.t =
        fun name websocket ->
          Log.info log_location (Format.sprintf "add %s" name);
          Hashtbl.add pool name websocket |> Lwt.return

      method remove : string -> unit Lwt.t =
        fun name ->
          Log.info log_location (Format.sprintf "remove %s" name);
          Hashtbl.remove pool name |> Lwt.return

      method remove_with_connection : Dream.websocket -> unit Lwt.t =
        fun find_connection ->
          let connection_name = ref String.empty in
          Hashtbl.iter
            (fun name connection ->
              if find_connection = connection then connection_name := name else ())
            pool;
          if String.empty = !connection_name
          then
            Log.warn
              log_location
              "The target connection was not found and cannot be remove"
            |> Lwt.return
          else self#remove !connection_name

      method get : string -> (Dream.websocket, string) result Lwt.t =
        fun name ->
          try Ok (Hashtbl.find pool name) |> Lwt.return with
          | Not_found ->
            let err_msg = Format.sprintf "Connection not found: %s" name in
            Log.error log_location err_msg;
            Lwt.return (Error err_msg)

      method broadcast : string -> unit Lwt.t =
        fun message ->
          Log.info log_location "Broadcasting message to all connections...";
          Hashtbl.iter
            (fun name websocket ->
              Log.info log_location (Format.sprintf "Broadcast to %s" name);
              Dream.send websocket message |> ignore)
            pool
          |> Lwt.return
    end

  type t = pool
end

let instances : Pool.t = new Pool.pool

let remove_with_connection : Dream.websocket -> unit Lwt.t =
  instances#remove_with_connection
;;

let get : string -> (Dream.websocket, string) result Lwt.t = instances#get
