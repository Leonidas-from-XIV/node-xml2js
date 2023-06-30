module Js = Js_of_ocaml.Js

let suite =
  let noop () = () in
  let test = Webtest.Suite.Sync.(bracket noop (fun () -> ()) noop) in
  Webtest.Suite.("Dummy test" >:: test)

let _require s =
  Js.Unsafe.fun_call
    (Js.Unsafe.js_expr "require")
    [| Js.Unsafe.inject (Js.string s) |]

let _xml2js = _require "../lib/xml2js.bc.js"

let () =
  print_endline "calling Test_parser";
  Test_parser.ehh ();
  print_endline "done"

let () =
  let suite = 
    Webtest.Suite.(
      "xml2js" >::: [
        suite;
        Test_parser.suite
      ])
  in
  Webtest_js.Runner.run ~with_colors:true suite
