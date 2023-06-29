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

let is_blank s = match String.trim s with "" -> true | _ -> false

let rec names_unique ?(acc = []) = function
  | [] -> true
  | (k, _) :: xs -> (
      match List.mem k acc with
      | true -> false
      | false -> names_unique ~acc:(k :: acc) xs)

let all_unique jsons =
  let names =
    List.map
      (function
        (* if it is an object and it has one key-value pair *)
        | Object [ (k, v) ] -> Some (k, v)
        (* atomic values get mapped to _ *)
        | (Float _ as v) | (Integer _ as v) | (String _ as v) -> Some ("_", v)
        (* other types of values will get discarded *)
        | _ -> None)
      jsons
  in
  match List.for_all Option.is_some names with
  | false -> List jsons
  | true -> (
      let kvs = List.filter_map Fun.id names in
      match names_unique kvs with true -> Object kvs | false -> List jsons)

let tree_to_js tree =
  let rec convert = function
    | Parser.Text s -> (
        match is_blank s with false -> Some (String s) | true -> None)
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
              attrs
              |> List.map (fun ((_uri, local), value) -> (local, String value))
              |> Option.some
        in
        let subtrees = List.filter_map convert subtrees in
        let subtrees =
          match attributes with
          | Some attributes ->
              let temp = Object [ ("$", Object attributes) ] in
              temp :: subtrees
          | None -> subtrees
        in
        let subtrees = all_unique subtrees in
        Some (Object [ (out_name, subtrees) ])
  in
  js_of_json
  @@
  match convert tree with
  | None -> String "TODO, unclear semantics"
  | Some json -> json

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
