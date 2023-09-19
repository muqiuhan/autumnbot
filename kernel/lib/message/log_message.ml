type level =
  | DEBUG
  | INFO
  | WARN
  | ERROR

type t = {
  log_message_id: string;
  log_message_level : level;
  log_message_value : string;
}
