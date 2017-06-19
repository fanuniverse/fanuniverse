import { $ } from './utils/dom';

export default function() {
  if (localStorage['disable-ga'] !== 'true') run();
  setupPrivacyHelpers();
}

function run() {
  /* eslint-disable */
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');
  /* eslint-enable */

  ga('create', 'UA-93933418-1', 'www.fanuniverse.org');
  ga('set', 'anonymizeIp', true);
  ga('send', 'pageview');
}

function setupPrivacyHelpers() {
  const optOutLink = $('.js-ga-opt-out');

  if (!optOutLink) return;

  if (localStorage['disable-ga'] === 'true') togglePrivacyState();
  else {
    optOutLink.addEventListener('click', (e) => {
      e.preventDefault();

      togglePrivacyState();

      localStorage['disable-ga'] = true;
    });
  }
}

function togglePrivacyState() {
  $('.js-ga-opt-out-info').classList.toggle('hidden');
  $('.js-ga-opted-out-info').classList.toggle('hidden');
}
