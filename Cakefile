{spawn, exec} = require 'child_process'

task 'build', 'build the JavaScript code', ->
  coffeeScript = if process.platform == 'win32' then 'coffee.cmd' else 'coffee'
  coffee = spawn coffeeScript, ['-c', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'doc', 'rebuild the Docco documentation', ->
  exec([
    'docco src/xml2js.coffee'
  ].join(' && '), (err) ->
    throw err if err
  )
