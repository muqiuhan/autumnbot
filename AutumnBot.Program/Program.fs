open Mirai.Net

let _ =
  use bot =
    new Sessions.MiraiBot(
      Address = "localhost:9993",
      QQ = "2109939614",
      VerifyKey = "autumn"
    )

  printfn "正在连接到MIRAI终端..."

  task { return! bot.LaunchAsync() }
  |> Async.AwaitTask
  |> Async.RunSynchronously

  printfn "正在等待群消息..."

  bot.MessageReceived
  |> Observable.filter (fun event ->
    event :? Data.Messages.Receivers.GroupMessageReceiver)
  |> Observable.subscribe (fun message ->
    message :?> Data.Messages.Receivers.GroupMessageReceiver
    |> (fun message ->
      printfn
        $"收到了来自群{message.GroupId}由{message.Sender.Id}发送的消息：{message.MessageChain.GetPlainMessage()}"))
  |> ignore

  System.Console.ReadKey()
