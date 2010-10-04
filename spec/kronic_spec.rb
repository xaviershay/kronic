require 'spec_helper'

describe Kronic do
  def self.should_parse(string, date)
    it "should parse '#{string}'" do
      Kronic.parse(string).should == date
    end

    if js_supported?
      # Johnson strips out the time zone data, we need to put it back in
      def utc_to_local(date_time)
        date_time.new_offset(Time.now.utc_offset / 60 / 60 / 24.0)
      end

      it "should parse '#{string}' (JS)" do
        x = @js.evaluate(%{Kronic.parse("#{string}")})

        if x.is_a?(DateTime)
          x = utc_to_local(x)
          Date.new(x.year, x.month, x.day).should == date
        else
          x.should == date
        end
      end
    end
  end

  def self.should_format(string, date)
    it "should format '#{string}'" do
      Kronic.format(date).should == string
    end
  end

  def self.date(key)
    {
      :today       => Date.new(2010, 9, 18),
      :last_monday => Date.new(2010, 9, 13),
      :next_monday => Date.new(2010, 9, 20),
      :sep_4       => Date.new(2010, 9, 4),
      :sep_20      => Date.new(2009, 9, 20),
      :sep_28      => Date.new(2010, 9, 28)
    }.fetch(key)
  end
  def date(key); self.class.date(key); end;

  if js_supported?
    before :all do
      x = date(:today)
      @js = Johnson::Runtime.new
      @js['alert'] = lambda {|x| puts x.inspect }
      @js.evaluate(File.open(File.dirname(__FILE__) + '/../lib/strftime.js').read)
      @js.evaluate(File.open(File.dirname(__FILE__) + '/../lib/kronic.js').read)
      @js.evaluate(%(Kronic.today = function() { return new Date(Date.UTC(#{x.year}, #{x.month - 1}, #{x.day}))}))
    end
  end

  before :each do
    Time.zone = nil
    ENV['TZ'] = "Australia/Melbourne"
    d = date(:today)
    Timecop.freeze(Time.utc(d.year, d.month, d.day))
  end

  after :each do
    Timecop.return
  end

  should_parse('Today',              date(:today))
  should_parse(:today,               date(:today))
  should_parse('today',              date(:today))
  should_parse('  Today',            date(:today))
  should_parse('Yesterday',          date(:today) - 1)
  should_parse('Tomorrow',           date(:today) + 1)
  should_parse('Last Monday',        date(:last_monday))
  should_parse('This Monday',        date(:next_monday))
  should_parse('4 Sep',              date(:sep_4))
  should_parse('4  Sep',             date(:sep_4))
  should_parse('4 September',        date(:sep_4))
  should_parse('20 Sep',             date(:sep_20))
  should_parse('28 Sep 2010',        date(:sep_28))
  should_parse('14 Sep 2008',        Date.new(2008, 9, 14))
  should_parse('14th Sep 2008',      Date.new(2008, 9, 14))
  should_parse('23rd Sep 2008',      Date.new(2008, 9, 23))
  should_parse('September 14 2008',  Date.new(2008, 9, 14))
  should_parse('Sep 4th',            date(:sep_4))
  should_parse('September 4',        date(:sep_4))
  should_parse('2008-09-04',         Date.new(2008, 9, 4))
  should_parse('2008-9-4',           Date.new(2008, 9, 4))
  should_parse('bogus',              nil)
  should_parse('14',                 nil)
  should_parse('14 bogus in',        nil)
  should_parse('14 June oen',        nil)

  should_format('Today',             date(:today))
  should_format('Yesterday',         date(:today) - 1)
  should_format('Tomorrow',          date(:today) + 1)
  should_format('Last Monday',       date(:last_monday))
  should_format('This Monday',       date(:next_monday))
  should_format('14 September 2008', Date.new(2008, 9, 14))
  should_format('14 September 2008', Time.utc(2008, 9, 14))

  describe 'timezone support' do
    before :all do
      Time.extend(MethodVisibility)
    end

    it 'should be timezone aware if activesupport Time.zone is set' do
      Time.zone = "US/Eastern"
      Kronic.parse("today").should == date(:today) - 1
      Kronic.format(date(:today) - 1).should == "Today"
    end

    it 'should fallback to Date.today if Time.zone is not available' do
      Time.hide_class_method(:zone) do
        Kronic.parse("today").should == date(:today)
        Kronic.format(date(:today)).should == "Today"
      end
    end

    it 'should fallback to Date.today if Time.zone is not set' do
      Time.zone = nil
      Kronic.parse("today").should == date(:today)
      Kronic.format(date(:today)).should == "Today"
    end
  end
end
