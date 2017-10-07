import { $, on } from './utils/dom';

export default function() {
  on('click', '.js-dropdown__toggle', (e, toggle) => {
    e.preventDefault();
    e.stopPropagation();

    const container = toggle.parentNode,
      content = $('.js-dropdown__content', container);

    content.classList.toggle('hidden');
    toggle.classList.toggle('active');

    if (toggle.classList.contains('active')) {
      document.addEventListener('click', hideMenuOnClick);
    }
    else document.removeEventListener('click', hideMenuOnClick);
  });
}

function hideMenuOnClick(e) {
  if (!e.target.closest('.js-dropdown__content')) {
    document.removeEventListener('click', hideMenuOnClick);

    $('.js-dropdown__content:not(.hidden)').classList.add('hidden');
    $('.js-dropdown__toggle.active').classList.remove('active');
  }
}
