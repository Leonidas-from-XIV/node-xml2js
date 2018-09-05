
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
to migrate to the saner way of parsing in `xml2js` 0.2. We try to make the
migration as simple and gentle as possible, but some breakage cannot be
avoided.

So, what exactly did change and why? In 0.2 we changed some defaults to parse
the XML in a more universal and sane way. So we disabled `normalize` and `trim`
so `xml2js` does not cut out any text content. You can reenable this at will of
course. A more important change is that we return the root tag in the resulting
JavaScript structure via the `explicitRoot` setting, so you need to access the
first element. This is useful for anybody who wants to know what the root node
is and preserves more information. The last major change was to enable
`explicitArray`, so everytime it is possible that one might embed more than one
sub-tag into a tag, xml2js >= 0.2 returns an array even if the array just
includes one element. This is useful when dealing with APIs that return
variable amounts of subtags.
