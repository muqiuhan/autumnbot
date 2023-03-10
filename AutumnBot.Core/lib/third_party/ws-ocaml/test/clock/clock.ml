open Ws_ocaml

let str_of_time { Unix.tm_sec; tm_min; tm_hour; tm_mday; tm_mon; tm_year; _ } =
  Printf.sprintf
    "%d/%02d/%02d %02d:%02d:%02d"
    (tm_year + 1900)
    (tm_mon + 1)
    tm_mday
    tm_hour
    tm_min
    tm_sec
;;

let () =
  let body client =
    let ok = ref true in
    while !ok do
      ok
        := Websocket.send_text
             client
             (Unix.time () |> Unix.localtime |> str_of_time |> Bytes.of_string);
      Unix.sleep 1
    done
  in
  Websocket.(run ~addr:"127.0.0.1" ~port:"3000" (make_app ~body ()))
;;
