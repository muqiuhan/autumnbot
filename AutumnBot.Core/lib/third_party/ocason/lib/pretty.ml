open Ast

exception InvalidJson of string

let pretty_list sep ppx out l =
  let pp_sep out () = Format.fprintf out "%s@ " sep in
  Format.pp_print_list ~pp_sep ppx out l
;;

let is_obj_or_arr = function
  | JsonArray _ | JsonObject _ -> true
  | _ -> false
;;

let quote s = Printf.sprintf {|"%s"|} s

let rec format std (out : Format.formatter) (x : Ast.json) =
  match x with
  | JsonNull -> Format.pp_print_string out "null"
  | JsonBool b -> Format.pp_print_bool out b
  | JsonNumber i -> Format.pp_print_string out (string_of_int i)
  | JsonString s -> Format.pp_print_string out (quote s)
  | JsonFloat f -> Format.pp_print_string out (string_of_float f)
  | JsonArray [] -> Format.pp_print_string out "[]"
  | JsonArray l ->
    Format.fprintf out "[@;<1 0>@[<hov>%a@]@;<1 -2>]" (pretty_list "," (format std)) l
  | JsonObject [] -> Format.pp_print_string out "{}"
  | JsonObject o ->
    Format.fprintf out "{@;<1 0>%a@;<1 -2>}" (pretty_list "," (format_field std)) o

and format_field std out (name, field) =
  Format.fprintf out "@[<hv2>%s: %a@]" (quote name) (format std) field
;;

let pretty ?(std = false) out x =
  if std && not (is_obj_or_arr x)
  then raise (InvalidJson "root is not an object or array")
  else Format.fprintf out "@[<hv2>%a@]" (format std) (x :> Ast.json)
;;

let to_string ?std x = Format.asprintf "%a" (pretty ?std) x

let to_channel ?std oc x =
  Format.fprintf (Format.formatter_of_out_channel oc) "%a@?" (pretty ?std) x
;;
