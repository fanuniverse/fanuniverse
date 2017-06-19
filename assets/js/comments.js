import { $ } from './utils/dom';
import { timeago } from './timeago';
import { loadStarrable } from './stars';

export default function() {
  const commentable = $('[data-commentable-url]');

  if (commentable) {
    load(commentable, commentable.getAttribute('data-commentable-url'));
    pagination(commentable);
    setupAjax(commentable);
  }
}

function load(container, endpoint) {
  fetch(endpoint, { credentials: 'same-origin' })
      .then((response) => response.text())
      .then((comments) => display(container, comments));
}

function display(container, comments) {
  container.innerHTML = comments;
  timeago(container);
  loadStarrable(container);
}

function pagination(container) {
  container.addEventListener('click', (e) => {
    if (e.target && e.target.closest('.page')) {
      e.preventDefault();
      load(container, e.target.getAttribute('href'));
    }
  });
}

function setupAjax(container) {
  /* Form submission is handled by rails-ujs,
   * we just need to display the comments we get as a response. */
  document.addEventListener('ajax:success', (e) => {
    if (e.target.id === 'js-commentable-form') showPosted(container, e.detail);
  });
  document.addEventListener('ajax:error', (e) => {
    if (e.target.id === 'js-commentable-form') showError(e.detail);
  });
}

function showPosted(container, response) {
  const comments      = response[2].responseText,
        editArea      = $('#js-commentable-form textarea'),
        previousError = $('.js-model-errors');

  editArea.value = '';
  previousError && previousError.remove();

  display(container, comments);
}

function showError(response) {
  const errorHtml     = response[2].status === 422 && response[2].responseText,
        container     = $('#js-commentable-form').parentNode,
        previousError = $('.js-model-errors', container);

  previousError && previousError.remove();

  errorHtml && container.insertAdjacentHTML('afterbegin', errorHtml);
}
