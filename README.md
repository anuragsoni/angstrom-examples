# Angstrom Examples

Some toy parsers written using Angstrom.

1. Hex color parser.
2. Bencode (`.torrent` file format) parser.
   We use the following type for representing bencode:
    ```ocaml
    type t =
      | Integer of int
      | String of string
      | List of t list
      | Dict of (string * t) list
    ```
    `List` and `Dict` contain values that are themselves bencode values, so we need
    a parser that will accept bencode list and dictionary but we don't yet have access
    to a parser for bencode values as a whole. We get around the issue by using `fix` from
    `Angstrom`. We define our parsers for `List` and `Dict` within the function passed to `fix`,
    which gives us access to a parser we can use to parse bencode values as a whole.
