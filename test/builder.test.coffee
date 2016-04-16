# use zap to run tests, it also detects CoffeeScript files
xml2js = require '../lib/xml2js'
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
  'test building basic XML structure': (test) ->
    expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><xml><Label/><MsgId>5850440872586764820</MsgId></xml>'
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

  'test headless option': (test) ->
    expected = """
      <xml>
          <MsgId>5850440872586764820</MsgId>
      </xml>

    """
    opts =
      renderOpts: pretty: true, indent: '    '
      headless: true
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":["5850440872586764820"]}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test allowSurrogateChars option': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
          <MsgId>\uD83D\uDC33</MsgId>
      </xml>

    """
    opts =
      renderOpts: pretty: true, indent: '    '
      allowSurrogateChars: true
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":["\uD83D\uDC33"]}}
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

  'test building obj with undefined value' : (test) ->
    obj = { node: 'string', anothernode: undefined }
    builder = new xml2js.Builder renderOpts: { pretty: false }
    actual = builder.buildObject(obj);
    expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root><node>string</node><anothernode/></root>'
    equ actual, expected
    test.finish();

  'test building obj with null value' : (test) ->
    obj = { node: 'string', anothernode: null }
    builder = new xml2js.Builder renderOpts: { pretty: false }
    actual = builder.buildObject(obj);
    expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root><node>string</node><anothernode/></root>'
    equ actual, expected
    test.finish();

  'test escapes escaped characters': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <MsgId>&amp;amp;&amp;lt;&amp;gt;</MsgId>
      </xml>

    """
    builder = new xml2js.Builder
    obj = {"xml":{"MsgId":["&amp;&lt;&gt;"]}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test cdata text nodes': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <MsgId><![CDATA[& <<]]></MsgId>
      </xml>

    """
    opts = cdata: true
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":["& <<"]}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test cdata text nodes with escaped end sequence': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <MsgId><![CDATA[& <<]]]]><![CDATA[>]]></MsgId>
      </xml>

    """
    opts = cdata: true
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":["& <<]]>"]}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test uses cdata only for chars &, <, >': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <MsgId><![CDATA[& <<]]></MsgId>
        <Message>Hello</Message>
      </xml>

    """
    opts = cdata: true
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":["& <<"],"Message":["Hello"]}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test uses cdata for string values of objects': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <MsgId><![CDATA[& <<]]></MsgId>
      </xml>

    """
    opts = cdata: true
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":"& <<"}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()

  'test does not error on non string values when checking for cdata': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <MsgId>10</MsgId>
      </xml>

    """
    opts = cdata: true
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":10}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with tagNameProcessors': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <msgid>10</msgid>
      </xml>

    """
    opts = tagNameProcessors: [
      ( name ) ->
        return name.toLowerCase()
    ]
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":10}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with tagNameProcessors with attribute': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <msgid id="1">10</msgid>
      </xml>

    """
    opts = tagNameProcessors: [
      ( name ) ->
        return name.toLowerCase()
    ]
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":{"$":{"id":"1"},"_":10}}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with valueProcessors': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <Test>NothingToDo</Test>
        <Value>200</Value>
      </xml>

    """
    opts = valueProcessors: [
      ( value ) ->
        return if isNaN( value ) then value else Number( value ).toFixed( 2 ).replace( '.', '' );
    ]
    builder = new xml2js.Builder opts
    obj = {"xml":{"Test": "NothingToDo", "Value":2.0}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with valueProcessors with extra params': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <Test>NothingToDo</Test>
        <Value>Changed</Value>
      </xml>

    """
    opts = valueProcessors: [
      ( value, tagName ) ->
        return if tagName == 'Value' then 'Changed' else value;
    ]
    builder = new xml2js.Builder opts
    obj = {"xml":{"Test": "NothingToDo", "Value":"ValueToChange"}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with valueProcessors with attributes': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <Test>NothingToDo</Test>
        <Value id="1">200</Value>
      </xml>

    """
    opts = valueProcessors: [
      ( value ) ->
        return if isNaN( value ) then value else Number( value ).toFixed( 2 ).replace( '.', '' );
    ]
    builder = new xml2js.Builder opts
    obj = {"xml":{"Test": "NothingToDo","Value":{"$":{"id":"1"},"_":2.0}}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with attrNameProcessors': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <MsgId attr-id="2">10</MsgId>
      </xml>

    """
    opts = attrNameProcessors: [
      ( name ) ->
        return 'attr-' + name.toLowerCase();
    ]
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":"$":{"Id":'2'},"_":'10'}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with attrNameProcessors with extra params': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <Test id="1">Test</Test>
        <Value id-changed="2">Value</Value>
      </xml>

    """
    opts = attrNameProcessors: [
      ( attrName, tagName ) ->
        return if tagName == 'Value' then attrName + '-changed' else attrName;
    ]
    builder = new xml2js.Builder opts
    obj = {"xml":{"Test": { "$":{"id":1},"_":'Test'}, "Value":{ "$":{"id":2},"_":'Value'}}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with attrValueProcessors': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <MsgId id="value-2">10</MsgId>
      </xml>

    """
    opts = attrValueProcessors: [
      ( value ) ->
        return 'value-' + value;
    ]
    builder = new xml2js.Builder opts
    obj = {"xml":{"MsgId":"$":{"id":'2'},"_":'10'}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with attrValueProcessors with extra params': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <Test id="1">Test</Test>
        <Value id="20">Value</Value>
      </xml>

    """
    opts = attrValueProcessors: [
      ( value, attrName, tagName ) ->
        return if tagName == 'Value' then value * 10 else value;
    ]
    builder = new xml2js.Builder opts
    obj = {"xml":{"Test": { "$":{"id":1},"_":'Test'}, "Value":{ "$":{"id":2},"_":'Value'}}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with all processors': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <test>NothingToDo</test>
        <value attr-id="value-2">200</value>
      </xml>

    """
    opts = attrValueProcessors: [
      ( value ) ->
        return 'value-' + value;
    ],
    attrNameProcessors: [
      ( name ) ->
        return 'attr-' + name.toLowerCase();
    ],
    valueProcessors: [
      ( value ) ->
        return if isNaN( value ) then value else Number( value ).toFixed( 2 ).replace( '.', '' );
    ],
    tagNameProcessors: [
      ( name ) ->
        return name.toLowerCase()
    ]
    builder = new xml2js.Builder opts
    obj = {"xml":{"Test": "NothingToDo", "Value":"$":{"id":'2'},"_":2.0}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()


  'test with date': (test) ->
    expected = """
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <xml>
        <date>2015-12-04T00:00:00.000Z</date>
      </xml>

    """
    builder = new xml2js.Builder
    obj = {"xml":{"date":new Date( Date.UTC( 2015, 11, 4, 0, 0, 0, 0 ) )}}
    actual = builder.buildObject obj
    diffeq expected, actual
    test.finish()
