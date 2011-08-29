(function() {
  var events, isEmpty, sax;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  sax = require('sax');
  events = require('events');
  isEmpty = function(thing) {
    return typeof thing === 'object' && (thing != null) && Object.keys(thing).length === 0;
  };
  exports.Parser = (function() {
    __extends(Parser, events.EventEmitter);
    function Parser(opts) {
      this.parseString = __bind(this.parseString, this);
      var attrkey, charkey, err, key, options, stack, value;
      options = {
        explicitCharkey: false,
        trim: true,
        normalize: true,
        attrkey: "@",
        charkey: "#",
        explicitArray: false
      };
      for (key in opts) {
        if (!__hasProp.call(opts, key)) continue;
        value = opts[key];
        options[key] = value;
      }
      this.saxParser = sax.parser(true, {
        trim: false,
        normalize: false
      });
      err = false;
      this.saxParser.onerror = __bind(function(error) {
        if (!err) {
          err = true;
          return this.emit("error", error);
        }
      }, this);
      this.EXPLICIT_CHARKEY = options.explicitCharkey;
      this.resultObject = null;
      stack = [];
      attrkey = options.attrkey;
      charkey = options.charkey;
      this.saxParser.onopentag = __bind(function(node) {
        var key, obj, _ref;
        obj = {};
        obj[charkey] = "";
        _ref = node.attributes;
        for (key in _ref) {
          if (!__hasProp.call(_ref, key)) continue;
          if (!(attrkey in obj)) {
            obj[attrkey] = {};
          }
          obj[attrkey][key] = node.attributes[key];
        }
        obj["#name"] = node.name;
        return stack.push(obj);
      }, this);
      this.saxParser.onclosetag = __bind(function() {
        var nodeName, obj, old, s;
        obj = stack.pop();
        nodeName = obj["#name"];
        delete obj["#name"];
        s = stack[stack.length - 1];
        if (obj[charkey].match(/^\s*$/)) {
          delete obj[charkey];
        } else {
          if (options.trim) {
            obj[charkey] = obj[charkey].trim();
          }
          if (options.normalize) {
            obj[charkey] = obj[charkey].replace(/\s{2,}/g, " ").trim();
          }
          if (Object.keys(obj).length === 1 && charkey in obj && !this.EXPLICIT_CHARKEY) {
            obj = obj[charkey];
          }
        }
        if (options.emptyTag !== void 0 && isEmpty(obj)) {
          obj = options.emptyTag;
        }
        if (stack.length > 0) {
          if (!options.explicitArray) {
            if (!(nodeName in s)) {
              return s[nodeName] = obj;
            } else if (s[nodeName] instanceof Array) {
              return s[nodeName].push(obj);
            } else {
              old = s[nodeName];
              s[nodeName] = [old];
              return s[nodeName].push(obj);
            }
          } else {
            if (!(s[nodeName] instanceof Array)) {
              s[nodeName] = [];
            }
            return s[nodeName].push(obj);
          }
        } else {
          if (options.explicitRoot) {
            old = obj;
            obj = {};
            obj[nodeName] = old;
          }
          this.resultObject = obj;
          return this.emit("end", this.resultObject);
        }
      }, this);
      this.saxParser.ontext = this.saxParser.oncdata = __bind(function(text) {
        var s;
        s = stack[stack.length - 1];
        if (s) {
          return s[charkey] += text;
        }
      }, this);
    }
    Parser.prototype.parseString = function(str) {
      return this.saxParser.write(str.toString());
    };
    return Parser;
  })();
}).call(this);
