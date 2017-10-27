import { on } from '../utils/dom';
import { csrfToken } from '../utils/csrf';

/* Handle non-GET links (`ujs-method`). This script is based
 * on https://github.com/jalkoby/phoenix_ujs/blob/master/src/ujs/link.js.
 * phoenix_ujs is released under the MIT license,
 * https://github.com/jalkoby/phoenix_ujs/blob/master/LICENSE.txt. */

export default function() {
  on('click', '[ujs-method]', (e, link) => {
    e.preventDefault();
    submit(link);
  });
}

function submit(link) {
  const url = link.href,
    method = link.getAttribute('ujs-method'),
    params = link.getAttribute('ujs-method-params'),
    form = document.createElement('form');

  form.method = 'post';
  form.action = url;

  addParam(form, '_csrf_token', csrfToken);
  addParam(form, '_method', method);

  if (params) {
    const paramPairs = Object.entries(JSON.parse(params));

    paramPairs.forEach(([key, value]) =>
      addParam(form, key, value));
  }

  document.body.appendChild(form);
  form.submit();
}

function addParam(form, name, value) {
  const input = document.createElement('input');

  input.type = 'hidden';
  input.name = name;
  input.value = value;

  form.appendChild(input);
}
