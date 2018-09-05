
Displaying results
------------------

You might wonder why, using `console.dir` or `console.log` the output at some
level is only `[Object]`. Don't worry, this is not because `xml2js` got lazy.
That's because Node uses `util.inspect` to convert the object into strings and
that function stops after `depth=2` which is a bit low for most XML.

To display the whole deal, you can use `console.log(util.inspect(result, false,
null))`, which displays the whole result.

So much for that, but what if you use
[eyes](https://github.com/cloudhead/eyes.js) for nice colored output and it
truncates the output with `…`? Don't fear, there's also a solution for that,
you just need to increase the `maxLength` limit by creating a custom inspector
`var inspect = require('eyes').inspector({maxLength: false})` and then you can
easily `inspect(result)`.
