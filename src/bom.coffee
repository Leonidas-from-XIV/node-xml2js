"use strict"

exports.stripBOM = (str) ->
  if str[0] == '\uFEFF'
    str.substring(1)
  else
    str
