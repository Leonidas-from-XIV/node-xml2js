
Parsing multiple files
----------------------

If you want to parse multiple files, you have multiple possibilities:

  * You can create one `xml2js.Parser` per file. That's the recommended one
    and is promised to always *just work*.
  * You can call `reset()` on your parser object.
  * You can hope everything goes well anyway. This behaviour is not
    guaranteed work always, if ever. Use option #1 if possible. Thanks!
