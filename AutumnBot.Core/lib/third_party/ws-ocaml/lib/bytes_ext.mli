(** Bytes functions. *)

(** [encode_int x dst start len] encodes integer [x] into [dst] from [start]
    with [len] characters in big endian. *)
val encode_int : int -> bytes -> int -> int -> unit

(** [bytes_of_int x n] newly allocate a byte sequence of [n] characters where
    [x] is encoded in big endian. *)
val bytes_of_int : int -> int -> bytes

(** [decode_int src start len] decodes [len] characters of [src] starting at
    [start] as an integer of big endian. *)
val decode_int : bytes -> int -> int -> int

(** [int_of_bytes bytes] translates [bytes] into an integer. *)
val int_of_bytes : bytes -> int
