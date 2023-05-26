module Jsoo = Js_of_ocaml

let () =
  Jsoo.Js.export "xml2js"
    (object%js
       method foo () = 42
       method parseString str _opts _cb = Parser.parse str
    end)
