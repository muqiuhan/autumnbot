open Ws_ocaml
open Handshake
open Test_helper

let test () =
  print_endline "Test for Websocket";
  let { request_line; headers; message_body } =
    "GET / HTTP/1.1\r\n\
     Host: localhost:3000\r\n\
     Connection: Upgrade\r\n\
     Pragma: no-cache\r\n\
     Cache-Control: no-cache\r\n\
     Upgrade: websocket\r\n\
     Origin: null\r\n\
     Sec-WebSocket-Version: 13\r\n\
     User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 \
     (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36\r\n\
     Accept-Encoding: gzip, deflate, sdch\r\n\
     Accept-Language: ja,en-US;q=0.8,en;q=0.6\r\n\
     Sec-WebSocket-Key: eUksYQMw3z+ZMjb6baawiw==\r\n\
     Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits\r\n\
     \r\n"
    |> Bytes.of_string
    |> in_channel_of_bytes
    |> parse_request
  in
  assert (request_line = Bytes.of_string "GET / HTTP/1.1");
  assert (Hashtbl.find headers (Bytes.of_string "HOST") = Bytes.of_string "localhost:3000");
  assert (Hashtbl.find headers (Bytes.of_string "CONNECTION") = Bytes.of_string "Upgrade");
  assert (Hashtbl.find headers (Bytes.of_string "PRAGMA") = Bytes.of_string "no-cache");
  assert (
    Hashtbl.find headers (Bytes.of_string "CACHE-CONTROL") = Bytes.of_string "no-cache");
  assert (Hashtbl.find headers (Bytes.of_string "UPGRADE") = Bytes.of_string "websocket");
  assert (Hashtbl.find headers (Bytes.of_string "ORIGIN") = Bytes.of_string "null");
  assert (
    Hashtbl.find headers (Bytes.of_string "SEC-WEBSOCKET-VERSION") = Bytes.of_string "13");
  assert (
    Hashtbl.find headers (Bytes.of_string "USER-AGENT")
    = Bytes.of_string
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like \
         Gecko) Chrome/45.0.2454.85 Safari/537.36");
  assert (
    Hashtbl.find headers (Bytes.of_string "ACCEPT-ENCODING")
    = Bytes.of_string "gzip, deflate, sdch");
  assert (
    Hashtbl.find headers (Bytes.of_string "ACCEPT-LANGUAGE")
    = Bytes.of_string "ja,en-US;q=0.8,en;q=0.6");
  assert (
    Hashtbl.find headers (Bytes.of_string "SEC-WEBSOCKET-KEY")
    = Bytes.of_string "eUksYQMw3z+ZMjb6baawiw==");
  assert (
    Hashtbl.find headers (Bytes.of_string "SEC-WEBSOCKET-EXTENSIONS")
    = Bytes.of_string "permessage-deflate; client_max_window_bits");
  assert (message_body = Bytes.empty);
  let { request_line; headers; message_body } =
    "POST / HTTP/1.1\r\n\
     Host: localhost:3000\r\n\
     User-Agent: curl/7.43.0\r\n\
     Accept: */*\r\n\
     Content-Length: 21\r\n\
     Content-Type: application/x-www-form-urlencoded\r\n\
     \r\n\
     query=hoge fuga hello"
    |> Bytes.of_string
    |> in_channel_of_bytes
    |> parse_request
  in
  assert (request_line = Bytes.of_string "POST / HTTP/1.1");
  assert (Hashtbl.find headers (Bytes.of_string "HOST") = Bytes.of_string "localhost:3000");
  assert (
    Hashtbl.find headers (Bytes.of_string "USER-AGENT") = Bytes.of_string "curl/7.43.0");
  assert (Hashtbl.find headers (Bytes.of_string "ACCEPT") = Bytes.of_string "*/*");
  assert (Hashtbl.find headers (Bytes.of_string "CONTENT-LENGTH") = Bytes.of_string "21");
  assert (
    Hashtbl.find headers (Bytes.of_string "CONTENT-TYPE")
    = Bytes.of_string "application/x-www-form-urlencoded");
  assert (message_body = Bytes.of_string "query=hoge fuga hello")
;;
