module AutumnBot.Core.Program

open AutumnBot.Service.ServiceManager
open AutumnBot.Service.QQGroup
open AutumnBot.Plugin.Log

let log = Log("AutumnBot.Core")

[<EntryPoint>]
let main argv =
  log.info "Initializing..."
  let services = new ServiceManager([ new QQGroup.Service() ])

  services.Stop()
  System.Console.ReadKey() |> ignore
  0
