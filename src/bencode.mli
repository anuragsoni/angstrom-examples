type t =
  | BInteger of int
  | BString of string
  | BList of t list
  | BDict of (string * t) list

val bencode : t Angstrom.t
