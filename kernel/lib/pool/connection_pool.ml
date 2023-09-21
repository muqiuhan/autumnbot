module Connection_pool = Hashtbl.Make (String)

type t = Io.Client.t Connection_pool.t

let add pool (connection_id, connection_client) =
    match Connection_pool.find_opt pool connection_id with
    | Some _ -> Io.Client.close connection_client
    | None -> Connection_pool.add pool connection_id connection_client

let get pool connection_id = Connection_pool.find connection_id pool
