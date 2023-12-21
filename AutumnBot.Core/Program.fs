module AutumnBot.Core.Program

open AutumnBot.Service.ServiceManager
open AutumnBot.Service


[<EntryPoint>]
let main argv =
  let services = new ServiceManager([ new QQ.Service() ])

  System.Console.ReadKey() |> ignore
  services.Stop()
  0
