import WebSocket from "ws";

const ws = new WebSocket("ws://127.0.0.1:3000");

ws.on("error", console.error);

ws.on("open", function open() {
  console.log("Successfully connected to AutumnBot.Core");


  // Mount message
  ws.send(JSON.stringify({
    header: "AutumnBot.Service.SayHello",
    client: "",
    body: "",
  }));
});

ws.on("message", function message(data) {
  let header = JSON.parse(data)["header"];

  console.log("Received message from " + header + " : " + JSON.parse(data)["body"]);

  if(JSON.parse(data)["body"] == "Hi") {
    ws.send(JSON.stringify({
      header: "AutumnBot.Service.SayHello",
      client: header,
      body: "Hello!",
    }));
  } else {
    ws.send(JSON.stringify({
      header: "AutumnBot.Service.SayHello",
      client: header,
      body: "ERROR",
    }));
  }
});
