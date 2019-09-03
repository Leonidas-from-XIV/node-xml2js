# use zap to run tests, it also detects CoffeeScript files
xml2js = require '../lib/xml2js'
fs = require 'fs'
util = require 'util'
assert = require 'assert'
path = require 'path'
os = require 'os'
promisify = require 'util.promisify'

fileName = path.join __dirname, '/fixtures/sample.xml'

readFilePromise = promisify fs.readFile

skeleton = (options, checks) ->
  (test) ->
    xmlString = options?.__xmlString
    delete options?.__xmlString
    x2js = new xml2js.Parser options
    x2js.addListener 'end', (r) ->
      checks r
      test.finish()
    if not xmlString
      fs.readFile fileName, 'utf8', (err, data) ->
        data = data.split(os.EOL).join('\n')
        x2js.parseString data
    else
      x2js.parseString xmlString

nameToUpperCase = (name) ->
  return name.toUpperCase()

nameCutoff = (name) ->
  return name.substr(0, 4)

replaceValueByName = (value, name) ->
  return name

###
The `validator` function validates the value at the XPath. It also transforms the value
if necessary to conform to the schema or other validation information being used. If there
is an existing value at this path it is supplied in `currentValue` (e.g. this is the second or
later item in an array).
If the validation fails it should throw a `ValidationError`.
###
validator = (xpath, currentValue, newValue) ->
  if xpath == '/sample/validatortest/numbertest'
    return Number(newValue)
  else if xpath in ['/sample/arraytest', '/sample/validatortest/emptyarray', '/sample/validatortest/oneitemarray']
    if not newValue or not ('item' of newValue)
      return {'item': []}
  else if xpath in ['/sample/arraytest/item', '/sample/validatortest/emptyarray/item', '/sample/validatortest/oneitemarray/item']
    if not currentValue
      return newValue
  else if xpath == '/validationerror'
    throw new xml2js.ValidationError("Validation error!")
  return newValue

# shortcut, because it is quite verbose
equ = assert.strictEqual

