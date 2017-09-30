import buble from 'rollup-plugin-buble';
import when from 'rollup-plugin-conditional';
import uglify from 'rollup-plugin-uglify';
import replace from 'rollup-plugin-replace';

const production = process.env.NODE_ENV === "production",
      development = !production;

export default {
  input: 'js/app.js',
  output: {
    file: '../priv/static/app.js',
    format: 'iife',
    sourcemap: (development ? 'inline' : false)
  },
  plugins: [
    buble(),
    when(production, [
      uglify(),
      replace({ 'lvh.me': 'fanuniverse.org' })
    ])
  ]
};
