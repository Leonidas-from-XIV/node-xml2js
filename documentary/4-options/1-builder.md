
Options for the `Builder` class
-------------------------------
These options are specified by ``new Builder({optionName: value})``.
Possible options are:

  * `attrkey` (default: `$`): Prefix that is used to access the attributes.
    Version 0.1 default was `@`.
  * `charkey` (default: `_`): Prefix that is used to access the character
    content. Version 0.1 default was `#`.
  * `rootName` (default `root` or the root key name): root element name to be used in case
     `explicitRoot` is `false` or to override the root element name.
  * `renderOpts` (default `{ 'pretty': true, 'indent': '  ', 'newline': '\n' }`):
    Rendering options for xmlbuilder-js.
    * pretty: prettify generated XML
    * indent: whitespace for indentation (only when pretty)
    * newline: newline char (only when pretty)
  * `xmldec` (default `{ 'version': '1.0', 'encoding': 'UTF-8', 'standalone': true }`:
    XML declaration attributes.
    * `xmldec.version` A version number string, e.g. 1.0
    * `xmldec.encoding` Encoding declaration, e.g. UTF-8
    * `xmldec.standalone` standalone document declaration: true or false
  * `doctype` (default `null`): optional DTD. Eg. `{'ext': 'hello.dtd'}`
  * `headless` (default: `false`): omit the XML header. Added in 0.4.3.
  * `allowSurrogateChars` (default: `false`): allows using characters from the Unicode
    surrogate blocks.
  * `cdata` (default: `false`): wrap text nodes in `<![CDATA[ ... ]]>` instead of
    escaping when necessary. Does not add `<![CDATA[ ... ]]>` if it is not required.
    Added in 0.4.5.

`renderOpts`, `xmldec`,`doctype` and `headless` pass through to
[xmlbuilder-js](https://github.com/oozcitak/xmlbuilder-js).
