import { $ } from '../utils/dom';

export default function() {
  document.addEventListener('click', (e) =>
    e.target && e.target.hasAttribute('ujs-tab') && switchTab(e.target));
}

function switchTab(selectedLink) {
  const tabContainer = $(selectedLink.getAttribute('ujs-tabs-in')),
        linkContainer = $(selectedLink.getAttribute('ujs-links-in')),
        selectedTab = $(selectedLink.getAttribute('ujs-tab'), tabContainer);

  Array.from(tabContainer.children)
    .forEach((tab) => tab.classList.add('hidden'));

  Array.from(linkContainer.children)
    .forEach((link) => link.classList.remove('active'));

  selectedLink.classList.add('active');
  selectedTab.classList.remove('hidden');
}
