import { $ } from './utils/dom';

export default function() {
  const form = $('.js-upload'),
        fancy = form && form.classList.contains('js-upload--image');

  if (form && fancy) restoreForm() || setupForm(true);
  else if (form) setupForm(false);
}

function restoreForm() {
  const previousSubmission = $('.js-model-errors');

  return previousSubmission && proceedToNextStep();
}

function setupForm(fancy) {
  const reader = new FileReader();

  $('.file-upload__input').addEventListener('change', (e) =>
    e.target.files[0] && reader.readAsDataURL(e.target.files[0]));

  reader.addEventListener('load', (e) => {
    showImage(e.target.result);
    fancy && proceedToNextStep();
  });

  if (fancy) $('.js-upload__fetch').addEventListener('click', scrapeUrl);
}

function showImage(src) {
  const image = $('.js-upload__preview');
  image.classList.remove('hidden');
  image.src = src;

  return true;
}

function scrapeUrl(e) {
  const url = $('.js-upload__url').value;

  if (url) {
    toggleFetchButton();

    fetch(`//client.lvh.me/scrape?url=${url}`)
        .then((response) => response.json())
        .then((data) => insertScraped(data) && proceedToNextStep())
        .catch(() => {
          toggleFetchButton();
          $('.js-upload__fetch-error').classList.remove('hidden');
        });
  }
  else e.stopPropagation();
}

function toggleFetchButton() {
  const button = $('.js-upload__fetch'),
        oldState = button.textContent;
  button.textContent = button.getAttribute('data-toggle-text');
  button.setAttribute('data-toggle-text', oldState);
}

function insertScraped(data) {
  data.imageUrl && ($('#image_remote_image').value = data.imageUrl);

  data.pageUrl && ($('#image_source').value = data.pageUrl);

  data.artist && ($('#image_tags').value = `artist: ${data.artist.toLowerCase()}, `);

  data.thumbnailUrl && showImage(data.thumbnailUrl);

  return true;
}

function proceedToNextStep() {
  $('.js-upload__file').classList.add('hidden');
  $('.js-upload__meta').classList.remove('hidden');
  $('#image_tags').focus();

  return true;
}
