import './utils/polyfills';

import csrf from './utils/csrf'

import stars from './stars';
import upload from './upload';
import timeago from './timeago';
import comments from './comments';
import autocomplete from './autocomplete';

import dropdowns from './dropdowns';
import video from './video';
import masonry from './masonry';
import swipeto from './swipeto';

import ujsEventactions from './ujs/eventactions';
import ujsLinks from './ujs/links';
import ujsForm from './ujs/form';
import ujsTab from './ujs/tab';

import ga from './googleanalytics';

function load() {
  csrf();

  stars();
  upload();
  timeago();
  comments();
  autocomplete();

  dropdowns();
  video();
  masonry();
  swipeto();

  ujsEventactions();
  ujsLinks();
  ujsForm();
  ujsTab();

  ga();
}

if (document.readyState !== 'loading') load();
else document.addEventListener('DOMContentLoaded', load);
