import WebSocket from "ws";

const ws = new WebSocket("ws://127.0.0.1:3000");

ws.on("error", console.error);

ws.on("open", function open() {
  console.log("Successfully connected to AutumnBot.Core");

  ws.send(JSON.stringify({
    header: "AutumnBot.Service.SayHello",
    client: "",
    body: "",
  }));
});

ws.on("message", function message(data) {
  let header = JSON.parse(data)["header"];

  ws.send(JSON.stringify({
    header: "AutumnBot.Service.SayHello",
    client: header,
    body: "Hello!",
  }));
});

