// matches all xml prefixes, except for `xmlns:`
const prefixMatch = /^(?!xmlns).*:/

const normalize = str => str.toLowerCase()

const firstCharLowerCase = str => str.charAt(0).toLowerCase() + str.slice(1)

const stripPrefix = str => str.replace(prefixMatch, '')

const parseNumbers = function (str) {
  if (!isNaN(str)) {
    str = (str % 1) === 0 ? parseInt(str, 10) : parseFloat(str)
  }
  return str
}

const parseBooleans = function (str) {
  if (/^(?:true|false)$/i.test(str)) {
    str = str.toLowerCase() === 'true'
  }
  return str
}

export {
  normalize,
  firstCharLowerCase,
  stripPrefix,
  parseNumbers,
  parseBooleans
}
