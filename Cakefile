{spawn, exec} = require 'child_process'

task 'build', 'continually build the JavaScript code', ->
  # http://stackoverflow.com/a/17537559/1683359
  coffeeCmd = if process.platform == 'win32' then 'coffee.cmd' else 'coffee'
  coffee = spawn coffeeCmd, ['-cw', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'doc', 'rebuild the Docco documentation', ->
  exec([
    'docco src/xml2js.coffee'
  ].join(' && '), (err) ->
    throw err if err
  )
