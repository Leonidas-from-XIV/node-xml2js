"use strict"

sax = require 'sax'
events = require 'events'
bom = require './bom'
processors = require './processors'
setImmediate = require('timers').setImmediate
defaults = require('./defaults').defaults
promisify = require 'util.promisify'

# Underscore has a nice function for this, but we try to go without dependencies
isEmpty = (thing) ->
  return typeof thing is "object" && thing? && Object.keys(thing).length is 0

processItem = (processors, item, key) ->
  item = process(item, key) for process in processors
  return item

class exports.Parser extends events
  constructor: (opts) ->
    # if this was called without 'new', create an instance with new and return
    return new exports.Parser opts unless @ instanceof exports.Parser
    # copy this versions default options
    @options = {}
    @options[key] = value for own key, value of defaults["0.2"]
    # overwrite them with the specified options, if any
    @options[key] = value for own key, value of opts
    # define the key used for namespaces
    if @options.xmlns
      @options.xmlnskey = @options.attrkey + "ns"
    if @options.normalizeTags
      if ! @options.tagNameProcessors
        @options.tagNameProcessors = []
      @options.tagNameProcessors.unshift processors.normalize

    @reset()

  processAsync: =>
    try
      if @remaining.length <= @options.chunkSize
        chunk = @remaining
        @remaining = ''
        @saxParser = @saxParser.write chunk
        @saxParser.close()
      else
        chunk = @remaining.substr 0, @options.chunkSize
        @remaining = @remaining.substr @options.chunkSize, @remaining.length
        @saxParser = @saxParser.write chunk
        setImmediate @processAsync
    catch err
      if ! @saxParser.errThrown
        @saxParser.errThrown = true
        @emit err

  assignOrPush: (obj, key, newValue) =>
    if key not of obj
      if not @options.explicitArray
        obj[key] = newValue
      else
        obj[key] = [newValue]
    else
      obj[key] = [obj[key]] if not (obj[key] instanceof Array)
      obj[key].push newValue

  reset: =>
    # remove all previous listeners for events, to prevent event listener
    # accumulation
    @removeAllListeners()
    # make the SAX parser. tried trim and normalize, but they are not
    # very helpful
    @saxParser = sax.parser @options.strict, {
      trim: false,
      normalize: false,
      xmlns: @options.xmlns
    }

    # emit one error event if the sax parser fails. this is mostly a hack, but
    # the sax parser isn't state of the art either.
    @saxParser.errThrown = false
    @saxParser.onerror = (error) =>
      @saxParser.resume()
      if ! @saxParser.errThrown
        @saxParser.errThrown = true
        @emit "error", error

    @saxParser.onend = () =>
      if ! @saxParser.ended
        @saxParser.ended = true
        @emit "end", @resultObject

    # another hack to avoid throwing exceptions when the parsing has ended
    # but the user-supplied callback throws an error
    @saxParser.ended = false

    # always use the '#' key, even if there are no subkeys
    # setting this property by and is deprecated, yet still supported.
    # better pass it as explicitCharkey option to the constructor
    @EXPLICIT_CHARKEY = @options.explicitCharkey
    @resultObject = null
    stack = []
    # aliases, so we don't have to type so much
    attrkey = @options.attrkey
    charkey = @options.charkey

    @saxParser.onopentag = (node) =>
      obj = {}
      obj[charkey] = ""
      unless @options.ignoreAttrs
        for own key of node.attributes
          if attrkey not of obj and not @options.mergeAttrs
            obj[attrkey] = {}
          newValue = if @options.attrValueProcessors then processItem(@options.attrValueProcessors, node.attributes[key], key) else node.attributes[key]
          processedKey = if @options.attrNameProcessors then processItem(@options.attrNameProcessors, key) else key
          if @options.mergeAttrs
            @assignOrPush obj, processedKey, newValue
          else
            obj[attrkey][processedKey] = newValue

      # need a place to store the node name
      obj["#name"] = if @options.tagNameProcessors then processItem(@options.tagNameProcessors, node.name) else node.name
      if (@options.xmlns)
        obj[@options.xmlnskey] = {uri: node.uri, local: node.local}
      stack.push obj

    @saxParser.onclosetag = =>
      obj = stack.pop()
      nodeName = obj["#name"]
      delete obj["#name"] if not @options.explicitChildren or not @options.preserveChildrenOrder

      if obj.cdata == true
        cdata = obj.cdata
        delete obj.cdata

      s = stack[stack.length - 1]
      # remove the '#' key altogether if it's blank
      if obj[charkey].match(/^\s*$/) and not cdata
        emptyStr = obj[charkey]
        delete obj[charkey]
      else
        obj[charkey] = obj[charkey].trim() if @options.trim
        obj[charkey] = obj[charkey].replace(/\s{2,}/g, " ").trim() if @options.normalize
        obj[charkey] = if @options.valueProcessors then processItem @options.valueProcessors, obj[charkey], nodeName else obj[charkey]
        # also do away with '#' key altogether, if there's no subkeys
        # unless EXPLICIT_CHARKEY is set
        if Object.keys(obj).length == 1 and charkey of obj and not @EXPLICIT_CHARKEY
          obj = obj[charkey]

      if (isEmpty obj)
        obj = if @options.emptyTag != '' then @options.emptyTag else emptyStr

      if @options.validator?
        xpath = "/" + (node["#name"] for node in stack).concat(nodeName).join("/")
        # Wrap try/catch with an inner function to allow V8 to optimise the containing function
        # See https://github.com/Leonidas-from-XIV/node-xml2js/pull/369
        do =>
          try
            obj = @options.validator(xpath, s and s[nodeName], obj)
          catch err
            @emit "error", err

      # put children into <childkey> property and unfold chars if necessary
      if @options.explicitChildren and not @options.mergeAttrs and typeof obj is 'object'
        if not @options.preserveChildrenOrder
          node = {}
          # separate attributes
          if @options.attrkey of obj
            node[@options.attrkey] = obj[@options.attrkey]
            delete obj[@options.attrkey]
          # separate char data
          if not @options.charsAsChildren and @options.charkey of obj
            node[@options.charkey] = obj[@options.charkey]
            delete obj[@options.charkey]

          if Object.getOwnPropertyNames(obj).length > 0
            node[@options.childkey] = obj

          obj = node
        else if s
          # append current node onto parent's <childKey> array
          s[@options.childkey] = s[@options.childkey] or []
          # push a clone so that the node in the children array can receive the #name property while the original obj can do without it
          objClone = {}
          for own key of obj
            objClone[key] = obj[key]
          s[@options.childkey].push objClone
          delete obj["#name"]
          # re-check whether we can collapse the node now to just the charkey value
          if Object.keys(obj).length == 1 and charkey of obj and not @EXPLICIT_CHARKEY
            obj = obj[charkey]

      # check whether we closed all the open tags
      if stack.length > 0
        @assignOrPush s, nodeName, obj
      else
        # if explicitRoot was specified, wrap stuff in the root tag name
        if @options.explicitRoot
          # avoid circular references
          old = obj
          obj = {}
          obj[nodeName] = old

        @resultObject = obj
        # parsing has ended, mark that so we won't throw exceptions from
        # here anymore
        @saxParser.ended = true
        @emit "end", @resultObject

    ontext = (text) =>
      s = stack[stack.length - 1]
      if s
        s[charkey] += text

        if @options.explicitChildren and @options.preserveChildrenOrder and @options.charsAsChildren and (@options.includeWhiteChars or text.replace(/\\n/g, '').trim() isnt '')
          s[@options.childkey] = s[@options.childkey] or []
          charChild =
            '#name': '__text__'
          charChild[charkey] = text
          charChild[charkey] = charChild[charkey].replace(/\s{2,}/g, " ").trim() if @options.normalize
          s[@options.childkey].push charChild

        s

    @saxParser.ontext = ontext
    @saxParser.oncdata = (text) =>
      s = ontext text
      if s
        s.cdata = true

  parseString: (str, cb) =>
    if cb? and typeof cb is "function"
      @on "end", (result) ->
        @reset()
        cb null, result
      @on "error", (err) ->
        @reset()
        cb err

    try
      str = str.toString()
      if str.trim() is ''
        @emit "end", null
        return true

      str = bom.stripBOM str
      if @options.async
        @remaining = str
        setImmediate @processAsync
        return @saxParser
      @saxParser.write(str).close()
    catch err
      unless @saxParser.errThrown or @saxParser.ended
        @emit 'error', err
        @saxParser.errThrown = true
      else if @saxParser.ended
        throw err

  parseStringPromise: (str) =>
    promisify(@parseString) str

exports.parseString = (str, a, b) ->
  # let's determine what we got as arguments
  if b?
    if typeof b == 'function'
      cb = b
    if typeof a == 'object'
      options = a
  else
    # well, b is not set, so a has to be a callback
    if typeof a == 'function'
      cb = a
    # and options should be empty - default
    options = {}

  # the rest is super-easy
  parser = new exports.Parser options
  parser.parseString str, cb

exports.parseStringPromise = (str, a) ->
  if typeof a == 'object'
    options = a

  parser = new exports.Parser options
  parser.parseStringPromise str
