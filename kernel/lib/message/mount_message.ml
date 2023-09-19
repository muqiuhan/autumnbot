type client_type =
  | Mount_message_client
  | Mount_message_service

type t = {
  mount_message_client_type : client_type;
  mount_message_client : Dream.client;
  mount_message_id : string;
  mount_message_address : (string * int) option;
}
