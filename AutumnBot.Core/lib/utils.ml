open Base

module List = struct
  include List

  let remove (l : 'a list) ~(f : 'a -> bool) = List.filter l ~f
end
