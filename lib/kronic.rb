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

    return Date.today     if string == 'today'
    return Date.yesterday if string == 'yesterday'
    return Date.tomorrow  if string == 'tomorrow'

    tokens = string.split(/\s+/)

    # Last|This X
    if %w(last this).include?(tokens[0])
      days = (1..7).map {|x| 
        Date.today + (tokens[0] == 'last' ? -x.days : x.days)
      }.inject({}) {|a, x| 
        a.update(x.strftime("%A").downcase => x) 
      }
      return days[tokens[1]]
    end

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
      result -= 1.year if result > Date.today
      return result
    end

    nil
  end

  # Converts a date to a human readable string.
  def self.format(date, opts = {})
    case ((opts[:today] || Date.today).to_date - date.to_date).to_i
      when 0      then "Today"
      when 1      then "Yesterday"
      when (2..7) then "Last " + date.strftime("%A")
      else              date.strftime("%e %B %Y").strip
    end
  end

  def self.month_from_name(month)
    return nil unless month

    human_month = month.downcase.humanize
    Date::MONTHNAMES.index(human_month) || Date::ABBR_MONTHNAMES.index(human_month)
  end
  private_class_method :month_from_name
end
