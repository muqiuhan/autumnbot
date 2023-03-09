open Base

module List = struct
  include List

  let remove (l : 'a list) ~(f : 'a -> bool) = List.filter l ~f
end

let check_send_status = function
  | true -> Log.info "Websocket send successfully"
  | false -> Log.error "Websocket send failed"
;;
