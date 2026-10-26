processors = require '../lib/processors'
xml2js = require '../lib/xml2js'
assert = require 'assert'
equ = assert.equal

parseNumbersExceptAccount = (value, key) ->
  if (key == 'accountNumber')
    return value;
  return processors.parseNumbers(value);

module.exports =
  'test normalize': (test) ->
    demo = 'This shOUld BE loWErcase'
    result = processors.normalize demo
    equ result, 'this should be lowercase'
    test.done()

  'test firstCharLowerCase': (test) ->
    demo = 'ThiS SHould OnlY LOwercase the fIRST cHar'
    result = processors.firstCharLowerCase demo
    equ result, 'thiS SHould OnlY LOwercase the fIRST cHar'
    test.done()

  'test stripPrefix': (test) ->
    demo = 'stripMe:DoNotTouch'
    result = processors.stripPrefix demo
    equ result, 'DoNotTouch'
    test.done()

  'test stripPrefix, ignore xmlns': (test) ->
    demo = 'xmlns:shouldHavePrefix'
    result = processors.stripPrefix demo
    equ result, 'xmlns:shouldHavePrefix'
    test.done()

  'test parseNumbers': (test) ->
    equ processors.parseNumbers('0'), 0
    equ processors.parseNumbers('123'), 123
    equ processors.parseNumbers('15.56'), 15.56
    equ processors.parseNumbers('10.00'), 10
    test.done()

  'test parseNumbers preserves empty and whitespace values': (test) ->
    for value in ['', ' ', '\t\r\n', '\u00a0']
      assert.strictEqual processors.parseNumbers(value), value
    assert.strictEqual processors.parseNumbers(' 0 '), 0
    assert.strictEqual processors.parseNumbers(' -12.5 '), -12.5
    assert.strictEqual processors.parseNumbers('text'), 'text'
    test.done()

  'test number processors preserve empty XML values': (test) ->
    xml = '<root empty="" blank=" " count="0"><empty/><blank> </blank><count>0</count></root>'
    options =
      valueProcessors: [processors.parseNumbers]
      attrValueProcessors: [processors.parseNumbers]
    xml2js.parseString xml, options, (err, parsed) ->
      assert.ifError err
      assert.strictEqual parsed.root.$.empty, ''
      assert.strictEqual parsed.root.$.blank, ' '
      assert.strictEqual parsed.root.$.count, 0
      assert.strictEqual parsed.root.empty[0], ''
      assert.strictEqual parsed.root.blank[0], ' '
      assert.strictEqual parsed.root.count[0], 0
      test.done()

  'test parseBooleans': (test) ->
    equ processors.parseBooleans('true'), true
    equ processors.parseBooleans('True'), true
    equ processors.parseBooleans('TRUE'), true
    equ processors.parseBooleans('false'), false
    equ processors.parseBooleans('False'), false
    equ processors.parseBooleans('FALSE'), false
    equ processors.parseBooleans('truex'), 'truex'
    equ processors.parseBooleans('xtrue'), 'xtrue'
    equ processors.parseBooleans('x'), 'x'
    equ processors.parseBooleans(''), ''
    test.done()
    
  'test a processor that filters by node name': (test) ->
    xml = '<account><accountNumber>0012345</accountNumber><balance>123.45</balance></account>'
    options = { valueProcessors: [parseNumbersExceptAccount] }
    xml2js.parseString xml, options, (err, parsed) ->
      equ parsed.account.accountNumber, '0012345'
      equ parsed.account.balance, 123.45
      test.finish()
      
  'test a processor that filters by attr name': (test) ->
    xml = '<account accountNumber="0012345" balance="123.45" />'
    options = { attrValueProcessors: [parseNumbersExceptAccount] }
    xml2js.parseString xml, options, (err, parsed) ->
      equ parsed.account.$.accountNumber, '0012345'
      equ parsed.account.$.balance, 123.45
      test.finish()
