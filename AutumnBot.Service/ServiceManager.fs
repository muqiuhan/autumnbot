module AutumnBot.Service.ServiceManager

open Log

type ServiceManager (services : list<Service.Service>) as self =
  inherit Log ("AutumnBot.Service.ServiceManager")
  do self.info "Initializing..."

  let pool =
    List.map
      (fun (service : Service.Service) -> async { service.Start() })
      services
    |> List.iter Async.RunSynchronously

  member public this.Stop () =
    List.iter
      (fun (service : Service.Service) -> service.Stop.Cancel())
      services
