exports.defaults = {
  "0.1":
    explicitCharkey: false
    trim: true
    # normalize implicates trimming, just so you know
    normalize: true
    # normalize tag names to lower case
    normalizeTags: false
    # set default attribute object key
    attrkey: "@"
    # set default char object key
    charkey: "#"
    # always put child nodes in an array
    explicitArray: false
    # ignore all attributes regardless
    ignoreAttrs: false
    # merge attributes and child elements onto parent object.  this may
    # cause collisions.
    mergeAttrs: false
    explicitRoot: false
    validator: null
    xmlns : false
    # fold children elements into dedicated property (works only in 0.2)
    explicitChildren: false
    childkey: '@@'
    charsAsChildren: false
    # include white-space only text nodes
    includeWhiteChars: false
    # callbacks are async? not in 0.1 mode
    async: false
    strict: true
    attrNameProcessors: null
    attrValueProcessors: null
    tagNameProcessors: null
    valueProcessors: null
    emptyTag: ''

  "0.2":
    explicitCharkey: false
    trim: false
    normalize: false
    normalizeTags: false
    attrkey: "$"
    charkey: "_"
    explicitArray: true
    ignoreAttrs: false
    mergeAttrs: false
    explicitRoot: true
    validator: null
    xmlns : false
    explicitChildren: false
    preserveChildrenOrder: false
    childkey: '$$'
    charsAsChildren: false
    # include white-space only text nodes
    includeWhiteChars: false
    # not async in 0.2 mode either
    async: false
    strict: true
    attrNameProcessors: null
    attrValueProcessors: null
    tagNameProcessors: null
    valueProcessors: null
    # xml building options
    rootName: 'root'
    xmldec: {'version': '1.0', 'encoding': 'UTF-8', 'standalone': true}
    doctype: null
    renderOpts: { 'pretty': true, 'indent': '  ', 'newline': '\n' }
    headless: false
    chunkSize: 10000
    emptyTag: ''
    cdata: false
}
