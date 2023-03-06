open Base

module String = struct
  include String

  let contains (x : string) (s : string) : bool =
    let bords (x : string) : int array =
      let m : int = String.length x in
      let b : int array = Array.create m ~len:0 in
      let i : int ref = ref 0 in
      for j = 1 to m - 1 do
        while Int.(!i > 0) && Char.(x.[!i] <> x.[j]) do
          i := b.(!i - 1)
        done;
        if Char.(x.[!i] = x.[j]) then Int.incr i;
        b.(j) <- !i
      done;
      b
    in
    let m : int = String.length x
    and n : int = String.length s in
    let b : int array = bords (x ^ "$" ^ s) in
    let res : int list ref = ref [] in
    for k = m + 1 to m + n do
      if Int.(b.(k) = m) then res := (k - (2 * m)) :: !res
    done;
    List.is_empty !res
  ;;
end

module List = struct
  include List

  let remove (l : 'a list) ~(f : 'a -> bool) = List.filter l ~f
end
