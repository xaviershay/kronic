require 'date'

# Main class for library, provides date parsing and formatting methods.
class Kronic
  # Public: Converts a human readable day (today, yesterday) to a Date.
  # If Time.zone is available and set (added by active_support and rails),
  # Time.zone.today will be used as a reference point, otherwise Date.today
  # will be used.
  #
  # string - The String to convert to a Date. #to_s is called on the parameter.
  #          Supported formats are: Today, yesterday, tomorrow, last thursday,
  #          this thursday, 14 Sep, Sep 14, 14 June 2010. Parsing is
  #          case-insensitive.
  #
  # Returns the Date, or nil if the input could not be parsed.
  def self.parse(string)
    string = string.to_s.downcase.strip
    now = today

    parse_nearby_days(string, now) ||
      parse_last_or_this_day(string, now) ||
      parse_exact_date(string, now) ||
      parse_iso_8601_date(string)
  end

  # Public: Converts a date to a human readable string. If Time.zone is
  # available and set (it is added by active_support and rails by default),
  # Time.zone.today will be used as a reference point, otherwise Date.today
  # will be used.
  #
  # date - The Date to be converted
  # opts - The Hash options used to customize formatting
  #        :today - The reference point for calculations (default: Date.today)
  #
  # Returns a relative string ("Today", "This Monday") if available, otherwise
  # the full representation of the date ("19 September 2010").
  def self.format(date, opts = {})
    case (to_date(date) - to_date(opts[:today] || today)).to_i
      when (2..7)   then "This " + date.strftime("%A")
      when 1        then "Tomorrow"
      when 0        then "Today"
      when -1       then "Yesterday"
      when (-7..-2) then "Last " + date.strftime("%A")
      else               date.strftime("%e %B %Y").strip
    end
  end

  class << self
    private

    DELIMITER           = /[,\s]+/
    NUMBER              = /^[0-9]+$/
    NUMBER_WITH_ORDINAL = /^([0-9]+)(st|nd|rd|th)?$/
    ISO_8601_DATE       =
      /^([0-9]{4})-?(1[0-2]|0?[1-9])-?(3[0-1]|[1-2][0-9]|0?[1-9])$/

    MONTH_NAMES =
      Date::MONTHNAMES.zip(Date::ABBR_MONTHNAMES).flatten.compact.map {|x|
        x.downcase
      }

    # Ruby 1.8 does not provide a to_date method on Time. This methods works
    # on all rubies.
    def to_date(time)
      Date.new(time.year, time.month, time.day)
    end

    def today
      if Time.respond_to?(:zone) && Time.zone
        to_date(Time.zone.now)
      else
        Date.today
      end
    end

    # Examples
    #
    #   month_from_name("january") # => 1
    #   month_from_name("jan")     # => 1
    def month_from_name(month)
      month = MONTH_NAMES.index(month)
      month ? month / 2 + 1 : nil
    end

    # Parse "Today", "Tomorrow" and "Yesterday"
    def parse_nearby_days(string, today)
      return today     if string == 'today'
      return today - 1 if string == 'yesterday'
      return today + 1 if string == 'tomorrow'
    end

    # Parse "Last Monday", "This Monday"
    def parse_last_or_this_day(string, today)
      tokens = string.split(DELIMITER)

      if %w(last this).include?(tokens[0])
        days = (1..7).map {|x|
          today + (tokens[0] == 'last' ? -x : x)
        }.inject({}) {|a, x|
          a.update(x.strftime("%A").downcase => x)
        }

        days[tokens[1]]
      end
    end

    # Parse "14 Sep", "14 September", "14 September 2010", "Sept 14 2010"
    def parse_exact_date(string, today)
      tokens = string.split(DELIMITER)

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

      begin
        result = Date.new(year, month, day)
        result = result << 12 if result > today && !raw_year
        result
      rescue ArgumentError
        nil
      end
    end

    # Parses "2010-09-04", "2010-9-4"
    #
    # NOTE: this is not strictly the ISO 8601 date format as it allows months
    # and days without the zero prefix. e.g. 2010-9-4
    def parse_iso_8601_date(string)
      if string =~ ISO_8601_DATE
        Date.parse(string) rescue nil
      end
    end
  end
end
