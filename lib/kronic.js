var Kronic = (function() { 
  function trim(string) {
    return string.replace(/^\s+|\s+$/g, '')
  }

  function map(array, func) {
    var result = [];
    for (x in array) {
      result.push(func(array[x]));
    }
    return result;
  }
  
  function inject(array, initialValue, func) {
    var accumulator = initialValue;
    for (x in array) {
      accumulator = func(accumulator, array[x]);
    }
    return accumulator;
  }

  function addDays(date, numberOfDays) {
    return new Date(date * 1 + numberOfDays * 60 * 60 * 24 * 1000);
  }

  function parseNearbyDays(string, today) {
    if (string == 'today')     return today;
    if (string == 'yesterday') return addDays(today, -1);
    if (string == 'tomorrow')  return addDays(today, +1);
  }

  function parseLastOrThisDay(string, today) {
    var tokens = string.split(/\s+/);

    if (['last', 'this'].indexOf(tokens[0]) >= 0) {
      var days = map([1,2,3,4,5,6,7], function(x) {
        return addDays(today, tokens[0] == 'last' ? -x : x);
      });

      days = inject(days, {}, function(a, x) {
        a[x.strftime("%A").toLowerCase()] = x;
        return a;
      });

      return days[tokens[1]];
    }
  }

  function parseExactDay(string, today) {
    var tokens = string.split(/\s+/);

    if (tokens.length >= 2) {
      var matches = tokens[0].match(/^([0-9]+)(st|nd|rd|th)?$/);
      if (matches) {
        return parseExactDateParts(matches[1], tokens[1], tokens[2], today);
      } else {
        matches = tokens[1].match(/^([0-9]+)(st|nd|rd|th)?$/);
        return parseExactDateParts(matches[1], tokens[0], tokens[2], today);
      }
    }
  }

  function parseExactDateParts(rawDay, rawMonth, rawYear, today) {
    var day = rawDay * 1;
    var month = monthFromName(rawMonth);
    var year;

    if (rawYear)
      year = rawYear.match(/^[0-9]+$/) ? rawYear * 1 : null;
    else
      year = today.getYear() + 1900;

    if (!(day && month && year))
      return null;

    var result = new Date(year, month, day);
    if (result > today && !rawYear)
      result = new Date(year - 1, month, day);
    return result;
  }

  function parseIso8601Date(string) {
    if (string.match(/^([0-9]{4})-?(1[0-2]|0?[1-9])-?(3[0-1]|[1-2][0-9]|0?[1-9])$/)) {
      var tokens = map(string.split('-'), function(x) { return x * 1});
      return (new Date(tokens[0], tokens[1] - 1, tokens[2]));
    }
  }

  function monthFromName(month) {
    var monthNames = [];
    for (var i = 0; i < 12; i++) {
      monthNames.push((new Date(2010, i, 1)).strftime("%b").toLowerCase());
      monthNames.push((new Date(2010, i, 1)).strftime("%B").toLowerCase());
    }
    monthIndex = monthNames.indexOf(month);
    return monthIndex >= 0 ? Math.floor(monthIndex / 2) : null;
  }

  return {
    parse: function(string) {
      string = trim(string + '').toLowerCase();
      return parseNearbyDays(string, Kronic.today()) ||
             parseLastOrThisDay(string, Kronic.today()) ||
             parseExactDay(string, Kronic.today()) ||
             parseIso8601Date(string);
    },
    format: function(date, opts) {
      if (!opts)
        opts = {today: Kronic.today()};

      var diff = Math.floor((date * 1 - opts.today * 1) / 60 / 60 / 24 / 1000);
      switch (diff) {
        case -7:
        case -6:
        case -5:
        case -4:
        case -3:
        case -2: return "Last " + date.strftime("%A");
        case -1: return "Yesterday";
        case 0:  return "Today";
        case 1: return "Tomorrow";
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7: return "This " + date.strftime("%A");
        default: return date.strftime("%e %B %Y");
      }
    },
    today: function() {
      return new Date();
    }
  };
})();
