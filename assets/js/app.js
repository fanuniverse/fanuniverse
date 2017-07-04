import './utils/polyfills';

import stars from './stars';
import upload from './upload';
import timeago from './timeago';
import comments from './comments';

import dropdowns from './dropdowns';
import video from './video';
import masonry from './masonry';
import swipeto from './swipeto';

import ujsEventactions from './ujs/eventactions';
import ujsForm from './ujs/form';
import ujsTab from './ujs/tab';

import ga from './googleanalytics';

function load() {
  stars();
  upload();
  timeago();
  comments();

  dropdowns();
  video();
  masonry();
  swipeto();

  ujsEventactions();
  ujsForm();
  ujsTab();

  ga();
}

if (document.readyState !== 'loading') load();
else document.addEventListener('DOMContentLoaded', load);
