import { $, on } from '../utils/dom';

export default function() {
  Object.keys(actions).forEach((action) => {
    on('click', `[ujs-click-${action}]`, (e, target) => {
      const data = target.getAttribute(`ujs-click-${action}`);

      /* preventDefault unless the action returns true */
      (actions[action](target, data) || e.preventDefault())
    });
  });
}

const actions = {
  toggle(element, data) {
    const set = data.startsWith('{') && JSON.parse(data);

    if (set) {
      Object.entries(set).forEach(([selector, cls]) => {
        $(selector).classList.toggle(cls);
      });
    }
    else {
      $(data).classList.toggle('hidden');
    }
  },

  show(element, data) {
    $(data).classList.remove('hidden');
  },

  hide(element, data) {
    $(data).classList.add('hidden');
  },

  focus(element, data) {
    $(data).focus();
  },
};
