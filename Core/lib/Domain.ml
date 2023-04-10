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

exception Unknown_message_source of string

let log_location : string = "Domain"

type t =
  | Client_Message of message
  | Service_Message of message

and message =
  { header: message_header;
    body: string }

and message_header =
  { self: string;
    target: string }

let parse_body : Yojson.Basic.t -> string =
 fun json ->
  let open Yojson.Basic.Util in
  match json |> member "header" with
  | `Null ->
    raise (Yojson.Json_error "The body field is not included in the message!")
  | `String body -> body
  | _ -> raise (Yojson.Json_error "body format is invalid!")

let parse_header : Yojson.Basic.t -> message_header =
 fun json ->
  let open Yojson.Basic.Util in
  match json |> member "header" with
  | `Null ->
    raise (Yojson.Json_error "The header field is not included in the message!")
  | `Assoc [("self", `String self); ("target", `String target)] -> {self; target}
  | _ -> raise (Yojson.Json_error "header format is invalid!")

let parse_message : string -> t option =
 fun raw_message ->
  try
    let json : Yojson.Basic.t = Yojson.Basic.from_string raw_message in
    let header = parse_header json
    and body = parse_body json in
    if String.starts_with ~prefix:"AutumnBot.Client" header.self then
      Some (Client_Message {header; body})
    else if String.starts_with ~prefix:"AutumnBot.Service" header.self then
      Some (Service_Message {header; body})
    else
      raise (Unknown_message_source header.self)
  with Yojson.Json_error error_msg ->
    Log.error log_location error_msg ;
    None
