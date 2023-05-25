type tag = string
type attr = string * string

type tree =
  | Node of tag * attr list * tree list

let parse data =
  let _input = Xmlm.make_input (`String (0, data)) in
  Node ("root", [("hest", "giraf")], [])
