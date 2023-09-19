let process (message : Message.Type.t) =
    Task.Domain.async (fun () ->
        let pool = new Task.Thread.t in
            match message with
            | Message.Type.Client client_message ->
                Message_processer.Client.process client_message pool
            | Message.Type.Sevice service_message ->
                Message_processer.Service.process service_message pool
            | Message.Type.Log log_message ->
                Message_processer.Log.process log_message pool
            | Message.Type.Mount mount_message ->
                Message_processer.Mount.process mount_message pool)
