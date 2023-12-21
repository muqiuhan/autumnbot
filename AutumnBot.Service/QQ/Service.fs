module AutumnBot.Service.QQ

open AutumnBot.Service
open Mirai.Net
open System

type Service () =
  inherit Service.Service ()

  let bot =
    new Sessions.MiraiBot(
      Address = "localhost:9993",
      QQ = "2109939614",
      VerifyKey = "autumn"
    )

  interface IDisposable with
    member this.Dispose () = bot.Dispose()

  override this.Start () =
    printfn $"QQ Service启动中..."

    task { return! bot.LaunchAsync() }
    |> Async.AwaitTask
    |> Async.RunSynchronously

    this.Config()

    async {
      while true do
        if this.Stop.IsCancellationRequested then
          printfn $"QQ Service停止中..."
          raise Service.ServiceStop
    }

  member private this.Config () =
    bot.MessageReceived
    |> Observable.filter (fun event ->
      event :? Data.Messages.Receivers.GroupMessageReceiver)
    |> Observable.subscribe (fun message ->
      message :?> Data.Messages.Receivers.GroupMessageReceiver
      |> (fun message ->
        printfn
          $"收到了来自群{message.GroupId}由{message.Sender.Id}发送的消息：{message.MessageChain.GetPlainMessage()}"))
    |> ignore
