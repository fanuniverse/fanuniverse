'use strict';

/* Why Gulp?
 *
 * Sprockets asset pipeline is very outdated. It lacks such essential features
 * as source maps, and even though there is a new major version in development (4.0.0),
 * I doubt it is going to see a wide adoption due to the recent DHH's decision
 * to bring Webpack to Rails.
 *
 * The reason I chose not to use Webpack lies in the way it treats modules —
 * see https://github.com/webpack/webpack/issues/2873. Otherwise, it looks like a
 * solid bundler that can totally replace these hand-written tasks.
 */

import gulp from 'gulp';

import js from './gulp_javascripts.babel';
import css from './gulp_stylesheets.babel';

import { javascripts, stylesheets, pack } from './gulp_manifest.babel';

gulp.task('default', ['compile-javascripts', 'compile-stylesheets'], pack);

gulp.task('watch', ['watch-javascripts', 'watch-stylesheets']);

gulp.task('compile-javascripts', js);

gulp.task('watch-javascripts', () => gulp.watch(javascripts.all, ['compile-javascripts']));

gulp.task('compile-stylesheets', css);

gulp.task('watch-stylesheets', () => gulp.watch(stylesheets.all, ['compile-stylesheets']));
