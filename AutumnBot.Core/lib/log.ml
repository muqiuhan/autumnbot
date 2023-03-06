let info str =
  Simlog.info ("AutumnBot.Core: " ^ str);
  flush stdout
;;

let error str =
  Simlog.error ("AutumnBot.Core: " ^ str);
  flush stdout
;;
