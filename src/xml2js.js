/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import defaults from './defaults'
import builder from './builder'
import parser from './parser'
import processors from './processors'
const defaultExport = {}

defaultExport.defaults = defaults.defaults

defaultExport.processors = processors

defaultExport.ValidationError = class ValidationError extends Error {
  // NOTHING
}

defaultExport.Builder = builder.Builder

defaultExport.Parser = parser.Parser

defaultExport.parseString = parser.parseString
defaultExport.parseStringPromise = parser.parseStringPromise
export default defaultExport