module.exports =
  'test parse with defaults': skeleton(undefined, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.chartest[0].$.desc, 'Test for CHARs'
    equ r.sample.chartest[0]._, 'Character data here!'
    equ r.sample.cdatatest[0].$.desc, 'Test for CDATA'
    equ r.sample.cdatatest[0].$.misc, 'true'
    equ r.sample.cdatatest[0]._, 'CDATA here!'
    equ r.sample.nochartest[0].$.desc, 'No data'
    equ r.sample.nochartest[0].$.misc, 'false'
    equ r.sample.listtest[0].item[0]._, '\n            This  is\n            \n            character\n            \n            data!\n            \n        '
    equ r.sample.listtest[0].item[0].subitem[0], 'Foo(1)'
    equ r.sample.listtest[0].item[0].subitem[1], 'Foo(2)'
    equ r.sample.listtest[0].item[0].subitem[2], 'Foo(3)'
    equ r.sample.listtest[0].item[0].subitem[3], 'Foo(4)'
    equ r.sample.listtest[0].item[1], 'Qux.'
    equ r.sample.listtest[0].item[2], 'Quux.'
    # determine number of items in object
    equ Object.keys(r.sample.tagcasetest[0]).length, 3)

  'test parse with explicitCharkey': skeleton(explicitCharkey: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.chartest[0].$.desc, 'Test for CHARs'
    equ r.sample.chartest[0]._, 'Character data here!'
    equ r.sample.cdatatest[0].$.desc, 'Test for CDATA'
    equ r.sample.cdatatest[0].$.misc, 'true'
    equ r.sample.cdatatest[0]._, 'CDATA here!'
    equ r.sample.nochartest[0].$.desc, 'No data'
    equ r.sample.nochartest[0].$.misc, 'false'
    equ r.sample.listtest[0].item[0]._, '\n            This  is\n            \n            character\n            \n            data!\n            \n        '
    equ r.sample.listtest[0].item[0].subitem[0]._, 'Foo(1)'
    equ r.sample.listtest[0].item[0].subitem[1]._, 'Foo(2)'
    equ r.sample.listtest[0].item[0].subitem[2]._, 'Foo(3)'
    equ r.sample.listtest[0].item[0].subitem[3]._, 'Foo(4)'
    equ r.sample.listtest[0].item[1]._, 'Qux.'
    equ r.sample.listtest[0].item[2]._, 'Quux.')

  'test parse with mergeAttrs': skeleton(mergeAttrs: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.chartest[0].desc[0], 'Test for CHARs'
    equ r.sample.chartest[0]._, 'Character data here!'
    equ r.sample.cdatatest[0].desc[0], 'Test for CDATA'
    equ r.sample.cdatatest[0].misc[0], 'true'
    equ r.sample.cdatatest[0]._, 'CDATA here!'
    equ r.sample.nochartest[0].desc[0], 'No data'
    equ r.sample.nochartest[0].misc[0], 'false'
    equ r.sample.listtest[0].item[0].subitem[0], 'Foo(1)'
    equ r.sample.listtest[0].item[0].subitem[1], 'Foo(2)'
    equ r.sample.listtest[0].item[0].subitem[2], 'Foo(3)'
    equ r.sample.listtest[0].item[0].subitem[3], 'Foo(4)'
    equ r.sample.listtest[0].item[1], 'Qux.'
    equ r.sample.listtest[0].item[2], 'Quux.'
    equ r.sample.listtest[0].single[0], 'Single'
    equ r.sample.listtest[0].attr[0], 'Attribute')

  'test parse with mergeAttrs and not explicitArray': skeleton(mergeAttrs: true, explicitArray: false, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.chartest.desc, 'Test for CHARs'
    equ r.sample.chartest._, 'Character data here!'
    equ r.sample.cdatatest.desc, 'Test for CDATA'
    equ r.sample.cdatatest.misc, 'true'
    equ r.sample.cdatatest._, 'CDATA here!'
    equ r.sample.nochartest.desc, 'No data'
    equ r.sample.nochartest.misc, 'false'
    equ r.sample.listtest.item[0].subitem[0], 'Foo(1)'
    equ r.sample.listtest.item[0].subitem[1], 'Foo(2)'
    equ r.sample.listtest.item[0].subitem[2], 'Foo(3)'
    equ r.sample.listtest.item[0].subitem[3], 'Foo(4)'
    equ r.sample.listtest.item[1], 'Qux.'
    equ r.sample.listtest.item[2], 'Quux.'
    equ r.sample.listtest.single, 'Single'
    equ r.sample.listtest.attr, 'Attribute')

  'test parse with explicitChildren': skeleton(explicitChildren: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.$$.chartest[0].$.desc, 'Test for CHARs'
    equ r.sample.$$.chartest[0]._, 'Character data here!'
    equ r.sample.$$.cdatatest[0].$.desc, 'Test for CDATA'
    equ r.sample.$$.cdatatest[0].$.misc, 'true'
    equ r.sample.$$.cdatatest[0]._, 'CDATA here!'
    equ r.sample.$$.nochartest[0].$.desc, 'No data'
    equ r.sample.$$.nochartest[0].$.misc, 'false'
    equ r.sample.$$.listtest[0].$$.item[0]._, '\n            This  is\n            \n            character\n            \n            data!\n            \n        '
    equ r.sample.$$.listtest[0].$$.item[0].$$.subitem[0], 'Foo(1)'
    equ r.sample.$$.listtest[0].$$.item[0].$$.subitem[1], 'Foo(2)'
    equ r.sample.$$.listtest[0].$$.item[0].$$.subitem[2], 'Foo(3)'
    equ r.sample.$$.listtest[0].$$.item[0].$$.subitem[3], 'Foo(4)'
    equ r.sample.$$.listtest[0].$$.item[1], 'Qux.'
    equ r.sample.$$.listtest[0].$$.item[2], 'Quux.'
    equ r.sample.$$.nochildrentest[0].$$, undefined
    # determine number of items in object
    equ Object.keys(r.sample.$$.tagcasetest[0].$$).length, 3)

  'test parse with explicitChildren and preserveChildrenOrder': skeleton(explicitChildren: true, preserveChildrenOrder: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.$$[10]['#name'], 'ordertest'
    equ r.sample.$$[10].$$[0]['#name'], 'one'
    equ r.sample.$$[10].$$[0]._, '1'
    equ r.sample.$$[10].$$[1]['#name'], 'two'
    equ r.sample.$$[10].$$[1]._, '2'
    equ r.sample.$$[10].$$[2]['#name'], 'three'
    equ r.sample.$$[10].$$[2]._, '3'
    equ r.sample.$$[10].$$[3]['#name'], 'one'
    equ r.sample.$$[10].$$[3]._, '4'
    equ r.sample.$$[10].$$[4]['#name'], 'two'
    equ r.sample.$$[10].$$[4]._, '5'
    equ r.sample.$$[10].$$[5]['#name'], 'three'
    equ r.sample.$$[10].$$[5]._, '6')

  'test parse with explicitChildren and charsAsChildren and preserveChildrenOrder': skeleton(explicitChildren: true, preserveChildrenOrder: true, charsAsChildren: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.$$[10]['#name'], 'ordertest'
    equ r.sample.$$[10].$$[0]['#name'], 'one'
    equ r.sample.$$[10].$$[0]._, '1'
    equ r.sample.$$[10].$$[1]['#name'], 'two'
    equ r.sample.$$[10].$$[1]._, '2'
    equ r.sample.$$[10].$$[2]['#name'], 'three'
    equ r.sample.$$[10].$$[2]._, '3'
    equ r.sample.$$[10].$$[3]['#name'], 'one'
    equ r.sample.$$[10].$$[3]._, '4'
    equ r.sample.$$[10].$$[4]['#name'], 'two'
    equ r.sample.$$[10].$$[4]._, '5'
    equ r.sample.$$[10].$$[5]['#name'], 'three'
    equ r.sample.$$[10].$$[5]._, '6'

    # test text ordering with XML nodes in the middle
    equ r.sample.$$[17]['#name'], 'textordertest'
    equ r.sample.$$[17].$$[0]['#name'], '__text__'
    equ r.sample.$$[17].$$[0]._, 'this is text with '
    equ r.sample.$$[17].$$[1]['#name'], 'b'
    equ r.sample.$$[17].$$[1]._, 'markup'
    equ r.sample.$$[17].$$[2]['#name'], 'em'
    equ r.sample.$$[17].$$[2]._, 'like this'
    equ r.sample.$$[17].$$[3]['#name'], '__text__'
    equ r.sample.$$[17].$$[3]._, ' in the middle')

  'test parse with explicitChildren and charsAsChildren and preserveChildrenOrder and includeWhiteChars': skeleton(explicitChildren: true, preserveChildrenOrder: true, charsAsChildren: true, includeWhiteChars: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.$$[35]['#name'], 'textordertest'
    equ r.sample.$$[35].$$[0]['#name'], '__text__'
    equ r.sample.$$[35].$$[0]._, 'this is text with '
    equ r.sample.$$[35].$$[1]['#name'], 'b'
    equ r.sample.$$[35].$$[1]._, 'markup'
    equ r.sample.$$[35].$$[2]['#name'], '__text__'
    equ r.sample.$$[35].$$[2]._, '   '
    equ r.sample.$$[35].$$[3]['#name'], 'em'
    equ r.sample.$$[35].$$[3]._, 'like this'
    equ r.sample.$$[35].$$[4]['#name'], '__text__'
    equ r.sample.$$[35].$$[4]._, ' in the middle')

  'test parse with explicitChildren and charsAsChildren and preserveChildrenOrder and includeWhiteChars and normalize': skeleton(explicitChildren: true, preserveChildrenOrder: true, charsAsChildren: true, includeWhiteChars: true, normalize: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    # normalized whitespace-only text node becomes empty string
    equ r.sample.$$[35]['#name'], 'textordertest'
    equ r.sample.$$[35].$$[0]['#name'], '__text__'
    equ r.sample.$$[35].$$[0]._, 'this is text with'
    equ r.sample.$$[35].$$[1]['#name'], 'b'
    equ r.sample.$$[35].$$[1]._, 'markup'
    equ r.sample.$$[35].$$[2]['#name'], '__text__'
    equ r.sample.$$[35].$$[2]._, ''
    equ r.sample.$$[35].$$[3]['#name'], 'em'
    equ r.sample.$$[35].$$[3]._, 'like this'
    equ r.sample.$$[35].$$[4]['#name'], '__text__'
    equ r.sample.$$[35].$$[4]._, 'in the middle')

  'test element without children': skeleton(explicitChildren: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.$$.nochildrentest[0].$$, undefined)

  'test parse with explicitChildren and charsAsChildren': skeleton(explicitChildren: true, charsAsChildren: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.$$.chartest[0].$$._, 'Character data here!'
    equ r.sample.$$.cdatatest[0].$$._, 'CDATA here!'
    equ r.sample.$$.listtest[0].$$.item[0].$$._, '\n            This  is\n            \n            character\n            \n            data!\n            \n        '
    # determine number of items in object
    equ Object.keys(r.sample.$$.tagcasetest[0].$$).length, 3)

  'test text trimming, normalize': skeleton(trim: true, normalize: true, (r) ->
    equ r.sample.whitespacetest[0]._, 'Line One Line Two')

  'test text trimming, no normalizing': skeleton(trim: true, normalize: false, (r) ->
    equ r.sample.whitespacetest[0]._, 'Line One\n        Line Two')

  'test text no trimming, normalize': skeleton(trim: false, normalize: true, (r) ->
    equ r.sample.whitespacetest[0]._, 'Line One Line Two')

  'test text no trimming, no normalize': skeleton(trim: false, normalize: false, (r) ->
    equ r.sample.whitespacetest[0]._, '\n        Line One\n        Line Two\n    ')

  'test enabled root node elimination': skeleton(__xmlString: '<root></root>', explicitRoot: false, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    assert.deepEqual r, '')

  'test disabled root node elimination': skeleton(__xmlString: '<root></root>', explicitRoot: true, (r) ->
    assert.deepEqual r, {root: ''})

  'test default empty tag result': skeleton(undefined, (r) ->
    assert.deepEqual r.sample.emptytest, [''])

  'test empty tag result specified null': skeleton(emptyTag: null, (r) ->
    equ r.sample.emptytest[0], null)

  'test invalid empty XML file': skeleton(__xmlString: ' ', (r) ->
    equ r, null)

  'test enabled normalizeTags': skeleton(normalizeTags: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ Object.keys(r.sample.tagcasetest).length, 1)

  'test parse with custom char and attribute object keys': skeleton(attrkey: 'attrobj', charkey: 'charobj', (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.chartest[0].attrobj.desc, 'Test for CHARs'
    equ r.sample.chartest[0].charobj, 'Character data here!'
    equ r.sample.cdatatest[0].attrobj.desc, 'Test for CDATA'
    equ r.sample.cdatatest[0].attrobj.misc, 'true'
    equ r.sample.cdatatest[0].charobj, 'CDATA here!'
    equ r.sample.cdatawhitespacetest[0].charobj, '   '
    equ r.sample.nochartest[0].attrobj.desc, 'No data'
    equ r.sample.nochartest[0].attrobj.misc, 'false')

  'test child node without explicitArray': skeleton(explicitArray: false, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.arraytest.item[0].subitem, 'Baz.'
    equ r.sample.arraytest.item[1].subitem[0], 'Foo.'
    equ r.sample.arraytest.item[1].subitem[1], 'Bar.')

  'test child node with explicitArray': skeleton(explicitArray: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.arraytest[0].item[0].subitem[0], 'Baz.'
    equ r.sample.arraytest[0].item[1].subitem[0], 'Foo.'
    equ r.sample.arraytest[0].item[1].subitem[1], 'Bar.')

  'test ignore attributes': skeleton(ignoreAttrs: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.chartest[0], 'Character data here!'
    equ r.sample.cdatatest[0], 'CDATA here!'
    equ r.sample.nochartest[0], ''
    equ r.sample.listtest[0].item[0]._, '\n            This  is\n            \n            character\n            \n            data!\n            \n        '
    equ r.sample.listtest[0].item[0].subitem[0], 'Foo(1)'
    equ r.sample.listtest[0].item[0].subitem[1], 'Foo(2)'
    equ r.sample.listtest[0].item[0].subitem[2], 'Foo(3)'
    equ r.sample.listtest[0].item[0].subitem[3], 'Foo(4)'
    equ r.sample.listtest[0].item[1], 'Qux.'
    equ r.sample.listtest[0].item[2], 'Quux.')

  'test simple callback mode': (test) ->
    x2js = new xml2js.Parser()
    fs.readFile fileName, (err, data) ->
      equ err, null
      x2js.parseString data, (err, r) ->
        equ err, null
        # just a single test to check whether we parsed anything
        equ r.sample.chartest[0]._, 'Character data here!'
        test.finish()

  'test simple callback with options': (test) ->
    fs.readFile fileName, (err, data) ->
      xml2js.parseString data,
        trim: true
        normalize: true,
        (err, r) ->
          console.log r
          equ r.sample.whitespacetest[0]._, 'Line One Line Two'
          test.finish()

  'test double parse': (test) ->
    x2js = new xml2js.Parser()
    fs.readFile fileName, (err, data) ->
      equ err, null
      x2js.parseString data, (err, r) ->
        equ err, null
        # make sure we parsed anything
        equ r.sample.chartest[0]._, 'Character data here!'
        x2js.parseString data, (err, r) ->
          equ err, null
          equ r.sample.chartest[0]._, 'Character data here!'
          test.finish()

  'test element with garbage XML': (test) ->
    x2js = new xml2js.Parser()
    xmlString = "<<>fdfsdfsdf<><<><??><<><>!<>!<!<>!."
    x2js.parseString xmlString, (err, result) ->
      assert.notEqual err, null
      test.finish()

  'test simple function without options': (test) ->
    fs.readFile fileName, (err, data) ->
      xml2js.parseString data, (err, r) ->
        equ err, null
        equ r.sample.chartest[0]._, 'Character data here!'
        test.finish()

  'test simple function with options': (test) ->
    fs.readFile fileName, (err, data) ->
      # well, {} still counts as option, right?
      xml2js.parseString data, {}, (err, r) ->
        equ err, null
        equ r.sample.chartest[0]._, 'Character data here!'
        test.finish()

  'test async execution': (test) ->
    fs.readFile fileName, (err, data) ->
      xml2js.parseString data, async: true, (err, r) ->
        equ err, null
        equ r.sample.chartest[0]._, 'Character data here!'
        test.finish()

  'test validator': skeleton(validator: validator, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ typeof r.sample.validatortest[0].stringtest[0], 'string'
    equ typeof r.sample.validatortest[0].numbertest[0], 'number'
    assert.ok r.sample.validatortest[0].emptyarray[0].item instanceof Array
    equ r.sample.validatortest[0].emptyarray[0].item.length, 0
    assert.ok r.sample.validatortest[0].oneitemarray[0].item instanceof Array
    equ r.sample.validatortest[0].oneitemarray[0].item.length, 1
    equ r.sample.validatortest[0].oneitemarray[0].item[0], 'Bar.'
    assert.ok r.sample.arraytest[0].item instanceof Array
    equ r.sample.arraytest[0].item.length, 2
    equ r.sample.arraytest[0].item[0].subitem[0], 'Baz.'
    equ r.sample.arraytest[0].item[1].subitem[0], 'Foo.'
    equ r.sample.arraytest[0].item[1].subitem[1], 'Bar.')

  'test validation error': (test) ->
    x2js = new xml2js.Parser({validator: validator})
    x2js.parseString '<validationerror/>', (err, r) ->
      equ err.message, 'Validation error!'
      test.finish()

  'test error throwing': (test) ->
    xml = '<?xml version="1.0" encoding="utf-8"?><test>content is ok<test>'
    try
      xml2js.parseString xml, (err, parsed) ->
        throw new Error 'error throwing in callback'
      throw new Error 'error throwing outside'
    catch e
      # the stream is finished by the time the parseString method is called
      # so the callback, which is synchronous, will bubble the inner error
      # out to here, make sure that happens
      equ e.message, 'error throwing in callback'
      test.finish()

  'test error throwing after an error (async)': (test) ->
    xml = '<?xml version="1.0" encoding="utf-8"?><test node is not okay>content is ok</test node is not okay>'
    nCalled = 0
    xml2js.parseString xml, async: true, (err, parsed) ->
      # Make sure no future changes break this
      ++nCalled
      if nCalled > 1
        test.fail 'callback called multiple times'
      # SAX Parser throws multiple errors when processing async. We need to catch and return the first error
      # and then squelch the rest. The only way to test this is to defer the test finish call until after the
      # current stack processes, which, if the test would fail, would contain and throw the additional errors
      setTimeout test.finish.bind test

  'test xmlns': skeleton(xmlns: true, (r) ->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample["pfx:top"][0].$ns.local, 'top'
    equ r.sample["pfx:top"][0].$ns.uri, 'http://foo.com'
    equ r.sample["pfx:top"][0].$["pfx:attr"].value, 'baz'
    equ r.sample["pfx:top"][0].$["pfx:attr"].local, 'attr'
    equ r.sample["pfx:top"][0].$["pfx:attr"].uri, 'http://foo.com'
    equ r.sample["pfx:top"][0].middle[0].$ns.local, 'middle'
    equ r.sample["pfx:top"][0].middle[0].$ns.uri, 'http://bar.com')

  'test callback should be called once': (test) ->
    xml = '<?xml version="1.0" encoding="utf-8"?><test>test</test>'
    i = 0
    try
      xml2js.parseString xml, (err, parsed) ->
        i = i + 1
        # throw something custom
        throw new Error 'Custom error message'
    catch e
      equ i, 1
      equ e.message, 'Custom error message'
      test.finish()

  'test no error event after end': (test) ->
    xml = '<?xml version="1.0" encoding="utf-8"?><test>test</test>'
    i = 0
    x2js = new xml2js.Parser()
    x2js.on 'error', ->
      i = i + 1

    x2js.on 'end', ->
      #This is a userland callback doing something with the result xml.
      #Errors in here should not be passed to the parser's 'error' callbacks
      #Errors here should be propagated so that the user can see them and
      #fix them.
      throw new Error('some error in user-land')

    try
      x2js.parseString(xml)
    catch e
      equ e.message, 'some error in user-land'

    equ i, 0
    test.finish()

  'test empty CDATA': (test) ->
    xml = '<xml><Label><![CDATA[]]></Label><MsgId>5850440872586764820</MsgId></xml>'
    xml2js.parseString xml, (err, parsed) ->
      equ parsed.xml.Label[0], ''
      test.finish()

  'test CDATA whitespaces result': (test) ->
    xml = '<spacecdatatest><![CDATA[ ]]></spacecdatatest>'
    xml2js.parseString xml, (err, parsed) ->
      equ parsed.spacecdatatest, ' '
      test.finish()

  'test escaped CDATA result': (test) ->
    xml = '<spacecdatatest><![CDATA[]]]]><![CDATA[>]]></spacecdatatest>'
    xml2js.parseString xml, (err, parsed) ->
      equ parsed.spacecdatatest, ']]>'
      test.finish()

  'test escaped CDATA result': (test) ->
    xml = '<spacecdatatest><![CDATA[]]]]><![CDATA[>]]></spacecdatatest>'
    xml2js.parseString xml, (err, parsed) ->
      equ parsed.spacecdatatest, ']]>'
      test.finish()

  'test non-strict parsing': (test) ->
    html = '<html><head></head><body><br></body></html>'
    xml2js.parseString html, strict: false, (err, parsed) ->
      equ err, null
      test.finish()

  'test construction with new and without': (test) ->
    demo = '<xml><foo>Bar</foo></xml>'
    withNew = new xml2js.Parser
    withNew.parseString demo, (err, resWithNew) ->
      equ err, null
      withoutNew = xml2js.Parser()
      withoutNew.parseString demo, (err, resWithoutNew) ->
        equ err, null
        assert.deepEqual resWithNew, resWithoutNew
        test.finish()

  'test not closed but well formed xml': (test) ->
    xml = "<test>"
    xml2js.parseString xml, (err, parsed) ->
      assert.equal err.message, 'Unclosed root tag\nLine: 0\nColumn: 6\nChar: '
      test.finish()

  'test cdata-named node': (test) ->
    xml = "<test><cdata>hello</cdata></test>"
    xml2js.parseString xml, (err, parsed) ->
      assert.equal parsed.test.cdata[0], 'hello'
      test.finish()

  'test onend with empty xml': (test) ->
    xml = "<?xml version=\"1.0\"?>"
    xml2js.parseString xml, (err, parsed) ->
      assert.equal parsed, null
      test.finish()

  'test parsing null': (test) ->
    xml = null
    xml2js.parseString xml, (err, parsed) ->
      assert.notEqual err, null
      test.finish()

  'test parsing undefined': (test) ->
    xml = undefined
    xml2js.parseString xml, (err, parsed) ->
      assert.notEqual err, null
      test.finish()

  'test chunked processing': (test) ->
    xml = "<longstuff>abcdefghijklmnopqrstuvwxyz</longstuff>"
    xml2js.parseString xml, chunkSize: 10, (err, parsed) ->
      equ err, null
      equ parsed.longstuff, 'abcdefghijklmnopqrstuvwxyz'
      test.finish()

  'test single attrNameProcessors': skeleton(attrNameProcessors: [nameToUpperCase], (r)->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.attrNameProcessTest[0].$.hasOwnProperty('CAMELCASEATTR'), true
    equ r.sample.attrNameProcessTest[0].$.hasOwnProperty('LOWERCASEATTR'), true)

  'test multiple attrNameProcessors': skeleton(attrNameProcessors: [nameToUpperCase, nameCutoff], (r)->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.attrNameProcessTest[0].$.hasOwnProperty('CAME'), true
    equ r.sample.attrNameProcessTest[0].$.hasOwnProperty('LOWE'), true)

  'test single attrValueProcessors': skeleton(attrValueProcessors: [nameToUpperCase], (r)->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.attrValueProcessTest[0].$.camelCaseAttr, 'CAMELCASEATTRVALUE'
    equ r.sample.attrValueProcessTest[0].$.lowerCaseAttr, 'LOWERCASEATTRVALUE')

  'test multiple attrValueProcessors': skeleton(attrValueProcessors: [nameToUpperCase, nameCutoff], (r)->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.attrValueProcessTest[0].$.camelCaseAttr, 'CAME'
    equ r.sample.attrValueProcessTest[0].$.lowerCaseAttr, 'LOWE')

  'test single valueProcessors': skeleton(valueProcessors: [nameToUpperCase], (r)->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.valueProcessTest[0], 'SOME VALUE')

  'test multiple valueProcessors': skeleton(valueProcessors: [nameToUpperCase, nameCutoff], (r)->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.valueProcessTest[0], 'SOME')

  'test single tagNameProcessors': skeleton(tagNameProcessors: [nameToUpperCase], (r)->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.hasOwnProperty('SAMPLE'), true
    equ r.SAMPLE.hasOwnProperty('TAGNAMEPROCESSTEST'), true)

  'test single tagNameProcessors in simple callback': (test) ->
    fs.readFile fileName, (err, data) ->
      xml2js.parseString data, tagNameProcessors: [nameToUpperCase], (err, r)->
        console.log 'Result object: ' + util.inspect r, false, 10
        equ r.hasOwnProperty('SAMPLE'), true
        equ r.SAMPLE.hasOwnProperty('TAGNAMEPROCESSTEST'), true
        test.finish()

  'test multiple tagNameProcessors': skeleton(tagNameProcessors: [nameToUpperCase, nameCutoff], (r)->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.hasOwnProperty('SAMP'), true
    equ r.SAMP.hasOwnProperty('TAGN'), true)

  'test attrValueProcessors key param': skeleton(attrValueProcessors: [replaceValueByName], (r)->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.attrValueProcessTest[0].$.camelCaseAttr, 'camelCaseAttr'
    equ r.sample.attrValueProcessTest[0].$.lowerCaseAttr, 'lowerCaseAttr')

  'test valueProcessors key param': skeleton(valueProcessors: [replaceValueByName], (r)->
    console.log 'Result object: ' + util.inspect r, false, 10
    equ r.sample.valueProcessTest[0], 'valueProcessTest')
  
  'test parseStringPromise parsing': (test) ->
    x2js = new xml2js.Parser()
    readFilePromise(fileName).then (data) ->
      x2js.parseStringPromise data
    .then (r) ->
      # just a single test to check whether we parsed anything
      equ r.sample.chartest[0]._, 'Character data here!'
      test.finish()
    .catch (err) ->
      test.fail('Should not error')
    
  'test parseStringPromise with bad input': (test) ->
    x2js = new xml2js.Parser()
    x2js.parseStringPromise("< a moose bit my sister>").then (r) ->
      test.fail('Should fail')
    .catch (err) ->
      assert.notEqual err, null
      test.finish()

  'test global parseStringPromise parsing': (test) ->
    readFilePromise(fileName).then (data) ->
      xml2js.parseStringPromise data
    .then (r) ->
      assert.notEqual r, null
      equ r.sample.listtest[0].item[0].subitem[0], 'Foo(1)'
      test.finish()
    .catch (err) ->
      test.fail('Should not error')

  'test global parseStringPromise with options': (test) ->
    readFilePromise(fileName).then (data) ->
      xml2js.parseStringPromise data,
        trim: true
        normalize: true
    .then (r) ->
      assert.notEqual r, null
      equ r.sample.whitespacetest[0]._, 'Line One Line Two'
      test.finish()
    .catch (err) ->
      test.fail('Should not error')
    
  'test global parseStringPromise with bad input': (test) ->
    xml2js.parseStringPromise("< a moose bit my sister>").then (r) ->
      test.fail('Should fail')
    .catch (err) ->
      assert.notEqual err, null
      test.finish()
