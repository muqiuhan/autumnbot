open Base
open Ws_ocaml

module Instance = struct
  module T = struct
    type t = string * Websocket.client

    let compare ((header_x, _) : t) ((header_y, _) : t) : int =
      String.compare header_x header_y
    ;;

    let sexp_of_t (instance : t) : Sexp.t =
      let (header : string), _ = instance in
      List [ Atom header ]
    ;;
  end

  include T
  include Comparator.Make (T)
end

class instances =
  object (self)
    val mutable instances : (Instance.t, Instance.comparator_witness) Set.t =
      Set.empty (module Instance)

    method contain (instance : Instance.t) : unit = self#put instance

    method put (instance : Instance.t) : unit =
      let header, _ = instance in
      Log.debug ("Add instance: " ^ header);
      instances <- Set.add instances instance

    method get_client (instance_header : string) : Websocket.client option =
      Option.bind
        (Set.find instances ~f:(fun (header, _) -> String.equal header instance_header))
        ~f:(fun (_, client) -> Some client)

    method remove (instance_client : Websocket.client) : unit =
      match
        Set.find instances ~f:(fun (_, client) -> phys_equal client instance_client)
      with
      | None -> ()
      | Some instance ->
        let header, _ = instance in
        Log.debug ("Remove instance: " ^ header);
        instances <- Set.remove instances instance
  end

let clients = new instances
let services = new instances
let find_service = services#get_client
let find_client = clients#get_client
