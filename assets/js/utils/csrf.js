export function csrfToken() {
  return document.head
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content');
}
