import { $, $$ } from '../utils/dom';

export default function() {
  $$('[ujs-tab-links-for]').forEach((linkContainer) => {
    const tabContainer = $(linkContainer.getAttribute('ujs-tab-links-for'));

    linkContainer.addEventListener('click', (e) => {
      const tabQuery = e.target.getAttribute('ujs-tab');

      if (!tabQuery) return;

      const selectedLink = e.target,
        selectedTab = $(tabQuery, tabContainer);

      Array.from(linkContainer.children)
        .forEach((link) => link.classList.remove('active'));

      Array.from(tabContainer.children)
        .forEach((tab) => tab.classList.add('hidden'));

      selectedLink.classList.add('active');
      selectedTab.classList.remove('hidden');
    });
  });
}
