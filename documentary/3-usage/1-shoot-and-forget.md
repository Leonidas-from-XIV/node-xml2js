
Shoot-and-forget usage
----------------------

You want to parse XML as simple and easy as possible? It's dangerous to go
alone, take this:

%EXAMPLE: example/index.js, .. => xml2js, javascript%

%FORK-js example%

Can't get easier than this, right? This works starting with `xml2js` 0.2.3.
With CoffeeScript it looks like this:

%EXAMPLE: example/index.coffee, .. => xml2js, coffeescript%

If you need some special options, fear not, `xml2js` supports a number of
options (see below), you can specify these as second argument:

```javascript
parseString(xml, {trim: true}, function (err, result) {
});
```
