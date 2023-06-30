(lang dune 3.7)
(name xml2js)

(generate_opam_files true)

(source (github Leonidas-from-XIV/node-xml2js))
(license MIT)
(authors "Marek Kubica <marek@xivilization.net>")
(maintainers "Marek Kubica <marek@xivilization.net>")

(package
  (name xml2js)
  (synopsis "Simple XML to JavaScript object converter")
  (depends
    (ocaml (>= 4.14))
    (js_of_ocaml (>= 5.2))
    (js_of_ocaml-compiler (>= 5.2))
    (js_of_ocaml-ppx (>= 5.2))
    (xmlm (>= 1.4.0))
    (webtest (and (>= 2.0.0) :with-test))
    (webtest-js (and (>= 2.0.0) :with-test)))
  ;; we only compile to JS
  (allow_empty))
