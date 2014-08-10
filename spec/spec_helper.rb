require 'xspec'
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
  warn "Not running JS specs."
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
      freeze_time do
        assert_equal date, Kronic.parse(string)
      end
    end

    if js_supported?
      it "should parse '#{string}' (JS)" do
        x = js.eval("Kronic").parse(string)

        if x.is_a?(Time)
          x = x.to_date
          assert_equal date, Date.new(x.year, x.month, x.day)
        else
          assert_equal date, x
        end
      end
    end
  end

  def it_should_format(string, date)
    it "should format '#{string}'" do
      freeze_time do
        assert_equal string, Kronic.format(date)
      end
    end

    if js_supported?
      it "should format '#{string}' (JS)" do
        assert_equal string, js.eval("Kronic").format(date.to_time)
      end
    end
  end
end

def js_supported?
  $js_loaded
end
