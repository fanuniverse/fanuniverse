import { $, fireEvent } from '../utils/dom';

export default function() {
  document.addEventListener('submit', (e) => {
    const form = e.target;

    if (form.hasAttribute('ujs-remote')) {
      e.preventDefault();
      submitRemoteForm(form);
    }
  });
}

function submitRemoteForm(form) {
  fetch(form.action, {
    method: form.method,
    credentials: 'same-origin',
    body: new FormData(form)
  })
  .then((response) => {
    if (response.ok) fireEvent(form, 'ajax:success', response);
    else fireEvent(form, 'ajax:error', response);
  });
}
