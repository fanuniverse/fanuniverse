import { $, on } from './utils/dom';
import { timeago } from './timeago';
import { loadStarrable } from './stars';

export default function() {
  const commentable = $('[data-commentable-url]');

  if (commentable) {
    load(commentable, commentable.getAttribute('data-commentable-url'));
    pagination(commentable);
    ajaxPosting(commentable);
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
  on('click', '.page', (e, page) => {
    e.preventDefault();
    load(container, page.href);
  }, container);
}

function ajaxPosting(container) {
  /* Form submission is handled by UJS,
   * we just need to display the comments we get as a response. */
  on('ajax:success', '#js-comment-form', (e) =>
    showPosted(container, e.data));

  on('ajax:error', '#js-comment-form', (e) =>
    showError(e.data));
}

function showPosted(container, response) {
  response
    .text()
    .then((comments) => {
      const editArea = $('#js-comment-form textarea'),
        previousError = $('.js-model-errors');

      editArea.value = '';
      previousError && previousError.remove();

      display(container, comments);
    });
}

function showError(response) {
  response
    .text()
    .then((errors) => {
      const container = $('#js-comment-form').parentNode,
        previousError = $('.js-model-errors', container);

      previousError && previousError.remove();

      container.insertAdjacentHTML('afterbegin', errors);
    });
}
