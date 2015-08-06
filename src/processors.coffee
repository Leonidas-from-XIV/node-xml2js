"use strict"

# matches all xml prefixes, except for `xmlns:`
prefixMatch = new RegExp /(?!xmlns)^.*:/

exports.normalize = (str) ->
  return str.toLowerCase()

exports.firstCharLowerCase = (str) ->
  return str.charAt(0).toLowerCase() + str.slice(1)

exports.stripPrefix = (str) ->
  return str.replace prefixMatch, ''

exports.parseNumbers = (str) ->
  if !isNaN str
    str = if str % 1 == 0 then parseInt str, 10 else parseFloat str
  return str

exports.parseBooleans = (str) ->
  if /^(?:true|false)$/i.test(str)
    str = str.toLowerCase() == 'true'
  return str
