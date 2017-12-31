import { $ } from './utils/dom';
import { setupComments } from './comments';
import mediagrid from './mediagrid';

export default function() {
  const imageTabs    = $('.js-image-tabs'),
        commentsLink = imageTabs && $('[ujs-tab=".js-image-tabs__comments"]');

  if (imageTabs) {
    fetchMltTab();
    commentsLink.addEventListener('click', fetchComments);
  }
}

function fetchMltTab() {
  const container = $('.js-image-tabs__mlt');

  fetch(container.dataset.url)
    .then((response) => response.text())
    .then((mlt) => {
      container.innerHTML = mlt;
      mediagrid();
    });
}

function fetchComments(e) {
  const container = $('.js-image-comments');

  e.target.removeEventListener('click', fetchComments);

  setupComments(container, container.dataset.url);
}
