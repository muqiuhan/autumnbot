let start () =
  try
    Log.info "Core: start";
    Connection.start ();
    Dispatch.start ()
  with
  | e -> Printexc.to_string e |> Log.error
;;
