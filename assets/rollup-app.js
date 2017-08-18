import buble from 'rollup-plugin-buble';
import when from 'rollup-plugin-conditional';
import uglify from 'rollup-plugin-uglify';

const production = process.env.NODE_ENV === "production",
      development = !production;

export default {
  entry: 'js/app.js',
  dest: '../priv/static/app.js',
  plugins: [
    buble(),
    when(production, [
      uglify()
    ])
  ],
  format: 'iife',
  sourceMap: (development ? 'inline' : false)
};
