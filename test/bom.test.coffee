xml2js = require '../lib/xml2js'
assert = require 'assert'
equ = assert.equal

describe 'bom', ->
  test 'decoded BOM', (done) ->
    demo = '\uFEFF<xml><foo>bar</foo></xml>'
    xml2js.parseString demo, (err, res) ->
      equ err, undefined
      equ res.xml.foo[0], 'bar'
      done()
