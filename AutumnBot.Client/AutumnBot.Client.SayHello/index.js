import WebSocket from "ws";

const ws = new WebSocket("ws://127.0.0.1:3000");

ws.on("error", console.error);

ws.on("open", function open() {
  console.log("Successfully connected to AutumnBot.Core");


  // Mount message
  ws.send(JSON.stringify({
    header: "AutumnBot.Client.SayHello",
    service: "",
    body: "",
  }));

  // Request service
  ws.send(JSON.stringify({
    header: "AutumnBot.Client.SayHello",
    service: "AutumnBot.Service.SayHello",
    body: "Hi",
  }));
});

ws.on("message", function message(data) {
  console.log(JSON.parse(data)["body"]);
});
