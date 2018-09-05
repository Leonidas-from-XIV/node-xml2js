
Simple as pie usage
-------------------

That's right, if you have been using xml-simple or a home-grown
wrapper, this was added in 0.1.11 just for you:

%EXAMPLE: example/simple.js, .. => xml2js, javascript%

%FORK-js example/simple%

Look ma, no event listeners!

You can also use `xml2js` from
[CoffeeScript](https://github.com/jashkenas/coffeescript), further reducing
the clutter:

%EXAMPLE: example/simple.coffee, coffeescript%

But what happens if you forget the `new` keyword to create a new `Parser`? In
the middle of a nightly coding session, it might get lost, after all. Worry
not, we got you covered! Starting with 0.2.8 you can also leave it out, in
which case `xml2js` will helpfully add it for you, no bad surprises and
inexplicable bugs!
