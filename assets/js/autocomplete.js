import { $, $$, on, removeChildren } from './utils/dom';
import { afterLast, escapeHtml } from './utils/text';

let typingTimeout;

export default function() {
  $$('.js-autocomplete-target').forEach(setup);
}

function setup(field) {
  const container = $('.js-autocomplete', field.parentNode);

  on('click', '.js-autocomplete__line', (e, line) =>
    insertSuggestion(container, field, line.textContent), container);

  field.addEventListener('input', () => {
    clearTimeout(typingTimeout);
    typingTimeout = setTimeout(() => loadSuggestions(container, field), 200);
    repositionSuggestionBox(container, field);
  });

  document.addEventListener('click', (e) => {
    const outside = e.target
      && !e.target.closest('.js-autocomplete')
      && !e.target.closest('.js-autocomplete-target');

    if (outside) container.classList.add('invisible');
  });
}

function loadSuggestions(container, field) {
  const tag = typedTag(field.value);

  tag && fetch(`//client.lvh.me/autocomplete?q=${tag}`)
    .then((response) => response.json())
    .then((tags) => displaySuggestions(container, field, tags));
}

function displaySuggestions(container, field, tags) {
  removeChildren(container);

  const typed = typedTag(field.value);

  tags.forEach(([tag, score]) => {
    const line = document.createElement('div');

    line.className = 'js-autocomplete__line';
    line.innerHTML = highlightTyped(tag, typed);

    container.appendChild(line);
  });

  if (tags.length > 0) container.classList.remove('invisible');
  else container.classList.add('invisible');
}

function repositionSuggestionBox(container, field) {
  const { top: caretTop, left: caretLeft } =
    window.getCaretCoordinates(field, field.selectionEnd);

  const approxLineHeight = 30,
    leftShift = 30,
    /* Place suggestions under the caret on y-axis */
    top = field.offsetTop + caretTop + approxLineHeight,
    /* Place suggestions near the caret on x-axis */
    shiftedLeft = field.offsetLeft + caretLeft - leftShift,
    /* Don't place suggestions outside the input field _left_ bound */
    adjustedLeft = Math.max(shiftedLeft, field.offsetLeft),
    /* Don't place suggestions outside the input field _right_ bound */
    maxLeft = field.offsetLeft + field.offsetWidth - container.offsetWidth,
    left = Math.min(adjustedLeft, maxLeft);

  container.style.top = `${top}px`;
  container.style.left = `${left}px`;
}

function insertSuggestion(container, field, tag) {
  const insertAfter = field.value.lastIndexOf(typedTag(field.value));

  field.value = `${field.value.substring(0, insertAfter) + tag}, `;
  field.focus();

  container.classList.add('invisible');
}

function typedTag(text) {
  const separators = [',', 'AND', '|', 'OR'];

  const tag = separators
    .map((sep) => afterLast(text, sep))
    .concat([text]) /* in case there are no separators yet */
    .filter((tag) => tag.length >= 2)
    .sort((a, b) => a.length - b.length) /* shortest first */
    .shift();

  /* Remove prefix unary operators, parens, and whitespace */
  return tag && tag.replace(/^\s*(-|NOT|[(])/, '').trim();
}

function highlightTyped(tag, typed) {
  const typedPrefixes = typed.split(' '),
    tagTerms = tag.split(' ');

  return tagTerms.map((term) => {
    const highlight = typedPrefixes.find((prefix) => term.startsWith(prefix)),
      rest = highlight && term.slice(highlight.length);

    if (highlight) {
      return `<strong>${escapeHtml(highlight)}</strong>${escapeHtml(rest)}`;
    }
    else {
      return escapeHtml(term);
    }
  }).join(' ');
}
