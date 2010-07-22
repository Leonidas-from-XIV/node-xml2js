node-xml2js
===========

Description
-----------
Simple XML to JavaScript object converter.  Uses [sax-js](http://github.com/isaacs/sax-js/).  Install with [npm](http://github.com/isaacs/npm) :)
See the tests for examples until docs are written.
Note:  If you're looking for a full DOM parser, you probably want [JSDom](http://github.com/tmpvar/jsdom).

Simple usage
-----------

    var sys = require('sys'),
        fs = require('fs'),
        xml2js = require('xml2js');

    var parser = new xml2js.Parser();
    parser.addListener('end', function(result) {
        console.log(sys.inspect(result));
        console.log('Done.');
    });
    fs.readFile(__dirname + '/foo.xml', function(err, data) {
        parser.parseString(data);
    });

