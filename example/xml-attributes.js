var xml2js = require('..');

var obj = {root: {$: {id: "my id"}, _: "my inner text"}};

var builder = new xml2js.Builder();
var xml = builder.buildObject(obj);