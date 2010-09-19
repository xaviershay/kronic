require 'spec_helper'

describe Kronic do
  def self.should_parse(string, date)
    it "should parse '#{string}'" do
      Kronic.parse(string).should == date
    end
  end

  def self.should_format(string, date)
    it "should format '#{string}'" do
      Kronic.format(date).should == string
    end
  end

  def self.date(key)
    {
      :today  => Date.new(2010, 9, 19),
      :monday => Date.new(2010, 9, 13),
      :sep_4  => Date.new(2010, 9, 4)
    }.fetch(key)
  end

  before :all do
    Timecop.freeze(Date.new(2010, 9, 19))
  end

  should_parse('Today',       date(:today))
  should_parse(:today,        date(:today))
  should_parse('today',       date(:today))
  should_parse('Yesterday',   date(:today) - 1.day)
  should_parse('Last Monday', date(:monday))
  should_parse('4 Sep',       date(:sep_4))
  should_parse('4 September', date(:sep_4))
  should_parse('14 Sep 2008', Date.new(2008, 9, 14))
  should_parse('bogus',       nil)
  should_parse('14',          nil)
  should_parse('14 bogus in', nil)

  should_format('Today',       date(:today))
  should_format('Yesterday',   date(:today) - 1.day)
  should_format('Last Monday', date(:monday))
  should_format('14 September 2008', Date.new(2008, 9, 14))
end
