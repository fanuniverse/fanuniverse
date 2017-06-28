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
  /* Form submission is handled by UJS,
   * we just need to display the comments we get as a response. */
  document.addEventListener('ajax:success', (e) => {
    if (e.target.id === 'js-comment-form') showPosted(container, e.data);
  });
  document.addEventListener('ajax:error', (e) => {
    if (e.target.id === 'js-comment-form') showError(e.data);
  });
}

function showPosted(container, response) {
  response
    .text()
    .then((comments) => {
      const editArea      = $('#js-comment-form textarea'),
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
        const container     = $('#js-comment-form').parentNode,
              previousError = $('.js-model-errors', container);

        previousError && previousError.remove();

        container.insertAdjacentHTML('afterbegin', errors);
    });
}
