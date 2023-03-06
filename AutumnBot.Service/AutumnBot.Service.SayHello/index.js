import WebSocket from "ws";

const ws = new WebSocket("ws://localhost:3000");

ws.on("error", console.error);

ws.on("open", function open() {
  console.log("Successfully connected to AutumnBot.Core");
});

ws.on("message", function message(data) {
  let header = JSON.parse(data)["header"];

  ws.send({
    header: "AutumnBot.Service.SayHello",
    client: header,
    body: "Hello!",
  });
});

while (true);
