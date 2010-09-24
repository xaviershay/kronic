require 'date'

class Kronic
  # Public: Converts a human readable day (Today, yesterday) to a Date.
  #
  # Will call #to_s on the input, so can process Symbols or whatever other
  # object you wish to throw at it.
  #
  # string - The String to convert to a Date. Supported formats are: Today,
  #          yesterday, tomorrow, last thursday, this thursday, 14 Sep,
  #          Sep 14, 14 June 2010. Parsing is case-insensitive.
  #
  # Returns the Date, or nil if the input could not be parsed.
  def self.parse(string)
    string = string.to_s.downcase.strip
    today  = Date.today

    parse_nearby_days(string, today) ||
      parse_last_or_this_day(string, today) ||
      parse_exact_date(string, today)
  end

  # Public: Converts a date to a human readable string.
  #
  # date - The Date to be converted
  # opts - The Hash options used to customize formatting
  #        :today - The reference point for calculations (default: Date.today)
  #
  # Returns a relative string ("Today", "This Monday") if available, otherwise
  # the full representation of the date ("19 September 2010").
  def self.format(date, opts = {})
    case (date - (opts[:today] || Date.today)).to_i
      when (2..7)   then t[:this] + " " + date.strftime("%A")
      when 1        then t[:tomorrow]
      when 0        then t[:today]
      when -1       then t[:yesterday]
      when (-7..-2) then t[:last] + " " + date.strftime("%A")
      else              date.strftime("%e %B %Y").strip
    end
  end

  # Public: The translations used for parsing and formatting. 
  #
  # Returns a hash containing key/value pairs. This hash is mutable, meaning
  # you should update it to change the translations.
  def self.translations
    @translations ||= {
      :this        => 'This',
      :tomorrow    => 'Tomorrow',
      :today       => 'Today',
      :yesterday   => 'Yesterday',
      :last        => 'Last',
      :months      => Date::MONTHNAMES,
      :months_abbr => Date::ABBR_MONTHNAMES
    }
  end

  class << self
    alias_method :t, :translations

    private

    NUMBER              = /^[0-9]+$/
    NUMBER_WITH_ORDINAL = /^[0-9]+(st|nd|rd|th)?$/

    # Examples
    #
    #   month_from_name("january") # => 1
    #   month_from_name("jan")     # => 1
    def month_from_name(month)
      f = lambda {|months| months.compact.map {|x| x.downcase }.index(month) }

      month = f[t[:months]] || f[t[:months_abbr]]
      month ? month + 1 : nil
    end

    # Parse "Today", "Tomorrow" and "Yesterday"
    def parse_nearby_days(string, today)
      return today     if string == t[:today    ].downcase
      return today - 1 if string == t[:yesterday].downcase
      return today + 1 if string == t[:tomorrow ].downcase
    end

    # Parse "Last Monday", "This Monday"
    def parse_last_or_this_day(string, today)
      tokens = string.split(/\s+/)

      if %w(last this).include?(tokens[0])
        days = (1..7).map {|x| 
          today + (tokens[0] == t[:last].downcase ? -x : x)
        }.inject({}) {|a, x| 
          a.update(x.strftime("%A").downcase => x) 
        }

        days[tokens[1]]
      end
    end

    # Parse "14 Sep", "14 September", "14 September 2010", "Sept 14 2010"
    def parse_exact_date(string, today)
      tokens = string.split(/\s+/)

      if tokens.length >= 2
        if    tokens[0] =~ NUMBER_WITH_ORDINAL
          parse_exact_date_parts(tokens[0], tokens[1], tokens[2], today)
        elsif tokens[1] =~ NUMBER_WITH_ORDINAL
          parse_exact_date_parts(tokens[1], tokens[0], tokens[2], today)
        end
      end
    end
    
    # Parses day, month and year parts
    def parse_exact_date_parts(raw_day, raw_month, raw_year, today)
      day   = raw_day.to_i
      month = month_from_name(raw_month)
      year = if raw_year
        raw_year =~ NUMBER ? raw_year.to_i : nil
      else
        today.year
      end

      return nil unless day && month && year

      result = Date.new(year, month, day)
      result = result << 12 if result > today && !raw_year
      result
    end
  end
end
