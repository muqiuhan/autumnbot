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

module Message = struct
  type t =
    | Client_Message of message
    | Service_Message of message

  and message =
    { header : message_header
    ; body : string
    }

  and message_header =
    { self : string
    ; target : string
    }
end

module Instance = struct
  module type Pool = sig
    class pool :
      object
        val log_location : string
        val pool : (string, Dream.websocket) Hashtbl.t
        method add : string -> Dream.websocket -> unit Lwt.t
        method broadcast : string -> unit Lwt.t
        method get : string -> (Dream.websocket, string) result Lwt.t
        method remove : string -> unit Lwt.t
        method remove_with_connection : Dream.websocket -> unit Lwt.t
      end

    type t = pool
  end
end

module Dispatcher = struct
  type instruction =
    | Request of
        { request_self : string
        ; request_service : string
        ; request_body : string
        }
    | Reply of
        { reply_self : string
        ; reply_client : string
        ; reply_body : string
        }
end
