import { $, $$, on } from './utils/dom';
import { post } from './utils/requests';
import { signedIn } from './utils/users';

export default function() {
  loadStarrable(document);

  on('click', '[data-starrable-id]', (e, star) =>
    signedIn(e) && toggleStar(star));
}

export function loadStarrable(container) {
  const datasets = $$('[data-starrable-ids]', container);

  datasets.forEach((dataset) => {
    const starrableKey = dataset.getAttribute('data-starrable-key'),
      ids = JSON.parse(dataset.getAttribute('data-starrable-ids'));

    ids.forEach((starrableId) => show(starElement(starrableKey, starrableId)));
  });
}

function toggleStar(star) {
  const { starrableKey, starrableId } = star.dataset;

  post('/stars/toggle', { [starrableKey]: starrableId })
    .then((data) => {
      const star = starElement(starrableKey, starrableId);

      if (data.status === 'added') show(star);
      else remove(star);

      setStarCount(star, data.stars);
    });
}

function starElement(key, id) {
  return $(`[data-starrable-key="${key}"][data-starrable-id="${id}"]`);
}

function show(star) {
  star.classList.add('active');
}

function remove(star) {
  star.classList.remove('active');
}

function setStarCount(star, count) {
  $('.meta__count', star).textContent = count;
}
