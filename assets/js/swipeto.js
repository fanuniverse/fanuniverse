import { $ } from './utils/dom';

/* Based on http://stackoverflow.com/a/23230280/1726690
 * and https://lehollandaisvolant.net/tout/examples/swipe/ */

export default function() {
  $('[data-swipe-to]') && setupSwipeEvent();
}

function swipe(direction) {
  const data = $('[data-swipe-to]').getAttribute('data-swipe-to'),
        urls = JSON.parse(data);

  window.location.href = urls[direction];
}

function setupSwipeEvent() {
  document.addEventListener('touchstart', touchStart);
  document.addEventListener('touchmove', touchMove);
}

const minSwipeDelta = 9;

let startX,
    startY;

function touchStart(e) {
  const movement = e.touches[0];

  startX = movement.clientX;
  startY = movement.clientY;
}

function touchMove(e) {
  if (!startX || !startY) return;

  const movement = e.touches[0];

  if (!hasSwipeActions(movement)) return;

  const endX   = movement.clientX,
        endY   = movement.clientY,
        deltaX = startX - endX,
        deltaY = startY - endY;

  /* Is it a horizontal swipe? If no, return. */
  if (Math.abs(deltaX) < Math.abs(deltaY)) return;

  if (deltaX > minSwipeDelta) swipe('left');
  if (deltaX < -minSwipeDelta) swipe('right');

  startX = startY = null;
}

function hasSwipeActions(movement) {
  return !!movement.target.closest('[data-swipe-to]');
}
