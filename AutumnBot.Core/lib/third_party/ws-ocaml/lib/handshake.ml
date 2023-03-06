let input_line_rn ?(buf_size = 1024) cin =
  let buf = ref (Bytes.create buf_size) in
  let rec loop i prev =
    if Bytes.length !buf <= i then buf := Bytes.extend !buf 0 buf_size;
    let c = input_char cin in
    if prev = '\r' && c = '\n'
    then Bytes.sub !buf 0 (i - 1)
    else (
      Bytes.set !buf i c;
      loop (i + 1) c)
  in
  loop 0 '\000'
;;

let split ~sep s =
  let idx = Bytes.index s sep in
  Bytes.sub s 0 idx, Bytes.sub s (idx + 1) (Bytes.length s - idx - 1)
;;

type request =
  { request_line : bytes
  ; headers : (bytes, bytes) Hashtbl.t
  ; message_body : bytes
  }

let parse_request cin : request =
  let request_line = input_line_rn cin in
  let tbl = Hashtbl.create 20 in
  let rec headers () =
    let l =
      try input_line_rn ~buf_size:256 cin with
      | End_of_file -> Bytes.empty
    in
    if Bytes.length l > 0
    then (
      let k, v =
        try split ~sep:':' l with
        | Not_found -> l, Bytes.empty
      in
      let k = k |> Bytes.trim |> Bytes.uppercase_ascii
      and v = v |> Bytes.trim in
      Hashtbl.add tbl k v;
      headers ())
  in
  headers ();
  let message_body =
    try
      let content_length =
        Hashtbl.find tbl (Bytes.of_string "CONTENT-LENGTH")
        |> String.of_bytes
        |> int_of_string
      in
      let buf = Bytes.create content_length in
      for i = 0 to content_length - 1 do
        Bytes.set buf i (input_char cin)
      done;
      buf
    with
    | Not_found -> Bytes.empty
  in
  { request_line; headers = tbl; message_body }
;;

exception Bad_request of string

let bad_request ?(headers = []) message =
  raise
    (Bad_request
       (("HTTP/1.1 400 Bad Request" :: headers)
        @ (if message = ""
          then []
          else [ "Content-Length: " ^ (message |> String.length |> string_of_int) ])
        @ [ ""; message ]
       |> String.concat "\r\n"))
;;

let generate_sec_websocket_accept key =
  let open Crypto in
  base64encode (key ^ "258EAFA5-E914-47DA-95CA-C5AB0DC85B11" |> Bytes.of_string |> sha1)
;;

let find_eq tbl k v =
  try Hashtbl.find tbl k = v with
  | Not_found -> false
;;

let make_response { headers; _ } =
  if not
       (find_eq headers (Bytes.of_string "UPGRADE") (Bytes.of_string "websocket")
       && find_eq headers (Bytes.of_string "CONNECTION") (Bytes.of_string "Upgrade"))
  then bad_request "Not WebSocket handshake";
  let sec_websocket_key =
    try Hashtbl.find headers (Bytes.of_string "SEC-WEBSOCKET-KEY") with
    | Not_found -> bad_request "Sec-WebSocket-Key is missing"
  and sec_websocket_version =
    try Hashtbl.find headers (Bytes.of_string "SEC-WEBSOCKET-VERSION") with
    | Not_found -> bad_request "Sec-WebSocket-Version is missing"
  in
  if sec_websocket_version <> Bytes.of_string "13"
  then bad_request ~headers:[ "Sec-WebSocket-Version: 13" ] "";
  let accept = generate_sec_websocket_accept (Bytes.to_string sec_websocket_key) in
  [ "HTTP/1.1 101 Switching Protocols"
  ; "Upgrade: websocket"
  ; "Connection: Upgrade"
  ; "Sec-WebSocket-Accept: " ^ Bytes.to_string accept
  ; ""
  ; ""
  ]
  |> String.concat "\r\n"
;;
