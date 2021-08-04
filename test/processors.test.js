/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const processors = require('../lib/processors');
const xml2js = require('../lib/xml2js');
const assert = require('assert');
const equ = assert.equal;

const parseNumbersExceptAccount = function(value, key) {
  if (key === 'accountNumber') {
    return value;
  }
  return processors.parseNumbers(value);
};

module.exports = {
  'test normalize'(test) {
    const demo = 'This shOUld BE loWErcase';
    const result = processors.normalize(demo);
    equ(result, 'this should be lowercase');
    return test.done();
  },

  'test firstCharLowerCase'(test) {
    const demo = 'ThiS SHould OnlY LOwercase the fIRST cHar';
    const result = processors.firstCharLowerCase(demo);
    equ(result, 'thiS SHould OnlY LOwercase the fIRST cHar');
    return test.done();
  },

  'test stripPrefix'(test) {
    const demo = 'stripMe:DoNotTouch';
    const result = processors.stripPrefix(demo);
    equ(result, 'DoNotTouch');
    return test.done();
  },

  'test stripPrefix, ignore xmlns'(test) {
    const demo = 'xmlns:shouldHavePrefix';
    const result = processors.stripPrefix(demo);
    equ(result, 'xmlns:shouldHavePrefix');
    return test.done();
  },

  'test parseNumbers'(test) {
    equ(processors.parseNumbers('0'), 0);
    equ(processors.parseNumbers('123'), 123);
    equ(processors.parseNumbers('15.56'), 15.56);
    equ(processors.parseNumbers('10.00'), 10);
    return test.done();
  },

  'test parseBooleans'(test) {
    equ(processors.parseBooleans('true'), true);
    equ(processors.parseBooleans('True'), true);
    equ(processors.parseBooleans('TRUE'), true);
    equ(processors.parseBooleans('false'), false);
    equ(processors.parseBooleans('False'), false);
    equ(processors.parseBooleans('FALSE'), false);
    equ(processors.parseBooleans('truex'), 'truex');
    equ(processors.parseBooleans('xtrue'), 'xtrue');
    equ(processors.parseBooleans('x'), 'x');
    equ(processors.parseBooleans(''), '');
    return test.done();
  },
    
  'test a processor that filters by node name'(test) {
    const xml = '<account><accountNumber>0012345</accountNumber><balance>123.45</balance></account>';
    const options = { valueProcessors: [parseNumbersExceptAccount] };
    return xml2js.parseString(xml, options, function(err, parsed) {
      equ(parsed.account.accountNumber, '0012345');
      equ(parsed.account.balance, 123.45);
      return test.finish();
    });
  },
      
  'test a processor that filters by attr name'(test) {
    const xml = '<account accountNumber="0012345" balance="123.45" />';
    const options = { attrValueProcessors: [parseNumbersExceptAccount] };
    return xml2js.parseString(xml, options, function(err, parsed) {
      equ(parsed.account.$.accountNumber, '0012345');
      equ(parsed.account.$.balance, 123.45);
      return test.finish();
    });
  }
};