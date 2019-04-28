type t = {red: int; green: int; blue: int}

let create_color red green blue = {red; green; blue}

(* We use bind here since the result of `take` is required to decide
   the result of the next parser. *)
let hex =
  let open Angstrom in
  take 2
  >>= fun s ->
  match int_of_string_opt ("0x" ^ s) with
  | Some x ->
      return x
  | _ ->
      fail "invalid number"

let color =
  let open Angstrom in
  (* We combine three hex parsers via `apply` since
     all three parsers are independant. *)
  create_color <$> char '#' *> hex <*> hex <*> hex <?> "color"

let parse str =
  (* In a real program we would probably do somewith in the error
     scenario instead of raising an exception. *)
  match Angstrom.parse_string color str with
  | Ok c ->
      c
  | Error msg ->
      failwith msg
