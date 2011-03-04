var xml2js = require('./xml2js');

for (var key in xml2js) {
  if (xml2js.hasOwnProperty(key)) {
    exports[key] = xml2js[key];
  }
}
