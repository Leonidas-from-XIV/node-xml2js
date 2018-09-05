
XML builder usage
-----------------

Since 0.4.0, objects can be also be used to build XML:

%EXAMPLE: example/xml.js, .. => xml2js, javascript%

At the moment, a one to one bi-directional conversion is guaranteed only for
default configuration, except for `attrkey`, `charkey` and `explicitArray` options
you can redefine to your taste. Writing CDATA is supported via setting the `cdata`
option to `true`.

To specify attributes:
%EXAMPLE: example/xml-attributes.js, .. => xml2js, javascript%

### Adding xmlns attributes

You can generate XML that declares XML namespace prefix / URI pairs with xmlns attributes.

Example declaring a default namespace on the root element:

%EXAMPLE: example/xml-namespace.js, .. => xml2js, javascript%
Result of `buildObject(obj)`:
%FORK-xml example/xml-namespace%
Example declaring non-default namespaces on non-root elements:
%EXAMPLE: example/xml-nondefault.js, .. => xml2js, javascript%
Result of `buildObject(obj)`:
%FORK-xml example/xml-nondefault%
