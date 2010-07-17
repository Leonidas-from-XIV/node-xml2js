Object.size = function(obj) {
    var size = 0, key;
    for (key in obj)
        if (obj.hasOwnProperty(key))
            size++;
    return size;
};

var xml = require('xml'),
    sys = require('sys'),
    events = require('events');

var Parser = function() {
    var that = this;
    this.EXPLICIT_CHARKEY = false; // always use the '#' key, even if there are no subkeys
    var saxHandler = function(cb) {
        var stack = [];

        cb.onStartElementNS(function(elem, attrs, prefix, uri, namespaces) {
            var obj = {};
            obj['#'] = "";
            for(var i=0, len=attrs.length; i<len; i++) {
                if(typeof obj['@'] === 'undefined') {
                    obj['@'] = {};
                }
                obj['@'][attrs[i][0]] = attrs[i][1];
            }
            stack.push(obj);
        });

        cb.onEndElementNS(function(elem, prefix, uri) {
            var obj = stack.pop();
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
                if( Object.size(obj) == 1 && '#' in obj && !(that.EXPLICIT_CHARKEY) ) {
                    obj = obj['#'];
                }
            }
            
            // set up the parent element relationship
            if (stack.length > 0) {
                if (typeof s[elem] === 'undefined')
                    s[elem] = obj;
                else if (s[elem] instanceof Array)
                    s[elem].push(obj);
                else {
                    var old = s[elem];
                    s[elem] = [old];
                    s[elem].push(obj);
                }
            }
            else {
                that.resultObject = obj;
            }
        });

        function addContent(chars) {
            var s = stack[stack.length-1];
            if(s) { 
                s['#'] += chars;
            }
        }
        cb.onCharacters(addContent);
        cb.onCdata(addContent);
        cb.onEndDocument(function() { that.emit("end"); });
    };

    this.resultObject = null;
    this.sax = new xml.SaxParser(saxHandler);
};
sys.inherits(Parser, events.EventEmitter);
Parser.prototype.parseString = function(str) { this.sax.parseString(str); };
exports.Parser = Parser;
