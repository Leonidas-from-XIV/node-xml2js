/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS203: Remove `|| {}` from converted for-own loops
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import builder from 'xmlbuilder'
import { defaults } from './defaults'

const requiresCDATA = entry => (typeof entry === 'string') && ((entry.indexOf('&') >= 0) || (entry.indexOf('>') >= 0) || (entry.indexOf('<') >= 0))

// Note that we do this manually instead of using xmlbuilder's `.dat` method
// since it does not support escaping the CDATA close entity (throws an error if
// it exists, and if it's pre-escaped).
const wrapCDATA = entry => `<![CDATA[${escapeCDATA(entry)}]]>`

const escapeCDATA = entry => // Split the CDATA section in two;
// The first contains the ']]'
// The second contains the '>'
// When later parsed, it will be put back together as ']]>'
  entry.replace(']]>', ']]]]><![CDATA[>')

class Builder {
  constructor (opts) {
    // copy this versions default options
    let key, value
    this.options = {}
    for (key of Object.keys(defaults['0.2'] || {})) { value = defaults['0.2'][key]; this.options[key] = value }
    // overwrite them with the specified options, if any
    for (key of Object.keys(opts || {})) { value = opts[key]; this.options[key] = value }
  }

  buildObject (rootObj) {
    let rootName
    const {
      attrkey
    } = this.options
    const {
      charkey
    } = this.options

    // If there is a sane-looking first element to use as the root,
    // and the user hasn't specified a non-default rootName,
    if ((Object.keys(rootObj).length === 1) && (this.options.rootName === defaults['0.2'].rootName)) {
      // we'll take the first element as the root element
      rootName = Object.keys(rootObj)[0]
      rootObj = rootObj[rootName]
    } else {
      // otherwise we'll use whatever they've set, or the default
      ({
        rootName
      } = this.options)
    }

    const render = (element, obj) => {
      let child, entry, index, key
      if (typeof obj !== 'object') {
        // single element, just append it as text
        if (this.options.cdata && requiresCDATA(obj)) {
          element.raw(wrapCDATA(obj))
        } else {
          element.txt(obj)
        }
      } else if (Array.isArray(obj)) {
        // fix issue #119
        for (index of Object.keys(obj || {})) {
          child = obj[index]
          for (key in child) {
            entry = child[key]
            element = render(element.ele(key), entry).up()
          }
        }
      } else {
        for (key of Object.keys(obj || {})) {
          // Case #1 Attribute
          child = obj[key]
          if (key === attrkey) {
            if (typeof child === 'object') {
              // Inserts tag attributes
              for (const attr in child) {
                const value = child[attr]
                element = element.att(attr, value)
              }
            }

          // Case #2 Char data (CDATA, etc.)
          } else if (key === charkey) {
            if (this.options.cdata && requiresCDATA(child)) {
              element = element.raw(wrapCDATA(child))
            } else {
              element = element.txt(child)
            }

          // Case #3 Array data
          } else if (Array.isArray(child)) {
            for (index of Object.keys(child || {})) {
              entry = child[index]
              if (typeof entry === 'string') {
                if (this.options.cdata && requiresCDATA(entry)) {
                  element = element.ele(key).raw(wrapCDATA(entry)).up()
                } else {
                  element = element.ele(key, entry).up()
                }
              } else {
                element = render(element.ele(key), entry).up()
              }
            }

          // Case #4 Objects
          } else if (typeof child === 'object') {
            element = render(element.ele(key), child).up()

          // Case #5 String and remaining types
          } else {
            if ((typeof child === 'string') && this.options.cdata && requiresCDATA(child)) {
              element = element.ele(key).raw(wrapCDATA(child)).up()
            } else {
              if ((child == null)) {
                child = ''
              }
              element = element.ele(key, child.toString()).up()
            }
          }
        }
      }

      return element
    }

    const rootElement = builder.create(rootName, this.options.xmldec, this.options.doctype, {
      headless: this.options.headless,
      allowSurrogateChars: this.options.allowSurrogateChars
    })

    return render(rootElement, rootObj).end(this.options.renderOpts)
  }
}

export {
  Builder
}
