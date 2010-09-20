require 'active_support/core_ext'

class Kronic
  # Converts a human readable day (Today, yesterday) to a date in the past.
  # Supported inputs include Today, yesterday, last thursday, 14 Sep, 14
  # June 2010, all case-insensitive.
  #
  # Will call #to_s on the input, so can process Symbols or whatever other
  # object you wish to throw at it.
  def self.parse(string)
    string = string.to_s.downcase.strip
    today  = Date.today

    parse_nearby_days(string, today) ||
      parse_last_or_this_day(string, today) ||
      parse_exact_date(string, today)
  end

  # Converts a date to a human readable string.
  def self.format(date, opts = {})
    case (date.to_date - (opts[:today] || Date.today)).to_i
      when (2..7)   then "This " + date.strftime("%A")
      when 1        then "Tomorrow"
      when 0        then "Today"
      when -1       then "Yesterday"
      when (-7..-2) then "Last " + date.strftime("%A")
      else              date.strftime("%e %B %Y").strip
    end
  end

  class << self
    private

    def month_from_name(month)
      return nil unless month

      human_month = month.downcase.humanize
      Date::MONTHNAMES.index(human_month) || Date::ABBR_MONTHNAMES.index(human_month)
    end

    def parse_nearby_days(string, today)
      return today         if string == 'today'
      return today - 1.day if string == 'yesterday'
      return today + 1.day if string == 'tomorrow'
    end

    def parse_last_or_this_day(string, today)
      tokens = string.split(/\s+/)

      if %w(last this).include?(tokens[0])
        days = (1..7).map {|x| 
          today + (tokens[0] == 'last' ? -x.days : x.days)
        }.inject({}) {|a, x| 
          a.update(x.strftime("%A").downcase => x) 
        }

        days[tokens[1]]
      end
    end

    def parse_exact_date(string, today)
      tokens = string.split(/\s+/)

      # 14 Sep, 14 September, 14 September 2010
      if tokens[0] =~ /^[0-9]+$/ && tokens[1]
        day   = tokens[0].to_i
        month = month_from_name(tokens[1])
        year  = if tokens[2]
          tokens[2] =~ /^[0-9]+$/ ? tokens[2].to_i : nil
        else
          today.year
        end

        return nil unless day && month && year

        result = Date.new(year, month, day)
        result -= 1.year if result > today
        result
      end
    end
  end
end
