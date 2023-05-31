module Jsoo = Js_of_ocaml
module Js = Jsoo.Js

type json =
  | String of string
  | Integer of int
  | Float of float
  | Object of (string * json) list
  | List of json list

let rec js_of_json = function
  | String s -> Js.Unsafe.inject @@ Js.string s
  | Integer i -> Js.Unsafe.inject i
  | Float f -> Js.Unsafe.inject f
  | Object content ->
      let content =
        content
        |> List.map (fun (key, v) ->
               let v = js_of_json v in
               (key, v))
        |> Array.of_list
      in
      Js.Unsafe.obj content
  | List content ->
      let content =
        content |> List.map js_of_json |> Array.of_list |> Js.array
      in
      Js.Unsafe.inject content

let rec tree_to_js tree =
  match tree with
  | Parser.Text s -> Js.Unsafe.inject @@ Js.string s
  | Tag (tag, subtrees) ->
      let tag_name, attrs = tag in
      let tag_name_uri, tag_name_local = tag_name in
      let out_name =
        match tag_name_uri with
        | "" -> tag_name_local
        | tag_name_uri -> tag_name_uri ^ ":" ^ tag_name_local
      in
      let attributes =
        match attrs with
        | [] -> None
        | attrs ->
            let mappings =
              attrs
              |> List.map (fun ((_uri, local), value) ->
                     (local, Js.Unsafe.inject @@ Js.string value))
              |> Array.of_list
            in
            Some mappings
      in
      let subtrees = List.map tree_to_js subtrees in
      let subtrees =
        match attributes with
        | Some attributes ->
            let temp = Js.Unsafe.obj [| ("$", Js.Unsafe.obj attributes) |] in
            temp :: subtrees
        | None -> subtrees
      in
      let subtrees =
        subtrees |> Array.of_list |> Js.array |> Js.Unsafe.inject
      in
      Js.Unsafe.obj [| (out_name, subtrees) |]

(* API *)

let () =
  Jsoo.Js.export_all
    (object%js
       method test1 = js_of_json (String "foo")
       method test2 = js_of_json (Integer 42)
       method test3 = js_of_json (Float 23.)
       method test4 = js_of_json (List [ Integer 42 ])
       method test5 = js_of_json (Object [ ("foo", String "bar") ])

       method parseString str cb =
         match Parser.parse str with
         | tree ->
             let tree = tree_to_js tree in
             Js.Unsafe.fun_call cb
               [| Js.Unsafe.inject Js.null; Js.Unsafe.inject @@ Js.some tree |]
         | exception _ ->
             Js.Unsafe.fun_call cb
               [|
                 Js.Unsafe.inject @@ Js.some "TODO parsing error";
                 Js.Unsafe.inject Js.null;
               |]
       (* method parseString_withOpts str _opts _cb = Parser.parse str *)
    end)
