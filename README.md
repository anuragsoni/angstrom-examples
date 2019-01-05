# Angstrom Examples

Examples of parsers written using [Angstrom](https://github.com/inhabitedtype/angstrom).

## Build
1. Install `angstrom` (`opam install angstrom`)
2. `dune build`

## Explore via repl
1. `dune utop src`

## Example list

1. Hex color parser. [Link](https://github.com/anuragsoni/angstrom-examples/blob/master/src/colors.ml).
2. Bencode (`.torrent` file format) parser. [Link](https://github.com/anuragsoni/angstrom-examples/blob/master/src/bencode.ml).
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
