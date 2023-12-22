module AutumnBot.Core.Program

open AutumnBot.Service.ServiceManager
open AutumnBot.Service
open AutumnBot.Service.Log

let log = Log("AutumnBot.Core")

[<EntryPoint>]
let main argv =
  log.info "Initializing..."
  let services = new ServiceManager([ new QQ.Service() ])

  services.Stop()
  System.Console.ReadKey() |> ignore
  0
