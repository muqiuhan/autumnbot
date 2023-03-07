let start () =
  Log.info "Start AutumnBot.Core";
  Connection.start ();
  Dispatch.start ()
;;
