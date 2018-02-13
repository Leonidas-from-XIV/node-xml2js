"use strict"

defaults = require './defaults'
builder = require './builder'
parser = require './parser'
processors = require './processors'

exports.defaults = defaults.defaults

exports.processors = processors

class exports.ValidationError extends Error
  constructor: (message) ->
    @message = message

exports.Builder = builder.Builder

exports.Parser = parser.Parser

exports.parseString = parser.parseString
exports.parseStringPromise = parser.parseStringPromise
