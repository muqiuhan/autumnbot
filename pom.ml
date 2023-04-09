#!/bin/env ocaml

module Module = struct
  type config = 
    { path: string;
      build: string;
      dev: string;
      run: string;
      setup: string list }
end

module type Module_Sig = sig
  val config : Module.config
end

let modules = [
  ("Core", 
    (module struct let config = 
      Module.
        { path = "./Core";
          build = "dune build --release";
          dev = "dune build -w";
          run = "dune exec Core";
          setup = ["opam install . --deps-only"] } end : Module_Sig))
]

let get_action (module M : Module_Sig) (action : string) = 
  (match action with
  | "build" -> M.config.build
  | "setup" -> M.config.setup |> String.concat "&&"
  | "dev" -> M.config.dev
  | "run" -> M.config.run
  | _ -> failwith "Unsupported action")
  |> Format.sprintf "cd %s && %s" M.config.path

let _ = 
  let target = Sys.argv.(1)
  and action = Sys.argv.(2) in
  match List.assoc_opt target modules with
  | Some target -> get_action target action |> Sys.command
  | _ -> failwith ("Undefined target: " ^ target)