import './utils/polyfills';

import csrf from './utils/csrf';

import stars from './stars';
import upload from './upload';
import timeago from './timeago';
import comments from './comments';
import autocomplete from './autocomplete';

import dropdowns from './dropdowns';
import video from './video';
import mediagrid from './mediagrid';
import swipeto from './swipeto';

import imagetabs from './imagetabs';

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
  mediagrid();
  swipeto();

  ujsEventactions();
  ujsLinks();
  ujsForm();
  ujsTab();

  imagetabs();

  ga();
}

if (document.readyState !== 'loading') load();
else document.addEventListener('DOMContentLoaded', load);
