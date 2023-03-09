open Base
include Simlog
module Domain = Stdlib.Domain

let _ =
  Domain.spawn (fun () ->
      while true do
        Unix.sleep 1;
        Stdlib.flush_all ()
      done)

let error (msg : string) : unit =
  error msg;
  Stdlib.Printexc.get_callstack 20
  |> Stdlib.Printexc.raw_backtrace_to_string
  |> String.chop_suffix_if_exists ~suffix:"\n"
  |> String.split ~on:'\n'
  |> List.iter ~f:(fun msg -> error ("  CALLSTACK: " ^ msg))
