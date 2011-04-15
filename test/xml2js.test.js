// use zap to run the tests
var xml2js = require('xml2js'),
    fs = require('fs'),
    sys = require('sys'),
    assert = require('assert');

module.exports = {
    'test default parse' : function(test) {
        var x2js = new xml2js.Parser();
        //assert.isNotUndefined(x2js);
        x2js.addListener('end', function(r) {
            console.log('Result object: ' + sys.inspect(r, false, 10));
            assert.equal(r['chartest']['@']['desc'], "Test for CHARs");
            assert.equal(r['chartest']['#'], "Character data here!");
            assert.equal(r['cdatatest']['@']['desc'], "Test for CDATA");
            assert.equal(r['cdatatest']['@']['misc'], "true");
            assert.equal(r['cdatatest']['#'], "CDATA here!");
            assert.equal(r['nochartest']['@']['desc'], "No data");
            assert.equal(r['nochartest']['@']['misc'], "false");
            assert.equal(r['listtest']['item'][0]['#'], "This is character data!");
            assert.equal(r['listtest']['item'][0]['subitem'][0], "Foo(1)");
            assert.equal(r['listtest']['item'][0]['subitem'][1], "Foo(2)");
            assert.equal(r['listtest']['item'][0]['subitem'][2], "Foo(3)");
            assert.equal(r['listtest']['item'][0]['subitem'][3], "Foo(4)");
            assert.equal(r['listtest']['item'][1], "Qux.");
            assert.equal(r['listtest']['item'][2], "Quux.");
	    test.finish();
        });
        fs.readFile(__dirname + '/fixtures/sample.xml', function(err, data) {
            //assert.isNull(err);
            x2js.parseString(data);
        });
    },
    'test parse EXPLICIT_CHARKEY' : function(test) {
        var x2js = new xml2js.Parser();
        //assert.isNotUndefined(x2js);
        x2js.EXPLICIT_CHARKEY = true;
        x2js.addListener('end', function(r) {
            assert.equal(r['chartest']['@']['desc'], "Test for CHARs");
            assert.equal(r['chartest']['#'], "Character data here!");
            assert.equal(r['cdatatest']['@']['desc'], "Test for CDATA");
            assert.equal(r['cdatatest']['@']['misc'], "true");
            assert.equal(r['cdatatest']['#'], "CDATA here!");
            assert.equal(r['nochartest']['@']['desc'], "No data");
            assert.equal(r['nochartest']['@']['misc'], "false");
            assert.equal(r['listtest']['item'][0]['#'], "This is character data!");
            assert.equal(r['listtest']['item'][0]['subitem'][0]['#'], "Foo(1)");
            assert.equal(r['listtest']['item'][0]['subitem'][1]['#'], "Foo(2)");
            assert.equal(r['listtest']['item'][0]['subitem'][2]['#'], "Foo(3)");
            assert.equal(r['listtest']['item'][0]['subitem'][3]['#'], "Foo(4)");
            assert.equal(r['listtest']['item'][1]['#'], "Qux.");
            assert.equal(r['listtest']['item'][2]['#'], "Quux.");
	    test.finish();
        });
        fs.readFile(__dirname + '/fixtures/sample.xml', function(err, data) {
            //assert.isNull(err);
            x2js.parseString(data);
        });
    }
}
