'use strict';

import gulp from 'gulp';

import sourcemaps from 'gulp-sourcemaps';
import stream from 'event-stream';
import concat from 'gulp-concat';

import sass from 'gulp-sass';
import autoprefixer from 'gulp-autoprefixer';
import cleancss from 'gulp-clean-css';

import { production, development, dest, stylesheets } from './gulp_manifest.babel';

export default function() {
  return stream.merge(application(),
                      fontawesome());
}

function fontawesome() {
  return gulp.src(stylesheets.fontawesomeWebfont)
      .pipe(gulp.dest(dest.fonts));
}

function application() {
  return stream.merge(gulp.src(stylesheets.vendor),
                      gulp.src(stylesheets.application))
      .pipe(concat('app.css'))
      .pipe(development(sourcemaps.init()))
      .pipe(sass({
          indentedSyntax: false,
          errLogToConsole: true,
          includePaths: [stylesheets.fontawesomeSass]
        }))
      .pipe(autoprefixer({
          browsers: ['last 2 versions'],
          cascade: false
        }))
      .pipe(production(cleancss({
          level: {
            1: {
              tidySelectors: false,
              tidyBlockScopes: false,
              specialComments: 0
            },
            2: {
              all: false
            }
          }
        })))
      .pipe(development(sourcemaps.write()))
      .pipe(gulp.dest(dest.assets));
}
