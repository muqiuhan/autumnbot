module AutumnBot.Service.QQ

open AutumnBot.Service
open Mirai.Net
open System

type Service () =
  inherit Service.Service ("AutumnBot.Service.QQ")

  member this.bot =
    new Sessions.MiraiBot(
      Address = "localhost:9993",
      QQ = "2109939614",
      VerifyKey = "autumn"
    )

  interface IDisposable with
    member this.Dispose () = this.bot.Dispose()

  override this.Start () =
    this.info "Starting..."

    task { return! this.bot.LaunchAsync() }
    |> Async.AwaitTask
    |> Async.RunSynchronously

    this.debug "Configuring..."
    this.Config()

    while true do
      if this.Stop.IsCancellationRequested then
        this.info "Aborting..."
        raise Service.ServiceStop


  member private this.Config () =
    this.bot.MessageReceived
    |> Observable.filter (fun event ->
      event :? Data.Messages.Receivers.GroupMessageReceiver)
    |> Observable.subscribe (fun message ->
      message :?> Data.Messages.Receivers.GroupMessageReceiver
      |> (fun message ->
        this.info
          $"Received group message from {message.GroupId}: Sender: {message.Sender.Id} -> {message.MessageChain.GetPlainMessage()}"))
    |> ignore
