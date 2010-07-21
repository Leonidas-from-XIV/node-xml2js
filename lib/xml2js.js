require('./proto');

var sax = require('sax'),
    sys = require('sys'),
    events = require('events');

var Parser = function() {
    var that = this;
    this.saxParser = sax.parser(true); // make the sax parser

    this.EXPLICIT_CHARKEY = false; // always use the '#' key, even if there are no subkeys
    this.resultObject = null;

    var stack = [];

    this.saxParser.onopentag = function(node) {
        var obj = {};
        obj['#'] = "";
        if(Object.keys(node.attributes).length) {
            node.attributes.forEach( function(v,k) {
                if(typeof obj['@'] === 'undefined') {
                    obj['@'] = {};
                }
                obj['@'][k] = v;
            });
        }
        obj['#name'] = node.name; // need a place to store the node name
        stack.push(obj);
    };

    this.saxParser.onclosetag = function() {
        var obj = stack.pop();
        var nodeName = obj['#name'];
        delete obj['#name'];
        var s = stack[stack.length-1];

        // remove the '#' key altogether if it's blank
        if(obj['#'].match(/^\s*$/)) {
            delete obj['#'];
        }
        else {
            // turn 2 or more spaces into one space
            obj['#'] = obj['#'].replace(/\s{2,}/g, " ").trim();

            // also do away with '#' key altogether, if there's no subkeys
            // unless EXPLICIT_CHARKEY is set
            if( Object.keys(obj).length == 1 && '#' in obj && !(that.EXPLICIT_CHARKEY) ) {
                obj = obj['#'];
            }
        }
        
        // set up the parent element relationship
        if (stack.length > 0) {
            if (typeof s[nodeName] === 'undefined')
                s[nodeName] = obj;
            else if (s[nodeName] instanceof Array)
                s[nodeName].push(obj);
            else {
                var old = s[nodeName];
                s[nodeName] = [old];
                s[nodeName].push(obj);
            }
        }
        else {
            that.resultObject = obj;
            that.emit("end", that.resultObject);
        }
    };

    this.saxParser.ontext = this.saxParser.oncdata = function(t) {
        var s = stack[stack.length-1];
        if(s) { 
            s['#'] += t;
        }
    }
};
sys.inherits(Parser, events.EventEmitter);
Parser.prototype.parseString = function(str) { this.saxParser.write(str.toString()); };
exports.Parser = Parser;
