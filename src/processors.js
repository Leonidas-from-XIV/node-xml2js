// matches all xml prefixes, except for `xmlns:`
const prefixMatch = new RegExp(/(?!xmlns)^.*:/);

const defaultExport = {};

defaultExport.normalize = str => str.toLowerCase();

defaultExport.firstCharLowerCase = str => str.charAt(0).toLowerCase() + str.slice(1);

defaultExport.stripPrefix = str => str.replace(prefixMatch, '');

defaultExport.parseNumbers = function(str) {
  if (!isNaN(str)) {
    str = (str % 1) === 0 ? parseInt(str, 10) : parseFloat(str);
  }
  return str;
};

defaultExport.parseBooleans = function(str) {
  if (/^(?:true|false)$/i.test(str)) {
    str = str.toLowerCase() === 'true';
  }
  return str;
};
export default defaultExport;
