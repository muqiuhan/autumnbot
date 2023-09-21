type server = Dream.server

let init () =
    Task.Domain.async (fun () ->
        Dream.run
        @@ Dream.router
             [
               Dream.get "/kernel" (fun _ ->
                   Dream.websocket (fun client ->
                       match%lwt Dream.receive client with
                       | Some msg -> Log.info "Receive: %s" msg |> Lwt.return
                       | _ -> Dream.close_websocket client));
             ])
