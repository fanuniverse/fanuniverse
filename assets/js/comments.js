import { $, on } from './utils/dom';
import { timeago } from './timeago';
import { loadStarrable } from './stars';

export default function() {
  const commentable = $('[data-commentable-url]');

  commentable && setupComments(commentable,
    commentable.dataset.commentableUrl);
}

export function setupComments(container, endpoint) {
  fetchListing(container, endpoint);
  paginate(container);
  setupForm(container);
}

function fetchListing(container, endpoint) {
  fetch(endpoint, { credentials: 'same-origin' })
    .then((response) => response.text())
    .then((comments) => displayListing(container, comments));
}

function displayListing(container, listing) {
  container.innerHTML = listing;
  timeago(container);
  loadStarrable(container);
}

function paginate(container) {
  on('click', '.page', (e, page) => {
    e.preventDefault();
    fetchListing(container, page.href);
  }, container);
}

function setupForm(container) {
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
    .then((listing) => {
      const editArea = $('#js-comment-form textarea'),
        previousError = $('.js-model-errors');

      editArea.value = '';
      previousError && previousError.remove();

      displayListing(container, listing);
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
