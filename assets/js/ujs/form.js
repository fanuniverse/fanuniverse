import { $, on, fireEvent } from '../utils/dom';

export default function() {
  on('submit', '[ujs-remote]', (e, form) => {
    e.preventDefault();
    submitRemoteForm(form);
  });
}

function submitRemoteForm(form) {
  fetch(form.action, {
    method: form.method,
    credentials: 'same-origin',
    body: new FormData(form),
  })
    .then((response) => {
      if (response.ok) fireEvent(form, 'ajax:success', response);
      else fireEvent(form, 'ajax:error', response);
    });
}
