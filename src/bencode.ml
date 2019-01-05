type t =
  | BInteger of int
  | BString of string
  | BList of t list
  | BDict of (string * t) list

let signed_integer =
  let open Angstrom in
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

let p a b = (a, b)

let bencode =
  let open Angstrom in
  fix (fun bencode ->
      let bstring =
        lift (fun x -> BString x) (signed_integer <* char ':' >>= take)
      in
      let binteger =
        lift (fun x -> BInteger x) (char 'i' *> signed_integer <* char 'e')
      in
      let blist =
        lift
          (fun x -> BList x)
          (char 'l' *> many (choice [bstring; binteger; bencode]) <* char 'e')
      in
      let bdictionary =
        lift
          (fun x -> BDict x)
          ( char 'd'
            *> many
                 ( p
                 <$> ( bstring
                     >>= function
                     | BString x -> return x | _ -> fail "invalid key" )
                 <*> bencode )
          <* char 'e' )
      in
      peek_char_fail
      >>= function
      | 'd' -> bdictionary | 'l' -> blist | 'i' -> binteger | _ -> bstring )
  <?> "bencode"
