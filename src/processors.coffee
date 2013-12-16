# matches all xml prefixes, except for `xmlns:`
prefixMatch = new RegExp /(?!xmlns)^.*:/

exports.normalize = (str) ->
  return str.toLowerCase()

exports.firstCharLowerCase = (str) ->
  return str.charAt(0).toLowerCase() + str.slice(1)

exports.stripPrefix = (str) ->
  return str.replace(prefixMatch, '')

