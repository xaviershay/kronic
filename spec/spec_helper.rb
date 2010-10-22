require 'rspec'
require 'timecop'
require 'active_support/core_ext/integer/time'
require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/date/conversions' # For nicer spec fail output

$js_loaded = begin
  require 'v8'
  true
rescue LoadError => e
  # Can't run JS specs
  false
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'kronic'

module MethodVisibility
  # Used to toggle whether Time.zone is available, for testing with and
  # without activesupport.
  def hide_class_method(method)
    metaclass = (class << self; self; end)
    metaclass.send :alias_method, :old_method, method
    metaclass.send :remove_method, method
    begin
      yield
    ensure
      metaclass.send :alias_method, method, :old_method
      metaclass.send :remove_method, :old_method
    end
  end
end

module KronicMatchers
  def it_should_parse(string, date)
    it "should parse '#{string}'" do
      Kronic.parse(string).should == date
    end

    if js_supported?
      it "should parse '#{string}' (JS)" do
        x = @js.evaluate("Kronic").parse(string)

        if x.is_a?(Time)
          x = x.to_date
          Date.new(x.year, x.month, x.day).should == date
        else
          x.should == date
        end
      end
    end
  end

  def it_should_format(string, date)
    it "should format '#{string}'" do
      Kronic.format(date).should == string
    end

    if js_supported?
      it "should format '#{string}' (JS)" do
        @js.evaluate("Kronic").format(date.to_time).should == string
      end
    end
  end
end

def js_supported?
  $js_loaded
end
