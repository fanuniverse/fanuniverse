import multiEntry from 'rollup-plugin-multi-entry';
import when from 'rollup-plugin-conditional';
import uglify from 'rollup-plugin-uglify';

const production = process.env.NODE_ENV === "production";

export default {
  entry: [
    './node_modules/whatwg-fetch/fetch.js',
    './node_modules/promise-polyfill/promise.js',
    './node_modules/element-closest/element-closest.js',
    './node_modules/textarea-caret/index.js',
    './node_modules/phoenix_html/priv/static/phoenix_html.js',
    './node_modules/masonry-layout/dist/masonry.pkgd.js',
    './node_modules/imagesloaded/imagesloaded.pkgd.js'
  ],
  dest: '../priv/static/vendor.js',
  plugins: [
    multiEntry(),

    when(production, [
      uglify()
    ])
  ],
  format: 'es',
  context: 'window'
};
