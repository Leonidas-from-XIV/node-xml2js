var xml2js = require('..');

var obj = {name: "Super", Surname: "Man", age: 23};

var builder = new xml2js.Builder();
var xml = builder.buildObject(obj);