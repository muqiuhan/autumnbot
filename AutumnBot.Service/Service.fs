module AutumnBot.Service.Service

open System
open AutumnBot.Plugin.Log

[<AbstractClass>]
type Service (serviceName : string) =
  inherit Log (serviceName)
  abstract Start : unit -> unit
  abstract Stop : Threading.CancellationTokenSource

  default this.Stop = new Threading.CancellationTokenSource()

exception ServiceStop
