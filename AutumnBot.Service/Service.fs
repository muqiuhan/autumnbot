module AutumnBot.Service.Service

open System

[<AbstractClass>]
type Service () =
  abstract Start : unit -> Async<unit>
  abstract Stop : Threading.CancellationTokenSource

  default this.Stop = new Threading.CancellationTokenSource()

exception ServiceStop
