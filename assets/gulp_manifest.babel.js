'use strict';

import gulp from 'gulp';
import rev from 'gulp-rev';
import gzip from 'gulp-gzip';

import environments from 'gulp-environments';

export const development = environments.development,
             production  = environments.production;

export const root = '..';

export const dest = {
  assets:   `${root}/priv/static`,
  fonts:    `${root}/priv/static/fonts`,
  manifest: `${root}/priv/static/manifest.json`
};

export const javascripts = {
  vendor: [
    './node_modules/phoenix_html/priv/static/phoenix_html.js',
    './node_modules/whatwg-fetch/fetch.js',
    './node_modules/promise-polyfill/promise.js',
    './node_modules/element-closest/element-closest.js',
    './node_modules/masonry-layout/dist/masonry.pkgd.js',
    './node_modules/imagesloaded/imagesloaded.pkgd.js'
  ],
  all:         `${root}/assets/js/**/*.js`,
  application: `${root}/assets/js/app.js`,
};

export const stylesheets = {
  vendor: [
    './node_modules/normalize.css/normalize.css'
  ],
  all:                `${root}/assets/css/**/*.scss`,
  application:        `${root}/assets/css/app.scss`,
  fontawesomeSass:    `./node_modules/font-awesome/scss`,
  fontawesomeWebfont: `./node_modules/font-awesome/fonts/**.*`,
};

/* Adds digests to asset files and Gzips them when running in production environment. */
export function pack() {
  const revStream =
      gulp.src([`${dest.assets}/app.js`,
                `${dest.assets}/app.css`])
        .pipe(production(rev()))
        .pipe(production(gulp.dest(dest.assets)));

  revStream
      .pipe(production(gzip({
          gzipOptions: {
            level: 9,
            memLevel: 9
          }
        })))
      .pipe(production(gulp.dest(dest.assets)));

  return revStream
      .pipe(production(rev.manifest(dest.manifest, { base: dest.assets })))
      .pipe(production(gulp.dest(dest.assets)))
}
