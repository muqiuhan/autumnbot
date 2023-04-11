#!/bin/env ocaml

type config = 
  { path: string;
    build: string;
    dev: string;
    run: string;
    setup: string list }

module type Module = sig val config : config end

let modules = [
  ("Core", 
    (module struct let config = 
        { path = "./Core";
          build = "dune build --release";
          dev = "dune build -w";
          run = "dune exec Core";
          setup = ["opam install . --deps-only"] } end : Module))
]

let get_action (module M : Module) (action : string) = 
  begin
    match action with
    | "build" -> M.config.build
    | "setup" -> M.config.setup |> String.concat "&&"
    | "dev" -> M.config.dev
    | "run" -> M.config.run
    | _ -> failwith "Unsupported action"
  end |> Format.sprintf "cd %s && %s" M.config.path

let _ = 
  match Sys.argv.(1) with
  | "start" ->  List.iter (fun (target, actions) -> get_action actions "run" |> Sys.command |> ignore) modules
  | "setup" -> List.iter  (fun (target, actions) -> get_action actions "setup" |> Sys.command |> ignore) modules
  | "build" -> List.iter  (fun (target, actions) -> get_action actions "build" |> Sys.command |> ignore) modules
  | target ->
    let action = Sys.argv.(2) in
    match List.assoc_opt target modules with
    | Some target -> get_action target action |> Sys.command |> ignore
    | _ -> failwith ("Undefined target: " ^ target)