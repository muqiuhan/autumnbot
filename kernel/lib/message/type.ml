type t =
  | Log of Log_message.t
  | Mount of Mount_message.t
  | Client of Client_message.t
  | Sevice of Service_message.t
