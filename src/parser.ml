type t = Tag of Xmlm.tag * t list | Text of string

let parse data =
  let input = Xmlm.make_input (`String (0, data)) in
  let el tag subtrees = Tag (tag, subtrees) in
  let data text = Text text in
  (* use `input_doc_tree` since `make_input gives an
     (potentially empty) DTD *)
  let _dtd, doc_tree = Xmlm.input_doc_tree ~el ~data input in
  doc_tree
