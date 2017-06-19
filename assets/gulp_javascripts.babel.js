'use strict';

import gulp from 'gulp';

import sourcemaps from 'gulp-sourcemaps';
import stream from 'event-stream';
import concat from 'gulp-concat';

import rollup from 'rollup-stream';
import buble from 'rollup-plugin-buble';

import source from 'vinyl-source-stream';
import buffer from 'vinyl-buffer';
import uglify from 'gulp-uglify';

import { production, development, dest, javascripts } from './gulp_manifest.babel';

export default function() {
  return stream.merge(vendor(),
                      application())
      .pipe(concat('app.js'))
      .pipe(production(uglify()))
      .pipe(gulp.dest(dest.assets));
}

function vendor() {
  return gulp.src(javascripts.vendor);
}

function application() {
  return rollup({
          plugins: [buble()],
          entry: javascripts.application,
          format: 'iife',
          sourceMap: development()
        })
      .pipe(source('app.js'))
      .pipe(buffer())
      .pipe(development(sourcemaps.init({ loadMaps: true })))
      .pipe(development(sourcemaps.write()));
}
