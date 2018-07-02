"use strict"

builder = require 'xmlbuilder'
defaults = require('./defaults').defaults

CHILDREN_KEY = '$$children_da914993d9904559be754444a4685d08$$'

requiresCDATA = (entry) ->
  return typeof entry is "string" && (entry.indexOf('&') >= 0 || entry.indexOf('>') >= 0 || entry.indexOf('<') >= 0)

# Note that we do this manually instead of using xmlbuilder's `.dat` method
# since it does not support escaping the CDATA close entity (throws an error if
# it exists, and if it's pre-escaped).
wrapCDATA = (entry) ->
  return "<![CDATA[#{escapeCDATA entry}]]>"

escapeCDATA = (entry) ->
  # Split the CDATA section in two;
  # The first contains the ']]'
  # The second contains the '>'
  # When later parsed, it will be put back together as ']]>'
  return entry.replace ']]>', ']]]]><![CDATA[>'

class exports.Builder
  constructor: (opts) ->
    # copy this versions default options
    @options = {}
    @options[key] = value for own key, value of defaults["0.2"]
    # overwrite them with the specified options, if any
    @options[key] = value for own key, value of opts

  buildObject: (rootObj) ->
    attrkey = @options.attrkey
    charkey = @options.charkey

    # If there is a sane-looking first element to use as the root,
    # and the user hasn't specified a non-default rootName,
    if ( Object.keys(rootObj).length is 1 ) and ( @options.rootName == defaults['0.2'].rootName )
      # we'll take the first element as the root element
      rootName = Object.keys(rootObj)[0]
      rootObj = rootObj[rootName]
    else
      # otherwise we'll use whatever they've set, or the default
      rootName = @options.rootName

    render = (element, obj) =>
      if typeof obj isnt 'object'
        # single element, just append it as text
        if @options.cdata && requiresCDATA obj
          element.raw wrapCDATA obj
        else
          element.txt obj
      else
        for own key, child of obj
          # Case #1 Attribute
          if key is attrkey
            if typeof child is "object"
              # Inserts tag attributes
              for attr, value of child
                element = element.att(attr, value)
          # Case #2 Char data (CDATA, etc.)
          else if key is charkey
            if @options.cdata && requiresCDATA child
              element = element.raw wrapCDATA child
            else
              element = element.txt child
          # Case #3 Preprocessed node
          else if key is CHILDREN_KEY
            for childObj in child
              element = render(element.ele(childObj.name), childObj.node).up()
          else
            throw new Error 'Invalid object given to xml2js builder'

      element

    rootElement = builder.create(rootName, @options.xmldec, @options.doctype,
      headless: @options.headless
      allowSurrogateChars: @options.allowSurrogateChars)

    # fix issue #119
    if Array.isArray rootObj
      rootArray = rootObj
      rootObj = {}
      for obj in rootArray
        for key, entry of obj
          if rootObj[key]
            rootObj[key].push entry
          else
            rootObj[key] = [entry]

    rootObj = @preprocess rootObj
    render(rootElement, rootObj).end(@options.renderOpts)

  preprocess: (obj) =>
    if typeof obj != 'object'
      return obj || ''
    if Array.isArray obj
      return obj.map @preprocess
    ret = {}
    children = []
    sourcePosition = 0
    for own key, value of obj
      if key is @options.attrkey or key is @options.charkey
        ret[key] = value
      else if key is @options.sourcemapkey
        continue # do not export metadata to the final XML
      else
        if Array.isArray value
          for child in value
            sourcePosition = (child?.$source?.start?.position) || (sourcePosition + 1)
            children.push
              name: key
              sourcePosition: sourcePosition
              node: @preprocess child
        else if typeof value == 'object'
          sourcePosition = (value?.$source?.start?.position) || (sourcePosition + 1)
          children.push
            name: key
            sourcePosition: sourcePosition
            node: @preprocess value
        else
          sourcePosition = sourcePosition + 1
          children.push
            name: key
            sourcePosition: sourcePosition
            node: value || ''

    if children.length > 0
      children.sort (a, b) -> a.sourcePosition - b.sourcePosition
      ret[CHILDREN_KEY] = children
    ret
