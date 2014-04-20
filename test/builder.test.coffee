# use zap to run tests, it also detects CoffeeScript files
xml2js = require '../src/xml2js'
assert = require 'assert'
fs = require 'fs'
path = require 'path'
diff = require 'diff'

# fileName = path.join __dirname, '/fixtures/sample.xml'

# shortcut, because it is quite verbose
equ = assert.equal

# equality test with diff output
diffeq = (expected, actual) ->
  diffless = "Index: test\n===================================================================\n--- test\texpected\n+++ test\tactual\n"
  patch = diff.createPatch('test', expected.trim(), actual.trim(), 'expected', 'actual')
  throw patch unless patch is diffless

module.exports =
  'test CDATA': (test) ->
    console.log "Test Cdata"
    expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><first><MsgId><![CDATA[5850440872586764820]]></MsgId><foo>bar</foo></first>'
    opts = renderOpts: pretty: false
    builder = new xml2js.Builder opts
    obj = {"first":{"MsgId":[{"dat":"5850440872586764820"}],"foo":"bar"}}
    actual = builder.buildObject obj
    console.log "Test -> " + actual
    diffeq expected, actual
    test.finish()
    
  'test building basic XML structure': (test) ->
    expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><xml><Label></Label><MsgId>5850440872586764820</MsgId></xml>'
    obj = {"xml":{"Label":[""],"MsgId":["5850440872586764820"]}}
    builder = new xml2js.Builder renderOpts: pretty: false
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test setting XML declaration': (test) ->
    expected = '<?xml version="1.2" encoding="WTF-8" standalone="no"?><root/>'
    opts =
      renderOpts: pretty: false
      xmldec: 'version': '1.2', 'encoding': 'WTF-8', 'standalone': false
    builder = new xml2js.Builder opts
    actual = builder.buildObject {}
    diffeq expected, actual
    test.finish()

  'test pretty by default': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <MsgId>5850440872586764820</MsgId>
      </xml>

    """
    builder = new xml2js.Builder()
    obj = {"xml":{"MsgId":["5850440872586764820"]}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test setting indentation': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
          <MsgId>5850440872586764820</MsgId>
      </xml>

    """
    opts = renderOpts: pretty: true, indent: '    '
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":["5850440872586764820"]}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test explicit rootName is always used: 1. when there is only one element': (test) ->
    expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><FOO><MsgId>5850440872586764820</MsgId></FOO>'
    opts = renderOpts: {pretty: false}, rootName: 'FOO'
    builder = new xml2js.Builder opts
    obj = {"MsgId":["5850440872586764820"]}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test explicit rootName is always used: 2. when there are multiple elements': (test) ->
    expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><FOO><MsgId>5850440872586764820</MsgId></FOO>'
    opts = renderOpts: {pretty: false}, rootName: 'FOO'
    builder = new xml2js.Builder opts
    obj = {"MsgId":["5850440872586764820"]}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test default rootName is used when there is more than one element in the hash': (test) ->
    expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root><MsgId>5850440872586764820</MsgId><foo>bar</foo></root>'
    opts = renderOpts: pretty: false
    builder = new xml2js.Builder opts
    obj = {"MsgId":["5850440872586764820"],"foo":"bar"}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test when there is only one first-level element in the hash, that is used as root': (test) ->
    expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><first><MsgId>5850440872586764820</MsgId><foo>bar</foo></first>'
    opts = renderOpts: pretty: false
    builder = new xml2js.Builder opts
    obj = {"first":{"MsgId":["5850440872586764820"],"foo":"bar"}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()



  'test parser -> builder roundtrip': (test) ->
    fileName = path.join __dirname, '/fixtures/build_sample.xml'
    fs.readFile fileName, (err, xmlData) ->
      xmlExpected = xmlData.toString()
      xml2js.parseString xmlData, {'trim': true}, (err, obj) ->
        equ err, null
        builder = new xml2js.Builder({})
        xmlActual = builder.buildObject obj
        diffeq xmlExpected, xmlActual
        test.finish()


