require 'rspec'
require 'timecop'
require 'active_support/core_ext'

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
