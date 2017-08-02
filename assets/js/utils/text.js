export function afterLast(text, separator) {
  const lastIndex = text.lastIndexOf(separator);

  if (lastIndex === -1) return "";
  else return text.substr(lastIndex + separator.length);
}

/* Source: https://github.com/liamwhite/js-utils/blob/c578afeab2d867a3a3cd7b272a03a3d1b82370bc/dom.js#L64 */
export function escapeHtml(text) {
  return text.replace(/&/g, '&amp;')
             .replace(/>/g, '&gt;')
             .replace(/</g, '&lt;')
             .replace(/"/g, '&quot;');
}
