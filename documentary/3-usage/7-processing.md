
Processing attribute, tag names and values
------------------------------------------

Since 0.4.1 you can optionally provide the parser with attribute name and tag name processors as well as element value processors (Since 0.4.14, you can also optionally provide the parser with attribute value processors):

```javascript

function nameToUpperCase(name){
    return name.toUpperCase();
}

//transform all attribute and tag names and values to uppercase
parseString(xml, {
  tagNameProcessors: [nameToUpperCase],
  attrNameProcessors: [nameToUpperCase],
  valueProcessors: [nameToUpperCase],
  attrValueProcessors: [nameToUpperCase]},
  function (err, result) {
    // processed data
});
```

The `tagNameProcessors` and `attrNameProcessors` options
accept an `Array` of functions with the following signature:

```javascript
function (name){
  //do something with `name`
  return name
}
```

The `attrValueProcessors` and `valueProcessors` options
accept an `Array` of functions with the following signature:

```javascript
function (value, name) {
  //`name` will be the node name or attribute name
  //do something with `value`, (optionally) dependent on the node/attr name
  return value
}
```

Some processors are provided out-of-the-box and can be found in `lib/processors.js`:

- `normalize`: transforms the name to lowercase.
(Automatically used when `options.normalize` is set to `true`)

- `firstCharLowerCase`: transforms the first character to lower case.
E.g. 'MyTagName' becomes 'myTagName'

- `stripPrefix`: strips the xml namespace prefix. E.g `<foo:Bar/>` will become 'Bar'.
(N.B.: the `xmlns` prefix is NOT stripped.)

- `parseNumbers`: parses integer-like strings as integers and float-like strings as floats
E.g. "0" becomes 0 and "15.56" becomes 15.56

- `parseBooleans`: parses boolean-like strings to booleans
E.g. "true" becomes true and "False" becomes false
