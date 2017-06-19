/* The $ and $$ shorthands idea is taken from https://github.com/DoublePipe. */

export function $(selector, container = document) {
  return container.querySelector(selector);
}

export function $$(selector, container = document) {
  return [].slice.call(container.querySelectorAll(selector));
}
