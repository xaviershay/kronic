require 'active_support/core_ext'
require 'active_support/duration'
require 'active_support/time_with_zone'

class Kronic
  def self.parse(string)
    string = string.downcase
    today  = Date.today

    return Date.today     if string == 'today'
    return Date.yesterday if string == 'yesterday'

    tokens = string.split(/\s+/)

    if tokens[0] == 'last'
      days = (1..7).map {|x| 
        (Date.today - x.days) 
      }.inject({}) {|a, x| 
        a.update(x.strftime("%A").downcase => x) 
      }
      return days[tokens[1]]
    end

    if tokens[0] =~ /^[0-9]+$/

      day   = tokens[0].to_i
      month = month_from_name(tokens[1])
      year  = tokens[2] ? tokens[2].to_i : today.year

      return nil unless month

      result = Date.new(year, month, day)
      result -= 1.year if result > Date.today
      return result
    end

    nil
  end

  def self.month_from_name(month)
    months = (1..12).map {|x|
      Date.new(2010, x, 1)
    }.inject({}) {|a, x|
      a.update(x.strftime("%B").downcase => x.month)
    }
    
    months[month] || months.detect {|name, number| name.starts_with?(month) }.last
  end

  def self.format(date, opts = {})
    case ((opts[:today] || Date.today).to_date - date.to_date).to_i
      when 0      then "Today"
      when 1      then "Yesterday"
      when (2..7) then "Last " + date.strftime("%A")
      else              date.strftime("%e %B %Y").strip
    end
  end
end
