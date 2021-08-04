/*
 * decaffeinate suggestions:
 * DS002: Fix invalid constructor
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS203: Remove `|| {}` from converted for-own loops
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import sax from 'sax'
import events from 'events'
import * as bom from './bom'
import * as processors from './processors'
import { setImmediate } from 'timers'
import { defaults } from './defaults'

// Underscore has a nice function for this, but we try to go without dependencies
const isEmpty = thing => (typeof thing === 'object') && (thing != null) && (Object.keys(thing).length === 0)

const processItem = function (processors, item, key) {
  for (const process of Array.from(processors)) { item = process(item, key) }
  return item
}

class Parser extends events {
  constructor (opts) {
    super()
    let key, value
    this.processAsync = this.processAsync.bind(this)
    this.assignOrPush = this.assignOrPush.bind(this)
    this.reset = this.reset.bind(this)
    this.parseString = this.parseString.bind(this)
    this.parseStringPromise = this.parseStringPromise.bind(this)
    // copy this versions default options
    this.options = {}
    for (key of Object.keys(defaults['0.2'] || {})) { value = defaults['0.2'][key]; this.options[key] = value }
    // overwrite them with the specified options, if any
    for (key of Object.keys(opts || {})) { value = opts[key]; this.options[key] = value }
    // define the key used for namespaces
    if (this.options.xmlns) {
      this.options.xmlnskey = this.options.attrkey + 'ns'
    }
    if (this.options.normalizeTags) {
      if (!this.options.tagNameProcessors) {
        this.options.tagNameProcessors = []
      }
      this.options.tagNameProcessors.unshift(processors.normalize)
    }

    this.reset()
  }

  processAsync () {
    try {
      let chunk
      if (this.remaining.length <= this.options.chunkSize) {
        chunk = this.remaining
        this.remaining = ''
        this.saxParser = this.saxParser.write(chunk)
        return this.saxParser.close()
      } else {
        chunk = this.remaining.substr(0, this.options.chunkSize)
        this.remaining = this.remaining.substr(this.options.chunkSize, this.remaining.length)
        this.saxParser = this.saxParser.write(chunk)
        return setImmediate(this.processAsync)
      }
    } catch (err) {
      if (!this.saxParser.errThrown) {
        this.saxParser.errThrown = true
        return this.emit(err)
      }
    }
  }

  assignOrPush (obj, key, newValue) {
    if (!(key in obj)) {
      if (!this.options.explicitArray) {
        obj[key] = newValue
        return obj[key]
      } else {
        obj[key] = [newValue]
        return obj[key]
      }
    } else {
      if (!(obj[key] instanceof Array)) { obj[key] = [obj[key]] }
      return obj[key].push(newValue)
    }
  }

  reset () {
    // remove all previous listeners for events, to prevent event listener
    // accumulation
    this.removeAllListeners()
    // make the SAX parser. tried trim and normalize, but they are not
    // very helpful
    this.saxParser = sax.parser(this.options.strict, {
      trim: false,
      normalize: false,
      xmlns: this.options.xmlns
    })

    // emit one error event if the sax parser fails. this is mostly a hack, but
    // the sax parser isn't state of the art either.
    this.saxParser.errThrown = false
    this.saxParser.onerror = error => {
      this.saxParser.resume()
      if (!this.saxParser.errThrown) {
        this.saxParser.errThrown = true
        return this.emit('error', error)
      }
    }

    this.saxParser.onend = () => {
      if (!this.saxParser.ended) {
        this.saxParser.ended = true
        return this.emit('end', this.resultObject)
      }
    }

    // another hack to avoid throwing exceptions when the parsing has ended
    // but the user-supplied callback throws an error
    this.saxParser.ended = false

    // always use the '#' key, even if there are no subkeys
    // setting this property by and is deprecated, yet still supported.
    // better pass it as explicitCharkey option to the constructor
    this.EXPLICIT_CHARKEY = this.options.explicitCharkey
    this.resultObject = null
    const stack = []
    // aliases, so we don't have to type so much
    const {
      attrkey
    } = this.options
    const {
      charkey
    } = this.options

    this.saxParser.onopentag = node => {
      const obj = {}
      obj[charkey] = ''
      if (!this.options.ignoreAttrs) {
        for (const key of Object.keys(node.attributes || {})) {
          if (!(attrkey in obj) && !this.options.mergeAttrs) {
            obj[attrkey] = {}
          }
          const newValue = this.options.attrValueProcessors ? processItem(this.options.attrValueProcessors, node.attributes[key], key) : node.attributes[key]
          const processedKey = this.options.attrNameProcessors ? processItem(this.options.attrNameProcessors, key) : key
          if (this.options.mergeAttrs) {
            this.assignOrPush(obj, processedKey, newValue)
          } else {
            obj[attrkey][processedKey] = newValue
          }
        }
      }

      // need a place to store the node name
      obj['#name'] = this.options.tagNameProcessors ? processItem(this.options.tagNameProcessors, node.name) : node.name
      if (this.options.xmlns) {
        obj[this.options.xmlnskey] = { uri: node.uri, local: node.local }
      }
      return stack.push(obj)
    }

    this.saxParser.onclosetag = () => {
      let cdata, emptyStr
      let node
      let obj = stack.pop()
      const nodeName = obj['#name']
      if (!this.options.explicitChildren || !this.options.preserveChildrenOrder) { delete obj['#name'] }

      if (obj.cdata === true) {
        ({
          cdata
        } = obj)
        delete obj.cdata
      }

      const s = stack[stack.length - 1]
      // remove the '#' key altogether if it's blank
      if (obj[charkey].match(/^\s*$/) && !cdata) {
        emptyStr = obj[charkey]
        delete obj[charkey]
      } else {
        if (this.options.trim) { obj[charkey] = obj[charkey].trim() }
        if (this.options.normalize) { obj[charkey] = obj[charkey].replace(/\s{2,}/g, ' ').trim() }
        obj[charkey] = this.options.valueProcessors ? processItem(this.options.valueProcessors, obj[charkey], nodeName) : obj[charkey]
        // also do away with '#' key altogether, if there's no subkeys
        // unless EXPLICIT_CHARKEY is set
        if ((Object.keys(obj).length === 1) && charkey in obj && !this.EXPLICIT_CHARKEY) {
          obj = obj[charkey]
        }
      }

      if (isEmpty(obj)) {
        if (typeof this.options.emptyTag === 'function') {
          obj = this.options.emptyTag()
        } else {
          obj = this.options.emptyTag !== '' ? this.options.emptyTag : emptyStr
        }
      }

      if (this.options.validator != null) {
        const xpath = '/' + ((() => {
          const result = []
          for (node of Array.from(stack)) {
            result.push(node['#name'])
          }
          return result
        })()).concat(nodeName).join('/');
        // Wrap try/catch with an inner function to allow V8 to optimise the containing function
        // See https://github.com/Leonidas-from-XIV/node-xml2js/pull/369
        (() => {
          try {
            obj = this.options.validator(xpath, s && s[nodeName], obj)
            return obj
          } catch (err) {
            return this.emit('error', err)
          }
        })()
      }

      // put children into <childkey> property and unfold chars if necessary
      if (this.options.explicitChildren && !this.options.mergeAttrs && (typeof obj === 'object')) {
        if (!this.options.preserveChildrenOrder) {
          node = {}
          // separate attributes
          if (this.options.attrkey in obj) {
            node[this.options.attrkey] = obj[this.options.attrkey]
            delete obj[this.options.attrkey]
          }
          // separate char data
          if (!this.options.charsAsChildren && this.options.charkey in obj) {
            node[this.options.charkey] = obj[this.options.charkey]
            delete obj[this.options.charkey]
          }

          if (Object.getOwnPropertyNames(obj).length > 0) {
            node[this.options.childkey] = obj
          }

          obj = node
        } else if (s) {
          // append current node onto parent's <childKey> array
          s[this.options.childkey] = s[this.options.childkey] || []
          // push a clone so that the node in the children array can receive the #name property while the original obj can do without it
          const objClone = {}
          for (const key of Object.keys(obj || {})) {
            objClone[key] = obj[key]
          }
          s[this.options.childkey].push(objClone)
          delete obj['#name']
          // re-check whether we can collapse the node now to just the charkey value
          if ((Object.keys(obj).length === 1) && charkey in obj && !this.EXPLICIT_CHARKEY) {
            obj = obj[charkey]
          }
        }
      }

      // check whether we closed all the open tags
      if (stack.length > 0) {
        return this.assignOrPush(s, nodeName, obj)
      } else {
        // if explicitRoot was specified, wrap stuff in the root tag name
        if (this.options.explicitRoot) {
          // avoid circular references
          const old = obj
          obj = {}
          obj[nodeName] = old
        }

        this.resultObject = obj
        // parsing has ended, mark that so we won't throw exceptions from
        // here anymore
        this.saxParser.ended = true
        return this.emit('end', this.resultObject)
      }
    }

    const ontext = text => {
      const s = stack[stack.length - 1]
      if (s) {
        s[charkey] += text

        if (this.options.explicitChildren && this.options.preserveChildrenOrder && this.options.charsAsChildren && (this.options.includeWhiteChars || (text.replace(/\\n/g, '').trim() !== ''))) {
          s[this.options.childkey] = s[this.options.childkey] || []
          const charChild =
            { '#name': '__text__' }
          charChild[charkey] = text
          if (this.options.normalize) { charChild[charkey] = charChild[charkey].replace(/\s{2,}/g, ' ').trim() }
          s[this.options.childkey].push(charChild)
        }

        return s
      }
    }

    this.saxParser.ontext = ontext
    this.saxParser.oncdata = text => {
      const s = ontext(text)
      if (s) {
        s.cdata = true
        return s.cdata
      }
    }
    return this.saxParser.oncdata
  }

  parseString (str, cb) {
    if ((cb != null) && (typeof cb === 'function')) {
      this.on('end', function (result) {
        this.reset()
        return cb(null, result)
      })
      this.on('error', function (err) {
        this.reset()
        return cb(err)
      })
    }

    try {
      str = str.toString()
      if (str.trim() === '') {
        this.emit('end', null)
        return true
      }

      str = bom.stripBOM(str)
      if (this.options.async) {
        this.remaining = str
        setImmediate(this.processAsync)
        return this.saxParser
      }
      return this.saxParser.write(str).close()
    } catch (error) {
      const err = error
      if (!this.saxParser.errThrown && !this.saxParser.ended) {
        this.emit('error', err)
        this.saxParser.errThrown = true
        return this.saxParser.errThrown
      } else if (this.saxParser.ended) {
        throw err
      }
    }
  }

  parseStringPromise (str) {
    return new Promise((resolve, reject) => {
      return this.parseString(str, (err, value) => {
        if (err) {
          return reject(err)
        } else {
          return resolve(value)
        }
      })
    })
  }
}

const parseString = function (str, a, b) {
  // let's determine what we got as arguments
  let cb, options
  if (b != null) {
    if (typeof b === 'function') {
      cb = b
    }
    if (typeof a === 'object') {
      options = a
    }
  } else {
    // well, b is not set, so a has to be a callback
    if (typeof a === 'function') {
      cb = a
    }
    // and options should be empty - default
    options = {}
  }

  // the rest is super-easy
  const parser = new Parser(options)
  return parser.parseString(str, cb)
}

const parseStringPromise = function (str, a) {
  let options
  if (typeof a === 'object') {
    options = a
  }

  const parser = new Parser(options)
  return parser.parseStringPromise(str)
}

export {
  Parser,
  parseString,
  parseStringPromise,
}

