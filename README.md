node-xml2js
===========

Description
-----------

Simple XML to JavaScript object converter. Uses [sax-js](http://github.com/isaacs/sax-js/).

See the tests for examples until docs are written.

Note: If you're looking for a full DOM parser, you probably want
[JSDom](http://github.com/tmpvar/jsdom).

Installation
------------

Simplest way to install `xml2js` is to use [npm](http://npmjs.org), just `npm
install xml2js` which will download xml2js and all dependencies.

Simple usage
-----------

    var fs = require('fs'),
        xml2js = require('xml2js');

    var parser = new xml2js.Parser();
    parser.addListener('end', function(result) {
        console.dir(result);
        console.log('Done.');
    });
    fs.readFile(__dirname + '/foo.xml', function(err, data) {
        parser.parseString(data);
    });

Options
-------

Apart from the default settings, there is a number of options that can be
specified for the parser. Options are specified by ``new Parser({optionName:
value})``. Possible options are:

  * `explicitCharkey` (default: `false`)
  * `trim` (default: `true`): Trim the whitespace at the beginning and end of
    text nodes.
  * `normalize` (default: `true`): Trim whitespaces inside text nodes.
  * `explicitRoot` (default: `false`): Set this if you want to get the root
    node in the resulting object.
  * `emptyTag` (default: `undefined`): what will the value of empty nodes be.
    Default is `{}`.
  * `explicitArray` (default: `false`): Always put child nodes in an array if true;
    otherwise an array is created only if there is more than one.

These default settings are for backward-compatibility (and might change in the
future). For the most 'clean' parsing, you should disable `normalize` and
`trimming` and enable `explicitRoot`.

Running tests, development
--------------------------

The development requirements are handled by npm, you just need to install
them. We also have a number of unittests, they can be run using `zap`
directly from the project root.
