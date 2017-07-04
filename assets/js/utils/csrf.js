import { $ } from './dom';

export let csrfToken;
export default function() {
  csrfToken = $('meta[name="csrf-token"]').content;
}
