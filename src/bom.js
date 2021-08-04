/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const defaultExport = {}

defaultExport.stripBOM = function (str) {
  if (str[0] === '\uFEFF') {
    return str.substring(1)
  } else {
    return str
  }
}
export default defaultExport
