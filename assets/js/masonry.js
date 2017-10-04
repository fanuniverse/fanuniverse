import { $, $$ } from './utils/dom';

/* NOTE: We assume that all items have fixed width. */

export default function() {
  const gridExists = $('.js-grid');

  if (gridExists) {
    setupLayout();
    window.addEventListener('resize', setupLayout);
  }
}

function setupLayout() {
  const grid = $('.js-grid');

  const imagesResized = resizeImages(grid),
        layout = calculateLayout(grid);

  (imagesResized
    || grid.clientWidth != layout.gridWidth) && applyLayout(grid, layout);
}

function calculateLayout(grid) {
  const itemMargin = 10; /* TODO: move to CSS */

  const itemWidth = $('.js-grid__item', grid).clientWidth,
        spaceFree = grid.closest('.js-grid-container').clientWidth;

  const itemSpace = itemMargin + itemWidth,
        columnCount = Math.max(1, Math.floor(spaceFree / itemSpace)),
        gridWidth = columnCount * itemSpace - itemMargin;

  return { itemMargin, itemSpace, columnCount, gridWidth };
}

function resizeImages(grid) {
  const sampleImage = $('.js-grid__media', grid),
        currentWidth = sampleImage.dataset.measuredAt;

  const container = sampleImage.closest('.js-grid__item');
  const availableWidth =
    window.getComputedStyle(container).getPropertyValue("width");

  if (currentWidth != availableWidth) {
    sampleImage.dataset.measuredAt = availableWidth;

    $$('.js-grid__media', grid).forEach((image) => {
      const ratio = parseFloat(image.dataset.ratio),
            width = parseInt(availableWidth, 10),
            height = Math.floor(width / ratio);

      image.style.height = `${height}px`;
    });

    return true;
  }
}

function applyLayout(grid, layout) {
  const items = $$('.js-grid__item', grid),
        { columnCount, gridWidth } = layout,
        { offsets, columnHeights } = calculateOffsets(items, layout),
        gridHeight = Math.max(...columnHeights);

  offsets.forEach(([top, left], index) => {
    items[index].style.position = 'absolute';
    items[index].style.top = `${top}px`;
    items[index].style.left = `${left}px`;

    items[index].classList.remove('media--unstyled');
  });

  grid.style.position = 'relative';
  grid.style.width = `${gridWidth}px`;
  grid.style.height = `${gridHeight}px`;
}

function calculateOffsets(gridItems, layout) {
  const { itemMargin, itemSpace, columnCount } = layout;

  const offsets = [],
        columnHeights = Array(columnCount).fill(0);

  gridItems.forEach((item, index) => {
    const column = index % columnCount,
          top = columnHeights[column],
          left = itemSpace * column,
          addedHeight = item.clientHeight + itemMargin;

    offsets.push([top, left]);
    columnHeights[column] += addedHeight;
  });

  return { offsets, columnHeights };
}
