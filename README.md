node-xml2js
===========

Ever had the urge to parse XML? And wanted to access the data in some sane,
easy way? Don't want to compile a C parser, for whatever reason? Then xml2js is
what you're looking for!

Description
===========

Simple XML to JavaScript object converter. Uses
[sax-js](https://github.com/isaacs/sax-js/).

Note: If you're looking for a full DOM parser, you probably want
[JSDom](https://github.com/tmpvar/jsdom).

Installation
============

Simplest way to install `xml2js` is to use [npm](http://npmjs.org), just `npm
install xml2js` which will download xml2js and all dependencies.

Usage
=====

This will have to do, unless you're looking for some fancy extensive
documentation. If you're looking for every single option and usage, see the
unit tests.

Simple as pie usage
-------------------

The simplest way to use it, is to use the optional callback interface added in
0.1.11. That's right, if you have been using xml-simple or a home-grown
wrapper, this is for you:

```javascript
var fs = require('fs'),
    xml2js = require('xml2js');

var parser = new xml2js.Parser();
fs.readFile(__dirname + '/foo.xml', function(err, data) {
    parser.parseString(data, function (err, result) {
        console.dir(result);
        console.log('Done');
    });
});
```

Look ma, no event listeners! Alternatively you can still use the traditional
`addListener` variant:

```javascript
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
```

You can also use xml2js from
[CoffeeScript](http://jashkenas.github.com/coffee-script/), further reducing
the clutter:

```coffeescript
fs = require 'fs',
xml2js = require 'xml2js'

parser = new xml2js.Parser()
fs.readFile __dirname + '/foo.xml', (err, data) ->
  parser.parseString data, (err, result) ->
    console.dir result
    console.log 'Done.'
```

So you wanna some JSON?
-----------------------

Just wrap the `result` object in a call to `JSON.stringify` like this
`JSON.stringify(result)`. You get a string containing the JSON representation
of the parsed object that you can feed to JSON-hungry consumers.

Displaying results
------------------

You might wonder why, using `console.dir` or `console.log` the output at some
level is only `[Object]`. Don't worry, this is not because xml2js got lazy.
That's because Node uses `util.inspect` to convert the object into strings and
that function stops after `depth=2` which is a bit low for most XML.

To display the whole deal, you can use `console.log(util.inspect(result, false,
null))`, which displays the whole result.

So much for that, but what if you use
[eyes](https://github.com/cloudhead/eyes.js) for nice colored output and it
truncates the output with `…`? Don't fear, there's also a solution for that,
you just need to increase the `maxLength` limit by creating a custom inspector
`var inspect = require('eyes').inspector({maxLength: false})` and then you can
easily `inspect(result)`.

Options
=======

Apart from the default settings, there is a number of options that can be
specified for the parser. Options are specified by ``new Parser({optionName:
value})``. Possible options are:

  * `attrkey` (default: `$`): Prefix that is used to access the attributes.
    Version 0.1 default was `@`.
  * `charkey` (default: `_`): Prefix that is used to access the character
    content. Version 0.1 default was `#`.
  * `explicitCharkey` (default: `false`)
  * `trim` (default: `false`): Trim the whitespace at the beginning and end of
    text nodes.
  * `normalizeTags` (default: `false`): Normalize all tag names to lowercase.
  * `normalize` (default: `false`): Trim whitespaces inside text nodes.
  * `explicitRoot` (default: `true`): Set this if you want to get the root
    node in the resulting object.
  * `emptyTag` (default: `undefined`): what will the value of empty nodes be.
    Default is `{}`.
  * `explicitArray` (default: `true`): Always put child nodes in an array if
    true; otherwise an array is created only if there is more than one.
  * `ignoreAttrs` (default: `false`): Ignore all XML attributes and only create
    text nodes.
  * `mergeAttrs` (default: `false`): Merge attributes and child elements as
    properties of the parent, instead of keying attributes off a child
    attribute object. This option is ignored if `ignoreAttrs` is `false`.
  * `validator` (default `null`): You can specify a callable that validates
    the resulting structure somehow, however you want. See unit tests
    for an example.
  * `xmlns` (default `false`): Give each element a field usually called '$ns'
    (the first character is the same as attrkey) that contains its local name
    and namespace URI.

Updating to new version
=======================

Version 0.2 changed the default parsing settings, but version 0.1.14 introduced
the default settings for version 0.2, so these settings can be tried before the
migration.

```javascript
var xml2js = require('xml2js');
var parser = new xml2js.Parser(xml2js.defaults["0.2"]);
```

To get the 0.1 defaults in version 0.2 you can just use
`xml2js.defaults["0.1"]` in the same place. This provides you with enough time
to migrate to the saner way of parsing in xml2js 0.2. We try to make the
migration as simple and gentle as possible, but some breakage cannot be
avoided.

So, what exactly did change and why? In 0.2 we changed some defaults to parse
the XML in a more universal and sane way. So we disabled `normalize` and `trim`
so xml2js does not cut out any text content. You can reenable this at will of
course. A more important change is that we return the root tag in the resulting
JavaScript structure via the `explicitRoot` setting, so you need to access the
first element. This is useful for anybody who wants to know what the root node
is and preserves more information. The last major change was to enable
`explicitArray`, so everytime it is possible that one might embed more than one
sub-tag into a tag, xml2js >= 0.2 returns an array even if the array just
includes one element. This is useful when dealing with APIs that return
variable amounts of subtags.

Running tests, development
==========================

The development requirements are handled by npm, you just need to install
them. We also have a number of unit tests, they can be run using `zap`
directly from the project root.
