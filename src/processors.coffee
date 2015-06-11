# matches all xml prefixes, except for `xmlns:`
prefixMatch = new RegExp /(?!xmlns)^.*:/

exports.normalize = (str) ->
  if typeof str is 'string'
    return str.toLowerCase()
  else
    return str

exports.firstCharLowerCase = (str) ->
  if typeof str is 'string'
    return str.charAt(0).toLowerCase() + str.slice(1)
  else
    return str

exports.stripPrefix = (str) ->
  return str.replace prefixMatch, ''

exports.parseNumbers = (str) ->
  if typeof str is 'string' and !isNaN str
    str = if str % 1 == 0 then parseInt str, 10 else parseFloat str
  else
    return str
