var xml2js = require('xml2js');
var fs = require('fs');

module.exports = {
    'test default parse' : function(assert) {
        var x2js = new xml2js.Parser();
        assert.isNotUndefined(x2js);
        x2js.addListener('end', function() {
            var r = x2js.resultObject;
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
        });
        fs.readFile(__dirname + '/fixtures/sample.xml', function(err, data) {
            assert.isNull(err);
            x2js.parseString(data);
        });
    },
    'test parse EXPLICIT_CHARKEY' : function(assert) {
        var x2js = new xml2js.Parser();
        assert.isNotUndefined(x2js);
        x2js.EXPLICIT_CHARKEY = true;
        x2js.addListener('end', function() {
            var r = x2js.resultObject;
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
        });
        fs.readFile(__dirname + '/fixtures/sample.xml', function(err, data) {
            assert.isNull(err);
            x2js.parseString(data);
        });
    }
}
