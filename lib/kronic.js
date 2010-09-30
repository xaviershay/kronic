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

  return {
    parse: function(string) {
      string = trim(string).toLowerCase();
      return parseNearbyDays(string, Kronic.today()) ||
             parseLastOrThisDay(string, Kronic.today());
    },
    today: function() {
      return new Date();
    }
  };
})();
