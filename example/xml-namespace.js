var xml2js = require('..');

/* start example */
let obj = {
  Foo: {
    $: {
      "xmlns": "http://foo.com"
    }
  }
};
/* end example */

var builder = new xml2js.Builder();
var xml = builder.buildObject(obj);

console.log(xml)