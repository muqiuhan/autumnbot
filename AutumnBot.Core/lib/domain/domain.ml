
let spawn (fn : unit -> unit) = Thread.create fn ()