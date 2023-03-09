open Base
open Ws_ocaml
module Mutex = Stdlib.Mutex
module Condition = Stdlib.Condition

module Instance = struct
  module T = struct
    type t = string * Websocket.client

    let compare ((header_x, _) : t) ((header_y, _) : t) : int =
      String.compare header_x header_y

    let sexp_of_t (instance : t) : Sexp.t =
      let (header : string), _ = instance in
      List [Atom header]
  end

  include T
  include Comparator.Make (T)
end

class instances =
  object (self)
    val mutable instances : (Instance.t, Instance.comparator_witness) Set.t =
      Set.empty (module Instance)

    val mutex : Mutex.t = Mutex.create ()

    method contain (instance : Instance.t) : unit =
      let instance_header, _ = instance in
      match
        Set.find instances ~f:(fun (header, _) ->
            String.equal header instance_header)
      with
      | None ->
        Log.info ("Instance: New " ^ instance_header);
        self#put instance
      | Some (_, client) ->
        let _, instance_client = instance in
        if phys_equal client instance_client then
          ()
        else (
          Log.info ("Instance: Replace" ^ instance_header);
          self#put instance)

    method put (instance : Instance.t) : unit =
      Mutex.lock mutex;
      instances <- Set.add instances instance;
      Mutex.unlock mutex

    method get_client (instance_header : string) : Websocket.client option =
      Mutex.lock mutex;
      let result =
        Option.bind
          (Set.find instances ~f:(fun (header, _) ->
               String.equal header instance_header))
          ~f:(fun (_, client) -> Some client)
      in
      Mutex.unlock mutex;
      result

    method remove (instance_header : string) : unit =
      match
        Set.find instances ~f:(fun (header, _) ->
            String.equal instance_header header)
      with
      | None -> ()
      | Some instance ->
        let header, _ = instance in
        Log.info ("Instance: Remove " ^ header);
        Mutex.lock mutex;
        instances <- Set.remove instances instance;
        Mutex.unlock mutex
  end

let clients = new instances
let services = new instances
let find_service = services#get_client
let find_client = clients#get_client
let remove_client = clients#remove
let remove_service = services#remove
