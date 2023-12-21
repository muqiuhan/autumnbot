module AutumnBot.Service.ServiceManager

open System

type ServiceManager (services : list<Service.Service>) =
  let pool =
    List.map (fun (service : Service.Service) -> service.Start()) services

  do printfn $"启动完成"

  member public this.Stop () =
    List.iter
      (fun (service : Service.Service) -> service.Stop.Cancel())
      services
