const CleanCSS = require("clean-css");

module.exports = {
  minify: (code, opts) => new CleanCSS(opts).minify(code),
};
