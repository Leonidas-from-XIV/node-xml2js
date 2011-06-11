sax = require("sax")
events = require("events")


class exports.Parser extends events.EventEmitter
  constructor: (opts) ->

    # default options
    options =
      explicitCharkey: false
      trim: false
      normalize: false
    # overwrite them with the specified options, if any
    options[key] = value for own key, value of opts

    # make the sax parser
    @saxParser = sax.parser true
    # always use the '#' key, even if there are no subkeys
    @EXPLICIT_CHARKEY = options.explicitCharkey
    @resultObject = null
    stack = []

    @saxParser.onopentag = (node) =>
      obj = {}
      obj["#"] = ""
      for own key of node.attributes
        if "@" not of obj
          obj["@"] = {}
        obj["@"][key] = node.attributes[key]

      # need a place to store the node name
      obj["#name"] = node.name
      stack.push obj
    
    @saxParser.onclosetag = =>
      obj = stack.pop()
      nodeName = obj["#name"]
      delete obj["#name"]

      s = stack[stack.length - 1]
      # remove the '#' key altogether if it's blank
      if obj["#"].match(/^\s*$/)
        delete obj["#"]
      else
        # turn 2 or more spaces into one space
        obj["#"] = obj["#"].replace(/\s{2,}/g, " ").trim()
        # also do away with '#' key altogether, if there's no subkeys
        # unless EXPLICIT_CHARKEY is set
        if Object.keys(obj).length == 1 and "#" of obj and not @EXPLICIT_CHARKEY
          obj = obj["#"]

      if stack.length > 0
        if nodeName not of s
          s[nodeName] = obj
        else if s[nodeName] instanceof Array
          s[nodeName].push obj
        else
          old = s[nodeName]
          s[nodeName] = [old]
          s[nodeName].push obj
      else
        @resultObject = obj
        @emit "end", @resultObject

    @saxParser.ontext = @saxParser.oncdata = (text) =>
      s = stack[stack.length - 1]
      if s
        s["#"] += text

  parseString: (str) =>
    @saxParser.write str.toString()
