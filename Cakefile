{spawn, exec} = require 'child_process'

task 'build', 'continually build the JavaScript code', ->
  coffee = spawn 'coffee', ['-cw', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'test', 'run the test suite', ->
  # wrapper around zap to return nonzero if tests failed
  exec 'zap', (err, stdout, stderr) ->
    console.log stdout.trim()
    if stdout.indexOf("\u001b[1;31mfailed\u001b[0m") != -1
      process.exit 1

task 'doc', 'rebuild the Docco documentation', ->
  exec([
    'docco src/xml2js.coffee'
  ].join(' && '), (err) ->
    throw err if err
  )
