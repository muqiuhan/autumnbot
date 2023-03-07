include Simlog

let _ =
  Domain.spawn (fun () ->
    while true do
      Unix.sleep 1;
      flush_all ()
    done)
;;
