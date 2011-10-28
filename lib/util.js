if (process.versions.node.match(/^0.3/)) {
  module.exports = require("util");
} else {
  // This module is called "sys" in 0.2.x
  module.exports = require("sys");
}
