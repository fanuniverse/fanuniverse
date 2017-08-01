export function afterLast(text, separator) {
  const lastIndex = text.lastIndexOf(separator);

  if (lastIndex === -1) return "";
  else return text.substr(lastIndex + 1);
}
