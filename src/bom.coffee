"use strict"

xml2js = require '../lib/xml2js'

exports.stripBOM = (str) ->
  if str[0] == '\uFEFF'
    str.substring(1)
  else
    str

