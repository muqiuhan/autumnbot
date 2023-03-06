open Core_lib

let _ =
  Log.info "Start AutumnBot.Core";
  Core.start ();
  input_line stdin
;;
