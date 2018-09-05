var xml2js = require('..');

/* start example */
let obj = {
  'foo:Foo': {
    $: {
      'xmlns:foo': 'http://foo.com'
    },
    'bar:Bar': {
      $: {
        'xmlns:bar': 'http://bar.com'
      }
    }
  }
}
/* end example */

var builder = new xml2js.Builder();
var xml = builder.buildObject(obj);

console.log(xml)