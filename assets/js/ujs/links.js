import { csrfToken } from '../utils/csrf';

/* Handle non-GET links (`ujs-method`). This script is based
 * on https://github.com/jalkoby/phoenix_ujs/blob/master/src/ujs/link.js.
 * phoenix_ujs is released under the MIT license,
 * https://github.com/jalkoby/phoenix_ujs/blob/master/LICENSE.txt. */

export default function() {
  document.addEventListener('click', (e) => {
    if (e.target && e.target.hasAttribute('ujs-method')) {
      e.preventDefault();
      submit(e.target);
    }
  });
}

function submit(link) {
  const url = link.href,
        method = link.getAttribute('ujs-method'),
        form = document.createElement('form');

  form.method = 'post';
  form.action = url;

  addParam(form, '_csrf_token', csrfToken);
  addParam(form, '_method', method);

  document.body.appendChild(form);
  form.submit();
}

function addParam(form, name, value) {
  const input = document.createElement('input');

  input.setAttribute('type', 'hidden');
  input.setAttribute('name', name);
  input.setAttribute('value', value);

  form.appendChild(input);
}
