"use strict"

builder = require 'xmlbuilder'
defaults = require('./defaults').defaults

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
      else if Array.isArray obj
        # fix issue #119
        for own index, child of obj
          for key, entry of child
            element = render(element.ele(key), entry).up()
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

          # Case #3 Array data
          else if Array.isArray child
            for own index, entry of child
              if typeof entry is 'string'
                if @options.cdata && requiresCDATA entry
                  element = element.ele(key).raw(wrapCDATA entry).up()
                else
                  element = element.ele(key, entry).up()
              else
                element = render(element.ele(key), entry).up()

          # Case #4 Objects
          else if typeof child is "object"
            element = render(element.ele(key), child).up()

          # Case #5 String and remaining types
          else
            if typeof child is 'string' && @options.cdata && requiresCDATA child
              element = element.ele(key).raw(wrapCDATA child).up()
            else
              if not child?
                child = ''
              element = element.ele(key, child.toString()).up()

      element

    rootElement = builder.create(rootName, @options.xmldec, @options.doctype,
      headless: @options.headless
      allowSurrogateChars: @options.allowSurrogateChars)

    render(rootElement, rootObj).end(@options.renderOpts)
