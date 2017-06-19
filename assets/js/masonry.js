import { $ } from './utils/dom';

export default function() {
  const grid    = $('.js-grid'),
        masonry = grid && masonryjs(grid),
        imgload = grid && imagesLoaded(grid);

  /* "Unloaded images can throw off Masonry layouts
   *  and cause item elements to overlap",
   * see http://masonry.desandro.com/layout.html#imagesloaded. */

  imgload && imgload.on('progress', () => masonry.layout());
}

function masonryjs(grid) {
  const masonry = new Masonry(grid, {
    itemSelector: '.js-grid__item',
    transitionDuration: '0.2s',
    isFitWidth: true,
    initLayout: false, /* delay layout() to bind the layoutComplete listener */
  });

  const container = $('.js-grid-container'),
        header    = $('.js-grid-header');

  masonry.on('layoutComplete', () => {
    const gridWidth = (masonry.cols * masonry.columnWidth);
    header.style.width = `${gridWidth}px`;
  });

  masonry.layout();

  /* When the header width is updated, the page visibly "jumps" (margin: auto).
   * To hide this from user during the page load, .js-grid-container
   * is initially set to .invisible. */
  container.classList.remove('invisible');

  return masonry;
}
