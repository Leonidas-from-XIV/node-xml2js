module Js = Js_of_ocaml.Js

let console = Js_of_ocaml.Firebug.console

let require s =
  Js.Unsafe.fun_call
    (Js.Unsafe.js_expr "require")
    [| Js.Unsafe.inject (Js.string s) |]

let _xml2js = require "../lib/xml2js.bc.js"
let path = require "path"
let fs = require "fs"
let util = require "util"
let file_name = path##join (Js.Unsafe.js_expr "__dirname") "fixtures/sample.xml"
let xml2js_path = path##join (Js.Unsafe.js_expr "__dirname") "../lib/xml2js.bc.js"

let () = console##log xml2js_path

(* let _xml2js = require xml2js_path *)
(* let _xml2js = require "xml2js" *)

(* let equ got expected = *)
(*   (1* jsoo compiles == into === *1) *)
(*   match got == expected with true -> () | false -> assert false *)

let skeleton _checks =
  let _ =
    fs##readFile file_name "utf8" (fun _err _data ->
      ()
    )
        (* xml2js##parseString data (fun _err value -> *)
        (*     checks value; *)
        (*     (1* console##log value; *1) *)
        (*     ())) *)
  in
  ()

let _index n arr =
  let v = Js.array_get arr n in
  Js.Optdef.get v (fun () -> Js.undefined)

let attr name v = Js.Unsafe.get v (Js.string name)
let dollar = attr "$"
let inspect v = util##inspect v false 10

let _wait () =
  skeleton
      (fun r ->
        console##log_2 "Sample" r##.sample;
        console##log_2 "Sample" (inspect r##.sample);

        (* actual value *)
        (* equ *)
        (*   (r##.sample |> index 1 |> attr "chartest" |> index 0 |> dollar *)
        (*  |> attr "desc") *)
        (*   "Test for CHARs"; *)

        (* existing value *)
        Webtest.Suite.assert_equal
          (r##.sample |> attr "chartest" |> dollar |> attr "desc")
          "Test for CHARs";
        ())

let suite =
  (* let noop = Webtest.Suite.Async.noop in *)
  let noop = fun () -> () in
  let async_test = Webtest.Suite.Async.(bracket noop (fun () wrapper -> wrapper (fun () -> console##log "Running")) noop) in
  let sync_test = Webtest.Suite.Sync.(bracket noop (fun () -> ()) noop) in
  Webtest.Suite.(
    "Parser" >::: [
      "sync" >:: sync_test;
      "async" >:~ async_test
      ]
  )

let ehh () = ()
