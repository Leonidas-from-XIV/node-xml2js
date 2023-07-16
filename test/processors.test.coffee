processors = require '../lib/processors'
xml2js = require '../lib/xml2js'
assert = require 'assert'
equ = assert.equal

parseNumbersExceptAccount = (value, key) ->
  if (key == 'accountNumber')
    return value;
  return processors.parseNumbers(value);

describe 'processors', ->
  test 'normalize', (done) ->
    demo = 'This shOUld BE loWErcase'
    result = processors.normalize demo
    equ result, 'this should be lowercase'
    done()

  test 'firstCharLowerCase', (done) ->
    demo = 'ThiS SHould OnlY LOwercase the fIRST cHar'
    result = processors.firstCharLowerCase demo
    equ result, 'thiS SHould OnlY LOwercase the fIRST cHar'
    done()

  test 'stripPrefix', (done) ->
    demo = 'stripMe:DoNotTouch'
    result = processors.stripPrefix demo
    equ result, 'DoNotTouch'
    done()

  test 'stripPrefix, ignore xmlns', (done) ->
    demo = 'xmlns:shouldHavePrefix'
    result = processors.stripPrefix demo
    equ result, 'xmlns:shouldHavePrefix'
    done()

  test 'parseNumbers', (done) ->
    equ processors.parseNumbers('0'), 0
    equ processors.parseNumbers('123'), 123
    equ processors.parseNumbers('15.56'), 15.56
    equ processors.parseNumbers('10.00'), 10
    done()

  test 'parseBooleans', (done) ->
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
    done()
    
  test 'a processor that filters by node name', (done) ->
    xml = '<account><accountNumber>0012345</accountNumber><balance>123.45</balance></account>'
    options = { valueProcessors: [parseNumbersExceptAccount] }
    xml2js.parseString xml, options, (err, parsed) ->
      equ parsed.account.accountNumber, '0012345'
      equ parsed.account.balance, 123.45
      done()
      
  test 'a processor that filters by attr name', (done) ->
    xml = '<account accountNumber="0012345" balance="123.45" />'
    options = { attrValueProcessors: [parseNumbersExceptAccount] }
    xml2js.parseString xml, options, (err, parsed) ->
      equ parsed.account.$.accountNumber, '0012345'
      equ parsed.account.$.balance, 123.45
      done()