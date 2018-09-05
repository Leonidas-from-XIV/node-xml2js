{parseString} = require 'xml2js'
xml = "<root>Hello xml2js!</root>"
parseString xml, (err, result) ->
    console.dir result