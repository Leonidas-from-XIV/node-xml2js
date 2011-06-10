(function() {
  var events, sax;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  sax = require("sax");
  events = require("events");
  exports.Parser = (function() {
    __extends(Parser, events.EventEmitter);
    function Parser() {
      this.parseString = __bind(this.parseString, this);      var stack;
      this.saxParser = sax.parser(true);
      this.EXPLICIT_CHARKEY = false;
      this.resultObject = null;
      stack = [];
      this.saxParser.onopentag = __bind(function(node) {
        var key, obj, _ref;
        obj = {};
        obj["#"] = "";
        _ref = node.attributes;
        for (key in _ref) {
          if (!__hasProp.call(_ref, key)) continue;
          if (!("@" in obj)) {
            obj["@"] = {};
          }
          obj["@"][key] = node.attributes[key];
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
        if (obj["#"].match(/^\s*$/)) {
          delete obj["#"];
        } else {
          obj["#"] = obj["#"].replace(/\s{2,}/g, " ").trim();
          if (Object.keys(obj).length === 1 && "#" in obj && !this.EXPLICIT_CHARKEY) {
            obj = obj["#"];
          }
        }
        if (stack.length > 0) {
          if (typeof s[nodeName] === "undefined") {
            return s[nodeName] = obj;
          } else if (s[nodeName] instanceof Array) {
            return s[nodeName].push(obj);
          } else {
            old = s[nodeName];
            s[nodeName] = [old];
            return s[nodeName].push(obj);
          }
        } else {
          this.resultObject = obj;
          return this.emit("end", this.resultObject);
        }
      }, this);
      this.saxParser.ontext = this.saxParser.oncdata = function(t) {
        var s;
        s = stack[stack.length - 1];
        if (s) {
          return s["#"] += t;
        }
      };
    }
    Parser.prototype.parseString = function(str) {
      return this.saxParser.write(str.toString());
    };
    return Parser;
  })();
}).call(this);
