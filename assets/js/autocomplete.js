import { $, $$, removeChildren } from './utils/dom';
import { afterLast } from './utils/text';

let typingTimeout;

export default function() {
  $$('.js-autocomplete-target').forEach((field) =>
    field.addEventListener('input', () => {
      clearTimeout(typingTimeout);
      typingTimeout = setTimeout(() => loadSuggestions(field), 200);
    }));
}

function loadSuggestions(field) {
  const tag = (afterLast(field.value, ",") || field.value).trim();

  fetch(`//client.lvh.me/autocomplete?q=${tag}`)
    .then((response) => response.json())
    .then((tags) => displaySuggestions(field, tags));
}

function displaySuggestions(field, tags) {
  const container = $('.js-autocomplete', field.parentNode);

  removeChildren(container);

  tags.forEach(([name, score]) => {
    const line = document.createElement('div');

    line.className = 'js-autocomplete__line';
    line.textContent = name;

    container.appendChild(line);
  });
}
