type t = {red: int; green: int; blue: int}

let hex str =
  let open Angstrom in
  match int_of_string_opt ("0x" ^ str) with
  | Some x -> return x
  | _ -> fail "hex"

let color =
  let open Angstrom in
  (* consume two characters and feed it to the parser returned by the `hex` function. *)
  let parse_hex = take 2 >>= hex in
  char '#' (* consume a `#` character and discard it. *)
  *> lift3
       (fun red green blue -> {red; green; blue})
       parse_hex parse_hex parse_hex
  <?> "color"

let parse str =
  (* In a real program we would probably do somewith in the error
     scenario instead of raising an exception. *)
  match Angstrom.parse_string color str with
  | Ok c -> c
  | Error msg -> failwith msg
