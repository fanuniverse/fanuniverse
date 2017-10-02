import { $ } from './utils/dom';
import { setupComments } from './comments';

export default function() {
  const imageTabs    = $('.js-image-tabs'),
        commentsLink = imageTabs && $('[ujs-tab=".js-image-tabs__comments"]');

  if (imageTabs) {
    fetchMoreTab();
    commentsLink.addEventListener('click', fetchComments);
  }
}

function fetchMoreTab() {
  const container = $('.js-image-tabs__more');

  fetch(container.dataset.url)
    .then((response) => response.text())
    .then((mlt) => container.innerHTML = mlt);
}

function fetchComments(e) {
  const container = $('.js-image-comments');

  e.target.removeEventListener('click', fetchComments);

  setupComments(container, container.dataset.url);
}
