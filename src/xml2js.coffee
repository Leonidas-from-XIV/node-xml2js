sax = require("sax")
sys = require("sys")
events = require("events")

Parser = ->
  that = this
  @saxParser = sax.parser(true)
  @EXPLICIT_CHARKEY = false
  @resultObject = null
  stack = []
  @saxParser.onopentag = (node) ->
    obj = {}
    obj["#"] = ""
    for own key of node.attributes
      if not ("@" of obj)
        obj["@"] = {}
      obj["@"][key] = node.attributes[key]

    obj["#name"] = node.name
    stack.push obj
  
  @saxParser.onclosetag = ->
    obj = stack.pop()
    nodeName = obj["#name"]
    delete obj["#name"]
    
    s = stack[stack.length - 1]
    if obj["#"].match(/^\s*$/)
      delete obj["#"]
    else
      obj["#"] = obj["#"].replace(/\s{2,}/g, " ").trim()
      if Object.keys(obj).length == 1 and "#" in obj and not (that.EXPLICIT_CHARKEY)
        obj = obj["#"]
    if stack.length > 0
      if typeof s[nodeName] == "undefined"
        s[nodeName] = obj
      else if s[nodeName] instanceof Array
        s[nodeName].push obj
      else
        old = s[nodeName]
        s[nodeName] = [ old ]
        s[nodeName].push obj
    else
      that.resultObject = obj
      that.emit "end", that.resultObject
  
  @saxParser.ontext = @saxParser.oncdata = (t) ->
    s = stack[stack.length - 1]
    if s
      s["#"] += t

  undefined

sys.inherits Parser, events.EventEmitter
Parser::parseString = (str) ->
  @saxParser.write str.toString()

exports.Parser = Parser
