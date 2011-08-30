# use zap to run tests, it also detects CoffeeScript files
xml2js = require '../lib/xml2js'
fs = require 'fs'
sys = require 'sys'
assert = require 'assert'
path = require 'path'

skeleton = (options, checks) ->
  (test) ->
    xmlString = options?.__xmlString
    delete options?.__xmlString
    x2js = new xml2js.Parser(options)
    x2js.addListener 'end', (r) ->
      checks(r)
      test.finish()
    fileName = path.join(__dirname, '/fixtures/sample.xml')
    if not xmlString
      fs.readFile fileName, (err, data) ->
        x2js.parseString data
    else
      x2js.parseString xmlString

module.exports =
  'test parse with defaults': skeleton(undefined, (r) ->
    console.log 'Result object: ' + sys.inspect(r, false, 10)
    assert.equal r['chartest']['@']['desc'], 'Test for CHARs'
    assert.equal r['chartest']['#'], 'Character data here!'
    assert.equal r['cdatatest']['@']['desc'], 'Test for CDATA'
    assert.equal r['cdatatest']['@']['misc'], 'true'
    assert.equal r['cdatatest']['#'], 'CDATA here!'
    assert.equal r['nochartest']['@']['desc'], 'No data'
    assert.equal r['nochartest']['@']['misc'], 'false'
    assert.equal r['listtest']['item'][0]['#'], 'This is character data!'
    assert.equal r['listtest']['item'][0]['subitem'][0], 'Foo(1)'
    assert.equal r['listtest']['item'][0]['subitem'][1], 'Foo(2)'
    assert.equal r['listtest']['item'][0]['subitem'][2], 'Foo(3)'
    assert.equal r['listtest']['item'][0]['subitem'][3], 'Foo(4)'
    assert.equal r['listtest']['item'][1], 'Qux.'
    assert.equal r['listtest']['item'][2], 'Quux.')
    
  'test parse with explicitCharkey': skeleton({explicitCharkey: true}, (r) ->
    assert.equal r['chartest']['@']['desc'], 'Test for CHARs'
    assert.equal r['chartest']['#'], 'Character data here!'
    assert.equal r['cdatatest']['@']['desc'], 'Test for CDATA'
    assert.equal r['cdatatest']['@']['misc'], 'true'
    assert.equal r['cdatatest']['#'], 'CDATA here!'
    assert.equal r['nochartest']['@']['desc'], 'No data'
    assert.equal r['nochartest']['@']['misc'], 'false'
    assert.equal r['listtest']['item'][0]['#'], 'This is character data!'
    assert.equal r['listtest']['item'][0]['subitem'][0]['#'], 'Foo(1)'
    assert.equal r['listtest']['item'][0]['subitem'][1]['#'], 'Foo(2)'
    assert.equal r['listtest']['item'][0]['subitem'][2]['#'], 'Foo(3)'
    assert.equal r['listtest']['item'][0]['subitem'][3]['#'], 'Foo(4)'
    assert.equal r['listtest']['item'][1]['#'], 'Qux.'
    assert.equal r['listtest']['item'][2]['#'], 'Quux.')
    
  'test default text handling': skeleton(undefined, (r) ->
    assert.equal r['whitespacetest']['#'], 'Line One Line Two')

  'test disable trimming': skeleton({trim: false}, (r) ->
    assert.equal r['whitespacetest']['#'], 'Line One Line Two')

  'test disable normalize': skeleton({normalize: false}, (r) ->
    assert.equal r['whitespacetest']['#'], 'Line One\n        Line Two')

  'test disable normalize and trim': skeleton({normalize: false, trim: false}, (r) ->
    assert.equal r['whitespacetest']['#'], '\n        Line One\n        Line Two\n    ')

  'test default root node eliminiation': skeleton({__xmlString: '<root></root>'}, (r) ->
    assert.deepEqual r, {})

  'test disabled root node elimination': skeleton({__xmlString: '<root></root>', explicitRoot: true}, (r) ->
    assert.deepEqual r, {root: {}})

  'test default empty tag result': skeleton(undefined, (r) ->
    assert.deepEqual r['emptytest'], {})

  'test empty tag result specified null': skeleton({emptyTag: null}, (r) ->
    assert.equal r['emptytest'], null)

  'test parse with custom char and attribute object keys': skeleton({attrkey: 'attrobj', charkey: 'charobj'}, (r) ->
    assert.equal r['chartest']['attrobj']['desc'], 'Test for CHARs'
    assert.equal r['chartest']['charobj'], 'Character data here!'
    assert.equal r['cdatatest']['attrobj']['desc'], 'Test for CDATA'
    assert.equal r['cdatatest']['attrobj']['misc'], 'true'
    assert.equal r['cdatatest']['charobj'], 'CDATA here!'
    assert.equal r['nochartest']['attrobj']['desc'], 'No data'
    assert.equal r['nochartest']['attrobj']['misc'], 'false')

  'test child node with explicitArray false': skeleton({explicitArray: false}, (r) ->
    assert.equal r['arraytest']['item'][0]['subitem'], 'Baz.'
    assert.equal r['arraytest']['item'][1]['subitem'][0], 'Foo.'
    assert.equal r['arraytest']['item'][1]['subitem'][1], 'Bar.')

  'test child node with explicitArray true': skeleton({explicitArray: true}, (r) ->
    assert.equal r['arraytest'][0]['item'][0]['subitem'][0], 'Baz.'
    assert.equal r['arraytest'][0]['item'][1]['subitem'][0], 'Foo.'
    assert.equal r['arraytest'][0]['item'][1]['subitem'][1], 'Bar.')
