import { $, $$ } from './utils/dom';

export default function() {
  $$('.js-video').forEach((container) =>
      container.addEventListener('click', playVideo));

  $$('.js-video video').forEach((video) =>
      video.addEventListener('play', hideControls));
}

function playVideo(e) {
  e.preventDefault();

  const container = e.target.closest('.js-video'),
        state     = $('.js-video__state', container),
        video     = $('video', container);

  container.classList.remove('interactable');

  container.removeEventListener('click', playVideo);

  state.textContent = 'loading';

  video.play();
}

function hideControls(e) {
  const container = e.target.closest('.js-video'),
        controls  = $('.js-video__controls', container);

  controls.classList.add('fade-out');
}
