import { $, $$, on, removeChildren } from './utils/dom';
import { afterLast, escapeHtml } from './utils/text';

let typingTimeout;

export default function() {
  $$('.js-autocomplete-target').forEach(setup);
}

function setup(field) {
  const container = $('.js-autocomplete', field.parentNode);

  on('click', '.js-autocomplete__line', (e, line) =>
    insertSuggestion(field, line.textContent), container);

  field.addEventListener('input', () => {
    clearTimeout(typingTimeout);
    typingTimeout = setTimeout(() => loadSuggestions(field), 200);
  });
}

function loadSuggestions(field) {
  fetch(`//client.lvh.me/autocomplete?q=${typedTag(field.value)}`)
    .then((response) => response.json())
    .then((tags) => displaySuggestions(field, tags));
}

function displaySuggestions(field, tags) {
  const container = $('.js-autocomplete', field.parentNode),
        typed = typedTag(field.value);

  removeChildren(container);

  tags.forEach(([tag, score]) => {
    const line = document.createElement('div');

    line.className = 'js-autocomplete__line';
    line.innerHTML = highlightTyped(tag, typed);

    container.appendChild(line);
  });
}

function insertSuggestion(field, tag) {
  const insertAfter = field.value.lastIndexOf(typedTag(field.value));

  field.value = field.value.substring(0, insertAfter) + tag + ', ';
  field.focus();
}

function typedTag(text) {
  return (afterLast(text, ",") || text).trim();
}

function highlightTyped(tag, typed) {
  const typedPrefixes = typed.split(" "),
        tagTerms = tag.split(" ");

  return tagTerms.map((term) => {
    const highlight = typedPrefixes.find((prefix) => term.startsWith(prefix)),
          rest = highlight && term.slice(highlight.length);

    if (highlight) {
      return `<strong>${escapeHtml(highlight)}</strong>` + escapeHtml(rest);
    }
    else {
      return escapeHtml(term);
    }
  }).join(' ');
}
