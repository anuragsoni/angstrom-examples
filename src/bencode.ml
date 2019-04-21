open Angstrom

type t =
  | BInteger of int
  | BString of string
  | BList of t list
  | BDict of (string * t) list

let signed_integer =
  let is_digit = function '0' .. '9' -> true | _ -> false in
  let is_sign = function '+' | '-' -> true | _ -> false in
  let take_digits = take_while1 is_digit >>| int_of_string in
  let multiplier = take_while is_sign >>= function
    | "" | "+" -> return 1
    | "-" -> return (-1)
    | _ -> fail "Invalid sign"
  in
  lift2 (fun multiplier digits -> multiplier * digits) multiplier take_digits

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
