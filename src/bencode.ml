open Angstrom

type t =
  | BInteger of int
  | BString of string
  | BList of t list
  | BDict of (string * t) list

let signed_integer =
  let is_digit = function '0' .. '9' -> true | _ -> false in
  let is_sign = function '+' | '-' -> true | _ -> false in
  let number sign str =
    let multiplier = if sign = "-" then -1 else 1 in
    match int_of_string_opt str with
    | Some x -> return (multiplier * x)
    | _ -> fail ("could not convert string to integer: " ^ str)
  in
  take_while is_sign
  >>= fun sign -> take_while is_digit >>= fun str -> number sign str

let make_tuple a b = (a, b)

let str = signed_integer <* char ':' >>= take

let num = char 'i' *> signed_integer <* char 'e'

let bencode =
  fix (fun bencode ->
      let bstring = lift (fun x -> BString x) str in
      let binteger = lift (fun x -> BInteger x) num in
      let blist =
        lift
          (fun x -> BList x)
          (char 'l' *> many (choice [bstring; binteger; bencode]) <* char 'e')
      in
      let bdictionary =
        lift
          (fun x -> BDict x)
          (char 'd' *> many (lift2 make_tuple str bencode) <* char 'e')
      in
      peek_char_fail
      >>= function
      | 'd' -> bdictionary | 'l' -> blist | 'i' -> binteger | _ -> bstring )
  <?> "bencode"
