module Js = Js_of_ocaml.Js

let console = Js_of_ocaml.Firebug.console

let require s =
  Js.Unsafe.fun_call
    (Js.Unsafe.pure_js_expr "require")
    [| Js.Unsafe.inject (Js.string s) |]

let xml2js = require "../lib/xml2js.bc.js"
let path = require "path"
let fs = require "fs"
let util = require "util"
let file_name = path##join (Js.Unsafe.js_expr "__dirname") "fixtures/sample.xml"

let equ got expected =
  (* jsoo compiles == into === *)
  match got == expected with true -> () | false -> assert false

let skeleton (_options, checks) =
  let _ =
    fs##readFile file_name "utf8" (fun _err data ->
        xml2js##parseString data (fun _err value ->
            checks value;
            (* console##log value; *)
            ()))
  in
  ()

let _index n arr =
  let v = Js.array_get arr n in
  Js.Optdef.get v (fun () -> Js.undefined)

let attr name v = Js.Unsafe.get v (Js.string name)
let dollar = attr "$"
let inspect v = util##inspect v false 10

let () =
  skeleton
    ( (),
      fun r ->
        console##log_2 "Sample" r##.sample;
        console##log_2 "Sample" (inspect r##.sample);

        (* actual value *)
        (* equ *)
        (*   (r##.sample |> index 1 |> attr "chartest" |> index 0 |> dollar *)
        (*  |> attr "desc") *)
        (*   "Test for CHARs"; *)

        (* existing value *)
        equ
          (r##.sample |> attr "chartest" |> dollar |> attr "desc")
          "Test for CHARs";
        () )
