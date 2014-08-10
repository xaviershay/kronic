require 'spec_helper'

extend XSpec.dsl

Time.extend(MethodVisibility)

describe Kronic do
  extend KronicMatchers

  # A constant set of dates are used for testing, the current system time is
  # frozen to date(:today) for the duration of each test.
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

  # it_should_parse and it_should_format macros are defined in
  # spec/spec_helper.rb
  it_should_parse('Today',              date(:today))
  it_should_parse(:today,               date(:today))
  it_should_parse('today',              date(:today))
  it_should_parse('  Today',            date(:today))
  it_should_parse('Yesterday',          date(:today) - 1)
  it_should_parse('Tomorrow',           date(:today) + 1)
  it_should_parse('Last Monday',        date(:last_monday))
  it_should_parse('This Monday',        date(:next_monday))
  it_should_parse('4 Sep',              date(:sep_4))
  it_should_parse('4  Sep',             date(:sep_4))
  it_should_parse('4 September',        date(:sep_4))
  it_should_parse('20 Sep',             date(:sep_20))
  it_should_parse('28 Sep 2010',        date(:sep_28))
  it_should_parse('14 Sep 2008',        Date.new(2008, 9, 14))
  it_should_parse('14th Sep 2008',      Date.new(2008, 9, 14))
  it_should_parse('23rd Sep 2008',      Date.new(2008, 9, 23))
  it_should_parse('September 14 2008',  Date.new(2008, 9, 14))
  it_should_parse('Sep 14, 2008',       Date.new(2008, 9, 14))
  it_should_parse('14 Sep, 2008',       Date.new(2008, 9, 14))
  it_should_parse('Sep 4th',            date(:sep_4))
  it_should_parse('September 4',        date(:sep_4))
  it_should_parse('2008-09-04',         Date.new(2008, 9, 4))
  it_should_parse('2008-9-4',           Date.new(2008, 9, 4))
  it_should_parse('1 Jan 2010',         Date.new(2010, 1, 1))
  it_should_parse('31 Dec 2010',        Date.new(2010, 12, 31))

  it_should_parse('0 Jan 2010',         nil)
  it_should_parse('32 Dec 2010',        nil)
  it_should_parse('366 Jan 2010',       nil)
  it_should_parse('bogus',              nil)
  it_should_parse('14',                 nil)
  it_should_parse('14 bogus in',        nil)
  it_should_parse('14 June oen',        nil)
  it_should_parse('January 1999',       nil)
  it_should_parse('Last M',             nil)

  it_should_format('Today',             date(:today))
  it_should_format('Yesterday',         date(:today) - 1)
  it_should_format('Tomorrow',          date(:today) + 1)
  it_should_format('Last Monday',       date(:last_monday))
  it_should_format('This Monday',       date(:next_monday))
  it_should_format('14 September 2008', Date.new(2008, 9, 14))
  it_should_format('14 September 2008', Time.utc(2008, 9, 14))

  describe 'timezone support' do
    it 'should be timezone aware if activesupport Time.zone is set' do
      freeze_time do
        Time.zone = "US/Eastern"
        assert_equal date(:today) - 1, Kronic.parse("today")
        assert_equal "Today", Kronic.format(date(:today) - 1)
      end
    end

    it 'should fallback to Date.today if Time.zone is not available' do
      freeze_time do
        Time.hide_class_method(:zone) do
          assert_equal date(:today), Kronic.parse("today")
          assert_equal "Today", Kronic.format(date(:today))
        end
      end
    end

    it 'should fallback to Date.today if Time.zone is not set' do
      freeze_time do
        Time.zone = nil
        assert_equal date(:today), Kronic.parse("today")
        assert_equal "Today", Kronic.format(date(:today))
      end
    end
  end

  def freeze_time(&block)
    begin
      Time.zone = nil
      ENV['TZ'] = "Australia/Melbourne"
      Timecop.freeze(Time.utc(
        date(:today).year,
        date(:today).month,
        date(:today).day
      ))
      block.call
    ensure
      Timecop.return
      Time.zone = nil
    end
  end

  def js
    @js ||= begin
      js = V8::Context.new
      js['alert'] = proc {|s| puts s.inspect } # For debugging
      js.eval(File.open(File.dirname(__FILE__) + "/../lib/js/kronic.js").read)
      js.eval("Kronic")['today'] = proc { date(:today).to_time }
      js
    end
  end
end
