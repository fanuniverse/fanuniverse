import { $ } from './dom';

const redirectSignedOutTo = '/sign_up';

export function signedIn(e) {
  e && e.preventDefault();

  const signedIn = !!$('.js-signed-in');

  if (signedIn) return true;
  else window.location.href = redirectSignedOutTo;
}
