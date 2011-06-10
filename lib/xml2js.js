(function() {
  var Parser, events, sax, sys;
  var __hasProp = Object.prototype.hasOwnProperty, __indexOf = Array.prototype.indexOf || function(item) {
    for (var i = 0, l = this.length; i < l; i++) {
      if (this[i] === item) return i;
    }
    return -1;
  };
  sax = require("sax");
  sys = require("sys");
  events = require("events");
  Parser = function() {
    var stack, that;
    that = this;
    this.saxParser = sax.parser(true);
    this.EXPLICIT_CHARKEY = false;
    this.resultObject = null;
    stack = [];
    this.saxParser.onopentag = function(node) {
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
    };
    this.saxParser.onclosetag = function() {
      var nodeName, obj, old, s;
      obj = stack.pop();
      nodeName = obj["#name"];
      delete obj["#name"];
      s = stack[stack.length - 1];
      if (obj["#"].match(/^\s*$/)) {
        delete obj["#"];
      } else {
        obj["#"] = obj["#"].replace(/\s{2,}/g, " ").trim();
        if (Object.keys(obj).length === 1 && __indexOf.call(obj, "#") >= 0 && !that.EXPLICIT_CHARKEY) {
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
        that.resultObject = obj;
        return that.emit("end", that.resultObject);
      }
    };
    this.saxParser.ontext = this.saxParser.oncdata = function(t) {
      var s;
      s = stack[stack.length - 1];
      if (s) {
        return s["#"] += t;
      }
    };
    return;
  };
  sys.inherits(Parser, events.EventEmitter);
  Parser.prototype.parseString = function(str) {
    return this.saxParser.write(str.toString());
  };
  exports.Parser = Parser;
}).call(this);
