import { $$ } from './utils/dom';

/* Based on jQuery.timeago, see http://timeago.yarp.com/ */

export default function refreshTimeago() {
  timeago(document);
  window.setTimeout(refreshTimeago, 60000);
}

export function timeago(target) {
  $$('time', target).forEach((time) => format(time));
}

const locale = {
  seconds: 'less than a minute',
  minute: 'about a minute',
  minutes: '%d minutes',
  hour: 'about an hour',
  hours: '%d hours',
  day: 'about a day',
  days: '%d days',
  week: 'about a week',
  weeks: '%d weeks',
  month: 'about a month',
  months: '%d months',
  year: 'about a year',
  years: '%d years',
};

function localize(string, num) {
  return `${string.replace('%d', Math.round(num))} ago`;
}

function format(element) {
  const distance = Math.abs(
    new Date() - new Date(element.getAttribute('datetime')));

  const seconds = distance / 1000,
    minutes = seconds / 60,
    days = minutes / 1440,
    years = days / 365;

  const timeago =
      seconds < 45 && localize(locale.seconds, seconds) ||
      seconds < 90 && localize(locale.minute, 1) ||
      minutes < 45 && localize(locale.minutes, minutes) ||
      minutes < 90 && localize(locale.hour, 1) ||
      minutes < 1440 && localize(locale.hours, (minutes / 60)) ||
      minutes < 2520 && localize(locale.day, 1) ||
      days < 6 && localize(locale.days, days) ||
      days < 12 && localize(locale.week, 1) ||
      days < 24 && localize(locale.weeks, (days / 7)) ||
      days < 45 && localize(locale.month, 1) ||
      days < 365 && localize(locale.months, (days / 30)) ||
      years < 1.5 && localize(locale.year, 1) ||
                        localize(locale.years, years);

  if (!element.getAttribute('title')) {
    element.setAttribute('title', element.textContent);
  }

  element.textContent = timeago;
}

