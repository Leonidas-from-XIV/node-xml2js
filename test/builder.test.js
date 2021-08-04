/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// use zap to run tests, it also detects CoffeeScript files
const xml2js = require('../lib/xml2js');
const assert = require('assert');
const fs = require('fs');
const path = require('path');
const diff = require('diff');

// fileName = path.join __dirname, '/fixtures/sample.xml'

// shortcut, because it is quite verbose
const equ = assert.equal;

// equality test with diff output
const diffeq = function(expected, actual) {
  const diffless = "Index: test\n===================================================================\n--- test\texpected\n+++ test\tactual\n";
  const patch = diff.createPatch('test', expected.trim(), actual.trim(), 'expected', 'actual');
  if (patch !== diffless) { throw patch; }
};

module.exports = {
  'test building basic XML structure'(test) {
    const expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><xml><Label/><MsgId>5850440872586764820</MsgId></xml>';
    const obj = {"xml":{"Label":[""],"MsgId":["5850440872586764820"]}};
    const builder = new xml2js.Builder({renderOpts: {pretty: false}});
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test setting XML declaration'(test) {
    const expected = '<?xml version="1.2" encoding="WTF-8" standalone="no"?><root/>';
    const opts = {
      renderOpts: { pretty: false
    },
      xmldec: { 'version': '1.2', 'encoding': 'WTF-8', 'standalone': false
    }
    };
    const builder = new xml2js.Builder(opts);
    const actual = builder.buildObject({});
    diffeq(expected, actual);
    return test.finish();
  },

  'test pretty by default'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xml>
  <MsgId>5850440872586764820</MsgId>
</xml>
\
`;
    const builder = new xml2js.Builder();
    const obj = {"xml":{"MsgId":["5850440872586764820"]}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test setting indentation'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xml>
    <MsgId>5850440872586764820</MsgId>
</xml>
\
`;
    const opts = {renderOpts: {pretty: true, indent: '    '}};
    const builder = new xml2js.Builder(opts);
    const obj = {"xml":{"MsgId":["5850440872586764820"]}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test headless option'(test) {
    const expected = `\
<xml>
    <MsgId>5850440872586764820</MsgId>
</xml>
\
`;
    const opts = {
      renderOpts: { pretty: true, indent: '    '
    },
      headless: true
    };
    const builder = new xml2js.Builder(opts);
    const obj = {"xml":{"MsgId":["5850440872586764820"]}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test allowSurrogateChars option'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xml>
    <MsgId>\uD83D\uDC33</MsgId>
</xml>
\
`;
    const opts = {
      renderOpts: { pretty: true, indent: '    '
    },
      allowSurrogateChars: true
    };
    const builder = new xml2js.Builder(opts);
    const obj = {"xml":{"MsgId":["\uD83D\uDC33"]}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test explicit rootName is always used: 1. when there is only one element'(test) {
    const expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><FOO><MsgId>5850440872586764820</MsgId></FOO>';
    const opts = {renderOpts: {pretty: false}, rootName: 'FOO'};
    const builder = new xml2js.Builder(opts);
    const obj = {"MsgId":["5850440872586764820"]};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test explicit rootName is always used: 2. when there are multiple elements'(test) {
    const expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><FOO><MsgId>5850440872586764820</MsgId></FOO>';
    const opts = {renderOpts: {pretty: false}, rootName: 'FOO'};
    const builder = new xml2js.Builder(opts);
    const obj = {"MsgId":["5850440872586764820"]};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test default rootName is used when there is more than one element in the hash'(test) {
    const expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root><MsgId>5850440872586764820</MsgId><foo>bar</foo></root>';
    const opts = {renderOpts: {pretty: false}};
    const builder = new xml2js.Builder(opts);
    const obj = {"MsgId":["5850440872586764820"],"foo":"bar"};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test when there is only one first-level element in the hash, that is used as root'(test) {
    const expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><first><MsgId>5850440872586764820</MsgId><foo>bar</foo></first>';
    const opts = {renderOpts: {pretty: false}};
    const builder = new xml2js.Builder(opts);
    const obj = {"first":{"MsgId":["5850440872586764820"],"foo":"bar"}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test parser -> builder roundtrip'(test) {
    const fileName = path.join(__dirname, '/fixtures/build_sample.xml');
    return fs.readFile(fileName, function(err, xmlData) {
      const xmlExpected = xmlData.toString();
      return xml2js.parseString(xmlData, {'trim': true}, function(err, obj) {
        equ(err, null);
        const builder = new xml2js.Builder({});
        const xmlActual = builder.buildObject(obj);
        diffeq(xmlExpected, xmlActual);
        return test.finish();
      });
    });
  },

  'test building obj with undefined value'(test) {
    const obj = { node: 'string', anothernode: undefined };
    const builder = new xml2js.Builder({renderOpts: { pretty: false }});
    const actual = builder.buildObject(obj);
    const expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root><node>string</node><anothernode/></root>';
    equ(actual, expected);
    return test.finish();
  },

  'test building obj with null value'(test) {
    const obj = { node: 'string', anothernode: null };
    const builder = new xml2js.Builder({renderOpts: { pretty: false }});
    const actual = builder.buildObject(obj);
    const expected = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root><node>string</node><anothernode/></root>';
    equ(actual, expected);
    return test.finish();
  },

  'test escapes escaped characters'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xml>
  <MsgId>&amp;amp;&amp;lt;&amp;gt;</MsgId>
</xml>
\
`;
    const builder = new xml2js.Builder;
    const obj = {"xml":{"MsgId":["&amp;&lt;&gt;"]}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test cdata text nodes'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xml>
  <MsgId><![CDATA[& <<]]></MsgId>
</xml>
\
`;
    const opts = {cdata: true};
    const builder = new xml2js.Builder(opts);
    const obj = {"xml":{"MsgId":["& <<"]}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test cdata text nodes with escaped end sequence'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xml>
  <MsgId><![CDATA[& <<]]]]><![CDATA[>]]></MsgId>
</xml>
\
`;
    const opts = {cdata: true};
    const builder = new xml2js.Builder(opts);
    const obj = {"xml":{"MsgId":["& <<]]>"]}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test uses cdata only for chars &, <, >'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xml>
  <MsgId><![CDATA[& <<]]></MsgId>
  <Message>Hello</Message>
</xml>
\
`;
    const opts = {cdata: true};
    const builder = new xml2js.Builder(opts);
    const obj = {"xml":{"MsgId":["& <<"],"Message":["Hello"]}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test uses cdata for string values of objects'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xml>
  <MsgId><![CDATA[& <<]]></MsgId>
</xml>
\
`;
    const opts = {cdata: true};
    const builder = new xml2js.Builder(opts);
    const obj = {"xml":{"MsgId":"& <<"}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test does not error on non string values when checking for cdata'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xml>
  <MsgId>10</MsgId>
</xml>
\
`;
    const opts = {cdata: true};
    const builder = new xml2js.Builder(opts);
    const obj = {"xml":{"MsgId":10}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test does not error on array values when checking for cdata'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xml>
  <MsgId>10</MsgId>
  <MsgId>12</MsgId>
</xml>
\
`;
    const opts = {cdata: true};
    const builder = new xml2js.Builder(opts);
    const obj = {"xml":{"MsgId":[10, 12]}};
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  },

  'test building obj with array'(test) {
    const expected = `\
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<root>
  <MsgId>10</MsgId>
  <MsgId2>12</MsgId2>
</root>
\
`;
    const opts = {cdata: true};
    const builder = new xml2js.Builder(opts);
    const obj = [{"MsgId": 10}, {"MsgId2": 12}];
    const actual = builder.buildObject(obj);
    diffeq(expected, actual);
    return test.finish();
  }
};
